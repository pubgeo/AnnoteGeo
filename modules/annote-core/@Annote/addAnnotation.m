function addAnnotation(obj, x, y, catMap)
% ADDANNOTATION 
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
    % Display user polygon
    hold(obj.hImage.Parent, 'on');
    obj.hPolys = [obj.drawAnnotation(x,y) obj.hPolys];
    hold(obj.hImage.Parent, 'off');
    

    obj.hPolys(1).Interruptible = 'off';
    obj.hPolys(1).ButtonDownFcn = @obj.callbackAnnotationButtonDownFcn;
	
	% New new annotation is inserted at beginning of arrays  (hPolys, table, etc)
    obj.setAnnotationContextMenu(obj.hPolys(1));
    
    % Update table
    entries = obj.createDerivedEntries(x,y);

    if exist('catMap', 'var') && ~isempty(catMap)
        keys = catMap.keys;
        for p = 1:numel(keys)
            % Don't allow derived entires to be overridden
            if ~entries.isKey(keys{p}) 
                entries(keys{p}) =  catMap(keys{p});
            end
        end
    end
    obj.table.addEntry(entries);


    % Update color
    eventdata.Indices = [1 1]; % New entries get added to top
    eventdata.NewData = [];
    obj.callbackCellEditCallback([], eventdata)
      

    obj.selectedPoly = 1;

end

