% 
% Extract current block image for processing
% (converted to pixels and provided as
% parameter to this function). Returns a single-precision grayscale image.
% 
%@
% Copyright 2016 The Johns Hopkins University Applied Physics Laboratory
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is 
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
%@
function [block_image, segment_pixel_row_range, segment_pixel_column_range] = ReadImageBlock(image_file, image_metadata, row_block_idx, column_block_idx, block_overlap_pixels)

% Handle missing arguments (default values)
if(nargin == 2)
    row_block_idx = 1;
    column_block_idx = 1;
    block_overlap_pixels = 0;
end

% Construct segment pixel region, taking into account the overlap pixels
row_start = max(min((row_block_idx-1)*image_metadata.NumRowPixelsPerBlock - block_overlap_pixels)+1, 1);
row_end   = min(max(row_block_idx*image_metadata.NumRowPixelsPerBlock + block_overlap_pixels), image_metadata.NumImageRows);
col_start = max(min((column_block_idx-1)*image_metadata.NumColumnPixelsPerBlock - block_overlap_pixels)+1, 1);
col_end   = min(max(column_block_idx*image_metadata.NumColumnPixelsPerBlock + block_overlap_pixels), image_metadata.NumImageColumns);
% Error check row range and column range values
row_start = min(row_start, row_end);
row_end   = max(row_start, row_end);
col_start = min(col_start, col_end);
col_end   = max(col_start, col_end);
% Assign segment pixel row and column ranges for extracting block image
segment_pixel_row_range    = [row_start, row_end];
segment_pixel_column_range = [col_start, col_end];

% Read image block based on image format and computed segment pixel region
block_image = ReadImageRegion(image_file, image_metadata, segment_pixel_row_range, segment_pixel_column_range);
