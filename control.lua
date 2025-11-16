local main_name = "lo-recipe-combinator"
local packed_name = "lo-recipe-combinator-packed"

local function ccs_get_info(entity)
	return {}
end

local function dbgPrint(s)
	return
--    for _, player in pairs(game.players) do
--        player.print(s)
--    end
end


local additional_suffixes = {
	"-recycling-comb",
	"-extended",
    "-all-except-blacklisted", 
	"-all",
	"-custom-1",
	"-custom-2",
	"-custom-3",
}

local recipeCombinatorNames = {
	["lo-recipe-combinator-recycling-comb"] = true,
	["lo-recipe-combinator-extended"] = true,
    ["lo-recipe-combinator-all-except-blacklisted"] = true, 
	["lo-recipe-combinator-all"] = true,
	["lo-recipe-combinator-custom-1"] = true,
	["lo-recipe-combinator-custom-2"] = true,
	["lo-recipe-combinator-custom-3"] = true,
	
	["lo-recipe-combinator-recycling-comb-packed"] = true,
	["lo-recipe-combinator-extended-packed"] = true,
    ["lo-recipe-combinator-all-except-blacklisted-packed"] = true, 
	["lo-recipe-combinator-all-packed"] = true,
	["lo-recipe-combinator-custom-1-packed"] = true,
	["lo-recipe-combinator-custom-2-packed"] = true,
	["lo-recipe-combinator-custom-3-packed"] = true,
}



local function ccs_handle_spawned(entityOrEvent, info)
	local entity = entityOrEvent.valid and entityOrEvent or entityOrEvent.entity
    if not (entity and entity.valid) then return end
	if not recipeCombinatorNames[entity.name] then return end
	
    local behavior = entity.get_or_create_control_behavior()	
	behavior.circuit_set_recipe = true
	behavior.circuit_read_contents = false
	behavior.include_in_crafting = false
	behavior.include_fuel = false
	behavior.circuit_read_ingredients = true
	behavior.circuit_read_recipe_finished = false
end

local function ccs_create_packed_entity(info, surface, position, force)
    local entity = surface.create_entity{
        name = packed_name,
        position = position,
        --direction = info.direction,
        force = force,
        raise_built = false
    }
    ccs_handle_spawned(entity, info)
    return entity
end

local function ccs_create_entity(info, surface, position, force)
    local entity = surface.create_entity{
        name = main_name,
        position = position,
        --direction = info.direction,
        force = force,
        raise_built = false,
    }
    ccs_handle_spawned(entity, info)
    return entity
end


local function ccs_init()
    if not (script.active_mods["compaktcircuit"]
        and remote.interfaces["compaktcircuit"]
        and remote.interfaces["compaktcircuit"]["add_combinator"]) then
        return
    end

    if not remote.interfaces[main_name] then
		remote.add_interface(main_name, {
			get_info = ccs_get_info,
			create_entity = ccs_create_entity,
			create_packed_entity = ccs_create_packed_entity
		})
    end

	remote.call("compaktcircuit", "add_combinator", {
		name = main_name,
		packed_names = { packed_name },
		interface_name = main_name
	})
	
	--------------------------------------------------------------------------
    -- ADDITIONAL SUFFIXES — each gets anonymous create functions
    --------------------------------------------------------------------------
    for _, suffix in ipairs(additional_suffixes) do
        local name = main_name .. suffix
		if prototypes.entity[name] then
			local packed = main_name .. suffix..'-packed'

			-- register interface only if not already defined
			if not remote.interfaces[name] then
				remote.add_interface(name, {
					get_info = ccs_get_info,

					create_entity = function(info, surface, position, force)
						local entity = surface.create_entity{
							name = name,
							position = position,
							force = force,
							raise_built = false,
						}
						ccs_handle_spawned(entity, info)
						return entity
					end,

					create_packed_entity = function(info, surface, position, force)
						local entity = surface.create_entity{
							name = packed,
							position = position,
							force = force,
							raise_built = false,
						}
						ccs_handle_spawned(entity, info)
						return entity
					end,
				})
			end

			remote.call("compaktcircuit", "add_combinator", {
				name = name,
				packed_names = { packed },
				interface_name = name
			})
		end
	end
end

script.on_init(ccs_init)
script.on_load(ccs_init)
script.on_configuration_changed(ccs_init)

script.on_event({
	defines.events.on_init,
	defines.events.on_load,
	defines.events.on_configuration_changed
}, ccs_init)


script.on_event({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
	defines.events.on_space_platform_built_entity,
	defines.events.script_raised_built,
	defines.events.script_raised_revive,
}, ccs_handle_spawned)
