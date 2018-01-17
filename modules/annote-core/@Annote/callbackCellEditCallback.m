function callbackCellEditCallback(obj, handles, eventdata)
% CALLBACKCELLEDITCALLBACK 
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
%        
      tableRow = eventdata.Indices(1,1);
      tableCol = eventdata.Indices(1,2);
      % Category drop downs
      
      % Update annotation color
      entry =  obj.table.getViewEntry(tableRow);
      h = obj.hPolys(tableRow);
      obj.setAnnotationColor(h, entry);

      % Determine if 'Display' checkbox changed
      if strcmp(obj.table.getColumnName(tableCol), 'Display')
         if eventdata.NewData == 1
           set(h, 'Visible', 'on')
         else
           set(h, 'Visible', 'off')
         end

      end
      
    end
      