% Summary: 
% Changes the cmap of a classification raster img, following LAS specifications, to one that is viewer friendly and
% accounts for color blindness. Input should be a array of doubles
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
function colorized_raster = change_cmap(raster_img)
     cmap = zeros(11, 3);
    %cmap(0,:) = [255 255 255]/255; % Never Classified, white
    cmap(1,:) = [245 245 245]/255; % Unclassified, beige
    cmap(2,:) = [224 224 224]/255; % Ground, Light Gray
    cmap(3,:) = [183 255 205]/255; % Low Vegetation, Light Green
    cmap(4,:) = [112 255 155]/255; % Medium Vegetation, Medium Green
    cmap(5,:) = [6 178 57]/255; % High Vegetation, Dark Green
    cmap(6,:) = [220 140 0]/255; % Building, Dark Orange
    cmap(9,:) = [0 109 219]/255; % Water, Dark Blue
    cmap(10,:) = [229 204 255]/255; % Rail, Light Purple
    cmap(17,:) = [255 255 0]/255; % Bridge, Yellow
    cmap(64,:) = [146 0 0]/255; % Vehicle, Red
    cmap(65,:) = [96 96 96]/255; % Uncertain, Black

    raster_img_temp = raster_img; % Because of the way we save rasters right now.
    ClassImgResults = ind2rgb(raster_img_temp, cmap);
    colorized_raster = ClassImgResults;
end