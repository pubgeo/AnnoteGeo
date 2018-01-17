classdef impolysplit < handle
% IMPOLYSPLIT 
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
    
    properties
        hPoly
        hAxis
        
        hPts
        
        hPreviewLine
        
        fcUnselected = 'r';
        fcSelected  = 'g';
        
        selected
        
        hKeyPressListener
        
        status;
        
    end
    
    methods
        function obj = impolysplit(h)
            if isstruct(h)
                obj.hPoly = h;
            else
                obj.hPoly = get(h);
            end
            
            obj.hAxis = obj.hPoly.Parent;
            hold(obj.hAxis, 'on')
            
            x = obj.hPoly.XData;
            y = obj.hPoly.YData;
            obj.hPts = zeros(1,numel(x));
            for p = 1:numel(x)
                obj.hPts(p) = plot(x(p), y(p), 'ro', 'Color', obj.fcUnselected, 'MarkerFaceColor', obj.fcUnselected, 'MarkerSize', 10);
                set(obj.hPts(p), 'ButtonDownFcn', {@obj.callbackLineButtonDownFunction, p});
                set(obj.hPts(p), 'UIContextMenu', obj.addContextMenu());                
            end
 
            obj.selected = [nan nan];
                    
            
            hold(obj.hAxis, 'off')
        end
        
        function delete(obj)
            delete(obj.hPts)
            delete(obj.hPreviewLine);
        end
        
        
        function callbackLineButtonDownFunction(obj, handles, eventdata, index)
            
            if ~strcmp(eventdata.EventName, 'Hit') || eventdata.Button ~= 1
                return
            end
        
            if any(obj.selected == index)
                return
            end
            
         
            mod = get(gcf,'CurrentModifier');
            if  ~isempty(mod) && strcmpi(mod, 'shift')
                obj.selected(1) = index;
                
            elseif  ~isempty(mod) && strcmpi(mod, 'control')
                obj.selected(2) = index;
                
            else   
                switch sum(~isnan(obj.selected))
                    case 0
                        obj.selected(1) = index;
                    case 1
                        obj.selected(2) = index;
                    case 2
                        obj.selected = [obj.selected(2) index];
                end
            end
            obj.updateImage();
            
            
           
            
        end
        
        
        function cmenu = addContextMenu(obj)
            
            cmenu = uicontextmenu;
            
            uimenu(cmenu, 'label', 'Preview', 'Callback', {@obj.callbackContextMenuPreview}, 'Checked', 'on');  
            uimenu(cmenu, 'label', 'Done',   'Callback',    {@obj.callbackContextMenuDone}, 'Separator', 'off');
            uimenu(cmenu, 'label', 'Cancel', 'Callback',    {@obj.callbackContextMenuCancel}, 'Separator', 'off');

        end
        
        function callbackContextMenuDone(obj, source,callbackdata)
            obj.status = 'Done';
    
        end
        
        function callbackContextMenuCancel(obj, source,callbackdata)
            obj.status = 'Cancel';
        end
        
        
        function [xy1, xy2] = getResults(obj)
                
            x = obj.hPoly.XData;
            y = obj.hPoly.YData;
            
            if any(isnan(obj.selected)) || strcmp(obj.status, 'Cancel')
                xy1 = [x y];
                xy2 = [];
            else
                ind = sort(obj.selected);
                xy1 =  [x(ind(1):ind(2))            y(ind(1):ind(2))];
                xy2 =  [[x(ind(2):end); x(1:ind(1))]  [y(ind(2):end); y(1:ind(1))]];
            end
        end
        
        function callbackContextMenuPreview(obj, source, callbackdata)
            
           if strcmp(source.Checked, 'off') 
               source.Checked = 'on';
               
              if ~isempty(obj.hPreviewLine)
                set(obj.hPreviewLine, 'Visible', 'on');
              end
           
           
                       
           elseif strcmp(source.Checked, 'on') 
               source.Checked = 'off';
               
              if ~isempty(obj.hPreviewLine)
                set(obj.hPreviewLine, 'Visible', 'off');
              end
           end
            
         
        end
        

    end % methods
    
    methods (Access = protected)
        
        function updateImage(obj)
               
            
            % Update vertices
            set(obj.hPts, 'Color', obj.fcUnselected, 'MarkerFaceColor', obj.fcUnselected); 
            set(obj.hPts(obj.selected(~isnan(obj.selected))), 'Color', obj.fcSelected, 'MarkerFaceColor', obj.fcSelected);
            
            
            % Update preview line
            if all(~isnan(obj.selected))
                x = [get(obj.hPts( obj.selected(1)), 'XData') get(obj.hPts( obj.selected(2)), 'XData')];
                y = [get(obj.hPts( obj.selected(1)), 'YData') get(obj.hPts( obj.selected(2)), 'YData')];

                if isempty(obj.hPreviewLine)
                    hold(obj.hAxis, 'on');
                    obj.hPreviewLine = plot(x, y, 'Color', obj.fcSelected, 'LineWidth', 4);
                    set(  obj.hPreviewLine, 'UIContextMenu', obj.addContextMenu()); 
                    hold(obj.hAxis, 'off');
                else
                    set( obj.hPreviewLine, 'XData', x, 'YData', y);
                end
            end
            
        end
    end
    
end

