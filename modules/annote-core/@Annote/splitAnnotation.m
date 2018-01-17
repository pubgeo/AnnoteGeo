function  splitAnnotation(obj)
% SPLITANNOTATION
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
    if obj.isDrawActive == false

        obj.isDrawActive = true;

        xyNew = roiPolygonSplit(obj.hPolys(obj.selectedPoly));

        % If annotation was split
        if ~isempty(xyNew{2})
            obj.updateAnnotation(obj.hPolys(obj.selectedPoly), xyNew{1}(:,1), xyNew{1}(:,2));

            % Convert entry into expected map format
            entry = obj.table.getEntryMap(obj.selectedPoly);


            obj.addAnnotation( xyNew{2}(:,1), xyNew{2}(:,2), entry);
        end

          obj.isDrawActive = false;
    end

end

