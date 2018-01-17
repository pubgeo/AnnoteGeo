function geoJump(obj, x, y)
% GEOJUMP
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

    [row_block_idx, col_block_idx] = ComputeBlockNumber(obj.metadata, y, x);

    % TODO: only load blocks not currently loaded.  This can probably
    % replaced/consolidated with pan.m
    curRows = obj.currentBlockRows;
    curCols = obj.currentBlockCols;
    loadRows = floor(row_block_idx + [-1 1]*(numel(curRows)-1)/2);
    loadCols = floor(col_block_idx + [-1 1]*(numel(curCols)-1)/2);
    loadRows = loadRows(1):loadRows(end);
    loadCols = loadCols(1):loadCols(end);
    
     % Check bounds
    if loadRows(end) > obj.metadata.NumRowBlocks
        loadRows = loadRows - (loadRows(end)-obj.metadata.NumRowBlocks);
    end
    
    if loadCols(end) > obj.metadata.NumColumnBlocks
        loadCols = loadCols - (loadCols(end)-obj.metadata.NumColumnBlocks);
    end
    
    if loadRows(1) < 1
        loadRows = loadRows + (1 - loadRows(1));
    end
    
     if loadCols(1) < 1
        loadCols = loadCols + (1 - loadCols(1));
    end
       
    if (all(obj.currentBlockRows == loadRows) && all(obj.currentBlockCols == loadCols))
        rowRange = obj.currentRows;
        colRange = obj.currentCols;
        blockImage = obj.hImage.CData;
    else
        title(obj.hFigure.CurrentAxes, 'Buffering...', 'FontWeight', 'Normal'); drawnow
        
        % Load new image block
        [blockImage, rowRange, colRange ] = loadImageData(obj, [], [], loadRows, loadCols);
        
        title(obj.hFigure.CurrentAxes, ''); drawnow
    end
    
    obj.updateSnailTrail(0, true);

    oldXLim = obj.hFigure.CurrentAxes.XLim;
    oldYLim = obj.hFigure.CurrentAxes.YLim;
    
    curXlim = oldXLim - oldXLim(1);
    curYLim = oldYLim - oldYLim(1);
    newXLim = (x - colRange(1)) + curXlim - curXlim(2)/2;
    newYLim = (y - rowRange(1)) + curYLim - curYLim(2)/2;
    
    % Check Bounds
    if newXLim(1) < 1
        newXLim = newXLim - newXLim(1) + 1;
    end
    
    if newYLim(1) < 1
        newYLim = newYLim - newYLim(1) + 1;
    end
    
    if newXLim(end) > size(blockImage,2)
        newXLim = newXLim - (newXLim(end) -  size(blockImage,2)) + 1;
    end
    
    if newYLim(end) > size(blockImage,1)
        newYLim = newYLim - (newYLim(end) -  size(blockImage,1)) + 1;
    end

    
    % -- Update Polygons
    % TODO: consolidate polygon management functions (also in pan and saveData)
    hP = obj.hPolys;
    yShift = obj.currentRows(1) - rowRange(1);
    xShift = obj.currentCols(1) - colRange(1);
    if ~isempty(hP) 
        if yShift ~= 0 
            if numel(hP) > 1
                tmp = get(hP, 'YData');
                cellfun(@(h,y) set(h, 'YData', y+yShift), num2cell(hP), tmp')
            else
                set(hP, 'YData', get(hP, 'YData') + yShift);
            end
        end
        if xShift ~= 0
            if  numel(hP) > 1
                tmp = get(hP, 'XData');
                cellfun(@(h,x) set(h, 'XData', x+xShift), num2cell(hP), tmp')
            else
                set(hP, 'XData', get(hP, 'XData') + xShift);
            end
        end
    end
    
    
    
    obj.hImage.CData = blockImage;
    obj.hFigure.CurrentAxes.XLim = newXLim;
    obj.hFigure.CurrentAxes.YLim = newYLim;
    
    obj.currentCols = colRange;
    obj.currentRows = rowRange;
    
    obj.currentBlockRows = loadRows(1):loadRows(end);
    obj.currentBlockCols = loadCols(1):loadCols(end);
    
    obj.updateSnailTrail(1);
    obj.updateSnailTrail(0);

end

