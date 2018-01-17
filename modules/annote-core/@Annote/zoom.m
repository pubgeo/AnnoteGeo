function zoom(obj, direction)
% ZOOM 
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
        if direction == 0
          limx  = [1 obj.zoomMaxAxisX] + (obj.imColRange(end) - obj.imColRange(1))/2;
          limy  = [1 obj.zoomMaxAxisY] + (obj.imRowRange(end) - obj.imRowRange(1))/2;
          xlim(obj.hAxis, limx)
          ylim(obj.hAxis, limy)
          return
        end
 
        x = xlim;
        y = ylim;
        
        scale   = 0.2;
        
        xrng    = (x(2) - x(1));
        xrngNew = xrng*(1-direction*scale);
        
        yrng    = (y(2) - y(1));
        yrngNew = yrng*(1-direction*scale);
        
        if yrngNew > obj.zoomMaxAxisY
            yrngNew = obj.zoomMaxAxisY;
        end
       
        if xrngNew > obj.zoomMaxAxisX
            xrngNew = obj.zoomMaxAxisX;
        end


        cx = obj.mousePos(1);
        cy = obj.mousePos(2);
        
        if cx < obj.hImage.XData(1);    return; end
        if cy < obj.hImage.YData(1);    return; end
        if cx > obj.hImage.XData(end);  return; end
        if cy > obj.hImage.YData(end);  return; end
        if cx < x(1); return; end
        if cy < y(1); return; end
        if cx > x(2); return; end
        if cy > y(2); return; end
        
        
        xratio = abs((cx-x(1))./xrng);
        yratio = abs((cy-y(1))./yrng);
        
        xnew = xrngNew*[-xratio 1-xratio] + cx;
        ynew = yrngNew*[-yratio 1-yratio] + cy;
         
        if ynew(2) <= ynew(1) || xnew(2) <= xnew(1)
          return;
        end
        
        if xnew(1) < obj.hImage.XData(1)
          xnew(1) = obj.hImage.XData(1);
        end
        
        if xnew(end) > obj.hImage.XData(end)
           xnew(end) = obj.hImage.XData(end);
        end
        
         if ynew(1) < 1
          ynew(1) = 1;
        end
        
        if ynew(end) > obj.hImage.YData(end)
           ynew(end) = obj.hImage.YData(end);
        end
        
        ylim(ynew);
        xlim(xnew);
        
     end