function [ bits ] = visualize_image( image )

% NAME: visualize_image
%
% DESCRIPTION:
%   Byte-scale the image to 8 bits and/or reduce 
%   to true color for visualization
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

[nr,nc,nb] = size(image);

% For two band, assume complex (real and imaginary) and compute 
%   square root of the magnitude
% For multi-spectral, choose bands based upon knowledge
%   of sensor bands for expected uses

pmin = [] ;
pmax = [] ;

if (nb == 2)
    band1 = double( image(:,:,1) );
    band2 = double( image(:,:,2) );
    magnitude = sqrt( band1 .* band1 + band2 .* band2 );
    data = sqrt( magnitude );
    minimage = min(min(data));
    maximage = max(max(data));
    image = uint16( 50000 * (data - minimage) / (maximage-minimage) );
    nb = 1;
    pmin = 0.25 ;
    pmax = 0.999 ;
elseif (nb == 3)
    desired_bands = [ 1, 2, 3 ];
elseif (nb == 4)
    desired_bands = [ 3, 2, 1 ]; % assume standard 4 band MSI
elseif (nb == 8)
    desired_bands = [ 5, 3, 2 ]; % assume WV02 8 band MSI
else
    b1 = round(nb*7/8);
    b2 = round(nb*4/8);
    b3 = round(nb*1/8);
    desired_bands = [ b1, b2, b3 ];
end;

% Byte-scale using histogram-based dynamic range algorithm
% Check for contrast and set image to X if none

if (nb == 1)
    minval = min(min(image));
    maxval = max(max(image));
    if ((maxval-minval) > 0)
        if (~isa(image,'uint8'))
            bits = nga_dra( image, pmin, pmax );
        else
            bits = image;
        end;
    else
        x = ones( [nr,nc], 'uint8' );
        x = mark_line_in_image( x, 1, 1, nr, nc, 255 );
        x = mark_line_in_image( x, nr, 1, 1, nc, 255 );
        bits = x;
    end;
    bits(:,:,2) = bits(:,:,1);
    bits(:,:,3) = bits(:,:,1);
else
    bits = zeros( nr, nc, 3, 'uint8' );
%    bdl_image = nga_bdl( image(:,:,desired_bands) );
    for band = 1:3
        img = image(:,:,desired_bands(band));
%        img = bdl_image(:,:,band);
        minval = min(min(img));
        maxval = max(max(img));
        if ((maxval-minval) > 0)
            bits(:,:,band) = nga_dra( img );
        else
            x = ones( [nr,nc], 'uint8' );
            x = mark_line_in_image( x, 1, 1, nr, nc, 255 );
            x = mark_line_in_image( x, nr, 1, 1, nc, 255 );
            bits(:,:,band) = x;
        end;
    end;
end

end