function [ image ] = mark_line_in_image( in_image, in_r1, in_c1, in_r2, in_c2, color )
% NAME: mark_line_in_image
%
% DESCRIPTION:
%   Mark the pixels of a line in an image in
%   a brute force fashion.
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

image = in_image ;
[nr, nc, nb] = size( image );

r1 = round(in_r1);
r2 = round(in_r2);
c1 = round(in_c1);
c2 = round(in_c2);

j1 = min(c1,c2);
j2 = max(c1,c2);
i1 = min(r1,r2);
i2 = max(r1,r2);

%fprintf( 'Draw line (%i,%i) --> (%i,%i)\n', r1,c1,r2,c2 );

dr = (r2 - r1);
dc = (c2 - c1);

% Horizontal line
if (dr == 0) & (r1 >=1) & (r1 <= nr)
    for c = j1:j2
        if (c >= 1) & (c <= nc)
            image(r1,c,:) = color;
        end;
    end;
else
% Vertical line
    if (dc == 0) & (c1 >=1) & (c1 <= nc)
        for r = i1:i2
            if (r >= 1) & (r <= nr)
                image(r,c1,:) = color;
            end;
        end;
    else
% Diagonal line        
        m = dr / dc;
        if (abs(dr) > abs(dc))
% ... that is more vertical
             rows = i1:i2 ;
             m = 1/m ;
             b = c1 - m*r1;
 %            fprintf( '  More vertical %f,%f\n', m, b );
             cols = round( m*rows + b );
             for r = i1:i2
                 if (r >= 1) & (r <= nr) & (cols(r-i1+1) >= 1) & (cols(r-i1+1) <= nc)
                     image(r,cols(r-i1+1),:) = color;
                 end;
             end;
        else
% ... that is more horizontal
            cols = j1:j2 ;
            b = r1 - m*c1 ;
%            fprintf( '  More horizontal %f,%f\n', m, b );
            rows = round( m*cols + b );
            for c = j1:j2
                if (rows(c-j1+1) >= 1) & (rows(c-j1+1) <= nr) & (c >= 1) & (c <= nc)
                    image(rows(c-j1+1),c,:) = color ;
                end;
            end;
        end;
    end;
end;

end