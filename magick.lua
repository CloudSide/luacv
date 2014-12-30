local VERSION = "1.0.0"
local ffi = require("ffi")
ffi.cdef([[  

  typedef void MagickWand;
  typedef void PixelWand;
  typedef void DrawingWand;

  typedef int MagickBooleanType;
  typedef int ExceptionType;
  typedef int ssize_t;
  typedef int CompositeOperator;
  typedef int GravityType;

  typedef enum {
    UndefinedPixel,
    CharPixel,
    DoublePixel,
    FloatPixel,
    IntegerPixel,
    LongPixel,
    QuantumPixel,
    ShortPixel
  } StorageType;

  DrawingWand *NewDrawingWand(void);
  DrawingWand *DestroyDrawingWand(DrawingWand *wand);
  void DrawSetFillColor(DrawingWand *wand, const PixelWand *fill_wand);
  void DrawSetStrokeColor(DrawingWand *wand, const PixelWand *stroke_wand);
  void DrawSetStrokeAntialias(DrawingWand *wand, const MagickBooleanType stroke_antialias);
  void DrawRoundRectangle(DrawingWand *wand, double x1, double y1, double x2,double y2, double rx, double ry);
  void DrawRectangle(DrawingWand *wand, const double x1, const double y1, const double x2, const double y2);
  void DrawEllipse(DrawingWand *wand, const double ox, const double oy, const double rx, const double ry, const double start, const double end);
  void DrawSetStrokeWidth(DrawingWand *wand, const double stroke_width);

  void PixelSetOpacity(PixelWand *wand, const double opacity);  
  double PixelGetRed(const PixelWand *wand);
  double PixelGetGreen(const PixelWand *wand);
  double PixelGetBlue(const PixelWand *wand);
  double PixelGetBlack(const PixelWand *wand);
  double PixelGetYellow(const PixelWand *wand);
  double PixelGetAlpha(const PixelWand *wand);

  MagickBooleanType MagickNewImage(MagickWand *wand, const size_t columns, const size_t rows, const PixelWand *background);

  MagickBooleanType MagickDrawImage(MagickWand *wand, const DrawingWand *drawing_wand);

  MagickBooleanType MagickSetImageBackgroundColor(MagickWand *wand, const PixelWand *background);

  void MagickWandGenesis();
  void MagickSetFirstIterator(MagickWand *wand);
  MagickWand* NewMagickWand();
  MagickWand* DestroyMagickWand(MagickWand*);
  MagickBooleanType MagickReadImage(MagickWand*, const char*);
  MagickBooleanType MagickReadImageBlob(MagickWand*, const void*, const size_t);
  MagickBooleanType MagickConstituteImage(MagickWand *wand, 
	const size_t columns, const size_t rows, const char *map,
    const StorageType storage, void *pixels);
  MagickBooleanType MagickExportImagePixels(MagickWand *wand,
    const ssize_t x, const ssize_t y, const size_t columns,
    const size_t rows, const char *map, const StorageType storage,
    void *pixels);

  const char* MagickGetException(const MagickWand*, ExceptionType*);

  int MagickGetImageWidth(MagickWand*);
  int MagickGetImageHeight(MagickWand*);

  MagickBooleanType MagickAddImage(MagickWand*, const MagickWand*);

  MagickBooleanType MagickAdaptiveResizeImage(MagickWand*, const size_t, const size_t);

  MagickBooleanType MagickWriteImage(MagickWand*, const char*);

  unsigned char* MagickGetImageBlob(MagickWand*, size_t*);

  void* MagickRelinquishMemory(void*);

  MagickBooleanType MagickCropImage(MagickWand*,
    const size_t, const size_t, const ssize_t, const ssize_t);

  MagickBooleanType MagickBlurImage(MagickWand*, const double, const double);

  MagickBooleanType MagickSetImageFormat(MagickWand* wand, const char* format);
  const char* MagickGetImageFormat(MagickWand* wand);

  size_t MagickGetImageCompressionQuality(MagickWand * wand);
  MagickBooleanType MagickSetImageCompressionQuality(MagickWand *wand,
    const size_t quality);

  MagickBooleanType MagickSharpenImage(MagickWand *wand,
    const double radius,const double sigma);

  MagickBooleanType MagickScaleImage(MagickWand *wand,
    const size_t columns,const size_t rows);

  MagickBooleanType MagickSetOption(MagickWand *,const char *,const char *);
    char* MagickGetOption(MagickWand *,const char *);

  MagickBooleanType MagickCompositeImage(MagickWand *wand,
    const MagickWand *source_wand,const CompositeOperator compose,
    const ssize_t x,const ssize_t y);

  GravityType MagickGetImageGravity(MagickWand *wand);
  MagickBooleanType MagickSetImageGravity(MagickWand *wand,
    const GravityType gravity);

  MagickBooleanType MagickStripImage(MagickWand *wand);

  MagickBooleanType MagickGetImagePixelColor(MagickWand *wand,
    const ssize_t x,const ssize_t y,PixelWand *color);

  MagickBooleanType MagickRotateImage(MagickWand *wand,
    const PixelWand *background,const double degrees);

  MagickBooleanType MagickEdgeImage(MagickWand *wand,const double radius);

  MagickBooleanType MagickShadowImage(MagickWand *wand,const double alpha,
    const double sigma,const ssize_t x,const ssize_t y);

  MagickBooleanType MagickBorderImage(MagickWand *wand,
	const PixelWand *bordercolor,
	const size_t width,
    const size_t height);
  
  MagickBooleanType MagickFrameImage(MagickWand *wand,
    const PixelWand *matte_color,const size_t width,
    const size_t height,const ssize_t inner_bevel,
    const ssize_t outer_bevel);

  MagickBooleanType MagickAutoOrientImage(MagickWand *image);

  PixelWand *NewPixelWand(void);
  MagickBooleanType PixelSetColor(PixelWand *wand,const char *color);
  PixelWand *DestroyPixelWand(PixelWand *);

  double PixelGetAlpha(const PixelWand *);
  double PixelGetRed(const PixelWand *);
  double PixelGetGreen(const PixelWand *);
  double PixelGetBlue(const PixelWand *);

  MagickBooleanType MagickFlopImage(MagickWand *wand);
  MagickBooleanType MagickFlipImage(MagickWand *wand);

  MagickBooleanType MagickSetImageOpacity(MagickWand *wand, const double alpha);

]])
local get_flags
get_flags = function()
  local proc = io.popen("MagickWand-config --cflags --libs", "r")
  local flags = proc:read("*a")
  get_flags = function()
    return flags
  end
  proc:close()
  return flags
end
local get_filters
get_filters = function()
  local fname = "magick/resample.h"
  local prefixes = {
    "/usr/include/ImageMagick",
    "/usr/local/include/ImageMagick",
    function()
      return get_flags():match("-I([^%s]+)")
    end
  }
  for _index_0 = 1, #prefixes do
    local _continue_0 = false
    repeat
      local p = prefixes[_index_0]
      if "function" == type(p) then
        p = p()
        if not (p) then
          _continue_0 = true
          break
        end
      end
      local full = tostring(p) .. "/" .. tostring(fname)
      do
        local f = io.open(full)
        if f then
          local content
          do
            local _with_0 = f:read("*a")
            f:close()
            content = _with_0
          end
          local filter_types = content:match("(typedef enum.-FilterTypes;)")
          if filter_types then
            ffi.cdef(filter_types)
            return true
          end
        end
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  return false
end
local try_to_load
try_to_load = function(...)
  local out
  local _list_0 = {
    ...
  }
  for _index_0 = 1, #_list_0 do
    local _continue_0 = false
    repeat
      local name = _list_0[_index_0]
      if "function" == type(name) then
        name = name()
        if not (name) then
          _continue_0 = true
          break
        end
      end
      if pcall(function()
        out = ffi.load(name)
      end) then
        return out
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  return error("Failed to load ImageMagick (" .. tostring(...) .. ")")
end
local lib = try_to_load("MagickWand", function()
  local lname = get_flags():match("-l(MagickWand[^%s]*)")
  local suffix
  if ffi.os == "OSX" then
    suffix = ".dylib"
  elseif ffi.os == "Windows" then
    suffix = ".dll"
  else
    suffix = ".so"
  end
  return lname and "lib" .. lname .. suffix
end)
local can_resize
if get_filters() then
  ffi.cdef([[    MagickBooleanType MagickResizeImage(MagickWand*,
      const size_t, const size_t,
      const FilterTypes, const double);
  ]])
  can_resize = true
end
local storage_type_op = {
  ["UndefinedPixel"] = 0,
  ["CharPixel"] = 1,
  ["DoublePixel"] = 2,
  ["FloatPixel"] = 3,
  ["IntegerPixel"] = 4,
  ["LongPixel"] = 5,
  ["QuantumPixel"] = 6,
  ["ShortPixel"] = 7,
}

local orientation_op = {
  ["UndefinedOrientation"] = 0,
  ["TopLeftOrientation"] = 1,
  ["TopRightOrientation"] = 2,
  ["BottomRightOrientation"] = 3,
  ["BottomLeftOrientation"] = 4,
  ["LeftTopOrientation"] = 5,
  ["RightTopOrientation"] = 6,
  ["RightBottomOrientation"] = 7,
  ["LeftBottomOrientation"] = 8,
}

local composite_op = {
  ["UndefinedCompositeOp"] = 0,
  ["NoCompositeOp"] = 1,
  ["ModulusAddCompositeOp"] = 2,
  ["AtopCompositeOp"] = 3,
  ["BlendCompositeOp"] = 4,
  ["BumpmapCompositeOp"] = 5,
  ["ChangeMaskCompositeOp"] = 6,
  ["ClearCompositeOp"] = 7,
  ["ColorBurnCompositeOp"] = 8,
  ["ColorDodgeCompositeOp"] = 9,
  ["ColorizeCompositeOp"] = 10,
  ["CopyBlackCompositeOp"] = 11,
  ["CopyBlueCompositeOp"] = 12,
  ["CopyCompositeOp"] = 13,
  ["CopyCyanCompositeOp"] = 14,
  ["CopyGreenCompositeOp"] = 15,
  ["CopyMagentaCompositeOp"] = 16,
  ["CopyOpacityCompositeOp"] = 17,
  ["CopyRedCompositeOp"] = 18,
  ["CopyYellowCompositeOp"] = 19,
  ["DarkenCompositeOp"] = 20,
  ["DstAtopCompositeOp"] = 21,
  ["DstCompositeOp"] = 22,
  ["DstInCompositeOp"] = 23,
  ["DstOutCompositeOp"] = 24,
  ["DstOverCompositeOp"] = 25,
  ["DifferenceCompositeOp"] = 26,
  ["DisplaceCompositeOp"] = 27,
  ["DissolveCompositeOp"] = 28,
  ["ExclusionCompositeOp"] = 29,
  ["HardLightCompositeOp"] = 30,
  ["HueCompositeOp"] = 31,
  ["InCompositeOp"] = 32,
  ["LightenCompositeOp"] = 33,
  ["LinearLightCompositeOp"] = 34,
  ["LuminizeCompositeOp"] = 35,
  ["MinusDstCompositeOp"] = 36,
  ["ModulateCompositeOp"] = 37,
  ["MultiplyCompositeOp"] = 38,
  ["OutCompositeOp"] = 39,
  ["OverCompositeOp"] = 40,
  ["OverlayCompositeOp"] = 41,
  ["PlusCompositeOp"] = 42,
  ["ReplaceCompositeOp"] = 43,
  ["SaturateCompositeOp"] = 44,
  ["ScreenCompositeOp"] = 45,
  ["SoftLightCompositeOp"] = 46,
  ["SrcAtopCompositeOp"] = 47,
  ["SrcCompositeOp"] = 48,
  ["SrcInCompositeOp"] = 49,
  ["SrcOutCompositeOp"] = 50,
  ["SrcOverCompositeOp"] = 51,
  ["ModulusSubtractCompositeOp"] = 52,
  ["ThresholdCompositeOp"] = 53,
  ["XorCompositeOp"] = 54,
  ["DivideDstCompositeOp"] = 55,
  ["DistortCompositeOp"] = 56,
  ["BlurCompositeOp"] = 57,
  ["PegtopLightCompositeOp"] = 58,
  ["VividLightCompositeOp"] = 59,
  ["PinLightCompositeOp"] = 60,
  ["LinearDodgeCompositeOp"] = 61,
  ["LinearBurnCompositeOp"] = 62,
  ["MathematicsCompositeOp"] = 63,
  ["DivideSrcCompositeOp"] = 64,
  ["MinusSrcCompositeOp"] = 65,
  ["DarkenIntensityCompositeOp"] = 66,
  ["LightenIntensityCompositeOp"] = 67
}
local gravity_str = {
  "ForgetGravity",
  "NorthWestGravity",
  "NorthGravity",
  "NorthEastGravity",
  "WestGravity",
  "CenterGravity",
  "EastGravity",
  "SouthWestGravity",
  "SouthGravity",
  "SouthEastGravity",
  "StaticGravity"
}
local gravity_type = { }
for i, t in ipairs(gravity_str) do
  gravity_type[t] = i
end
lib.MagickWandGenesis()
local filter
filter = function(name)
  return lib[name .. "Filter"]
end
local get_exception
get_exception = function(wand)
  local etype = ffi.new("ExceptionType[1]", 0)
  local msg = ffi.string(lib.MagickGetException(wand, etype))
  return etype[0], msg
end
local handle_result
handle_result = function(img_or_wand, status)
  local wand = img_or_wand.wand or img_or_wand
  if status == 0 then
    local code, msg = get_exception(wand)
    return nil, msg, code
  else
    return true
  end
end
local Image
do
  local _base_0 = {
    get_width = function(self)
      return lib.MagickGetImageWidth(self.wand)
    end,
    get_height = function(self)
      return lib.MagickGetImageHeight(self.wand)
    end,
    get_format = function(self)
      return ffi.string(lib.MagickGetImageFormat(self.wand)):lower()
    end,
    set_format = function(self, format)
      return handle_result(self, lib.MagickSetImageFormat(self.wand, format))
    end,
    get_quality = function(self)
      return lib.MagickGetImageCompressionQuality(self.wand)
    end,
    set_quality = function(self, quality)
      return handle_result(self, lib.MagickSetImageCompressionQuality(self.wand, quality))
    end,
    get_option = function(self, magick, key)
      local format = magick .. ":" .. key
      return ffi.string(lib.MagickGetOption(self.wand, format))
    end,
    set_option = function(self, magick, key, value)
      local format = magick .. ":" .. key
      return handle_result(self, lib.MagickSetOption(self.wand, format, value))
    end,
    get_gravity = function(self)
      return gravity_str[lib.MagickGetImageGravity(self.wand)]
    end,
    set_gravity = function(self, typestr)
      local type = gravity_type[typestr]
      if not (type) then
        error("invalid gravity type")
      end
      return lib.MagickSetImageGravity(self.wand, type)
    end,
	set_first_iterator = function(self)
		return lib.MagickSetFirstIterator(self.wand)
	end,
    strip = function(self)
      return lib.MagickStripImage(self.wand)
    end,
    _keep_aspect = function(self, w, h)
      if not w and h then
        return self:get_width() / self:get_height() * h, h
      elseif w and not h then
        return w, self:get_height() / self:get_width() * w
      else
        return w, h
      end
    end,
    clone = function(self)
      local wand = lib.NewMagickWand()
      lib.MagickAddImage(wand, self.wand)
      return Image(wand, self.path)
    end,
    resize = function(self, w, h, f, blur)
      if f == nil then
        f = "Lanczos2"
      end
      if blur == nil then
        blur = 1.0
      end
      if not (can_resize) then
        error("Failed to load filter list, can't resize")
      end
      w, h = self:_keep_aspect(w, h)
      return handle_result(self, lib.MagickResizeImage(self.wand, w, h, filter(f), blur))
    end,
    rotate = function(self, degrees, background)
      if background == nil then
        background = "rgba(255,255,255,0)"
      end
      local pixelWand = lib.NewPixelWand();
      lib.PixelSetColor(pixelWand, background)
      local hr = handle_result(self, lib.MagickRotateImage(self.wand, pixelWand, degrees))
	  lib.DestroyPixelWand(pixelWand)
	  return hr
    end,
    edge = function(self, radius)
      return handle_result(self, lib.MagickEdgeImage(self.wand, radius))
    end,
    shadow = function(self, alpha, sigma, x, y)
      return handle_result(self, lib.MagickShadowImage(self.wand, alpha, sigma, x, y))
    end,
    adaptive_resize = function(self, w, h)
      w, h = self:_keep_aspect(w, h)
      return handle_result(self, lib.MagickAdaptiveResizeImage(self.wand, w, h))
    end,
    scale = function(self, w, h)
      w, h = self:_keep_aspect(w, h)
      return handle_result(self, lib.MagickScaleImage(self.wand, w, h))
    end,
    crop = function(self, w, h, x, y)
      if x == nil then
        x = 0
      end
      if y == nil then
        y = 0
      end
      return handle_result(self, lib.MagickCropImage(self.wand, w, h, x, y))
    end,
    blur = function(self, sigma, radius)
      if radius == nil then
        radius = 0
      end
      return handle_result(self, lib.MagickBlurImage(self.wand, radius, sigma))
    end,
    sharpen = function(self, sigma, radius)
      if radius == nil then
        radius = 0
      end
      return handle_result(self, lib.MagickSharpenImage(self.wand, radius, sigma))
    end,
	flop = function(self)
		return handle_result(self, lib.MagickFlopImage(self.wand))
	end,
	flip = function(self)
		return handle_result(self, lib.MagickFlipImage(self.wand))
	end,
	opacity = function(self, alpha)
		return handle_result(self, lib.MagickSetImageOpacity(self.wand, alpha))
	end,
	border = function(self, color, bw)
	--[
		if not color then
			color = "rgba(255,255,255,0)"
		end

		if not bw then
			bw = 1
		end

		local w, h = self:get_width(), self:get_height()

		local draw = lib.NewDrawingWand()
		local pixelNone = lib.NewPixelWand() 
		lib.PixelSetColor(pixelNone, "none")
		local pixelBorder = lib.NewPixelWand()
		lib.PixelSetColor(pixelBorder, color)		
		
		local mask = lib.NewMagickWand()
		lib.MagickNewImage(mask, w, h, pixelNone)

		lib.DrawSetFillColor(draw, pixelNone)
		lib.DrawSetStrokeColor(draw, pixelBorder)
		lib.DrawSetStrokeWidth(draw, bw)
		lib.DrawSetStrokeAntialias(draw, false)
		lib.DrawRectangle(draw, bw / 2 - 1, bw / 2 - 1, w - bw / 2, h - bw / 2)

		lib.MagickDrawImage(mask, draw)
		lib.MagickCompositeImage(self.wand, mask, composite_op["OverCompositeOp"], 0, 0)

		lib.DestroyPixelWand(pixelNone)
		lib.DestroyPixelWand(pixelBorder)
		lib.DestroyMagickWand(mask)
		lib.DestroyDrawingWand(draw)
	--]]
	end,
	frame = function(self, color, w, h, inner_bevel, outer_bevel)
		if color == nil then
			color = "rgba(255,255,255,0)"
		end
		local pixelWand = lib.NewPixelWand();
		lib.PixelSetColor(pixelWand, color)
		local hr = handle_result(self, lib.MagickFrameImage(self.wand, pixelWand, w, h, inner_bevel, outer_bevel))
		lib.DestroyPixelWand(pixelWand)
		return hr
	end,
	auto_orient = function(self)
		return handle_result(self, lib.MagickAutoOrientImage(self.wand))
	end,
    composite = function(self, blob, x, y, opstr)
      if opstr == nil then
        opstr = "OverCompositeOp"
      end
      if type(blob) == "table" and blob.__class == Image then
        blob = blob.wand
      end
      local op = composite_op[opstr]
      if not (op) then
        error("invalid operator type")
      end
      return handle_result(self, lib.MagickCompositeImage(self.wand, blob, op, x, y))
    end,
	set_bg_color = function(self, color)
		color = color or "rgba(255,255,255,0)"
		local pixelWand = lib.NewPixelWand()
		lib.PixelSetColor(pixelWand, color)
		lib.MagickSetImageBackgroundColor(self.wand, pixelWand)
		lib.DestroyPixelWand(pixelWand)
	end,
	rounded_corner = function(self, radius, color)
		local w, h = self:get_width(), self:get_height()
		radius = radius or 0
		radius = (radius < 0) and (w + h) or radius
		if w > h  then
			--radius = (radius > h / 2) and (h / 2) or radius
			radius = (radius >= h / 2) and -1 or radius
		else
			--radius = (radius > w / 2) and (w / 2) or radius
			radius = (radius >= w / 2) and -1 or radius
		end

		local drawWand = lib.NewDrawingWand()
		local pixelBlack = lib.NewPixelWand()
		local pixelTrans = lib.NewPixelWand()
		local pixelWhite = lib.NewPixelWand() 
		lib.PixelSetColor(pixelBlack, "black")
		lib.PixelSetColor(pixelTrans, "transparent")
		lib.PixelSetColor(pixelWhite, "white")

		lib.DrawSetFillColor(drawWand, pixelBlack)
		lib.DrawSetStrokeColor(drawWand, pixelTrans)
		--lib.DrawSetStrokeWidth(drawWand, 0)
		lib.DrawSetStrokeAntialias(drawWand, true)
		
		if radius < 0 then
			lib.DrawEllipse(drawWand, w / 2 - 1, h / 2 - 1, w / 2 - 1, h / 2 - 1, 0, 360)
		else
			lib.DrawRoundRectangle(drawWand, 0, 0, w + 0, h + 0, radius + 2, radius + 2)
		end
		--local alpha = lib.PixelGetAlpha(pixelWand)
		--lib.PixelSetOpacity(pixelWand, alpha)

		local mask = lib.NewMagickWand()
		lib.MagickNewImage(mask, w, h, pixelTrans)
		lib.MagickSetImageBackgroundColor(mask, pixelTrans)


		lib.MagickDrawImage(mask, drawWand)
		lib.MagickCompositeImage(self.wand, mask, composite_op["DstInCompositeOp"], 0, 0)
		--lib.MagickCompositeImage(self.wand, mask, composite_op["CopyBlackCompositeOp"], 0, 0)

		--self.wand = mask
		
		lib.DestroyPixelWand(pixelBlack)
		lib.DestroyPixelWand(pixelTrans)
		lib.DestroyPixelWand(pixelWhite)
		lib.DestroyMagickWand(mask)
		lib.DestroyDrawingWand(drawWand)


		color = color or "white"
		local pixelWand = lib.NewPixelWand()
		lib.PixelSetColor(pixelWand, color)

		local mask_bg = lib.NewMagickWand()
		lib.MagickNewImage(mask_bg, w, h, pixelWand)
		lib.MagickCompositeImage(self.wand, mask_bg, composite_op["DstOverCompositeOp"], 0, 0)

		lib.DestroyPixelWand(pixelWand)
		lib.DestroyMagickWand(mask_bg)

	end,
    resize_and_crop = function(self, w, h)
      local src_w, src_h = self:get_width(), self:get_height()
      local ar_src = src_w / src_h
      local ar_dest = w / h
      if ar_dest > ar_src then
        local new_height = w / ar_src
        self:resize(w, new_height)
        return self:crop(w, h, 0, (new_height - h) / 2)
      else
        local new_width = h * ar_src
        self:resize(new_width, h)
        return self:crop(w, h, (new_width - w) / 2, 0)
      end
    end,
    scale_and_crop = function(self, w, h)
      local src_w, src_h = self:get_width(), self:get_height()
      local ar_src = src_w / src_h
      local ar_dest = w / h
      if ar_dest > ar_src then
        local new_height = w / ar_src
        self:resize(w, new_height)
        return self:scale(w, h)
      else
        local new_width = h * ar_src
        self:resize(new_width, h)
        return self:scale(w, h)
      end
    end,
    get_blob = function(self)
      local len = ffi.new("size_t[1]", 0)
      local blob = lib.MagickGetImageBlob(self.wand, len)
      do
        local _with_0 = ffi.string(blob, len[0])
        lib.MagickRelinquishMemory(blob)
        return _with_0
      end
    end,
    write = function(self, fname)
      return handle_result(self, lib.MagickWriteImage(self.wand, fname))
    end,
    destroy = function(self)
      if self.wand then
        lib.DestroyMagickWand(self.wand)
      end
      self.wand = nil
      if self.pixel_wand then
        lib.DestroyPixelWand(self.pixel_wand)
        self.pixel_wand = nil
      end
    end,
    get_pixel = function(self, x, y)
      self.pixel_wand = self.pixel_wand or lib.NewPixelWand()
      assert(lib.MagickGetImagePixelColor(self.wand, x, y, self.pixel_wand), "failed to get pixel")
      return lib.PixelGetRed(self.pixel_wand), lib.PixelGetGreen(self.pixel_wand), lib.PixelGetBlue(self.pixel_wand), lib.PixelGetAlpha(self.pixel_wand)
    end,
    __tostring = function(self)
      return "Image<" .. tostring(self.path) .. ", " .. tostring(self.wand) .. ">"
    end,
	export_image_pixels = function(self, x, y, w, h, map, storage, pixels)
		if 0 == lib.MagickExportImagePixels(self.wand, x, y, w, h, map, storage_type_op[storage], pixels) then
			return true
		end
		return false
	end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, wand, path)
      self.wand, self.path = wand, path
    end,
    __base = _base_0,
    __name = "Image"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Image = _class_0
end
local load_image
load_image = function(path)
  local wand = lib.NewMagickWand()
  if 0 == lib.MagickReadImage(wand, path) then
    local code, msg = get_exception(wand)
    lib.DestroyMagickWand(wand)
    return nil, msg, code
  end
  return Image(wand, path)
end
local constitute_image
constitute_image = function(w, h, map, storage_type, pixels)
	local wand = lib.NewMagickWand()
	if 0 == lib.MagickConstituteImage(wand, w, h, map, storage_type_op[storage_type], pixels) then
		local code, msg = get_exception(wand)
		lib.DestroyMagickWand(wand)
		return nil, msg, code
	end
	return Image(wand)
end
local load_image_from_blob
load_image_from_blob = function(blob)
  local wand = lib.NewMagickWand()
  if 0 == lib.MagickReadImageBlob(wand, blob, #blob) then
    local code, msg = get_exception(wand)
    lib.DestroyMagickWand(wand)
    return nil, msg, code
  end
  return Image(wand, "<from_blob>")
end
local tonumber = tonumber
local parse_size_str
parse_size_str = function(str, src_w, src_h)
  local w, h, rest = str:match("^(%d*%%?)x(%d*%%?)(.*)$")
  if not w then
    return nil, "failed to parse string (" .. tostring(str) .. ")"
  end
  do
    local p = w:match("(%d+)%%")
    if p then
      w = tonumber(p) / 100 * src_w
    else
      w = tonumber(w)
    end
  end
  do
    local p = h:match("(%d+)%%")
    if p then
      h = tonumber(p) / 100 * src_h
    else
      h = tonumber(h)
    end
  end
  local center_crop = rest:match("#") and true
  local crop_x, crop_y = rest:match("%+(%d+)%+(%d+)")
  if crop_x then
    crop_x = tonumber(crop_x)
    crop_y = tonumber(crop_y)
  else
    if w and h and not center_crop then
      if not (rest:match("!")) then
        if src_w / src_h > w / h then
          h = nil
        else
          w = nil
        end
      end
    end
  end
  return {
    w = w,
    h = h,
    crop_x = crop_x,
    crop_y = crop_y,
    center_crop = center_crop
  }
end
local thumb
thumb = function(img, size_str, output)
  if type(img) == "string" then
    img = assert(load_image(img))
  end
  local src_w, src_h = img:get_width(), img:get_height()
  local opts = parse_size_str(size_str, src_w, src_h)
  if opts.center_crop then
    img:resize_and_crop(opts.w, opts.h)
  elseif opts.crop_x then
    img:crop(opts.w, opts.h, opts.crop_x, opts.crop_y)
  else
    img:resize(opts.w, opts.h)
  end
  local ret
  if output then
    ret = img:write(output)
  else
    ret = img:get_blob()
  end
  img:destroy()
  return ret
end
return {
  load_image = load_image,
  load_image_from_blob = load_image_from_blob,
  constitute_image = constitute_image,
  thumb = thumb,
  Image = Image,
  parse_size_str = parse_size_str,
  VERSION = VERSION
}
