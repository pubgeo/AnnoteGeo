function [s, table0, poly0, img0] = saveData( obj, table, poly, img, filename)
% SAVEDATA
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

  table0 = [];
  poly0  = [];
  img0   = [];

  imSize = size(img);

  types = table(:,1);
  types(cellfun(@isempty, types)) = {' 0. NOT LABELED'};
  label = unique(types);
  mask  = zeros(imSize(1), imSize(2), numel(label));
  for p = 1:numel(poly)
    ind = strcmp(label, types(p));
    tmp = roipoly(mask(:,:,ind), poly{p}(:,1), poly{p}(:,2));
    mask(:,:,ind) = mask(:,:,ind) | tmp;
  end
  
  s.imSize = imSize;
  s.label  = label;
  s.mask   = mask;
end

