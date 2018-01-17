 function callbackFigureResizeFcn(obj, handles, eventdata)
% CALLBACKFIGURERESIZEFCN
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

     if true
        obj.jTable.setAutoResizeMode(1)
     else
     numCols = obj.jTable.getColumnModel.getColumnCount;

     % FIXME: Sometimes on initialization, the columns don't exist yet...
     if numCols == 0
         return;
     end

     colWidth = cell(1,numCols);
     subWidth = 0;
     
     % Sum of widths minus the last column "Description"
     for p = 0 : (numCols-2)
        colWidth{p+1} = obj.jTable.getColumnModel.getColumn(p).getWidth;
        subWidth = subWidth +  colWidth{p+1};
     end

     absoluteWidth = obj.jTable.getParent.getWidth;

     % Desired width of column
     colWidth{end} = absoluteWidth-subWidth-2;
     set(obj.hTable,'columnwidth', colWidth);

     end
end

