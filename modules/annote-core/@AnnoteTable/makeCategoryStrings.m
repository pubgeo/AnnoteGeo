function [typeNames, typeNamePairs] = makeCategoryStrings( typeMap )
% MAKECATEGORYSTRINGS 
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

  colHeaders  = {typeMap.majorLabel};
      

  % Make lists of names to put in table drop downs
  typeNames = cell(1,numel(colHeaders));
  typeNamePairs = cell(1,numel(colHeaders));
  for p = 1:numel(colHeaders)       
      thisCol = typeMap(p);
      keys = thisCol.labelMap(:,1);
      thisList = cell(2,numel(keys));
      thisMap  = cell(2,numel(keys));
      for q = 1:numel(keys)
          thisList{1,q} = sprintf('%2d. %s', q, keys{q});
          thisMap{1,q} = {{keys{q},''}};
          vals =  thisCol.labelMap{q,2};
          if ~isempty(vals)
            thisList{2,q} = cellfun(@(x,y) sprintf(' %2d%s. %s', q, x, y), num2cell(char( (1:numel(vals)) + 96)), vals, 'UniformOutput', false);
            thisMap{2,q} = cellfun(@(v) {keys{q},v}, vals, 'UniformOutput', false); 
          else
            thisList{2,q} = {};
            thisMap{2,q} = {};
          end
      end
      
     typeNames{p}  = [thisList{:}];
     
     tmp = [thisMap{:}]';
     typeNamePairs{p} = cat(1,tmp{:});
  end
      

end

