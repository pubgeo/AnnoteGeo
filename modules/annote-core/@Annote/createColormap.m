function [cm, cmUnassigned]= createColormap(obj)
% CREATECOLORMAP 
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

    % Create a default colormap for each dropdown
    tmp = obj.table.getTypeNames;
    for p = 1:numel(tmp) 
        cm = jet(numel(tmp{p}));
        obj.colormapMap(obj.table.getColumnName(p)) = cm; 
    end
    obj.colormapMap(obj.colorUnassignedKey) = [200 255 0]./255;
    
    
    
    % Override with custom colormaps
    obj.createCustomColormap();
    
    
    % Check if colormaps are correct size
     for p = 1:numel(tmp) 
        n = numel(tmp{p});
        cm = obj.colormapMap(obj.table.getColumnName(p));
        
        if size(cm,1) < n
            obj.colormapMap(obj.table.getColumnName(p)) = [cm; jet(n - size(cm,1))];   
            obj.log.warning(mfilename, sprintf('createColormap produced too few colors for %s column', obj.table.getColumnName(p)));
        elseif size(cm,1) > n
           obj.log.warning(mfilename, sprintf('createColormap produced too many colors for %s column', obj.table.getColumnName(p))); 
        end
    end
   
    
end

