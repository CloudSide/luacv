local ffi = require("ffi")
local cvCore, cvHighgui = ffi.load("opencv_core"), ffi.load("opencv_highgui")

ffi.cdef[[

	/*---------------------------------------------------------------------------------------*/
	/*											                                             */
	/*											Types                                        */
	/*                                                                                       */
	/*---------------------------------------------------------------------------------------*/

	typedef unsigned char uchar;
	
	typedef struct CvMat {
	    int type;
	    int step;
	    /* for internal use only */
	    int* refcount;
	    int hdr_refcount;
	    union {
	        uchar* ptr;
	        short* s;
	        int* i;
	        float* fl;
	        double* db;
	    } data;
	    int rows;
	    int cols;
	} CvMat;
	
	typedef struct _IplImage {
	    int		nSize;						/* sizeof(IplImage) */
	    int		ID;							/* version (=0)*/
	    int		nChannels;					/* Most of OpenCV functions support 1,2,3 or 4 channels */
	    int		alphaChannel;				/* Ignored by OpenCV */
	    int		depth;						/* Pixel depth in bits: IPL_DEPTH_8U, IPL_DEPTH_8S, IPL_DEPTH_16S,
											   IPL_DEPTH_32S, IPL_DEPTH_32F and IPL_DEPTH_64F are supported.  */
	
	    char	colorModel[4];				/* Ignored by OpenCV */
	    char	channelSeq[4];				/* ditto */
	    int		dataOrder;					/* 0 - interleaved color channels, 1 - separate color channels.
											cvCreateImage can only create interleaved images */
	
	    int		origin;						/* 0 - top-left origin,
											1 - bottom-left origin (Windows bitmaps style).  */
	
	    int		align;						/* Alignment of image rows (4 or 8).
											OpenCV ignores it and uses widthStep instead.    */
	
	    int		width;						/* Image width in pixels.                            */
	    int		height;						/* Image height in pixels.                           */
	    struct	_IplROI *roi;				/* Image ROI. If NULL, the whole image is selected.  */
	    struct	_IplImage *maskROI;			/* Must be NULL. */
	    void*	imageId;						/* "           " */
	    struct	_IplTileInfo *tileInfo;		/* "           " */
	    int		imageSize;					/* Image data size in bytes
											(==image->height*image->widthStep
											in case of interleaved data)*/
	
	    char*	imageData;					/* Pointer to aligned image data.         */
	    int		widthStep;					/* Size of aligned image row in bytes.    */
	    int		BorderMode[4];				/* Ignored by OpenCV.                     */
	    int		BorderConst[4];				/* Ditto.                                 */
	    char*	imageDataOrigin;			/* Pointer to very origin of image data
											(not necessarily aligned) -
											needed for correct deallocation */
	} IplImage;
	
	typedef void CvArr;
	
	typedef struct CvPoint {
	    int x;
	    int y;
	} CvPoint;
	
	typedef struct CvRect {
	    int x;
	    int y;
	    int width;
	    int height;
	} CvRect;
	
	typedef struct CvSize {
	    int width;
	    int height;
	} CvSize;
	
	typedef struct CvScalar {
	    double val[4];
	} CvScalar;
	
	
	/*--------------------------------------------------------------------------------------*/
	/*											                                            */
	/*											Functions                                   */
	/*                                                                                      */
	/*--------------------------------------------------------------------------------------*/
	
	int sprintf(char *str, const char *format, ...);
	
	CvMat* cvCreateMat(int rows, int cols, int type);
	
	IplImage* cvLoadImage( const char* filename, int iscolor);
	CvMat* cvLoadImageM( const char* filename, int iscolor);
	int cvSaveImage(const char* filename, const CvArr* image, const int* params);

	void cvEllipse(	CvArr* img, 
					CvPoint center, 
					CvSize axes, 
					double angle, 
					double start_angle, 
					double end_angle, 
					CvScalar color, 
					int thickness, 
					int line_type, 
					int shift);
	
	void cvRectangle(CvArr* img, 
					 CvPoint pt1, 
					 CvPoint pt2, 
					 CvScalar color, 
					 int thickness, 
					 int line_type, 
					 int shift);
						
	void cvLine(CvArr* img, 
				CvPoint pt1, 
				CvPoint pt2, 
				CvScalar color, 
				int thickness, 
				int line_type, 
				int shift);
	
	void cvReleaseImage(IplImage** image);
	void cvCopy(const CvArr* src, CvArr* dst, const CvArr* mask);
	void cvSetImageROI(IplImage* image, CvRect rect);
	void cvSetZero(CvArr* arr);
	IplImage* cvCreateImage(CvSize size, int depth, int channels);
]]
 
local _M = {
	_VERSION = '0.1.0',
}

local mt = { __index = _M }

function _M.CV(self, cv_image)
	return setmetatable({ cv_image = cv_image }, mt)
end

local iscolor_op = {
	['UNCHANGED'] = -1, --[[8bit, color or not]]
	['GRAYSCALE'] = 0,	--[[8bit, gray ]]
	['COLOR'] = 1,		--[[?, color]]
	['ANYDEPTH'] = 2,	--[[]ny depth, ?]]
	['ANYCOLOR'] = 4,	--[[?, any color]]
}

local save_op = {
	['JPEG_QUALITY'] = 1,
	['PNG_COMPRESSION'] = 16,
}

local line_type_op = {
	['CONNECTION_4'] = 4,
	['CONNECTION_8'] = 8,
	['CV_AA'] = 16,
}

local function cv_rect(x, y, w, h)
	return ffi.new("CvRect", {
		x = x or 0,
		y = y or 0, 
		width = w or 0, 
		height = h or 0,
	})
end

local function cv_point(x, y)
	return ffi.new("CvPoint", {
		x = x or 0,
		y = y or 0,
	})
end

local function cv_scalar(r, g, b, a)
	r = r or 255
	g = g or 255
	b = b or 255
	a = a or 1
	return ffi.new("CvScalar", {
		val = {b, g, r, a}
	})
end

local cv_color = cv_scalar

local function cv_size(w, h)
	return ffi.new("CvSize", {
		width = w or 0,
		height = h or 0,
	})
end

--[[ +++++++++++++++++++++++++++++++++++++++++++++++ ]]

function _M.load_image(filename, iscolor)
	if not iscolor then
		iscolor = 'UNCHANGED' 
	end
	local iscolor_val = iscolor_op[iscolor] or iscolor_op['UNCHANGED']
	local cv_image = cvHighgui.cvLoadImage(filename, iscolor_val)
	return _M:CV(cv_image)
end

function _M.save_image(self, filename, opt)
	local opt_val = nil
	if opt then
		if opt['JPEG_QUALITY'] and tonumber(opt['JPEG_QUALITY']) and tonumber(opt['JPEG_QUALITY']) >= 0 and tonumber(opt['JPEG_QUALITY']) <= 100 then
			opt_val = ffi.new("int[3]", {save_op['JPEG_QUALITY'], opt['JPEG_QUALITY'], 0})
		elseif opt['PNG_COMPRESSION'] and tonumber(opt['PNG_COMPRESSION']) and tonumber(opt['PNG_COMPRESSION']) >= 0 and tonumber(opt['PNG_COMPRESSION']) <= 9  then
			opt_val = ffi.new("int[3]", {save_op['PNG_COMPRESSION'], opt['PNG_COMPRESSION'], 0})
		end
	end
	if 1 == cvHighgui.cvSaveImage(filename, self.cv_image, opt_val) then
		return true
	else
		return error("Failed to save image to " .. filename)
	end
end

function _M.get_size(self)
	if not self.cv_image then
		return 0, 0
	else
		return self.cv_image.width, self.cv_image.height
	end
end

function _M.set_image_roi(self, x, y, w, h)
	local rect = cv_rect(x, y, w, h)
	return cvHighgui.cvSetImageROI(self.cv_image, rect)
end

function _M.line(self, x1, y1, x2, y2, scalar, thickness, line_type, shift)

	if not self.cv_image then
		return error("Failed to draw line on image")
	else
		local point1 = cv_point(x1, y1)
		local point2 = cv_point(x2, y2)
		
		local color
		if scalar then
			color = cv_scalar(scalar[1], scalar[2], scalar[3], scalar[4])
		else
			color = cv_scalar(255, 255, 255, 1)
		end
		
		if not thickness then
			thickness = 1
		end
		
		if not line_type then
			line_type = 'CONNECTION_8'
		end
		
		local line_type_val = line_type_op[line_type] or line_type_op['CONNECTION_8']
		
		if not shift then
			shift = 0 
		end
		
		return cvHighgui.cvLine(self.cv_image, point1, point2, color, thickness, line_type_val, shift)
	end
end

function _M.release_image(self)
	local pointer = ffi.new("IplImage *[1]")
	pointer[0] = self.cv_image
	return cvHighgui.cvReleaseImage(pointer)
end
					
function _M.rectangle(self, x1, y1, x2, y2, scalar, thickness, line_type, shift)

	if not self.cv_image then
		return error("Failed to draw rectangle on image")
	else
		local point1 = cv_point(x1, y1)
		local point2 = cv_point(x2, y2)
		
		local color
		if scalar then
			color = cv_scalar(scalar[1], scalar[2], scalar[3], scalar[4])
		else
			color = cv_scalar(255, 255, 255, 1)
		end
		
		if not thickness then
			thickness = 1
		end
		
		if not line_type then
			line_type = 'CONNECTION_8'
		end
		
		local line_type_val = line_type_op[line_type] or line_type_op['CONNECTION_8']
		
		if not shift then
			shift = 0 
		end
		
		return cvHighgui.cvRectangle(self.cv_image, point1, point2, color, thickness, line_type_val, shift)
	end
end

return _M


