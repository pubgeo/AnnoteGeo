function cm = getAnnotationColor(obj, entry, key, isColumnKey)
% GETANNOTATIONCOLOR 
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
    if ~exist('isColumnKey', 'var') || isempty(isColumnKey)
        isColumnKey = false;
    end
    
    if ~exist('entry', 'var') || isempty(entry)
        cm = obj.colormapMap(obj.colorUnassignedKey);
        return;
    end

    if ~exist('key', 'var') || isempty(key) 
        cm = obj.colormapMap(obj.colorUnassignedKey);
        return;
    end
    
    % Lookup column key from keyword mapping
    if ~isColumnKey  
        if obj.colorKeyMap.isKey(key)
            key = obj.colorKeyMap(key);
        else
            cm = obj.colormapMap(obj.colorUnassignedKey);
            return;  
        end 
    end
    
    if isnumeric(key)
        key = obj.table.getColumnName(key);
    end
        
    % Lookup the colormap
    if obj.colormapMap.isKey(key)
       thisColormap = obj.colormapMap(key);
    else
        cm = obj.colormapMap(obj.colorUnassignedKey);
        return;
    end
   
   
    if ischar(key)
        colorDefiningColumnIndex = obj.table.getColumnIndex(key);
    end
    
    colorInd = obj.table.getDropDownIndex(entry{colorDefiningColumnIndex}, colorDefiningColumnIndex);
    if sum(colorInd) == 1
        cm = thisColormap(colorInd, :);
    else
        cm = obj.colormapMap(obj.colorUnassignedKey);
    end
end

