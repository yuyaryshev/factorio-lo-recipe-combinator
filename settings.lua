data:extend({
  {
    type = "string-setting",
    name = "recipe-combinator-blacklist",
    setting_type = "startup",
    default_value = "barreling,unbarreling,recycling",
	allow_blank = true,
    order = "a"
  },
  {
    type = "bool-setting",
    name = "add-extended-recipe-combinators",
    setting_type = "startup",
    default_value = false,
    order = "b"
  },
  {
    type = "bool-setting",
    name = "add-custom-recipe-combinators",
    setting_type = "startup",
    default_value = false,
    order = "c"
  },
  {
    type = "string-setting",
    name = "custom-recipe-combinator-1",
    setting_type = "startup",
    default_value = "",
	allow_blank = true,
    order = "d1"
  },
  {
    type = "string-setting",
    name = "custom-recipe-combinator-2",
    setting_type = "startup",
    default_value = "",
	allow_blank = true,
    order = "d2"
  },
  {
    type = "string-setting",
    name = "custom-recipe-combinator-3",
    setting_type = "startup",
    default_value = "",
	allow_blank = true,
    order = "d3"
  },
})
