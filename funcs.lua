-- funcs.lua
local funcs = {}

function funcs.parse_csv_or_list(value)
  local t = {}
  if type(value) == "string" then
    for s in string.gmatch(value, "[^,%s]+") do table.insert(t, s) end
  elseif type(value) == "table" then
    for _, s in pairs(value) do table.insert(t, s) end
  end
  return t
end

function funcs.setup_recipe_combinator_visuals(rc, filename)
  rc.icon = "__lo-recipe-combinator__/" .. filename .. "-item.png"

  rc.graphics_set = {
    animation = {
      layers = {
        {
          scale = 0.5,
          filename = "__lo-recipe-combinator__/" .. filename .. ".png",
          priority = "high",
          width = 114,
          height = 102,
          shift = util.by_pixel(0, 5),
          frame_count = 1,
          line_length = 1
        },
        {
          scale = 0.5,
          filename = "__lo-recipe-combinator__/recipe-combinator-shadow.png",
          width = 98,
          height = 66,
          shift = util.by_pixel(8.5, 5.5),
          draw_as_shadow = true,
          priority = "high",
          line_length = 1,
          repeat_count = 1
        }
      }
    }
  }

  rc.circuit_connector = {
    {
      points = {
        shadow = { red = util.by_pixel(7, -6), green = util.by_pixel(23, -6) },
        wire   = { red = util.by_pixel(-8.5, -17.5), green = util.by_pixel(7, -17.5) }
      }
    },
    {
      points = {
        shadow = { red = util.by_pixel(32, -5), green = util.by_pixel(32, 8) },
        wire   = { red = util.by_pixel(14.5, -16.5), green = util.by_pixel(17.5, -3.5) }
      }
    },
    {
      points = {
        shadow = { red = util.by_pixel(25, 20), green = util.by_pixel(9, 20) },
        wire   = { red = util.by_pixel(9, 7.5), green = util.by_pixel(-6.5, 7.5) }
      }
    },
    {
      points = {
        shadow = { red = util.by_pixel(1, 11), green = util.by_pixel(1, -2) },
        wire   = { red = util.by_pixel(-13.5, -0.5), green = util.by_pixel(-16.5, -13.5) }
      }
    }
  }
end

return funcs