--编译C文件
--gcc -shared magicktype.c -o libmagicktype.so `freetype-config --cflags --libs` -fPIC
--ldconfig /usr/local/lib


local ffi = require'ffi'
local magick = require "magick"
local magick_type = require 'magick_type'


local mt = magick_type.new("Songti SC")

mt.print_font_table()

local text = ffi.cast("char *", "你好新浪云存储")
mt:set_font(50, {255,0,0,255}, "MT_font_style_bolddddddd")
print(mt:draw_text(text, -1, -1))

local im = magick.constitute_image(mt.mt_image.im_w, mt.mt_image.im_h, "BGRA", "CharPixel", mt.mt_image.image_data)
im:write("test_yui_2.bmp")


mt.font_face = "KaiTi"
mt:set_font(50, {255,0,0,255}, "MT_font_style_bold")
local text2 = ffi.cast("char *", "牛逼牛逼")
print(mt:draw_text(text2, -1, -1, 1))

local im = magick.constitute_image(mt.mt_image.im_w, mt.mt_image.im_h, "A", "CharPixel", mt.mt_image.image_data)
im:write("test_yui_1.bmp")


mt:destroy()