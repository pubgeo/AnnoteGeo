function defaultEntry = tableCategoryDefaults(obj, typeMap, typeNames)
% TABLECATEGORYDEFAULTS
%
% DESCRIPTION:
%   
% 
% SYNTAX:
%       tableCategoryDefaults(obj, typeMap, typeNames)
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

    % TODO: Make defaults configurable
    dCat = typeNames{1}(~cellfun(@isempty, (strfind(typeNames{1}, 'Building (6)'))));
    if isempty('tmp')
        dCat = [typeNames{1}{6} repmat({''}, 1, numel(typeNames)-1)];
    end
    
    defaultEntry = [dCat repmat({''}, 1, numel(typeNames)-1)];
end

