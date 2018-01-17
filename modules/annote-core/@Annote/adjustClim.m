function adjustClim(obj, lowerUpper, inOut)
% ADJUSTCLIM 
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
    % lowerUpper:
    %               -1: Lower end of caxis
    %               +1: Upper end of caxis
    % inOut:
    %               -1: Reduce dyanmic range
    %               +1: Increase dyamic range

    if size(obj.hImage.CData,3) > 1
        return;
    end
    
    title(obj.hFigure.CurrentAxes, 'Adjusting...', 'FontWeight', 'Normal'); drawnow
    if ~exist('lowerUpper', 'var') || isempty(lowerUpper) ||...
       ~exist('inOut', 'var') || isempty(inOut)
     
       caxis(obj.hImage.Parent, 'auto')
    else
    
     cOld = obj.hImage.Parent.CLim;

     scale = 0.05;
     rng = cOld(2)-cOld(1);

     cNew = cOld;


     if lowerUpper == 1
       cNew(2) = (cNew(2)+inOut*rng*scale);
     else
       cNew(1) = (cNew(1)+inOut*rng*scale); 
     end

     obj.hImage.Parent.CLim = cNew;
    end
    
    
   title(obj.hFigure.CurrentAxes, ''); drawnow
end