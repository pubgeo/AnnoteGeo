function callbackGeoJumpToggleTool(obj, source, eventdata)
% CALLBACKGEOJUMPTOGGLETOOL
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
    allButtons = allchild(source.Parent);
   
    allButtonsThisIdx = allButtons == source;

    callBackFun = @obj.callbackGeoJumpButtonDownFcn;
    
     switch source.State
         case 'on'
             
             % Check if any other tools are enabled
              allToggles = findobj(allButtons, '-class',  class(source));
             
             isOn = strcmp({allToggles.State}, 'on');
             if sum(isOn) > 1 || (sum(isOn) == 1 && allToggles(isOn) ~= source)
                source.State = 'off';  % untoggle GeoJump button
                return;
             else
                 out = arrayfun(@(x) set(x, 'Enable', 'off'), allButtons(~allButtonsThisIdx), 'UniformOutput', false);
             end
             
             % Enable Cursor
             cursor = nan(16,16);
             cursor(8:9,:) = 2;
             cursor(:,8:9) = 2;
             cursor(8:9,8:9) = 1;
             cursor([7 10],:) = 1;
             cursor(:,[7 10]) = 1;
  
             set(obj.hFigSnail, 'Pointer', 'custom', 'PointerShapeCData', cursor,  'PointerShapeHotSpot', [8.5 8.5]);
             set(obj.hImgSnail,'ButtonDownFcn',callBackFun)


         case 'off'
             out = arrayfun(@(x) set(x, 'Enable', 'on'), allButtons, 'UniformOutput', false);
             set(obj.hFigSnail, 'Pointer', 'arrow');
            
             obj.hImgSnail.ButtonDownFcn = [];
     end
end

