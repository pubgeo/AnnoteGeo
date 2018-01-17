function [s, table0, poly0, img0] = saveData( obj, table, poly, img, saveName, params)
% SAVEDATA
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

    saveRemovedPolygons = true;
    if exist('params', 'var') && ~isempty(params) && isstruct(params)
        fn = fieldnames(params);
        for p = fn'
            if exist(p{:}, 'var')
                eval(sprintf('%s = params.(''%s'');', p{:}, p{:}));
            end
        end
    end

    table0 = [];
    poly0  = [];
    img0   = false;


    s.imageFilename = obj.imageFilename;
    s.metadata = obj.metadata;
    s.currentBlockRows = obj.currentBlockRows;
    s.currentBlockCols = obj.currentBlockCols;
    s.currentRows = obj.currentRows;
    s.currentCols = obj.currentCols;


    % -- Update Polygons
    % TODO: consolidate polygon management functions (also in pan and geoJump)
    yShift = obj.currentRows(1);
    xShift = obj.currentCols(1);
    if ~isempty(poly)
        poly0 = cellfun(@(x) bsxfun(@plus, x, [xShift yShift]), poly, 'UniformOutput', false);
    end
    s.geoPoly = cellfun(@(x) geoTiffProj(s.metadata, x, 0, 1), poly0, 'UniformOutput', false);


    % Removed polys are those outside the image bounds, if 'Save' pressed
    % Skip if 'SaveGT' pressed
    if  saveRemovedPolygons
        % Put removed entries back
        [m,n] = size(obj.removedTable);
        [~,p] = size(table);
        if(n~=p) && (n~=0)
            tmp = repmat({''},m,p-n);
            obj.removedTable = [obj.removedTable(:,1:2) tmp obj.removedTable(:,3:end)];

            table0 = [table0; obj.removedTable];
            poly0 = [poly0 obj.removedPolygons];
            s.geoPoly = [s.geoPoly obj.removedGeoPoly];
            obj.logger.info(mfilename, sprintf('%d polygons added back into file', sum(obj.removedInd)))
        end

    end
    
end

