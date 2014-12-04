local ffi = require("ffi")
local magick = require("magick")

ffi.cdef[[

	/*---------------------------------------------------------------------------------------*/
	/*											                                              */
	/*								        	Types                                         */
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
	    int  	nSize;             			/* sizeof(IplImage) */
	    int  	ID;                			/* version (=0)*/
	    int  	nChannels;         			/* Most of OpenCV functions support 1,2,3 or 4 channels */
	    int  	alphaChannel;      			/* Ignored by OpenCV */
	    int  	depth;             			/* Pixel depth in bits: IPL_DEPTH_8U, IPL_DEPTH_8S, IPL_DEPTH_16S,
	                              				 IPL_DEPTH_32S, IPL_DEPTH_32F and IPL_DEPTH_64F are supported.  */
	    char 	colorModel[4];     			/* Ignored by OpenCV */
	    char 	channelSeq[4];     			/* ditto */
	    int  	dataOrder;         			/* 0 - interleaved color channels, 1 - separate color channels.
	                               				cvCreateImage can only create interleaved images */
	    int  	origin;            			/* 0 - top-left origin,
	                               				1 - bottom-left origin (Windows bitmaps style).  */
	    int  	align;             			/* Alignment of image rows (4 or 8).
	                               				OpenCV ignores it and uses widthStep instead.    */
	    int  	width;             			/* Image width in pixels.                            */
	    int  	height;            			/* Image height in pixels.                           */
	    struct 	_IplROI *roi;				/* Image ROI. If NULL, the whole image is selected.  */
	    struct	_IplImage *maskROI;			/* Must be NULL. */
	    void*	imageId;					/* "           " */
	    struct 	_IplTileInfo *tileInfo;  	/* "           " */
	    int  	imageSize;         			/* Image data size in bytes
	                               				(==image->height*image->widthStep
	                               				in case of interleaved data)*/
	    char*	imageData;        			/* Pointer to aligned image data.         */
	    int  	widthStep;         			/* Size of aligned image row in bytes.    */
	    int  	BorderMode[4];     			/* Ignored by OpenCV.                     */
	    int  	BorderConst[4];    			/* Ditto.                                 */
	    char*	imageDataOrigin;  			/* Pointer to very origin of image data
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
	
	
	/*---------------------------------------------------------------------------------------*/
	/*											                                              */
	/*								        	Functions                                     */
	/*                                                                                       */
	/*---------------------------------------------------------------------------------------*/
	
	int sprintf(char *str, const char *format, ...);
	
	CvMat* cvCreateMat(int rows, int cols, int type);
	
	IplImage* cvLoadImage( const char* filename, int iscolor);
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
	
	void cvRectangle(	CvArr* img, 
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
				
	void cvCopy(const CvArr* src, CvArr* dst, const CvArr* mask);
	void cvSetImageROI(IplImage* image, CvRect rect);
	void cvSetZero(CvArr* arr);
	IplImage* cvCreateImage(CvSize size, int depth, int channels);
]]
 
local cvCore, cvHighgui = ffi.load("libopencv_core.dylib"), ffi.load("libopencv_highgui.dylib")

local image_depth = {
	
	["IPL_DEPTH_8U"] = 8,
	["IPL_DEPTH_8S"] = 0x80000008,
	["IPL_DEPTH_16S"] = 0x80000010,
	["IPL_DEPTH_32S"] = 0x80000020,
	["IPL_DEPTH_32F"] = 32,
	["IPL_DEPTH_64F"] = 64,
	
  ["UndefinedPixel"] = 0,
  ["CharPixel"] = 1,
  ["DoublePixel"] = 2,
  ["FloatPixel"] = 3,
  ["IntegerPixel"] = 4,
  ["LongPixel"] = 5,
  ["QuantumPixel"] = 6,
  ["ShortPixel"] = 7,
}

local iplImage_to_magickImage = {
    ["columns"] = 0,
    ["rows"] = 0,
	["storageType"] = "",
	["map"] = "",
	["pixels"] = nil,
}

local function printf(...)
	print(string.format(...))
end


--local function imageCut(src, desX, desY, width, height, radius)
--
--	local mask = cvCore.cvCreateMat(src.height, src.width, 16)
--	local scalar = ffi.new("CvScalar", {val={255,255,255,0}})
--	local lineType = 16; --CV_AA 抗锯齿
--		
--	-- filter input
--	local desWidth = width > 0 and (width > src.width and src.width or width) or 0;
--	local desHeight = height > 0 and (height > src.height and src.height or height) or 0;
--	
--	local topLeftX = desX > 0 and ((desX + desWidth) > src.width and (src.width - desWidth) or desX) or 0;
--	local topLeftY = desY > 0 and ((desY + desHeight) > src.height and (src.height - desHeight) or desY) or 0;
--	
--	local desRadius = radius > 0 and radius or 0;
--	
--	if (desWidth >= desHeight) then
--		desRadius = (desRadius > desHeight / 2) and (desHeight / 2) or desRadius;
--	else
--		desRadius = (desRadius > desWidth / 2) and (desWidth / 2) or desRadius;
--	end
--
--
--	if (desRadius == 0) then
--			
--		cvHighgui.cvRectangle(	mask, 
--								ffi.new("CvPoint", {x=desX,y=desY}), 
--								ffi.new("CvPoint", {x=desX+desWidth,y=desY+desHeight}), 
--								scalar, -1, 8, 0);
--			
--	else
--			
--	-- draw straight lines
--	
--	cvHighgui.cvLine(	mask, 
--						ffi.new("CvPoint", {x = topLeftX + desRadius, y = topLeftY}), 
--						ffi.new("CvPoint", {x = topLeftX + desWidth - desRadius, y = topLeftY}), 
--						scalar, 0, 8, 0)
--	cvHighgui.cvLine(	mask, 
--						ffi.new("CvPoint", {x = topLeftX + desWidth, y = topLeftY + desRadius}), 
--						ffi.new("CvPoint", {x = topLeftX + desWidth, y = topLeftY + desHeight - desRadius}), 
--						scalar, 0, 8, 0)
--	cvHighgui.cvLine(	mask, 
--						ffi.new("CvPoint", {x = topLeftX + desRadius, y = topLeftY + desHeight}), 
--						ffi.new("CvPoint", {x = topLeftX + desWidth - desRadius, y = topLeftY + desHeight}), 
--						scalar, 0, 8, 0)
--	cvHighgui.cvLine(	mask, 
--						ffi.new("CvPoint", {x = topLeftX, y = topLeftY + desRadius}), 
--						ffi.new("CvPoint", {x = topLeftX + desWidth, y = topLeftY + desHeight - desRadius}), 
--						scalar, 0, 8, 0)
--	
--	cvHighgui.cvRectangle(	mask, 
--							ffi.new("CvPoint", {x = topLeftX + desRadius,y = topLeftY - 1}), 
--							ffi.new("CvPoint", {x = topLeftX + desWidth - desRadius,y = topLeftY + desHeight + 1}), 
--							scalar, -1, 8, 0);
--	
--	cvHighgui.cvRectangle(	mask, 
--							ffi.new("CvPoint", {x = topLeftX - 1, y = topLeftY + desRadius}), 
--							ffi.new("CvPoint", {x=topLeftX + desWidth + 1, y = topLeftY + desHeight - desRadius}), 
--							scalar, -1, 8, 0);
--		
--	-- draw arcs
--	
--	cvHighgui.cvEllipse(	mask,
--							ffi.new("CvPoint", {x = topLeftX + desRadius, y = topLeftY + desRadius}),
--							ffi.new("CvSize", {width = desRadius, height = desRadius}),
--							360, 180, 270, scalar, -1, 16, 0)
--	cvHighgui.cvEllipse(	mask,
--							ffi.new("CvPoint", {x = topLeftX + desWidth - desRadius, y = topLeftY + desRadius}),
--							ffi.new("CvSize", {width = desRadius, height = desRadius}),
--							360, 270, 360, scalar, -1, 16, 0)
--	cvHighgui.cvEllipse(	mask,
--							ffi.new("CvPoint", {x = topLeftX + desWidth - desRadius, y = topLeftY + desHeight - desRadius}),
--							ffi.new("CvSize", {width = desRadius, height = desRadius}),
--							360, 0, 90, scalar, -1, 16, 0)
--	cvHighgui.cvEllipse(	mask,
--							ffi.new("CvPoint", {x = topLeftX + desRadius, y = topLeftY + desHeight - desRadius}),
--							ffi.new("CvSize", {width = desRadius, height = desRadius}),
--							360, 180, 90, scalar, -1, 16, 0)
--	end
--		
--	
--	local dst = cvHighgui.cvCreateImage(ffi.new("CvSize", {width = src.width, height = src.height}), src.depth, src.nChannels)
--	cvHighgui.cvCopy(src, dst, mask)
--	cvHighgui.cvSetImageROI(dst, ffi.new("CvRect", {x=topLeftX,y=topLeftY,width=desWidth,height=desHeight}))
--	return dst
--end



local function image_cut(src, desX, desY, width, height, radius)

	local scalar = ffi.new("CvScalar", {val={255,255,255,0}})
	local lineType = 16; --CV_AA 抗锯齿
		
	-- filter input
	local desWidth = width > 0 and (width > src.width and src.width or width) or 0;
	local desHeight = height > 0 and (height > src.height and src.height or height) or 0;
	
	local topLeftX = desX > 0 and ((desX + desWidth) > src.width and (src.width - desWidth) or desX) or 0;
	local topLeftY = desY > 0 and ((desY + desHeight) > src.height and (src.height - desHeight) or desY) or 0;
	
	local desRadius = radius > 0 and radius or 0;
	
	if (desWidth >= desHeight) then
		desRadius = (desRadius > desHeight / 2) and (desHeight / 2) or desRadius;
	else
		desRadius = (desRadius > desWidth / 2) and (desWidth / 2) or desRadius;
	end


	cvHighgui.cvSetImageROI(src, ffi.new("CvRect", {x=topLeftX,y=topLeftY,width=desWidth,height=desHeight}))

	local mask = cvCore.cvCreateMat(desHeight, desWidth, 16)

	if (desRadius == 0) then
			
		cvHighgui.cvRectangle(	mask, 
								ffi.new("CvPoint", {x=0,y=0}), 
								ffi.new("CvPoint", {x=desWidth,y=desHeight}), 
								scalar, -1, 8, 0);
			
	else
			
	-- draw straight lines
	
	cvHighgui.cvLine(	mask, 
						ffi.new("CvPoint", {x = desRadius, y = 0}), 
						ffi.new("CvPoint", {x = desWidth - desRadius, y = 0}), 
						scalar, 0, 8, 0)
	cvHighgui.cvLine(	mask, 
						ffi.new("CvPoint", {x = desWidth, y = desRadius}), 
						ffi.new("CvPoint", {x = desWidth, y = desHeight - desRadius}), 
						scalar, 0, 8, 0)
	cvHighgui.cvLine(	mask, 
						ffi.new("CvPoint", {x = desRadius, y = desHeight}), 
						ffi.new("CvPoint", {x = desWidth - desRadius, y = desHeight}), 
						scalar, 0, 8, 0)
	cvHighgui.cvLine(	mask, 
						ffi.new("CvPoint", {x = 0, y = desRadius}), 
						ffi.new("CvPoint", {x = desWidth, y = desHeight - desRadius}), 
						scalar, 0, 8, 0)
	
	cvHighgui.cvRectangle(	mask, 
							ffi.new("CvPoint", {x = desRadius,y = 0}), 
							ffi.new("CvPoint", {x = desWidth - desRadius, y = desHeight}), 
							scalar, -1, 8, 0);
	
	cvHighgui.cvRectangle(	mask, 
							ffi.new("CvPoint", {x = 0, y = desRadius}), 
							ffi.new("CvPoint", {x = desWidth, y = desHeight - desRadius}), 
							scalar, -1, 8, 0);
		
	-- draw arcs
	
	cvHighgui.cvEllipse(	mask,
							ffi.new("CvPoint", {x = desRadius, y = desRadius}),
							ffi.new("CvSize", {width = desRadius, height = desRadius}),
							360, 180, 270, scalar, -1, 16, 0)
	cvHighgui.cvEllipse(	mask,
							ffi.new("CvPoint", {x = desWidth - desRadius, y = desRadius}),
							ffi.new("CvSize", {width = desRadius, height = desRadius}),
							360, 270, 360, scalar, -1, 16, 0)
	cvHighgui.cvEllipse(	mask,
							ffi.new("CvPoint", {x = desWidth - desRadius, y = desHeight - desRadius}),
							ffi.new("CvSize", {width = desRadius, height = desRadius}),
							360, 0, 90, scalar, -1, 16, 0)
	cvHighgui.cvEllipse(	mask,
							ffi.new("CvPoint", {x = desRadius, y = desHeight - desRadius}),
							ffi.new("CvSize", {width = desRadius, height = desRadius}),
							360, 180, 90, scalar, -1, 16, 0)
	end
		
	
	local dst = cvHighgui.cvCreateImage(ffi.new("CvSize", {width = desWidth, height = desHeight}), src.depth, src.nChannels)
	cvHighgui.cvCopy(src, dst, mask)
	cvHighgui.cvSetImageROI(dst, ffi.new("CvRect", {x=topLeftX,y=topLeftY,width=desWidth,height=desHeight}))
	return dst
end


local function iplImage_to_magickImage_op(iplImage)

	local storageTypeTrans
	
	if iplImage.depth == image_depth["IPL_DEPTH_8U"] then
		storageTypeTrans = "CharPixel"
	elseif iplImage.depth == image_depth["IPL_DEPTH_8S"] then
		storageTypeTrans = "ShortPixel"
	elseif iplImage.depth == image_depth["IPL_DEPTH_16S"] then
		storageTypeTrans = "IntegerPixel"
	elseif iplImage.depth == image_depth["IPL_DEPTH_32S"] then
		storageTypeTrans = "LongPixel"
	elseif iplImage.depth == image_depth["IPL_DEPTH_32F"] then
		storageTypeTrans = "FloatPixel"
	elseif iplImage.depth == image_depth["IPL_DEPTH_64F"] then
		storageTypeTrans = "DoublePixel"
	else
		storageTypeTrans = "UndefinedPixel"
	end
								
								
	iplImage_to_magickImage["columns"] = iplImage.width
	iplImage_to_magickImage["rows"] = iplImage.height
	iplImage_to_magickImage["storageType"] = storageTypeTrans
	iplImage_to_magickImage["map"] = string.format("%c%c%c%c", iplImage.colorModel[2], iplImage.colorModel[1], iplImage.colorModel[0], iplImage.colorModel[3])
	iplImage_to_magickImage["pixels"] = iplImage.imageData
								
	return iplImage_to_magickImage
end


local im = cvHighgui.cvLoadImage("files/test_1.jpg", 1)
--local resImage = image_cut(im, 100, 100, 1500, 1500, 500)
--
--
--local a = cvHighgui.cvSaveImage("files/test_save1.jpg", resImage, "1\01\00\0")
--local aa = cvHighgui.cvSaveImage("files/test_save50.jpg", resImage, ffi.new("int[3]",{1, 50, 0}))
--local aaa = cvHighgui.cvSaveImage("files/test_save100.jpg", resImage, ffi.new("int[3]",{1, 100, 0}))

--local transed = iplImage_to_magickImage_op(resImage)
--
--local img = magick.constitute_image(transed["columns"], transed["rows"], transed["map"], transed["storageType"], transed["pixels"])
--print("width:", img:get_width(), "\nheight:", img:get_height(), "\nmap:", transed["map"], "\nstorageType:", transed["storageType"]);
--img:write("resized.png")
--img:destroy()
