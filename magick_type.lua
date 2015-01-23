local VERSION = "1.0.0"
local ffi = require("ffi")
local lib = ffi.load'magicktype'

ffi.cdef([[  

typedef struct  MT_Font_Color_ {
    
    unsigned char r;
    unsigned char g;
    unsigned char b;
    unsigned char a;
    
} MT_Font_Color;

typedef struct  MT_Font_ {
    
    int font_size;
    float text_kerning;
    float word_spacing;
    float line_spacing;
    float font_lean;
    MT_Font_Color *font_color;
    
} MT_Font;

typedef struct  MT_Image_ {
    
    int im_w;
    int im_h;
    unsigned char *image_data;
    
} MT_Image;

MT_Font_Color *new_font_color(unsigned char r, unsigned char g, unsigned char b, unsigned char a);
void destroy_font_color(MT_Font_Color *font_color);

MT_Font *new_font();
void destroy_font(MT_Font *font);

MT_Image *new_image();
void destroy_image(MT_Image *image);

int convert_unicode(char *str, int *code);

MT_Image *str_to_image(char *str, int im_w, int im_h, const char *font_name, MT_Font font, int resolution, int channels);

void unpack_font(const char *font_name, void *lua_function(char *family_name, char *style_name, int index));

]])

local _M = {
	_VERSION = '0.1.0',
}

local metatable = { __index = _M }

local font_face_opt = {
	['楷体'] = "Kaiti.ttf",
	['微软雅黑'] = "Microsoft Yahei.ttf",
	['宋体-简'] = "Songti.ttc"
}

local font_path_prefix = "src/lib/data/font/"

local function _font_face(face)
	local font_path = font_face_opt[face] or font_face_opt['楷体']
	return font_path_prefix .. font_path
end

function _M.MT(self, font, font_face)
	return setmetatable({ font = font, font_face = font_face, mt_image = nil}, metatable)
end


function _M.new(font_face)
	local font = lib.new_font()
	return _M:MT(font, _font_face(font_face))
end

function _M.destroy(self)

	if self.font then
		lib.destroy_font(self.font)
		self.font = nil
	end
	
	if self.mt_image then
		lib.destroy_image(self.mt_image)
		self.mt_image = nil
	end

end


function _M.set_font(self, size, color, lean, kerning, word_spacing, line_spacing)

	if size then
		self.font.font_size = size
	end
	
	if color and (type(color)=="table") and (#color == 4) then
		self.font.font_color[0].r = color[1]
		self.font.font_color[0].g = color[2]
		self.font.font_color[0].b = color[3]
		self.font.font_color[0].a = color[4]
	end
	
	if lean then
		self.font.font_lean = lean
	end
	
	if kerning then
		self.font.text_kerning = kerning
	end
	
	if word_spacing then
		self.font.word_spacing = word_spacing
	end
	
	if line_spacing then
		self.font.line_spacing = line_spacing
	end
end

function _M.draw_text(self, text, w, h)                                   

	text = text or ""
	w = w or -1
	h = h or -1
	
	local font_face = ffi.cast("char *", self.font_face)
	self.mt_image = lib.str_to_image(text, w, h, font_face, self.font[0], 72, 4)
end

function _M.unpack_font(self)

	local font_face = ffi.cast("char *", self.font_face)
	
	local font_table = {}
	
	lib.unpack_font(font_face, function (family_name, style_name, index)
		
		if font_table[ffi.string(family_name)] == nil then
			font_table[ffi.string(family_name)] = {}
		end
		font_table[ffi.string(family_name)][ffi.string(style_name)] = index
		
	end)
	
	return font_table
end

return _M