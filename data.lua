-- data.lua

data:extend({
  {
    type = "item",
    name = "lo-recipe-combinator",
    icon = "__lo-recipe-combinator__/recipe-combinator-item.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "production-machine",
    order = "z[lo-recipe-combinator]",
    place_result = "lo-recipe-combinator",
    stack_size = 50
  }
})

data:extend({
  {
    type = "recipe",
    name = "lo-recipe-combinator",
    enabled = false,
    ingredients =
    {
      {type = "item", name = "copper-cable", amount = 5},
      {type = "item", name = "electronic-circuit", amount = 2}
    },
    results = {{type="item", name="lo-recipe-combinator", amount=1}}
  }
})

table.insert(data.raw.technology["circuit-network"].effects,
  { type = "unlock-recipe", recipe = "lo-recipe-combinator" }
)


local rc = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])

rc.type = "assembling-machine"
rc.name = "lo-recipe-combinator"
rc.icon = "__lo-recipe-combinator__/recipe-combinator-item.png"
rc.minable = {mining_time = 0.2, result = "lo-recipe-combinator"}



rc.graphics_set = {
  animation =
  {
	layers =
	{
	  {
	    scale = 0.5,
		filename = "__lo-recipe-combinator__/recipe-combinator.png",
		priority="high",
		width = 114,
		height = 102,
		shift = util.by_pixel(0, 5),
		frame_count = 1,
		line_length = 1,
	  },
	  {
		scale = 0.5,
		filename = "__lo-recipe-combinator__/recipe-combinator-shadow.png",
		width = 98,
		height = 66,
		shift = util.by_pixel(8.5, 5.5),
		draw_as_shadow = true,
  
		priority="high",
		line_length = 1,
		repeat_count = 1,
	  }
	}
  }
}

rc.crafting_categories = {"crafting"}
rc.crafting_speed = 0.000001
rc.energy_usage = "1W"
rc.energy_source = {type = "electric", usage_priority = "secondary-input"}
rc.module_specification = {module_slots = 0}
rc.allowed_effects = {}

data:extend({rc})
