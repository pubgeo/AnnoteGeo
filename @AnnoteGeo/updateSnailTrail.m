function updateSnailTrail(obj, isBlockChange, disableActiveOnly)
% UPDATESNAILTRAIL
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

    % Turns any Green to Cyan in current view.  Used to support geoJump.m
    if ~exist('disableActiveOnly', 'var') || isempty(disableActiveOnly)
        disableActiveOnly = false;
    end
    
    
    
    maskRows = round(obj.currentRows./obj.snailTrailZoomLevel);
    maskCols = round(obj.currentCols./obj.snailTrailZoomLevel);

    if isBlockChange > 0

        if maskCols(1) == 0; maskCols(1) = 1; end
        if maskRows(1) == 0; maskRows(1) = 1; end
        if maskCols(end) == size(obj.snailTrailMask,2); maskCols(end) = size(obj.snailTrailMask,2); end
        if maskRows(end) == size(obj.snailTrailMask,1); maskRows(end) = size(obj.snailTrailMask,1); end

        obj.snailTrailMask(maskRows, maskCols) = 1;

        cdataChip = obj.hImgSnail.CData(maskRows(1):maskRows(2), maskCols(1):maskCols(2),1);
        maskChip  = obj.snailTrailMask(maskRows(1):maskRows(2), maskCols(1):maskCols(2));

        % Update Loaded Image
        cdataChip(maskChip == 0) = cdataChip(maskChip == 0).*1.5;
        obj.hImgSnail.CData(maskRows(1):maskRows(2), maskCols(1):maskCols(2),1) = cdataChip;

        maskChip(maskChip == 0) = 1;
        obj.snailTrailMask(maskRows(1):maskRows(2), maskCols(1):maskCols(2)) = maskChip;

        if ~isfield(obj.hFigSnail.UserData, 'hCurrentBlock')
            obj.hFigSnail.UserData.hCurrentBlock = patch(maskCols([1 1 2 2]), maskRows([1 2 2 1]),...
                'c', 'FaceColor', 'none', 'EdgeColor', [1 .8 0.1].*0.8, 'LineWidth', 2, 'Parent', obj.hFigSnail.CurrentAxes);
        else
            set(obj.hFigSnail.UserData.hCurrentBlock, 'Vertices', [maskCols([1 1 2 2]); maskRows([1 2 2 1])]');
        end
        drawnow
        
    elseif isBlockChange == 0

        if maskCols(1) == 0; maskCols(1) = 1; end
        if maskRows(1) == 0; maskRows(1) = 1; end
        if maskCols(end) == size(obj.snailTrailMask,2); maskCols(end) = size(obj.snailTrailMask,2); end
        if maskRows(end) == size(obj.snailTrailMask,1); maskRows(end) = size(obj.snailTrailMask,1); end

        obj.snailTrailMask(maskRows, maskCols) = 1;

        maskChip  = obj.snailTrailMask(maskRows(1):maskRows(2), maskCols(1):maskCols(2));

        newMaskChip = zeros(size(maskChip));
        
        if ~disableActiveOnly
            xlim = round(obj.hFigure.CurrentAxes.XLim./(obj.currentCols(2)-obj.currentCols(1)+1)*size(maskChip,2));
            ylim = round(obj.hFigure.CurrentAxes.YLim./(obj.currentRows(2)-obj.currentRows(1)+1)*size(maskChip,1));

            if xlim(1) <= 0; xlim(1) = 1; end
            if ylim(1) <= 0; ylim(1) = 1; end
            if xlim(2) > size(newMaskChip,2); xlim(2) = size(newMaskChip,2); end
            if ylim(2) > size(newMaskChip,1); ylim(2)= size(newMaskChip,1); end


            newMaskChip(ylim(1):ylim(2),xlim(1):xlim(2)) = 1;
        end


        enable = newMaskChip == 1;
        disable = maskChip == 2 & newMaskChip == 0;

        cdataChip = obj.hImgSnail.CData(maskRows(1):maskRows(2), maskCols(1):maskCols(2),:);
        ch1 = cdataChip(:,:,1);
        ch2 = cdataChip(:,:,2);
        ch3 = cdataChip(:,:,3);

        
        % Current Location - Cyan -> Green
        ch3(enable & maskChip==2) = ch1(enable & maskChip==2);  % "Uncolored"
        ch2(enable & maskChip==2) = ch1(enable & maskChip==2)*1.8;



        % Current Location - Red -> Green
        ch1(enable & maskChip==1) = ch3(enable & maskChip==1);  % "Uncolored"
        ch2(enable & maskChip==1) = ch1(enable & maskChip==1)*1.8;
        ch3(enable & maskChip==1) = ch1(enable & maskChip==1);  % "Uncolored"

        maskChip(enable) = 2;

        % Visited Location: Green -> Cyan
        ch3(disable) = ch1(disable)*1.8;



        % Update Loaded Image;
        obj.hImgSnail.CData(maskRows(1):maskRows(2), maskCols(1):maskCols(2),:) = cat(3, ch1, ch2, ch3);
        obj.snailTrailMask(maskRows(1):maskRows(2), maskCols(1):maskCols(2)) = maskChip;

        if ~disableActiveOnly
            if ~isfield(obj.hFigSnail.UserData, 'hCurrentView')
                obj.hFigSnail.UserData.hCurrentView = patch(maskCols(1) - 1 + xlim([1 1 2 2]), maskRows(1) - 1 + ylim([1 2 2 1]),...
                    'c', 'FaceColor', 'none', 'EdgeColor', [.4 1 0.2].*0.7, 'LineWidth', 2, 'Parent', obj.hFigSnail.CurrentAxes);
            else
                set(obj.hFigSnail.UserData.hCurrentView, 'Vertices', [ maskCols(1) - 1 + xlim([1 1 2 2]);  maskRows(1) - 1 + ylim([1 2 2 1])]');
            end
            drawnow
        end

    else % Reset
        
        % Remove color coding
        mask  = obj.snailTrailMask;
        
        ch1 = obj.hImgSnail.CData(:,:,1);
        ch2 = obj.hImgSnail.CData(:,:,2);
        ch3 = obj.hImgSnail.CData(:,:,3);

        ch2(mask == 2) = ch1(mask == 2);
        ch3(mask == 2) = ch1(mask == 2);
        ch1(mask == 1) = ch2(mask == 1);
        
        obj.hImgSnail.CData = cat(3, ch1, ch2, ch3);
        obj.snailTrailMask  = zeros(size(mask));

        delete(obj.hFigSnail.UserData.hCurrentBlock)
        delete(obj.hFigSnail.UserData.hCurrentView)
        
        obj.hFigSnail.UserData = rmfield(obj.hFigSnail.UserData, 'hCurrentBlock');
        obj.hFigSnail.UserData = rmfield(obj.hFigSnail.UserData, 'hCurrentView');
        
    end

end

