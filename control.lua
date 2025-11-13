local main_name = "lo-recipe-combinator"
local packed_name = "lo-recipe-combinator-packed"

----------------------------------------------------------------
--  Apply fixed settings to an entity
----------------------------------------------------------------
---@param ent LuaEntity
local function apply_fixed_settings(ent)
    if not (ent and ent.valid) then return end
    local behavior = ent.get_or_create_control_behavior()

    -- ALWAYS force these modes:
    -- assembling-machine-style combinator flags
    pcall(function()
        behavior.use_exact_mode = false
        behavior.circuit_mode_of_operation = defines.control_behavior.assembling_machine.circuit_mode_of_operation.set_recipe
        behavior.circuit_read_hand_contents = false
        behavior.circuit_read_ingredients = true
        behavior.circuit_read_results = false
    end)
end

----------------------------------------------------------------
--  CompactCircuit: info returned for packing.
--  You don't want to preserve recipe or other runtime state.
----------------------------------------------------------------
---@param entity LuaEntity
local function cc_get_info(entity)
    if not (entity and entity.valid) then return nil end

    return {
        direction = entity.direction,
        position = entity.position,
    }
end

----------------------------------------------------------------
--  CompactCircuit: after entity is spawned/unpacked
----------------------------------------------------------------
local function cc_handle_spawned(ent, info)
    if not (ent and ent.valid) then return end
    apply_fixed_settings(ent)
end

----------------------------------------------------------------
--  CompactCircuit: create packed entity
----------------------------------------------------------------
local function cc_create_packed_entity(info, surface, position, force)
    local ent = surface.create_entity{
        name = packed_name,
        position = position,
        direction = info.direction,
        force = force,
        raise_built = false
    }
    cc_handle_spawned(ent, info)
    return ent
end

----------------------------------------------------------------
--  CompactCircuit: create main entity
----------------------------------------------------------------
local function cc_create_entity(info, surface, force)
    local ent = surface.create_entity{
        name = main_name,
        position = info.position,
        direction = info.direction,
        force = force,
        raise_built = false
    }
    cc_handle_spawned(ent, info)
    return ent
end

----------------------------------------------------------------
--  Register compatibility
----------------------------------------------------------------
local function init_compat()
    if not (script.active_mods["compaktcircuit"]
        and remote.interfaces["compaktcircuit"]
        and remote.interfaces["compaktcircuit"]["add_combinator"]) then
        return
    end

    if not remote.interfaces[main_name] then
        remote.add_interface(main_name, {
            get_info = cc_get_info,
            create_entity = cc_create_entity,
            create_packed_entity = cc_create_packed_entity
        })
    end

    remote.call("compaktcircuit", "add_combinator", {
        name = main_name,
        packed_names = { packed_name },
        interface_name = main_name
    })
end

----------------------------------------------------------------
--  Script events
----------------------------------------------------------------
script.on_init(init_compat)
script.on_load(init_compat)
script.on_configuration_changed(function()
    init_compat()
end)
