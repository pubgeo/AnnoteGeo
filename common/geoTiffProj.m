function [ outPts ] = geoTiffProj(info, pts, direction, isXY)
% GEOTIFFPROJ
%
% DESCRIPTION
%   
% 
% SYNTAX
%
%   
% INPUTS
%          info:  output of geotiffinfo.m
%          pts:   Nx2   [ image space is row/col; model space is x/y ]
%          direction:    0 or 1
%                       (0) image -> model conversion 
%                       (1) model -> image conversion
% 
%			isXY: (Default False)  
%				   True - sets image space to be X/Y
%				   False - sets image space to be Row/Col
% OUTPUTS
%
%
% REFERENCES
%       http://mac.mf3x3.com/GIS/GEOTIFF/geotiff_spec.pdf
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
%

    outPts = [];

    if ~isfield(info, 'GeoTIFFTags')
        fprintf('Not a GeoTIFF\n');
        return
    end
    
    if ~exist('isXY', 'var') || isempty(isXY)
        isXY = false;
    end

    IMAGE2MODEL = 0;
    MODEL2IMAGE = 1;

    model      = info.ModelType;
    projection = info.Projection;

    isPixelAsArea = info.GeoTIFFTags.GeoKeyDirectoryTag.GTRasterTypeGeoKey;

    % RowCol -> XY
    if isXY && (direction ==  IMAGE2MODEL)
        pts(:,[1 2]) = pts(:,[2 1]);
    end
    
    if direction == IMAGE2MODEL
        if isPixelAsArea == 1
            pts = pts - 0.5;
        else
            pts = pts - 1;
        end
    end

    geoTags = info.GeoTIFFTags;

    if isfield(geoTags, 'ModelTiepointTag')  && isfield(geoTags, 'ModelPixelScaleTag')


        if direction == IMAGE2MODEL

            x =  pts(:,2)*geoTags.ModelPixelScaleTag(2) + geoTags.ModelTiepointTag(1,4);
            y = -pts(:,1)*geoTags.ModelPixelScaleTag(1) + geoTags.ModelTiepointTag(1,5);

            outPts = [x y];

        else

            c =  ( pts(:,1) - geoTags.ModelTiepointTag(1,4) ) ./ geoTags.ModelPixelScaleTag(1);
            r = -( pts(:,2) - geoTags.ModelTiepointTag(1,5) ) ./ geoTags.ModelPixelScaleTag(2);

            outPts = [r c];

        end




    elseif isfield(geoTags, 'ModelTransformationTag')  &&  ( numel(geoTags.ModelTransformationTag) == 16 )

        tform = reshape(geoTags.ModelTransformationTag, 4, 4)';
        
        
    
        if direction == IMAGE2MODEL
            pts  = [pts(:,2) pts(:,1) zeros(size(pts,1),1) ones(size(pts,1),1)];
            x = sum((bsxfun(@times, tform(1,:), pts)),2);
            y = sum((bsxfun(@times, tform(2,:), pts)),2);
            z = sum((bsxfun(@times, tform(3,:), pts)),2);
            outPts = [x y z];
        else
            
            if( all(tform(:,3) == 0) && all(tform(3,:) == 0) )
                itform = inv(tform(1:2,1:2));
                 
                ptsNew = bsxfun(@minus, pts(:,[1 2]), tform([1 2],4)');
                
                c = sum( bsxfun(@times, itform(1,:), ptsNew),2);
                r = sum( bsxfun(@times, itform(2,:), ptsNew),2);
                
                outPts = [r c];
                
            else
                outPts= [];
            end
            
            
        end
        
    end


    if direction == MODEL2IMAGE
        if isPixelAsArea == 1
            outPts = outPts + 0.5;
        else
            outPts = outPts + 1;
        end
    end

    % RowCol -> XY
    if isXY &&  (direction ==  MODEL2IMAGE)
        outPts(:, [1 2]) = outPts(:, [2 1]);
    end

end

