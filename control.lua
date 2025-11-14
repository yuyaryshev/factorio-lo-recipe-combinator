local main_name = "lo-recipe-combinator"
local packed_name = "lo-recipe-combinator-packed"

local function ccs_get_info(entity)
	return {}
end


local function ccs_handle_spawned(entity, info)
    if not (entity and entity.valid) then return end
	if entity.name ~= main_name and entity.name ~= packed_name then return end

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
	script.on_nth_tick(60, nil) -- unregister self from on_nth_tick
    if remote.interfaces[main_name] then
		return
    end

    if not (script.active_mods["compaktcircuit"]
        and remote.interfaces["compaktcircuit"]
        and remote.interfaces["compaktcircuit"]["add_combinator"]) then
        return
    end
 
	remote.add_interface(main_name, {
		get_info = ccs_get_info,
		create_entity = ccs_create_entity,
		create_packed_entity = ccs_create_packed_entity
	})
	
	remote.call("compaktcircuit", "add_combinator", {
		name = main_name,
		packed_names = { packed_name },
		interface_name = main_name
	})
end

script.on_event({
	defines.events.on_init,
	defines.events.on_load,
	defines.events.on_configuration_changed
}, ccs_init)
script.on_nth_tick(60, ccs_init)


script.on_event({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
	defines.events.on_space_platform_built_entity
}, ccs_handle_spawned)
