function [xOut, yOut] = roiPolygonEdit(xIn, yIn, hAxis, isClosed)
% ANNOTE 
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

xOut = []; 
yOut = [];

if nargin < 2 || isempty(xIn) || isempty(yIn) || numel(yIn) < 3 || numel(xIn) < 3 || (numel(xIn) ~= numel(yIn))
    yIn = [];
    xIn = [];
end

if ~exist('isClosed' , 'var') || isempty(isClosed)
    isClosed = true;
end

if ~exist('hAxis', 'var') || isempty(hAxis)
   hAxis  = get(gcf,'CurrentAxes');
end

if isempty(hAxis) || isempty( findobj(hAxis, 'Type', 'image') )
    return;
end

[xOut,yOut, wasCancelled] = doEditablePoly(gca, [xIn(:) yIn(:)], isClosed);
xOut      = double(xOut);
yOut      = double(yOut);

% Check of operation cancelled or not enough points
if wasCancelled || (numel(xOut) < 3 && isClosed) || (numel(xOut) < 2 && ~isClosed)
    xOut = [];
    yOut = [];
    return;
end

% Close the polygon
if ( xOut(1) ~= xOut(end) || yOut(1) ~= yOut(end) )  && isClosed
    xOut = [xOut; xOut(1)]; 
    yOut = [yOut; yOut(1)];
end


% Transform xi,yi into pixel coordinates.
[xdata,ydata,a] = getimage(hAxis);
nrows = size(a,1);
ncols = size(a,2);
xOut = axes2pix(ncols, xdata, xOut);
yOut = axes2pix(nrows, ydata, yOut);

end 

    

function [x, y, wasCancelled] = doEditablePoly(hAxis,initPos, isClosed)

x = [];
y = [];

if ~exist('initPos', 'var')
  initPos = [];
end

% Create interactive poly
obj = impoly(hAxis,initPos, 'Closed', isClosed);


wasCancelled = isempty(obj);
if wasCancelled
    return;
end

% Wait...
pos = wait(obj);

% Remove the interactive polygon from the image
obj.delete();

if isempty(pos);
    wasCancelled = true;
    return;
end

x = pos(:,1);
y = pos(:,2);


end



    
