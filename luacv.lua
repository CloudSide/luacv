local ffi = require("ffi")
local cvCore, cvHighgui, cvImgproc = ffi.load("opencv_core"), ffi.load("opencv_highgui"), ffi.load("opencv_imgproc")

ffi.cdef[[

	/*---------------------------------------------------------------------------------------*/
	/*											                                             */
	/*											Types                                        */
	/*                                                                                       */
	/*---------------------------------------------------------------------------------------*/

	typedef unsigned char uchar;
	typedef signed char schar;
	
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
	
	
	/* Font structure */
	typedef struct CvFont {
		const char* nameFont;   		//Qt:nameFont
		CvScalar color;       		//Qt:ColorFont -> cvScalar(blue_component, green_component, red\_component[, alpha_component])
		int         font_face;   		//Qt: bool italic         /* =CV_FONT_* */
		const int*  ascii;      		/* font data and metrics */
		const int*  greek;
		const int*  cyrillic;
		float       hscale, vscale;
		float       shear;      		/* slope coefficient: 0 - normal, >0 - italic */
		int         thickness;    	//Qt: weight               /* letters thickness */
		float       dx;       		/* horizontal interval between letters */
		int         line_type;    	//Qt: PointSize
	} CvFont;
	
	
	/****************************************************************************************\
	*                                   Dynamic Data structures                              *
	\****************************************************************************************/

	/******************************** Memory storage ****************************************/

	typedef struct CvMemBlock {
	    struct CvMemBlock*  prev;
	    struct CvMemBlock*  next;
	} CvMemBlock;

	typedef struct CvMemStorage {
	    int signature;
	    CvMemBlock* bottom;           /* First allocated block.                   */
	    CvMemBlock* top;              /* Current memory block - top of the stack. */
	    struct  CvMemStorage* parent; /* We get new blocks from parent as needed. */
	    int block_size;               /* Block size.                              */
	    int free_space;               /* Remaining free space in current block.   */
	} CvMemStorage;
	
	typedef struct CvMemStoragePos {
	    CvMemBlock* top;
	    int free_space;
	} CvMemStoragePos;
	
	
	/*********************************** Sequence *******************************************/

	typedef struct CvSeqBlock {
		
		struct CvSeqBlock*  prev; 	/* Previous sequence block.                   */
		struct CvSeqBlock*  next; 	/* Next sequence block.                       */
		int start_index;				/* Index of the first element in the block +  */
	                              	/* sequence->first->start_index.              */
		int count;             		/* Number of elements in the block.           */
		schar* data;              	/* Pointer to the first element of the block. */
	} CvSeqBlock;


	/*
	   Read/Write sequence.
	   Elements can be dynamically inserted to or deleted from the sequence.
	*/

	typedef struct CvSeq {
		int       flags;             /* Miscellaneous flags.     */      
		int       header_size;       /* Size of sequence header. */      
		struct    CvSeq* h_prev; 		/* Previous sequence.       */      
		struct    CvSeq* h_next; 		/* Next sequence.           */      
		struct    CvSeq* v_prev; 		/* 2nd previous sequence.   */    
		struct    CvSeq* v_next;  	/* 2nd next sequence.       */
		                                        
		int       total;          	/* Total number of elements.            */  
		int       elem_size;      	/* Size of sequence element in bytes.   */  
		schar*    block_max;    	  	/* Maximal bound of the last block.     */ 
		schar*    ptr;          	  	/* Current write pointer.               */  
		int       delta_elems;    	/* Grow seq this many at a time.        */  
		CvMemStorage* storage;    	/* Where the seq is stored.             */  
		CvSeqBlock* free_blocks;  	/* Free blocks list.                    */  
		CvSeqBlock* first;        	/* Pointer to the first sequence block. */
	} CvSeq;

	
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
	void cvReleaseMat(CvMat** mat);
	void cvCopy(const CvArr* src, CvArr* dst, const CvArr* mask);
	void cvSetImageROI(IplImage* image, CvRect rect);
	void cvSetZero(CvArr* arr);
	IplImage* cvCreateImage(CvSize size, int depth, int channels);
	void cvResetImageROI( IplImage* image );
	IplImage* cvCloneImage(const IplImage* image);
	
	/* Renders text stroke with specified font and color at specified location.
	   CvFont should be initialized with cvInitFont */
	void cvPutText( CvArr* img, const char* text, CvPoint org,
	                const CvFont* font, CvScalar color );
	
	/* Initializes font structure used further in cvPutText */
	void cvInitFont( CvFont* font, int font_face,
	                 double hscale, double vscale,
	                 double shear,
	                 int thickness,
	                 int line_type);
	
	/* Resizes image (input array is resized to fit the destination array) */
	void cvResize(const CvArr* src, CvArr* dst, int interpolation);
	
	/* dst = src1 * alpha + src2 * beta + gamma */
	void cvAddWeighted( const CvArr* src1, double alpha,
	                    const CvArr* src2, double beta,
	                    double gamma, CvArr* dst );
	
	/* Mirror array data around horizontal (flip=0),
	   vertical (flip=1) or both(flip=-1) axises:
	   cvFlip(src) flips images vertically and sequences horizontally (inplace) */
	void cvFlip(const CvArr* src, CvArr* dst, int flip_mode);
	
	void* cvLoad( const char* filename,
	              CvMemStorage* memstorage,
	              const char* name,
	              const char** real_name );
	
	void cvCvtColor( const CvArr* src, CvArr* dst, int code );
	
	void cvEqualizeHist( const CvArr* src, CvArr* dst );
	
	CvMemStorage* cvCreateMemStorage( int block_size );
	
	void cvReleaseMemStorage( CvMemStorage** storage );
	
	schar* cvGetSeqElem( const CvSeq* seq, int index );
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

local font_face_op = {
	["HERSHEY_SIMPLEX"] = 0,
	["HERSHEY_PLAIN"] = 1,
	["HERSHEY_DUPLEX"] = 2,
	["HERSHEY_COMPLEX"] = 3,
	["HERSHEY_TRIPLEX"] = 4,
	["HERSHEY_COMPLEX_SMALL"] = 5,
	["HERSHEY_SCRIPT_SIMPLEX"] = 6,
	["HERSHEY_SCRIPT_COMPLEX"] = 7,
	["ITALIC"] = 16,
}

local interpolation_op = {
	["INTER_NN"] = 0,
	["INTER_LINEAR"] = 1,
	["INTER_CUBIC"] = 2,
	["INTER_AREA"] = 3,
	["INTER_LANCZOS4"] = 4,
}

local flip_mode_op = {
	["V_FLIP"] = 0,
	["H_FLIP"] = 1,
	["VH_FLIP"] = -1,
}

local resize_mode_op = {
	["RESIZE_SCALE"] = 0, --default
	["RESIZE_FIT"] = 1,
	["RESIZE_MFIT"] = 2,
	["RESIZE_LIMIT"] = 3,
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

local function cv_create_mat(rows, cols, type)
	rows = rows or 1
	cols = cols or 1
	type = type or 8
	return cvCore.cvCreateMat(rows, cols, type)
end

local function cv_release_mat(mat)
	local pointer = ffi.new("CvMat *[1]")
	pointer[0] = mat
	return cvCore.cvReleaseImage(pointer)
end

local function cv_create_image(w, h, depth, channels)
	return cvCore.cvCreateImage(cv_size(w, h), depth, channels)
end

local function cv_release_image(image)
	local pointer = ffi.new("IplImage *[1]")
	pointer[0] = image
	return cvCore.cvReleaseImage(pointer)
end

local function cv_copy(src, dst, mask)
	return cvCore.cvCopy(src, dst, mask)
end

local function cv_reset_image_roi(image)
	return cvHighgui.cvResetImageROI(image)
end

local function cv_set_zero(arr)
	return cvCore.cvSetZero(arr)
end

local function cv_clone_image(image)
	return cvCore.cvCloneImage(image)
end

local function cv_init_font(font_face, hscale, vscale, shear, thickness, line_type)
	if not font_face then
		font_face = "HERSHEY_SIMPLEX"
	end
	local font_face_val = font_face_op[font_face] or font_face_op["HERSHEY_SIMPLEX"]
	hscale = hscale or 1
	vscale = vscale or 1
	shear = shear or 0
	thickness = thickness or 1
	if not line_type then
		line_type = 'CONNECTION_8'
	end
	local line_type_val = line_type_op[line_type] or line_type_op['CONNECTION_8']
	local font = ffi.new("CvFont[1]")
	cvCore.cvInitFont(font, font_face_val, hscale, vscale, shear, thickness, line_type_val)
	return font
end

--[[ org & color should use function cv_point() & cv_scalar() ]]
local function cv_put_text(img, text, org, font, color)
	return cvCore.cvPutText(img, text, org, font, color)
end

local function cv_resize(src, dst, interpolation)
	if not interpolation then
		interpolation = "INTER_LINEAR"
	end
	local interpolation_val = interpolation_op[interpolation] or interpolation_op["INTER_LINEAR"]
	return cvImgproc.cvResize(src, dst, interpolation_val)
end

--[[ /* dst = src1 * alpha + src2 * beta + gamma */ ]]
local function cv_add_weighted(src1, alpha, src2, beta, gamma, dst)
	return cvCore.cvAddWeighted(src1, alpha, src2, beta, gamma, dst)
end

--[[ V_FLIP | H_FLIP | VH_FLIP ]]
local function cv_flip(src, dst, flip_mode)
	if not flip_mode then
		flip_mode = "V_FLIP"
	end
	local flip_mode_val = flip_mode_op[flip_mode] or flip_mode_op["V_FLIP"]
	return cvFlip(src, dst, flip_mode_val)
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

function _M.clone_image(self)
	return _M:CV(cv_clone_image(self.cv_image))
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
	return cv_release_image(self.cv_image)
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

function _M.ellipse(self, x1, y1, w, h, angle, start_angle, end_angle, scalar, thickness, line_type, shift)

	if not self.cv_image then
		return error("Failed to draw ellipse on image")
	else
		local point1 = cv_point(x1, y1)
		local size = cv_size(w, h)
		
		if not angle then
			angle = 360
		end
		
		if not start_angle then
			start_angle = 0
		end
		
		if not end_angle then
			end_angle = 360
		end
		
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
		
		return cvHighgui.cvEllipse(self.cv_image, point1, size, angle, start_angle, end_angle, color, thickness, line_type_val, shift)
	end
end

function _M.resize(self, w, h, mode)
	
	if not self.cv_image then
		return error("Failed to scale image")
	else
		local o_w = self.cv_image.width
		local o_h = self.cv_image.height
		
		w = w or 0
		h = h or 0
		
		local n_w
		local n_h
		if w <= 0 then
			if h <= 0 then
				n_w = o_w
				n_h = o_h
			else
				n_h = h
				n_w = o_w*n_h/o_h
			end
		else
			if h <= 0 then
				n_w = w
				n_h = n_w*o_h/o_w
			else
				n_w = w
				n_h = h
			end
		end

		
		if not mode then
			mode = 'RESIZE_SCALE'
		end
				
		
		local dst
		
		if n_w == o_w and n_h == o_h then
			dst = cv_clone_image()
		else
			if mode == 'RESIZE_SCALE' then
				
			elseif mode == 'RESIZE_FIT' then
				
				if o_w/o_h > n_w/n_h then
					n_h = n_w*o_h/o_w
				else
					n_w = o_w*n_h/o_h
				end
				
			elseif mode == 'RESIZE_MFIT' then
				
				if o_w/o_h > n_w/n_h then
					if n_w < o_w then n_w = o_w end
					n_h = n_w*o_h/o_w
				else
					if n_h < o_h then n_h = o_h end
					n_w = o_w*n_h/o_h
				end
				
			elseif mode == 'RESIZE_LIMIT' then
				
				if o_w/o_h > n_w/n_h then
					if n_w > o_w then n_w = o_w end
					n_h = n_w*o_h/o_w
				else
					if n_h > o_h then n_h = o_h end
					n_w = o_w*n_h/o_h
				end
				
			end
		
			dst = cv_create_image(n_w, n_h, self.cv_image.depth, self.cv_image.nChannels)
			cv_resize(self.cv_image, dst)
		end	
		
		return _M:CV(dst)
	end
	
end

return _M


