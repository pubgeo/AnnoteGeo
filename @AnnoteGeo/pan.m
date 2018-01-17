function pan(obj, direction)
% PAN
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
    % Disable multiple calls to functions. 
    % Matlab's event queue will allow multiple calls without finishing the 
    % previous call and messing up the with current state of what data is
    % currently loaded, and cause reloading of data already loaded and
    % displaying it in the wrong place.
    persistent bufferedPanInProccess;
    
    if isempty(bufferedPanInProccess)
        bufferedPanInProccess = false;
    end
    
    if bufferedPanInProccess
    	return;
    end
    
    bufferedPanInProccess = true;
    
    pan@Annote(obj, direction)   
    
    xlim = obj.hFigure.CurrentAxes.XLim;
    ylim = obj.hFigure.CurrentAxes.YLim;
    
    ydir = 0; xdir = 0;

    if (xlim(1) < obj.xBlockBuffer) && (obj.currentBlockCols(1) ~= 1)
        xdir = -1;
    elseif (xlim(2) > (obj.imWidth - obj.xBlockBuffer)) && (obj.currentBlockCols(end) ~= obj.metadata.NumColumnBlocks)
        xdir = 1;
    end

   
    if (ylim(1) < obj.yBlockBuffer) && (obj.currentBlockRows(1) ~= 1)
        ydir = -1;
    elseif (ylim(2) > (obj.imHeight - obj.yBlockBuffer)) && (obj.currentBlockRows(end) ~= obj.metadata.NumRowBlocks)
        ydir = 1;
    end
    
    if (ydir == 0) && (xdir == 0)
        bufferedPanInProccess = false;
        return
    end
    
    % Check boundaries (only one condition can ever happen at a time)
    newRows = obj.currentBlockRows + ydir;
    newCols = obj.currentBlockCols + xdir;
    
    [m, n, ~] = size(obj.hImage.CData);
    if (xdir > 0)
        if(newCols(end) > obj.metadata.NumColumnBlocks) 
            xdir = 0;
        else
            
            if (newRows(end) > obj.metadata.NumRowBlocks) 
            end
            loadRows = newRows;
            loadCols = newCols(end);
            shiftFromRows = 1:m;  
            shiftFromCols = (obj.metadata.NumColumnPixelsPerBlock+1):n;
            shiftToRows   = 1:m;
            shiftToCols   = 1:(n-obj.metadata.NumColumnPixelsPerBlock);
            insertRows    = 1:m;
            insertCols    = (n-obj.metadata.NumColumnPixelsPerBlock+1):n;
        end
    elseif (xdir < 0) 
        if (newCols(1) < 1)
            xdir = 0;
        else
            loadRows = newRows;
            loadCols = newCols(1);  
            shiftFromRows = 1:m;  
            shiftFromCols = 1:(n-obj.metadata.NumColumnPixelsPerBlock);
            shiftToRows   = 1:m;
            shiftToCols   = (obj.metadata.NumColumnPixelsPerBlock+1):n;
            insertRows    = 1:m;
            insertCols    = 1:obj.metadata.NumColumnPixelsPerBlock;
        end
    end
        
    if (ydir > 0)
        if (newRows(end) > obj.metadata.NumRowBlocks) 
             ydir = 0;
        else
            loadRows = newRows(end);
            loadCols = newCols; 
            shiftFromRows = (obj.metadata.NumRowPixelsPerBlock+1):m;  
            shiftFromCols = 1:n;
            shiftToRows   =  1:(m-obj.metadata.NumRowPixelsPerBlock);
            shiftToCols   = 1:n;
            insertRows    = (m-obj.metadata.NumRowPixelsPerBlock+1):m;
            insertCols    = 1:n;
        end
    elseif (ydir < 0) 
        if (newRows(1) < 1)
             ydir = 0;
        else
            loadRows = newRows(1);
            loadCols = newCols; 
            shiftFromRows = 1:(m-obj.metadata.NumRowPixelsPerBlock);  
            shiftFromCols = 1:n;
            shiftToRows   = (obj.metadata.NumRowPixelsPerBlock+1):m;
            shiftToCols   = 1:n;
            insertRows    = 1:obj.metadata.NumRowPixelsPerBlock;
            insertCols    = 1:n;
        end
    end
    
  
    if (ydir == 0) && (xdir == 0)
        bufferedPanInProccess = false;
        return
    end
    
    % Update 
    newRows = obj.currentBlockRows + ydir;
    newCols = obj.currentBlockCols + xdir;
    
    expectedBlockImageSize = [numel(loadRows)*obj.metadata.NumRowPixelsPerBlock  numel(loadCols)*obj.metadata.NumColumnPixelsPerBlock];
    
    title(obj.hFigure.CurrentAxes, 'Buffering...', 'FontWeight', 'Normal'); drawnow
    
    % Load new image block
    [ blockImage, rowRange, colRange ] = loadImageData(obj, [], [], loadRows, loadCols);
    
    title(obj.hFigure.CurrentAxes, ''); drawnow
    
    cdata = obj.hImage.CData;

    if any(expectedBlockImageSize >  [size(blockImage, 1) size(blockImage, 2)] )
        tmp = zeros(expectedBlockImageSize(1), expectedBlockImageSize(2), size(blockImage,3));
        tmp(1:size(blockImage,1), 1:size(blockImage,2), :) = blockImage;
        blockImage = tmp;
    end

    % Shift Previous Data
    cdata(shiftToRows, shiftToCols, :) = cdata(shiftFromRows, shiftFromCols, :);
    
    % Insert New Data
    cdata(insertRows, insertCols, :) = blockImage;

    anchorX = (newCols(1)-1) * obj.metadata.NumColumnPixelsPerBlock ;
    anchorY = (newRows(1)-1) * obj.metadata.NumRowPixelsPerBlock    ;
    
    if xdir == 0  % Move in Y-direction
        obj.currentCols = anchorX  + [1  diff(colRange)+1];
        obj.currentRows = anchorY +  [1  ((numel(newRows)-1)*obj.metadata.NumRowPixelsPerBlock + diff(rowRange)+1) ];
    else % Move in X-direction
        obj.currentCols = anchorX +  [1  ((numel(newCols)-1)*obj.metadata.NumColumnPixelsPerBlock + diff(colRange)+1) ];
        obj.currentRows = anchorY  + [1  diff(rowRange)+1];
    end

    
    % Begin: Common code from Geo-Jump  (TODO: Functionize)
    oldXLim = obj.hFigure.CurrentAxes.XLim;
    oldYLim = obj.hFigure.CurrentAxes.YLim;
    
    xShift =  - xdir*numel(insertCols);
    yShift =  - ydir*numel(insertRows);
    
    newXLim = oldXLim + xShift;
    newYLim = oldYLim + yShift;
    
    obj.hImage.CData = cdata;
    obj.hFigure.CurrentAxes.XLim = newXLim;
    obj.hFigure.CurrentAxes.YLim = newYLim;
    
    % -- Update Polygons
    % TODO: consolidate polygon management functions (also in geoJump)
    hP = obj.hPolys;
    if ~isempty(hP) 
        if yShift ~= 0 
            if  numel(hP) > 1
                tmp = get(hP, 'YData');
                % Redraw polygons
                cellfun(@(h,y) set(h, 'YData', y+yShift), num2cell(hP), tmp')
            else
                set(hP, 'YData', get(hP, 'YData') + yShift);
            end
        end
        if xShift ~= 0
            if  numel(hP) > 1
                tmp = get(hP, 'XData');
                % Redraw Polygons
                cellfun(@(h,x) set(h, 'XData', x+xShift), num2cell(hP), tmp')
            else
                set(hP, 'XData', get(hP, 'XData') + xShift);
            end
        end
    end

    obj.currentBlockRows = newRows;
    obj.currentBlockCols = newCols;
    
    obj.updateSnailTrail(1);
    obj.updateSnailTrail(0);
    
    % End Geo-Jump Code
    
    bufferedPanInProccess = false;
end