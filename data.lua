-- data.lua
local funcs = require("funcs")

----------------------------------------
-- Collect all crafting categories
----------------------------------------
local all_categories = {}
for _, proto_type in pairs(data.raw) do
  for _, proto in pairs(proto_type) do
    if proto.crafting_categories then
      for _, cat in pairs(proto.crafting_categories) do
        all_categories[cat] = true
      end
    end
  end
end

-- Convert to array
local function to_array(tbl)
  local arr = {}
  for k in pairs(tbl) do table.insert(arr, k) end
  table.sort(arr)
  return arr
end

local all_categories_list = to_array(all_categories)

----------------------------------------
-- Settings
----------------------------------------
local settings_startup = settings.startup
local blacklist = {}
for _, cat in pairs(funcs.parse_csv_or_list(settings_startup["recipe-combinator-blacklist"].value)) do
  blacklist[cat] = true
end

local add_extended = settings_startup["add-extended-recipe-combinators"].value
local add_custom   = settings_startup["add-custom-recipe-combinators"].value

----------------------------------------
-- Utility: Deepcopy and create base entity
----------------------------------------
local function make_base_combinator(name_suffix)
  local base = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
  base.type = "assembling-machine"
  base.name = "lo-recipe-combinator" .. name_suffix
  base.minable = {mining_time = 0.2, result = "lo-recipe-combinator" .. name_suffix}
  base.crafting_speed = 0.000001
  base.energy_usage = "1W"
  base.energy_source = {type = "electric", usage_priority = "secondary-input"}
  base.module_specification = {module_slots = 0}
  base.allowed_effects = {}
  base.fluid_boxes = {
    {
      production_type = "input",
      --pipe_picture = assembler3pipepictures(),
      --pipe_covers = pipecoverspictures(),
      volume = 1,
      pipe_connections = {{flow_direction="input", direction=defines.direction.north, position={0,0}}},
      secondary_draw_orders = {north=-1}
    },
    {
      production_type = "output",
      --pipe_picture = assembler3pipepictures(),
      --pipe_covers = pipecoverspictures(),
      volume = 1,
      pipe_connections = {{flow_direction="output", direction=defines.direction.south, position={0,0}}},
      secondary_draw_orders = {north=-1}
    }
  }
  base.fluid_boxes_off_when_no_fluid_recipe = true
  funcs.setup_recipe_combinator_visuals(base, "recipe-combinator" .. name_suffix)
  return base
end


---Returns only existing recipe categories.
---@param list string[]  -- array of category names
---@return string[]      -- filtered array
local function filter_existing_categories(list)
    local result = {}
    local categories = data.raw["recipe-category"]

    for _, name in pairs(list) do
        if categories[name] then
            result[#result + 1] = name
        end
    end

    return result
end


----------------------------------------
-- Default crafting categories
----------------------------------------
local default_categories = filter_existing_categories({
  "basic-crafting",
  "crafting",
  "advanced-crafting",
  "crafting-with-fluid",
  "electronics",
  "electronics-with-fluid",
  "pressing",
  "metallurgy-or-assembling",
  "organic",
  "organic-or-assembling",
  "electronics-or-assembling",
  "cryogenics-or-assembling",
  "crafting-with-fluid-or-metallurgy",
})

----------------------------------------
-- Define combinator types
----------------------------------------
local combinators = {
  { name = "", display = "Recipe Combinator", cats = default_categories },
--  { name = "-recycling-comb", display = "Recycling Recipe Combinator", cats = {"recycling"} },
}

if add_extended then
  -- All except recycling, minus blacklist
  local ext_cats = {}
  for _, c in pairs(all_categories_list) do
    if not blacklist[c] and c ~= "recycling" then table.insert(ext_cats, c) end
  end
  table.insert(combinators, { name = "-extended", display = "Extended Recipe Combinator", cats = ext_cats })
    
	-- Add All Except Blacklisted and All
	do
	  local all_exc_blacklist = {}
	  for _, c in pairs(all_categories_list) do
		if not blacklist[c] then table.insert(all_exc_blacklist, c) end
	  end
	  table.insert(combinators, { name = "-all-except-blacklisted", display = "All Except Blacklisted Recipe Combinator", cats = all_exc_blacklist })
	  table.insert(combinators, { name = "-all", display = "All Recipe Combinator", cats = all_categories_list })
	end
end

if add_custom then
  for i = 1, 3 do
    local setting_val = settings_startup["custom-recipe-combinator-" .. i].value
    local list = funcs.parse_csv_or_list(setting_val)
    if not list or #list == 0 then list = all_categories_list end
    table.insert(combinators, {
      name = "-custom-" .. i,
      display = "Custom Recipe Combinator " .. i,
      cats = list,
    })
  end
end


----------------------------------------
-- Generate items, recipes, and entities
----------------------------------------
for _, def in pairs(combinators) do
  local suffix = def.name
  local base = make_base_combinator(suffix)
  base.crafting_categories = filter_existing_categories(def.cats)

    local packed = table.deepcopy(base)
    packed.name = base.name..'-packed'
	
	packed.flags = {
	  "placeable-off-grid", "not-repairable", "not-on-map", "not-deconstructable",
	  "not-blueprintable", "hide-alt-info", "not-flammable", "no-copy-paste",
	  "not-selectable-in-game", "not-upgradable", "not-in-kill-statistics",
	  "not-in-made-in"
	}
	packed.hidden = true
	packed.hidden_in_factoriopedia = true	
	
	packed.draw_circuit_wires = false

	-- Must be tiny but valid, otherwise pipe positions fail
	packed.collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
	packed.selection_box = nil
	packed.graphics_set = nil

	packed.sprites = util.empty_sprite(1)
	packed.collision_mask = {layers={}, not_colliding_with_itself = true}
	packed.minable = nil
	packed.selectable_in_game = false

	-- Fix pipe connection positions (must be inside bounding box)
	if packed.fluid_boxes then
	  for _, fb in pairs(packed.fluid_boxes) do
		if fb.pipe_connections then
		  for _, pc in pairs(fb.pipe_connections) do
			pc.position = {0, 0.05}  -- inside collision_box, invisible, still valid
		  end
		end
	  end
	end

--    packed.activity_led_light_offsets = { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }
--    packed.and_symbol_sprites = util.empty_sprite(1)
--    packed.divide_symbol_sprites = util.empty_sprite(1)
--    packed.left_shift_symbol_sprites = util.empty_sprite(1)
--    packed.minus_symbol_sprites = util.empty_sprite(1)
--    packed.modulo_symbol_sprites = util.empty_sprite(1)
--    packed.multiply_symbol_sprites = util.empty_sprite(1)
--    packed.or_symbol_sprites = util.empty_sprite(1)
--    packed.plus_symbol_sprites = util.empty_sprite(1)
--    packed.power_symbol_sprites = util.empty_sprite(1)
--    packed.right_shift_symbol_sprites = util.empty_sprite(1)
--    packed.xor_symbol_sprites = util.empty_sprite(1)
--    packed.alert_icon_scale = 0
--    packed.activity_led_sprites = { north = util.empty_sprite(1), south = util.empty_sprite(1), east = util.empty_sprite(1), west = util.empty_sprite(1)}

  local name = "lo-recipe-combinator" .. suffix
  
  local item = {
    type = "item",
    name = name,
    icon = "__lo-recipe-combinator__/recipe-combinator" .. suffix .. "-item.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = data.raw["item"]["constant-combinator"].subgroup,
    order = data.raw["item"]["constant-combinator"].order.."-z" .. suffix,
    place_result = name,
    stack_size = 50,
  }

  local recipe = {
    type = "recipe",
    name = name,
    enabled = false,
    ingredients = {{type="item", name="copper-cable", amount=5}, {type="item", name="electronic-circuit", amount=2}},
    results = {{type="item", name=name, amount=1}},
  }
  
  data:extend({base, item, recipe, packed})
  table.insert(data.raw.technology["circuit-network"].effects, { type = "unlock-recipe", recipe = name })
end
 