% 
% Extract requested image image. Returns a single-precision grayscale
% image.
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

function image_region = ReadImageRegion(image_file, image_metadata, pixel_row_range, pixel_column_range, reduction_level)


% Handle missing arguments (default values)
if(nargin == 2) ||  ~exist('pixel_row_range', 'var') || isempty(pixel_row_range) || ~exist('pixel_column_range', 'var') || isempty(pixel_column_range)
    pixel_row_range = [1, image_metadata.NumImageRows];
    pixel_column_range = [1, image_metadata.NumImageColumns];
end

outHeight = pixel_row_range(2) - pixel_row_range(1) + 1;
outWidth  = pixel_column_range(2) - pixel_column_range(1) + 1;


padLeft   = 0;  
padTop    = 0;  
if(pixel_column_range(1)) < 0; 
    padLeft = -pixel_column_range(1) + 1;
    pixel_column_range(1) = 1;
end;

if(pixel_row_range(1)) < 0;    
    padTop = -pixel_row_range(1) + 1; 
    pixel_row_range(1) = 1;
end;

if(pixel_column_range(2)) > image_metadata.NumImageColumns
    pixel_column_range(2) = image_metadata.NumImageColumns;
end

if(pixel_row_range(2)) > image_metadata.NumImageRows
    pixel_row_range(2) = image_metadata.NumImageRows;
end


if ~exist('reduction_level', 'var') || isempty(reduction_level)
    reduction_level = 0;
end

% Read image region based on image format and requested pixel region
switch(lower(image_metadata.ImageFormat))


	% TIFF file
	case {lower('.TIFF'), lower('.TIF')}
        % RGB: image_region will be RxCx3 uint8
        try
            image_region = imread(image_file, 'PixelRegion', {pixel_row_range, pixel_column_range});
        catch ME
            image_region = imread(image_file);
            image_region = image_region(pixel_row_range(1):pixel_row_range(2), ...
                                        pixel_column_range(1):pixel_column_range(2), :);
        end        
        image_region = single(image_region);
        
        
        if reduction_level > 0
            outHeight    = round(outHeight./2^reduction_level);
            outWidth     = round(outWidth./2^reduction_level);
            image_region = imresize(image_region, [outHeight outWidth]);
        end
        
        
    % PNG file
	case {lower('.PNG')}
        % RGB: image_region will be RxCx3 uint8
        try
            image_region = imread(image_file, 'PixelRegion', {pixel_row_range, pixel_column_range});
        catch ME
            image_region = imread(image_file);
            image_region = image_region(pixel_row_range(1):pixel_row_range(2), ...
                                        pixel_column_range(1):pixel_column_range(2), :);
        end
        % Collapse RGB into grayscale (single-layer) image
        image_region = rgb2gray(image_region);
        % Convert to single precision and normalized [0,255] range
        %image_region = single(255 * mat2gray(image_region));
        image_region = single(image_region);
        
    % JPEG file
	case {lower('.JPEG'), lower('.JPG')}
        % RGB: image_region will be RxCx3 uint8
        try
            image_region = imread(image_file, 'PixelRegion', {pixel_row_range, pixel_column_range});
        catch ME
            image_region = imread(image_file);
            image_region = image_region(pixel_row_range(1):pixel_row_range(2), ...
                                        pixel_column_range(1):pixel_column_range(2), :);
        end
        % Collapse RGB into grayscale (single-layer) image
        image_region = rgb2gray(image_region);
        % Convert to single precision and normalized [0,255] range
        %image_region = single(255 * mat2gray(image_region));
        image_region = single(image_region);
        
	% Not a recognized image format
	otherwise
		error(['Unrecognized image file format (' image_metadata.ImageFormat ')!']);
	
end


imageOut = nan(outHeight, outWidth, size(image_region,3));
imageOut(padTop + (1:size(image_region,1)), padLeft + (1:size(image_region,2)), :) = image_region;
assert( size(imageOut,1) == outHeight  &  size(imageOut,2) == outWidth);
image_region = imageOut;

