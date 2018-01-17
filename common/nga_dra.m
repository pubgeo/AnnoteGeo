function [ out_image ] = nga_dra( in_image, pmin, pmax )

% NAME: nga_dra
%
% DESCRIPTION:
%   Implement NGA's dynamic range adjustment (dra)
%   algorithm as described in Paragraph 2.6 of reference.
%
% REFERENCE:
%   NGA.STND.0014_2.2, "Softcopy Image Processing Standard," 
%   Version 2.2, 2010/07/13.
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

% Default values for controls

%pmin = 0.02 ;
%pmax = 0.98 ;
%capa = 0.2 ;
%capb = 0.4 ;

if (nargin < 2)
    pmin = [] ;
end;

if (nargin < 3)
    pmax = [] ;
end;

if (isempty(pmin))
    pmin = 0.025 ;
end;

if (isempty(pmax))
    pmax = 0.99 ;
end;

capa = 0.1 ;
capb = 0.5 ;

Ymax = 255 ;
Xmax = 2^16 ;

% Histogram the image

x = 0:(Xmax-1);
q = reshape( in_image, numel(in_image), 1 );
h = hist( q, x );

h(1) = 0; % ignore zeros

% Find first and last entries

min_idx = 1;
done = 0;
idx = min_idx;
while( (done < 1) && (idx < size(h,2)) )
    if (h(idx) > 0) 
        min_idx = idx;
        done = 1;
    end
    idx = idx + 1;
end
Efirst = min_idx;

max_idx = Xmax-1;
done = 0;
idx = max_idx;
while ( (done < 1) && (idx > 1) )
    if (h(idx) > 0) 
        max_idx = idx;
        done = 1;
    end
    idx = idx - 1;
end
Elast = max_idx;

% Form the cumulative histogram

ch = cumsum( h );
ch = ch / ch(end);

% Find the percentage endpoints

min_idx = Efirst ;
done = 0;
idx = min_idx;
while ( (done < 1) && (idx < size(h,2)) )
    if (ch(idx) >= pmin) 
        min_idx = idx;
        done = 1;
    end
    idx = idx + 1;
end
Emin = min_idx;

max_idx = Elast;
done = 0;
idx = max_idx;
while( (done < 1) && (idx > 1) )
    if (ch(idx) <= pmax) 
        max_idx = idx;
        done = 1;
    end
    idx = idx - 1;
end
Emax = max_idx;

% Adjust min/max values

fmin = Emin - capa*(Emax-Emin);
fmax = Emax + capb*(Emax-Emin);

if (Efirst > fmin) 
    fmin = Efirst;
end
if (Elast < fmax) 
    fmax = Elast;
end

% Offset and scale for adjustment

b = Ymax;
if (abs(fmax-fmin) >= 1e-03)
    b = Ymax / (fmax-fmin);
end
h = fmin;

% Map the input image to the output
% Per MATLAB documentation, the uint functions
% will clip outside values to endpoints

tmp_image = b * (double(in_image) - h);

if (Ymax <= 255)
    out_image = uint8( tmp_image );
else
    out_image = uint16( tmp_image );
end

end