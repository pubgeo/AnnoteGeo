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
 
        x = xlim;
        y = ylim;
        
        scale   = 0.1;
        
        xrng    = (x(2) - x(1));        
        yrng    = (y(2) - y(1));      
        
        % Left/Right
        if abs(direction) == 2
          xnew = x + xrng*scale*direction;
        else
          xnew = x;
        end
        
        % Up/Down
        if abs(direction) == 1
          ynew = y - yrng*scale*direction;
        else
          ynew = y;
        end
        
        if ynew(2) <= ynew(1) || xnew(2) <= xnew(1)
          return;
        end
        
        if xnew(1) < obj.hImage.XData(1)
          xnew(1) = obj.hImage.XData(1);
          xnew(2) =  xnew(1) + xrng;
        end
        
        if xnew(2) > obj.hImage.XData(end)
           xnew(2) = obj.hImage.XData(end);
           xnew(1) = xnew(2) - xrng;
        end
        
         if ynew(1) < obj.hImage.YData(1)
          ynew(1) = obj.hImage.YData(1);
          ynew(2) = ynew(1) + yrng;
        end
        
        if ynew(2) > obj.hImage.YData(end)
           ynew(2) = obj.hImage.YData(end);
           ynew(1) = ynew(2) - yrng;
        end
        
        ylim(ynew);
        xlim(xnew);
        
        
     end