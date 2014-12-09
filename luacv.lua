local ffi = require("ffi")
local cvCore, cvHighgui, cvImgproc, cvObjdetect = 
	ffi.load("opencv_core"), 
	ffi.load("opencv_highgui"), 
	ffi.load("opencv_imgproc"),
	ffi.load("opencv_objdetect")

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
	
	/* Constants for color conversion */
	enum {
	    CV_BGR2BGRA    =0,
	    CV_RGB2RGBA    =CV_BGR2BGRA,

	    CV_BGRA2BGR    =1,
	    CV_RGBA2RGB    =CV_BGRA2BGR,

	    CV_BGR2RGBA    =2,
	    CV_RGB2BGRA    =CV_BGR2RGBA,

	    CV_RGBA2BGR    =3,
	    CV_BGRA2RGB    =CV_RGBA2BGR,

	    CV_BGR2RGB     =4,
	    CV_RGB2BGR     =CV_BGR2RGB,

	    CV_BGRA2RGBA   =5,
	    CV_RGBA2BGRA   =CV_BGRA2RGBA,

	    CV_BGR2GRAY    =6,
	    CV_RGB2GRAY    =7,
	    CV_GRAY2BGR    =8,
	    CV_GRAY2RGB    =CV_GRAY2BGR,
	    CV_GRAY2BGRA   =9,
	    CV_GRAY2RGBA   =CV_GRAY2BGRA,
	    CV_BGRA2GRAY   =10,
	    CV_RGBA2GRAY   =11,

	    CV_BGR2BGR565  =12,
	    CV_RGB2BGR565  =13,
	    CV_BGR5652BGR  =14,
	    CV_BGR5652RGB  =15,
	    CV_BGRA2BGR565 =16,
	    CV_RGBA2BGR565 =17,
	    CV_BGR5652BGRA =18,
	    CV_BGR5652RGBA =19,

	    CV_GRAY2BGR565 =20,
	    CV_BGR5652GRAY =21,

	    CV_BGR2BGR555  =22,
	    CV_RGB2BGR555  =23,
	    CV_BGR5552BGR  =24,
	    CV_BGR5552RGB  =25,
	    CV_BGRA2BGR555 =26,
	    CV_RGBA2BGR555 =27,
	    CV_BGR5552BGRA =28,
	    CV_BGR5552RGBA =29,

	    CV_GRAY2BGR555 =30,
	    CV_BGR5552GRAY =31,

	    CV_BGR2XYZ     =32,
	    CV_RGB2XYZ     =33,
	    CV_XYZ2BGR     =34,
	    CV_XYZ2RGB     =35,

	    CV_BGR2YCrCb   =36,
	    CV_RGB2YCrCb   =37,
	    CV_YCrCb2BGR   =38,
	    CV_YCrCb2RGB   =39,

	    CV_BGR2HSV     =40,
	    CV_RGB2HSV     =41,

	    CV_BGR2Lab     =44,
	    CV_RGB2Lab     =45,

	    CV_BayerBG2BGR =46,
	    CV_BayerGB2BGR =47,
	    CV_BayerRG2BGR =48,
	    CV_BayerGR2BGR =49,

	    CV_BayerBG2RGB =CV_BayerRG2BGR,
	    CV_BayerGB2RGB =CV_BayerGR2BGR,
	    CV_BayerRG2RGB =CV_BayerBG2BGR,
	    CV_BayerGR2RGB =CV_BayerGB2BGR,

	    CV_BGR2Luv     =50,
	    CV_RGB2Luv     =51,
	    CV_BGR2HLS     =52,
	    CV_RGB2HLS     =53,

	    CV_HSV2BGR     =54,
	    CV_HSV2RGB     =55,

	    CV_Lab2BGR     =56,
	    CV_Lab2RGB     =57,
	    CV_Luv2BGR     =58,
	    CV_Luv2RGB     =59,
	    CV_HLS2BGR     =60,
	    CV_HLS2RGB     =61,

	    CV_BayerBG2BGR_VNG =62,
	    CV_BayerGB2BGR_VNG =63,
	    CV_BayerRG2BGR_VNG =64,
	    CV_BayerGR2BGR_VNG =65,

	    CV_BayerBG2RGB_VNG =CV_BayerRG2BGR_VNG,
	    CV_BayerGB2RGB_VNG =CV_BayerGR2BGR_VNG,
	    CV_BayerRG2RGB_VNG =CV_BayerBG2BGR_VNG,
	    CV_BayerGR2RGB_VNG =CV_BayerGB2BGR_VNG,

	    CV_BGR2HSV_FULL = 66,
	    CV_RGB2HSV_FULL = 67,
	    CV_BGR2HLS_FULL = 68,
	    CV_RGB2HLS_FULL = 69,

	    CV_HSV2BGR_FULL = 70,
	    CV_HSV2RGB_FULL = 71,
	    CV_HLS2BGR_FULL = 72,
	    CV_HLS2RGB_FULL = 73,

	    CV_LBGR2Lab     = 74,
	    CV_LRGB2Lab     = 75,
	    CV_LBGR2Luv     = 76,
	    CV_LRGB2Luv     = 77,

	    CV_Lab2LBGR     = 78,
	    CV_Lab2LRGB     = 79,
	    CV_Luv2LBGR     = 80,
	    CV_Luv2LRGB     = 81,

	    CV_BGR2YUV      = 82,
	    CV_RGB2YUV      = 83,
	    CV_YUV2BGR      = 84,
	    CV_YUV2RGB      = 85,

	    CV_BayerBG2GRAY = 86,
	    CV_BayerGB2GRAY = 87,
	    CV_BayerRG2GRAY = 88,
	    CV_BayerGR2GRAY = 89,

	    //YUV 4:2:0 formats family
	    CV_YUV2RGB_NV12 = 90,
	    CV_YUV2BGR_NV12 = 91,
	    CV_YUV2RGB_NV21 = 92,
	    CV_YUV2BGR_NV21 = 93,
	    CV_YUV420sp2RGB = CV_YUV2RGB_NV21,
	    CV_YUV420sp2BGR = CV_YUV2BGR_NV21,

	    CV_YUV2RGBA_NV12 = 94,
	    CV_YUV2BGRA_NV12 = 95,
	    CV_YUV2RGBA_NV21 = 96,
	    CV_YUV2BGRA_NV21 = 97,
	    CV_YUV420sp2RGBA = CV_YUV2RGBA_NV21,
	    CV_YUV420sp2BGRA = CV_YUV2BGRA_NV21,

	    CV_YUV2RGB_YV12 = 98,
	    CV_YUV2BGR_YV12 = 99,
	    CV_YUV2RGB_IYUV = 100,
	    CV_YUV2BGR_IYUV = 101,
	    CV_YUV2RGB_I420 = CV_YUV2RGB_IYUV,
	    CV_YUV2BGR_I420 = CV_YUV2BGR_IYUV,
	    CV_YUV420p2RGB = CV_YUV2RGB_YV12,
	    CV_YUV420p2BGR = CV_YUV2BGR_YV12,

	    CV_YUV2RGBA_YV12 = 102,
	    CV_YUV2BGRA_YV12 = 103,
	    CV_YUV2RGBA_IYUV = 104,
	    CV_YUV2BGRA_IYUV = 105,
	    CV_YUV2RGBA_I420 = CV_YUV2RGBA_IYUV,
	    CV_YUV2BGRA_I420 = CV_YUV2BGRA_IYUV,
	    CV_YUV420p2RGBA = CV_YUV2RGBA_YV12,
	    CV_YUV420p2BGRA = CV_YUV2BGRA_YV12,

	    CV_YUV2GRAY_420 = 106,
	    CV_YUV2GRAY_NV21 = CV_YUV2GRAY_420,
	    CV_YUV2GRAY_NV12 = CV_YUV2GRAY_420,
	    CV_YUV2GRAY_YV12 = CV_YUV2GRAY_420,
	    CV_YUV2GRAY_IYUV = CV_YUV2GRAY_420,
	    CV_YUV2GRAY_I420 = CV_YUV2GRAY_420,
	    CV_YUV420sp2GRAY = CV_YUV2GRAY_420,
	    CV_YUV420p2GRAY = CV_YUV2GRAY_420,

	    //YUV 4:2:2 formats family
	    CV_YUV2RGB_UYVY = 107,
	    CV_YUV2BGR_UYVY = 108,
	    //CV_YUV2RGB_VYUY = 109,
	    //CV_YUV2BGR_VYUY = 110,
	    CV_YUV2RGB_Y422 = CV_YUV2RGB_UYVY,
	    CV_YUV2BGR_Y422 = CV_YUV2BGR_UYVY,
	    CV_YUV2RGB_UYNV = CV_YUV2RGB_UYVY,
	    CV_YUV2BGR_UYNV = CV_YUV2BGR_UYVY,

	    CV_YUV2RGBA_UYVY = 111,
	    CV_YUV2BGRA_UYVY = 112,
	    //CV_YUV2RGBA_VYUY = 113,
	    //CV_YUV2BGRA_VYUY = 114,
	    CV_YUV2RGBA_Y422 = CV_YUV2RGBA_UYVY,
	    CV_YUV2BGRA_Y422 = CV_YUV2BGRA_UYVY,
	    CV_YUV2RGBA_UYNV = CV_YUV2RGBA_UYVY,
	    CV_YUV2BGRA_UYNV = CV_YUV2BGRA_UYVY,

	    CV_YUV2RGB_YUY2 = 115,
	    CV_YUV2BGR_YUY2 = 116,
	    CV_YUV2RGB_YVYU = 117,
	    CV_YUV2BGR_YVYU = 118,
	    CV_YUV2RGB_YUYV = CV_YUV2RGB_YUY2,
	    CV_YUV2BGR_YUYV = CV_YUV2BGR_YUY2,
	    CV_YUV2RGB_YUNV = CV_YUV2RGB_YUY2,
	    CV_YUV2BGR_YUNV = CV_YUV2BGR_YUY2,

	    CV_YUV2RGBA_YUY2 = 119,
	    CV_YUV2BGRA_YUY2 = 120,
	    CV_YUV2RGBA_YVYU = 121,
	    CV_YUV2BGRA_YVYU = 122,
	    CV_YUV2RGBA_YUYV = CV_YUV2RGBA_YUY2,
	    CV_YUV2BGRA_YUYV = CV_YUV2BGRA_YUY2,
	    CV_YUV2RGBA_YUNV = CV_YUV2RGBA_YUY2,
	    CV_YUV2BGRA_YUNV = CV_YUV2BGRA_YUY2,

	    CV_YUV2GRAY_UYVY = 123,
	    CV_YUV2GRAY_YUY2 = 124,
	    //CV_YUV2GRAY_VYUY = CV_YUV2GRAY_UYVY,
	    CV_YUV2GRAY_Y422 = CV_YUV2GRAY_UYVY,
	    CV_YUV2GRAY_UYNV = CV_YUV2GRAY_UYVY,
	    CV_YUV2GRAY_YVYU = CV_YUV2GRAY_YUY2,
	    CV_YUV2GRAY_YUYV = CV_YUV2GRAY_YUY2,
	    CV_YUV2GRAY_YUNV = CV_YUV2GRAY_YUY2,

	    // alpha premultiplication
	    CV_RGBA2mRGBA = 125,
	    CV_mRGBA2RGBA = 126,

	    CV_RGB2YUV_I420 = 127,
	    CV_BGR2YUV_I420 = 128,
	    CV_RGB2YUV_IYUV = CV_RGB2YUV_I420,
	    CV_BGR2YUV_IYUV = CV_BGR2YUV_I420,

	    CV_RGBA2YUV_I420 = 129,
	    CV_BGRA2YUV_I420 = 130,
	    CV_RGBA2YUV_IYUV = CV_RGBA2YUV_I420,
	    CV_BGRA2YUV_IYUV = CV_BGRA2YUV_I420,
	    CV_RGB2YUV_YV12  = 131,
	    CV_BGR2YUV_YV12  = 132,
	    CV_RGBA2YUV_YV12 = 133,
	    CV_BGRA2YUV_YV12 = 134,

	    CV_COLORCVT_MAX  = 135
	};

	
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
	
	//CvRect* cvGetSeqElem( const CvSeq* seq, int index );
	
	CvSeq* cvHaarDetectObjects(const CvArr* image,
	                     		  void* cascade, 
								  CvMemStorage* storage,
	                     		  double scale_factor,
	                     		  int min_neighbors, 
								  int flags,
	                     		  CvSize min_size, 
								  CvSize max_size);
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

local fill_mode_op = {
	["FILL_DEFAULT"] = 0, --default
	["FILL_LIMIT"] = 1,
	["FILL_THUMB"] = 2,
}

local pad_mode_op = {
	["PAD_DEFAULT"] = 0, --default
	["PAD_LIMIT"] = 1,
	["PAD_M_LIMIT"] = 2,
}

local gravity_op = {
	["GRAVITY_CENTER"] = 0, --default
	["GRAVITY_NORTH_WEST"] = 1,
	["GRAVITY_NORTH"] = 2,
	["GRAVITY_NORTH_EAST"] = 3,
	["GRAVITY_WEST"] = 4,
	["GRAVITY_EAST"] = 5,
	["GRAVITY_SOUTH_WEST"] = 6,
	["GRAVITY_SOUTH"] = 7,
	["GRAVITY_SOUTH_EAST"] = 8,
	["GRAVITY_XY_CENTER"] = 9,
	["GRAVITY_FACE"] = 10,
	["GRAVITY_FACES"] = 11,
	["GRAVITY_FACE_CENTER"] = 12,
	["GRAVITY_FACES_CENTER"] = 13,
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

--[[ default: memstorage(nil), name(nil), real_name(nil) ]]
local function cv_load(filename, memstorage, name, real_name)
	return cvCore.cvLoad(filename, memstorage, name, real_name)
end

local function cv_cvt_color(src, dst, code)
	return cvImgproc.cvCvtColor(src, dst, code)
end

local function cv_equalize_hist(src, dst)
	return cvImgproc.cvEqualizeHist(src, dst);
end

local function cv_create_mem_storage(block_size)
	block_size = block_size or 0
	return cvCore.cvCreateMemStorage(block_size)
end

--[[
flags 或运算
#define CV_HAAR_DO_CANNY_PRUNING    1
#define CV_HAAR_SCALE_IMAGE         2
#define CV_HAAR_FIND_BIGGEST_OBJECT 4
#define CV_HAAR_DO_ROUGH_SEARCH     8
]]
local function cv_haar_detect_objects(image, cascade, storage, scale_factor, min_neighbors, flags, min_size, max_size)
	scale_factor = scale_factor or 1.1
	min_neighbors = min_neighbors or 3
	flags = flags or 0
	min_size = min_size or cv_size(0, 0)
	max_size = max_size or cv_size(0, 0)
	return cvObjdetect.cvHaarDetectObjects(image, cascade, storage, scale_factor, min_neighbors, flags, min_size, max_size)
end

local function cv_get_seq_elem(seq, index)
	return cvCore.cvGetSeqElem(seq, index)
end

local function cv_release_mem_storage(storage)
	local pointer = ffi.new("CvMemStorage *[1]")
	pointer[0] = storage
	return cvCore.cvReleaseMemStorage(pointer);
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

function _M.ellipse(self, x, y, w, h, angle, start_angle, end_angle, scalar, thickness, line_type, shift)

	if not self.cv_image then
		return error("Failed to draw ellipse on image")
	else
		local point = cv_point(x, y)
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
		
		return cvHighgui.cvEllipse(self.cv_image, point, size, angle, start_angle, end_angle, color, thickness, line_type_val, shift)
	end
end

function _M.object_detect(self, casc, find_biggest_object)
	local storage_cascade = cv_create_mem_storage(0)
	local cascade = cv_load(casc, storage_cascade)
	if not cascade then
		return error("Failed to load casc")
	end
	local gray = cv_create_image(self.cv_image.width, self.cv_image.height, 8, 1)
	cv_cvt_color(self.cv_image, gray, ffi.C.CV_BGR2GRAY)
	cv_equalize_hist(gray, gray)
	local storage = cv_create_mem_storage(0)
	local flags = 3
	if find_biggest_object then
		flags = 15
	end
	local faces = cv_haar_detect_objects(gray, cascade, storage, 1.06, 3, flags, cv_size(self.cv_image.width / 100, self.cv_image.height / 100), cv_size(0, 0))
	local rects = {}
	if faces and faces.total > 0 then
		for i=0, (faces.total - 1) do
			local rect = cv_get_seq_elem(faces, i)
			rect = ffi.cast("CvRect *", rect)
			table.insert(rects, rect)
		end
	end
	cv_release_mem_storage(storage_cascade)
	cv_release_mem_storage(storage)
	cv_release_image(gray)
	return rects
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


function _M.fill(self, w, h, fill_mode, gravity_mode, x, y)

	if not self.cv_image then
		return error("Failed to fill image")
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

		
		if not fill_mode then
			fill_mode = 'FILL_DEFAULT'
		end
		
		if not gravity_mode then
			gravity_mode = 'GRAVITY_CENTER'
		end
				
		
		local dst
		local h_roi
		local w_roi
		local x_roi
		local y_roi
		
		
		
		if fill_mode == 'FILL_THUMB' then
			
			local faces = self:object_detect('haarcascade_frontalface_alt2.xml')
			
			if #faces > 0 then
				if gravity_mode == 'GRAVITY_FACE' or gravity_mode == 'GRAVITY_FACE_CENTER' or gravity_mode == 'GRAVITY_FACES' or gravity_mode == 'GRAVITY_FACES_CENTER' then
					
					local min_x = faces[1].x
					local min_x_index = 1
					local min_y = faces[1].y
					local min_y_index = 1
					local max_x = faces[1].x
					local max_x_index = 1
					local max_y = faces[1].y
					local max_y_index = 1
					
					for i = 1, #faces, 1 do
						if faces[i].x > max_x then
							max_x = faces[i].x
							max_x_index = i
						elseif faces[i].x < min_x then
							min_x = faces[i].x
							min_x_index = i
						end
						
						if faces[i].y > max_y then
							max_y = faces[i].y
							max_y_index = i
						elseif faces[i].y < min_y then
							min_y = faces[i].y
							min_y_index = i
						end
					end
					
					w_roi = (max_x + faces[max_x_index].width) > o_w and (o_w - min_x) or (max_x - min_x + faces[max_x_index].width)
					h_roi = (max_y + faces[max_y_index].height) > o_h and (o_h - min_y) or (max_y - min_y + faces[max_y_index].height)
					x_roi = min_x
					y_roi = min_y
				end
				
				self:set_image_roi(x_roi, y_roi, w_roi, h_roi)
				dst = self:resize(n_w, n_h)
				return dst
			else
				if gravity_mode == 'GRAVITY_FACE' or gravity_mode == 'GRAVITY_FACES' then
					gravity_mode = 'GRAVITY_NORTH'
				elseif gravity_mode == 'GRAVITY_FACE_CENTER' or gravity_mode == 'GRAVITY_FACES_CENTER' then
					gravity_mode = 'GRAVITY_CENTER'
				end
			end
			
		end
		
		

		if fill_mode == 'FILL_DEFAULT' then
			
		elseif fill_mode == 'FILL_LIMIT' then
			n_w = (n_w > o_w) and o_w or n_w
			n_h = (n_h > o_h) and o_h or n_h
		end
		
		
		
		if n_w/n_h >= o_w/o_h then
			w_roi = (n_w > o_w) and o_w or n_w
			h_roi = n_h*w_roi/n_w
		else
			h_roi = (n_h > o_h) and o_h or n_h
			w_roi = h_roi*n_w/n_h
		end
		
		

		if gravity_mode == 'GRAVITY_CENTER' then
			x_roi = (o_w - w_roi) / 2
			y_roi = (o_h - h_roi) / 2
		elseif gravity_mode == 'GRAVITY_NORTH_WEST' then
			x_roi = 0
			y_roi = 0
		elseif gravity_mode == 'GRAVITY_NORTH' then
			x_roi = (o_w - w_roi) / 2
			y_roi = 0
		elseif gravity_mode == 'GRAVITY_NORTH_EAST' then
			x_roi = o_w - w_roi
			y_roi = 0
		elseif gravity_mode == 'GRAVITY_WEST' then
			x_roi = 0
			y_roi = (o_h - h_roi) / 2
		elseif gravity_mode == 'GRAVITY_EAST' then
			x_roi = o_w - w_roi
			y_roi = (o_h - h_roi) / 2
		elseif gravity_mode == 'GRAVITY_SOUTH_WEST' then
			x_roi = 0
			y_roi = o_h - h_roi
		elseif gravity_mode == 'GRAVITY_SOUTH' then
			x_roi = (o_w - w_roi) / 2
			y_roi = o_h - h_roi
		elseif gravity_mode == 'GRAVITY_SOUTH_EAST' then
			x_roi = o_w - w_roi
			y_roi = o_h - h_roi
		elseif gravity_mode == 'GRAVITY_XY_CENTER' then
			return error("GRAVITY_XY_CENTER only can be used for corp")
--			x = x or 0
--			y = y or 0
--			
--			if (x <= w_roi / 2)  then
--				x_roi = 0
--			elseif (x > o_w - w_roi / 2) then
--				x_roi = o_w - w_roi / 2
--			end
--			
--			if (y <= h_roi / 2)  then
--				y_roi = 0
--			elseif (y > o_h - h_roi / 2) then
--				y_roi = o_h - h_roi / 2
--			end
			
		elseif gravity_mode == 'GRAVITY_FACE' or gravity_mode == 'GRAVITY_FACE_CENTER' or gravity_mode == 'GRAVITY_FACES' or gravity_mode == 'GRAVITY_FACES_CENTER' then
			
			local faces = object_detect('haarcascade_frontalface_alt2.xml')
			
			if #faces > 0 then
				
				--逻辑要用测试图看例子效果
				
--				if n_w/n_h >= o_w/o_h then
--					w_roi = (n_w > o_w) and o_w or n_w
--					h_roi = n_h*w_roi/n_w
--				else
--					h_roi = (n_h > o_h) and o_h or n_h
--					w_roi = h_roi*n_w/n_h
--				end
--				
--				x_roi = faces[1].x 
--				y_roi = faces[1].y
				
			else
			
				if gravity_mode == 'GRAVITY_FACE' or gravity_mode == 'GRAVITY_FACES' then
					x_roi = (o_w - w_roi) / 2
					y_roi = 0
				else
					x_roi = (o_w - w_roi) / 2
					y_roi = (o_h - h_roi) / 2
				end
				
			end
			
		end
		
		
		self:set_image_roi(x_roi, y_roi, w_roi, h_roi)
		dst = self:resize(n_w, n_h)
		return dst
	end
	
end

return _M


