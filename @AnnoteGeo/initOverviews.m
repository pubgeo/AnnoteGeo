function initOverviews(obj, image_file)
% INITOVERVIEWS
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
      
        if ~ischar(image_file)
            error('%s: Input image must be filename', toolTitle);
        end
 
        % ======= Enable Image Overview/Snail Trail Image
        
        % Display new overview image
        maxDim = 900;
        max(obj.metadata.NumImageRows, obj.metadata.NumImageColumns)
        rrdsLevel = nextpow2(max(obj.metadata.NumImageRows, obj.metadata.NumImageColumns)/maxDim)+1;
        if rrdsLevel < 1
            rrdsLevel = 1;
        end
        zoomLevel = 2^rrdsLevel;
        
        % ===== START: CREATE OVERVIEW IMAGE ======
        image_region = ReadImageRegion(image_file, obj.metadata, [1 obj.metadata.NumImageRows], [1 obj.metadata.NumImageColumns], rrdsLevel);        
 
        bits = visualize_image( image_region );
        
        if size(bits, 3) == 3
            bits = rgb2gray(bits);
        else
            bits = double(bits);
            bits = (bits - min(bits(:))) / (max(bits(:)) - min(bits(:)));
        end
        
        bits = repmat(bits, 1, 1, 3);

        snailName = 'Overview';
        tag = [obj.toolTitle ':' snailName];
        if isempty(findobj('Tag',tag))
            obj.hFigSnail = figure('Tag', tag);
            set(obj.hFigSnail, 'NumberTitle', 'off')
            set(obj.hFigSnail, 'Name', snailName);
            obj.hImgSnail = imagesc(bits, 'Parent', gca);
            axis equal tight
        else
            obj.hFigSnail = figure(findobj('Tag',tag));
            obj.hImgSnail = findobj(obj.hFigSnail, 'Type', 'Image');
            obj.hImgSnail.CData = bits;
        end
        
        % ===== END: CREATE OVERVIEW IMAGE ======
        
        
        obj.snailTrailMask = zeros(size(obj.hImgSnail.CData,1), size(obj.hImgSnail.CData,2));
        
        obj.snailTrailZoomLevel = zoomLevel;
        
        obj.hImgSnail.ButtonDownFcn = [];
        set(obj.hFigSnail, 'WindowButtonMotionFcn', @obj.snailTrailCallbackWindowButtonMotionFcn); 

       
        if ~isfield(obj.hFigSnail.UserData, 'hReset') &&  ~isfield(obj.hFigSnail.UserData, 'hGeoJump')
        
             % Modify existing toolbar
            hToolbar = findall(obj.hFigSnail,'Type','uitoolbar');
            
            % Add a push tool to the toolbar
            img2 = rand(16,16,3).*0.5;
            img2(img2>1) = 1;
            img2(7:10, 7:10, :) = 1;
            hReset = uipushtool(hToolbar,'CData',img2,'Separator','off',...
                                    'TooltipString','Reset',...
                                    'HandleVisibility','off'); 
            obj.hFigSnail.UserData.hReset = hReset;   
            set(obj.hFigSnail.UserData.hReset, 'ClickedCallback', @(source, event)callbackResetPushTool(obj, source, event));
            
            % Relocated new button to beginning of toolbar
            oldOrder = allchild(hToolbar);                           
            newOrder = oldOrder([2:end 1]);
            hToolbar.Children = newOrder;
            newOrder(end-1).Separator = 'on';

     
            % Modify existing toolbar
            hToolbar = findall(obj.hFigSnail,'Type','uitoolbar');
        
            % Add a toggle tool to the toolbar
            img2 = rand(16,16,3).*0.5;
            img2(img2>1) = 1;
            img2(8:9, 3:14, :) = 1;
            img2(3:14, 8:9, :) = 1;
            hGeoJump = uitoggletool(hToolbar,'CData',img2,'Separator','off',...
                                   'TooltipString','Geo Jump',...
                                   'HandleVisibility','off'); 
            obj.hFigSnail.UserData.hGeoJump = hGeoJump;   
            set(obj.hFigSnail.UserData.hGeoJump, 'ClickedCallback', @(source, event)callbackGeoJumpToggleTool(obj, source, event));
            
            % Relocated new button to beginning of toolbar
            oldOrder = allchild(hToolbar);                           
            newOrder = oldOrder([2:end 1]);
            hToolbar.Children = newOrder;

            jToolbar = [];
            while isempty(jToolbar)
              jToolbar = get(get(hToolbar,'JavaContainer'),'ComponentPeer');  
              pause(0.1);
            end
            jText = javax.swing.JLabel;
            jText.setText('(0000000, 0000000) ')
            jSize = java.awt.Dimension(140,22);  % 100px wide, 25px tall
            jText.setMaximumSize(jSize)
            jText.setMinimumSize(jSize)
            jText.setPreferredSize(jSize)
            jText.setSize(jSize)
            jText.setVerticalAlignment(jText.CENTER)
            jText.setHorizontalAlignment(jText.RIGHT)
            jToolbar.add(jText,2);

            jText.setOpaque(true);
            jText.setBackground(java.awt.Color.white)
            
            % TODO There is something weird with the Java calls no being
            % synchronized with the rest of matlab 
            while ~isfield(obj.hFigSnail.UserData, 'jPixelPos')
              obj.hFigSnail.UserData.jPixelPos = jText;   
            end
        
            set(obj.hFigSnail, 'NumberTitle', 'off');
            
        end
        
        

    end