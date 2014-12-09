local luacv = require "luacv"

local image = luacv.load_image("files/test_0x11.png", "ANYCOLOR")
--local faces = image:object_detect("haarcascade_frontalface_alt2.xml")
local faces = image:object_detect("haarcascade_frontalface_default.xml")
for i = 1, #faces, 1 do
	print(faces[i].x, faces[i].y, faces[i].width, faces[i].height)
	local idx = i
	local w_o, h_o = image:get_size()

	local x_f = (faces[idx].x + faces[idx].width / 2) - (faces[idx].width * 1)
	local y_f = (faces[idx].y + faces[idx].height / 2) - (faces[idx].height * 1)
	local w_f = faces[idx].width * 2
	local h_f = faces[idx].height * 2
	x_f = x_f > 0 and x_f or 0
	y_f = y_f > 0 and y_f or 0
	--w_f = ((w_f + x_f) <= (w_o - x_f)) and w_f or (w_o - x_f)
	--h_f = ((h_f + y_f) <= (h_o - y_f)) and h_f or (h_o - y_f)

	--image:set_image_roi(faces[i].x, faces[i].y, faces[i].width, faces[i].height)
	image:ellipse((faces[i].x + faces[i].width / 2), (faces[i].y + faces[i].height / 2), faces[i].width / 2, faces[i].height / 2, 360, 0, 360, {255, 0, 0, 1})
	--image:rectangle(x1, y1, x2, y2, scalar, thickness, line_type, shift)


	--image:save_image("files/test_face_" .. idx .. ".png", {['PNG_COMPRESSION'] = 9})
end

image:save_image("files/test_face_" .. 1 .. ".png", {['PNG_COMPRESSION'] = 9})
image:release_image()