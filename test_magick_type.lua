local ffi = require'ffi'
local magick = require "magick"
local magick_type = require 'magick_type'



local mt = magick_type.new()

local text = ffi.cast("char *", "你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储你好，新浪云存储")

mt:set_font(50, {255,255,0,255},0.5)

--print(mt.font.font_color.r)
mt:draw_text(text, 475, -1)

local im = magick.constitute_image(mt.mt_image.im_w, mt.mt_image.im_h, "BGRA", "CharPixel", mt.mt_image.image_data)
im:write("test_hahaha.bmp")

mt:destroy()