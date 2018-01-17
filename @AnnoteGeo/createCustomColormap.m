function createCustomColormap(obj)
% CREATECUSTOMCOLORMAP 
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
        

    colorKeys = obj.colormapMap.keys;

    for key  = colorKeys
        
        switch key{:}
            case 'Material'
                cmap = zeros(11, 3);
                cmap(1,:) = [0 0 0]/255; % Unclassified, Black
                cmap(2,:) = [160 32 240]/255; % Asphalt
                cmap(3,:) = [190 190 190]/255; % Concrete/Stone
                cmap(4,:) = [255 233 127]/255; % Glass
                cmap(5,:) = [46 139 87]/255; % Tree
                cmap(6,:) = [ 205 0 0]/255; % Non-tree veg
                cmap(7,:) = [176 48 96 ]/255; % Metal
                cmap(8,:) = [ 255 0 0]/255; % Red Ceramic
                cmap(9,:) = [255 165 0]/255; % Soil
                cmap(10,:) = [0 255 255]/255; % Solar Panel
                cmap(11,:) = [0 0 255]/255; % Water
                cmap(12,:) = [255 255 255]/255; % Polymer
                cmap(13,:) = [255 0 255]/255; % Unscored
            otherwise
                break;
                
        end
        obj.colormapMap(key{:}) = cmap;
    end
end

