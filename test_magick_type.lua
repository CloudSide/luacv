local ffi = require'ffi'
local magick = require "magick"
local magick_type = require 'magick_type'

--local C = ffi.load'unicode'

--[[
--你好，新浪云存储这东西杠杠的，欢迎大家使用！如果爽，那就快点分享吧（^_^）
local text = ffi.cast("char *", "你好，新浪云存储这东西杠杠的，欢迎大家使用！如果爽，那就快点分享吧（^_^）你好，新浪云存储这东西杠杠的，欢迎大家使用！如果爽，那就快点分享吧（^_^)") --你好，新浪云存储这东西杠杠的，欢迎大家使用！如果爽，那就快点分享吧（^_^）新浪云存储\t新浪云存储\n新浪云    存储
local file = ffi.cast("char *", "/Library/Fonts/Microsoft/Kaiti.ttf")


local font_opt = C.new_font_opt()
font_opt.font_size = 30
font_opt.font_lean = 0
font_opt.line_spacing = 1
font_opt.text_kerning = 1
font_opt.word_spacing = 1

local font_color = C.new_font_color(255,0,0,255)
font_opt.font_color = font_color[0]


local image_width = 600
local image_height = 800
local image_struct = C.str_to_image(text, -1, -1, file, font_opt[0], 72, 4)


C.destroy_font_color(font_color)
C.destroy_font_opt(font_opt)


local im = magick.constitute_image(image_struct.im_w, image_struct.im_h, "BGRA", "CharPixel", image_struct.image_data)
im:write("/Users/littlebox222/workspace/luacv/files/test1.bmp")

C.destroy_image_opt(image_struct)
--]]
local mt = magick_type.new()

local text = ffi.cast("char *", "你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储")

mt:set_font(50, {255,255,0,255})

mt:draw_text(text, 500, -1)

local im = magick.constitute_image(mt.mt_image.im_w, mt.mt_image.im_h, "BGRA", "CharPixel", mt.mt_image.image_data)
im:write("/Users/littlebox222/workspace/luacv/files/test1.bmp")

mt:destroy()