function callbackAnnotationContextMenu(source,callbackdata, obj)
% CALLBACKANNOTATIONCONTEXTMENU 
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

      if ~strcmpi(callbackdata.EventName, 'Action')
          return;
      end

      % Top-level 'Edit'
      
      switch get(source, 'Tag')
          case 'annote.edit'
            obj.callbackEditButton([],[]);         
            
          case 'annote.delete'
               obj.callbackDeleteButton([],[]);         
              
          case 'annote.split'
                
              obj.splitAnnotation();
            
          case 'annote.category' 
              if(isempty(obj.multiSelectedPoly))
                  data = source.UserData;

                  colNum = obj.table.getColumnIndex(data.category);

                  m = containers.Map;
                  m(data.category) = obj.table.getTypeNameFromCat({data.major data.minor},colNum);

                  obj.table.updateEntry(m, obj.selectedPoly);

                  source.Checked = 'On';

                  entry =  obj.table.getViewEntry(obj.selectedPoly);
                  h = obj.hPolys(obj.selectedPoly);
                  obj.setAnnotationColor(h,entry)
                  
              else % multi selected poly
                  for i = 1:length(obj.multiSelectedPoly)
                     data = source.UserData;
                     colNum = obj.table.getColumnIndex(data.category);

                      m = containers.Map;
                      m(data.category) = obj.table.getTypeNameFromCat({data.major data.minor},colNum);

                      obj.table.updateEntry(m, obj.multiSelectedPoly(i));

                      source.Checked = 'On';
                      entry =  obj.table.getViewEntry(obj.multiSelectedPoly(i));
                      
                      h = obj.hPolys(obj.multiSelectedPoly(i));
                      obj.setAnnotationColor(h,entry)
                 end
              end
          otherwise
   
              obj.logger.warn(mfilename, sprintf('Unknown menu option selected'));
      end
end

