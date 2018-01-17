function [data] = loadData( obj, filename)
% LOADDATA
%
% DESCRIPTION:
%   
% 
% SYNTAX:
%
%   
% INPUTS:
%
% 
% OUTPUTS:
%
%
% COMMENTS:
%
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
   % -- Update Polygons
   % TODO: consolidate polygon management functions (also in pan and geoJump)
    data = load(filename, 'table', 'poly', 'currentRows', 'currentCols','metadata','geoPoly');
    obj.logger.info(mfilename, sprintf('%d polygons found in file', numel(data.poly)))
  
    keep = cellfun(@(x) any(x(:,1) > min(obj.metadata.CornerCoords.X) &  x(:,2) > min(obj.metadata.CornerCoords.Y) & x(:,1) < max(obj.metadata.CornerCoords.X) &  x(:,2) <  max(obj.metadata.CornerCoords.Y) ), data.geoPoly);
    remove = ~keep;
    obj.logger.info(mfilename, sprintf('%d polygons removed due to being outside the image bounds', sum(remove)))
    obj.removedPolygons = [obj.removedPolygons data.poly(remove)];
    obj.removedInd = [obj.removedInd remove];
    obj.removedGeoPoly = [obj.removedGeoPoly data.geoPoly(remove)];
    obj.removedTable =  [obj.removedTable; data.table(remove,:)];
    data.poly(remove) = [];
    data.geoPoly(remove) = [];
    data.table(remove,:) = [];
    
    refMat = obj.metadata.RefMatrix;
    
    % Georeference data to background image
    for p = 1:numel(data.poly)
        [latcells]={data.geoPoly{p}(:,1)'};
        [loncells]={data.geoPoly{p}(:,2)'};
        for j=1:length(latcells)
            [r_bldg, c_bldg] = map2pix(refMat, latcells{j}, loncells{j}); 
        end
        data.poly{p} = [c_bldg',r_bldg'];
    end
    
    % Calculate Shifts
    yShift = -obj.currentRows(1);
    xShift = -obj.currentCols(1);
    if ~isempty(data.poly) 
      poly = cellfun(@(x) bsxfun(@plus, x, [xShift yShift]), data.poly, 'UniformOutput', false);
      data.poly = poly;
    end
  
%   s.imSize = imSize;
%   s.label  = label;
%   s.mask   = mask;
end

