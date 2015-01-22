//
//  magicktype.c
//  magicktype
//
//  Created by Littlebox222 on 15/1/21.
//  Copyright (c) 2015年 Littlebox222. All rights reserved.
//

#include "magicktype.h"

#include <string.h>
#include <math.h>
#include <ft2build.h>
#include FT_FREETYPE_H
#include <freetype/ftglyph.h>


int convert_unicode(char *str, int *code)
{
    
    int c;
    char *p = str;
    
    *code = *p;
    
    if ((*p & 0x80) == 0x00) {
        *code &= 0x7f;
        if (*code >= 0x0) return 1;
        return -1;
    }
    
    c = (p[1] ^ 0x80) & 0xff;
    *code = (*code << 6) | c;
    if ((c & 0xc0) != 0) return -1;
    
    if ((*p & 0xe0) == 0xc0) {
        *code &= 0x7ff;
        if (*code >= 0x0000080) return 2;
        return -1;
    }
    
    c = (p[2] ^ 0x80) & 0xff;
    *code = (*code << 6) | c;
    if ((c & 0xc0) != 0) return -1;
    
    if ((*p & 0xf0) == 0xe0) {
        *code &= 0xffff;
        if (*code >= 0x0000800) return 3;
        return -1;
    }
    
    c = (p[3] ^ 0x80) & 0xff;
    *code = (*code << 6) | c;
    if ((c & 0xc0) != 0) return -1;
    
    if ((*p & 0xf8) == 0xf0) {
        *code &= 0x1fffff;
        if (*code >= 0x0010000) return 4;
        return -1;
    }
    
    c = (p[4] ^ 0x80) & 0xff;
    *code = (*code << 6) | c;
    if ((c & 0xc0) != 0) return -1;
    
    if ((*p & 0xfc) == 0xf8) {
        *code &= 0x3fffff;
        if (*code >= 0x0200000) return 5;
        return -1;
    }
    
    c = (p[5] ^ 0x80) & 0xff;
    *code = (*code << 6) | c;
    if ((c & 0xc0) != 0) return -1;
    
    if ((*p & 0xfe) == 0xfc) {
        if (*code >= 0x4000000) return 6;
        return -1;
    }
    
    return -1;
}


MT_Font_Color *new_font_color(unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    MT_Font_Color *font_color = (MT_Font_Color *)malloc(sizeof(MT_Font_Color));
    font_color->r = r;
    font_color->g = g;
    font_color->b = b;
    font_color->a = a;
    return font_color;
}

void destroy_font_color(MT_Font_Color *font_color) {
    if (font_color != NULL) {
        free(font_color);
    }
}

MT_Font *new_font() {
    MT_Font *font = (MT_Font *)malloc(sizeof(MT_Font));
    font->font_size = 14;
    font->text_kerning = 1;
    font->line_spacing = 1;
    font->font_lean = 0;
    font->word_spacing = 1;
    MT_Font_Color *color = new_font_color(0,0,0,0);
    font->font_color = color;
    return font;
}

void destroy_font(MT_Font *font) {
    if (font != NULL) {
        if (font->font_color) {
            destroy_font_color(font->font_color);
        }
        free(font);
    }
}

MT_Image *new_image() {
    MT_Image *image = (MT_Image *)malloc(sizeof(MT_Image));
    image->im_w = 0;
    image->im_h = 0;
    image->image_data = NULL;
    return image;
}

void destroy_image(MT_Image *image) {
    if (image != NULL) {
        if (image->image_data != NULL) {
            free(image->image_data);
        }
        free(image);
    }
}

void draw_bitmap(FT_Bitmap* bitmap, unsigned char *image, FT_Int x, FT_Int y, int im_w, int im_h, MT_Font_Color color, int channels) {
    
    FT_Int  i, j, p, q;
    FT_Int  x_max = x + bitmap->width;
    FT_Int  y_max = y + bitmap->rows;
    
    for (i=x, p=0; i<x_max; i++, p++) {
        for (j=y, q=0; j<y_max; j++, q++) {
            
            if (i<0 || j<0 || i>=im_w || j>=im_h) {
                continue;
            }else {
                
                if (channels == 1) {
                    image[j*im_w + i] |= bitmap->buffer[q * bitmap->width + p];
                }else {
                    image[j*im_w*4 + i*4 + 3] |= bitmap->buffer[q * bitmap->width + p];
                }
            }
        }
    }
    
}

void show_image(unsigned char * image, int w, int h)
{
    int i, j;
    
    for (i=0; i<h; i++) {
        for (j=0; j<w; j++) {
            putchar( image[i*w+j] == 0 ? '.' : image[i*w+j] < 128 ? '+' : '*' );
        }
        putchar( '\n' );
    }
}

MT_Image *str_to_image(char *str, int im_w, int im_h, const char *font_name, MT_Font font, int resolution, int channels) {
    
    if (str == NULL || font_name == NULL) {
        return NULL;
    }
    
    if (channels != 1 && channels != 4) {
        channels = 1;
    }
    
    int mode_all_all = 0;
    int mode_w_h = 0;
    int mode_all_h = 0;
    int mode_w_all = 0;
    
    if (im_w <= 0 && im_h <= 0) {
        mode_all_all = 1;
    }else if (im_w <= 0 && im_h > 0) {
        mode_all_h = 1;
    }else if (im_w > 0 && im_h <= 0) {
        mode_w_all = 1;
    }else {
        mode_w_h = 1;
    }
    
    FT_Library    library;
    FT_Face       face;
    FT_GlyphSlot  slot;
    FT_Matrix     matrix;
    FT_Vector     pen;
    FT_Error      error;
    
    
    const char *filename = font_name;
    char *text = str;
    long num_chars = strlen(text);
    int text_size = font.font_size;
    float text_lean = font.font_lean >= 0 ? font.font_lean : abs(font.font_lean);
    float text_kerning = font.text_kerning;
    float word_spacing = font.word_spacing;
    float line_spacing = font.line_spacing;
    MT_Image *mt_image = (MT_Image *)malloc(sizeof(MT_Image));
    
    
    error = FT_Init_FreeType( &library );
    error = FT_New_Face(library, filename, 0, &face);
    error = FT_Set_Char_Size(face, text_size * 64, 0, resolution, resolution);
    slot = face->glyph;
    
    int num_text = 0;
    if (!mode_w_h) {
        //////////////////////////////////////////////////////////////////////////////
        
        matrix.xx = 0x10000L;
        matrix.xy = text_lean * 0x10000L;
        matrix.yx = 0;
        matrix.yy = 0x10000L;
        
        pen.x = 0 * 64;
        pen.y = 0;
        
        int step = 0;
        long tmp_w = 0;
        long tmp_h = text_size;
        int n;
        
        for (n = 0; n < num_chars; n+=step ) {
            
            FT_Set_Transform( face, &matrix, &pen );
            FT_Select_Charmap(face, FT_ENCODING_UNICODE);
            
            int a = 0;
            step = convert_unicode(text+n, &a);
            
            if (step == -1) {
                break;
            }
            
            if (a == 10 || a == 13) {
                
                if (a == 32) {
                    tmp_w = pen.x + slot->advance.x * word_spacing > tmp_w ? pen.x + slot->advance.x * word_spacing : tmp_w;
                }else {
                    tmp_w = pen.x + slot->advance.x * text_kerning > tmp_w ? pen.x + slot->advance.x * text_kerning : tmp_w;
                }
                
                pen.x = 0;
                pen.y -= text_size * line_spacing * 64;
                tmp_h += text_size * line_spacing;
                continue;
            }else if (a == 9) {
                pen.x += text_size * 0.5 * word_spacing * 4 * 64;
                continue;
            }
            
            error = FT_Load_Char(face, a, FT_LOAD_RENDER);
            
            if (a == 32) {
                pen.x += slot->advance.x * word_spacing;
            }else {
                pen.x += slot->advance.x * text_kerning;
            }
            num_text++;
        }
        
        long raw_w = pen.x > tmp_w ? pen.x : tmp_w;
        long raw_h = tmp_h * 1.15;
        raw_w /= 64;
        
        if (mode_all_all || mode_all_h) {
            
            im_w = (int)raw_w;
            im_h = (int)raw_h;
            
            im_w += text_size * text_lean;
            
        }else if (mode_w_all) {
            
            int num_text_per_line = (im_w - text_size * text_lean) / text_size;
            num_text_per_line = num_text_per_line <= 0 ? 1 : num_text_per_line;
            int num_line = 0;
            num_line = num_text / num_text_per_line;
            num_line += (num_text % num_text_per_line > 0);
            im_h = num_line * text_size + text_size * 0.15;
            
        }
        
        //////////////////////////////////////////////////////////////////////////////
    }
    
    mt_image->im_w = im_w;
    mt_image->im_h = im_h;
    
    unsigned char *image = (unsigned char *)malloc(im_w * im_h * channels *sizeof(unsigned char));
    if (channels == 1) {
        memset(image, 0, im_w * im_h);
    }else {
        int i,j;
        for (i=0; i<im_h; i++) {
            for (j=0; j<im_w; j++) {
                image[i*im_w*4 + j*4 + 0] = font.font_color->b;
                image[i*im_w*4 + j*4 + 1] = font.font_color->g;
                image[i*im_w*4 + j*4 + 2] = font.font_color->r;
                image[i*im_w*4 + j*4 + 3] = 0;
            }
        }
    }
    
    matrix.xx = 0x10000L;
    matrix.xy = text_lean * 0x10000L;
    matrix.yx = 0;
    matrix.yy = 0x10000L;
    
    
    pen.x = 0 * 64;
    int target_height = im_h;
    pen.y = (target_height-text_size) * 64;
    
    int step = 0;
    int n;
    for (n = 0; n < num_chars; n+=step ) {
        
        FT_Set_Transform( face, &matrix, &pen );
        FT_Select_Charmap(face, FT_ENCODING_UNICODE);
        
        int a = 0;
        step = convert_unicode(text+n, &a);
        
        if (step == -1) {
            break;
        }
        
        if (a == 10 || a == 13) {
            pen.x = 0;
            pen.y -= text_size * line_spacing * 64;
            continue;
        }else if (a == 9) {
            pen.x += text_size * 0.5 * word_spacing * 4 * 64;
            if (pen.x + slot->advance.x * word_spacing >= (im_w - text_size * text_lean) * 64) {
                pen.x = 0;
                pen.y -= text_size * line_spacing * 64;
            }
            continue;
        }
        
        error = FT_Load_Char(face, a, FT_LOAD_RENDER);
        
        draw_bitmap(&slot->bitmap, image, slot->bitmap_left, target_height - slot->bitmap_top, im_w, im_h, *font.font_color, channels);
        
        if (a == 32) {
            pen.x += slot->advance.x * word_spacing;
            if (pen.x + slot->advance.x * word_spacing > (im_w - text_size * text_lean) * 64) {
                pen.x = 0;
                pen.y -= text_size * line_spacing * 64;
            }
        }else {
            pen.x += slot->advance.x * text_kerning;
            if (pen.x + slot->advance.x * text_kerning > (im_w - text_size * text_lean) * 64) {
                pen.x = 0;
                pen.y -= text_size * line_spacing * 64;
            }
        }
    }
    
    
    FT_Done_Face    ( face );
    FT_Done_FreeType( library );
    
    mt_image->image_data = image;
    return mt_image;
}
