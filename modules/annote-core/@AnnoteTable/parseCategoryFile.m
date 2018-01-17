function [categories, tagMap] = parseCategoryFile(obj, owner)
% PARSECATEGORYFILE 
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

classPath = which(class(owner));
[rootPath] = fileparts(classPath);
configFile = fullfile(rootPath, 'configCategories.txt');

if ~exist(configFile, 'file')
    classPath = which('Annote');
    [rootPath] = fileparts(classPath);
    configFile = fullfile(rootPath, 'configCategories.txt');
end

fclose('all');
fid = fopen(configFile, 'r');
if fid == -1
    error('Unable to read config file: %s\n', configFile);
end
data = fread(fid);
fclose(fid);

data = char(data');

%% Parse config Data
if strcmp(data(1:2), '##')
    [categories, tagMap] = parseNew(data);
else
    categories = parseOld(data);
    tagMap = [];
end

end

function [val, tags] = parseValString(str)
    str = strtrim(str);
    [val, extra] = strtok(str, '<');
    
    if ~isempty(extra) && (strcmp(extra(1), '<') && strcmp(extra(end), '>')) 
        tags = strsplit(extra(2:end-1), ',');
    else
        tags = [];
    end
end

function [categories, tagMap] = parseNew(data)

    tagMap = containers.Map;

    attributeSets = strsplit(data, '##');

    categories = cell(1,numel(attributeSets)-1);
    for loopSet = 2:numel(attributeSets)

        thisSet = attributeSets{loopSet};
        tmp = strsplit(thisSet, '=');
        attrName = tmp{1};
        labels   = tmp{2};

        tmp = strsplit(attrName, ':');
        majorAttr = strtrim(tmp{1});

        if length(tmp) == 1
            minorAttr = [];
        else
            minorAttr = strtrim(tmp{2});
        end

        valSets = strsplit(labels, '\n');
        
        labels = cell(numel(valSets),2); %containers.Map;

        for loopVal  = 1:numel(valSets);
            thisVal = valSets{loopVal};
            
            if isempty(strtrim(thisVal))
                continue
            end
            
            tmp = strsplit(thisVal, ':');

            [majorVal, tags] = parseValString(tmp{1});
            for loopTag = 1:numel(tags)
                tagMap(tags{loopTag}) = {majorVal, ''};
            end
            
            if length(tmp) == 1
                minorVal = [];
            else
                tmp = strsplit(tmp{2}, ';');
                minorVal = strtrim(tmp);
                minorVal(cellfun(@isempty, minorVal)) = [];
                for loopMinor = 1:numel(minorVal)
                    [minorVal{loopMinor}, tags] = parseValString(minorVal{loopMinor});
                    for loopTag = 1:numel(tags)
                        tagMap(tags{loopTag}) = {majorVal, minorVal{loopMinor}};
                    end
                end
            end
            labels{loopVal,1} = majorVal;
            labels{loopVal,2} = minorVal; 
        end
        
        tmp = cellfun(@isempty, labels);
        labels(all(tmp,2),:) = [];
        
        categories{loopSet}.majorLabel = majorAttr;
        categories{loopSet}.minorLabel = minorAttr;
        categories{loopSet}.labelMap = labels;
    end
    categories = [categories{:}];
    
end


function categories = parseOld(data)

    attributeSets = strsplit(data, '\n');

    categories = cell(1,numel(attributeSets));
    for loopSet = 1:numel(attributeSets)

        thisSet = attributeSets{loopSet};
        tmp = strsplit(thisSet, '=');
        attrName = tmp{1};
        labels   = tmp{2};

        tmp = strsplit(attrName, ':');
        majorAttr = strtrim(tmp{1});

        if length(tmp) == 1
            minorAttr = [];
        else
            minorAttr = strtrim(tmp{2});
        end

        valSets = strsplit(labels, ';');

        labels = containers.Map;
        for loopVal  = 1:numel(valSets);
            thisVal = valSets{loopVal};
            tmp = strsplit(thisVal, ':');
            majorVal = strtrim(tmp{1});
            if length(tmp) == 1
                minorVal = [];
            else
                tmp = strsplit(tmp{2}, ',');
                minorVal = strtrim(tmp);
                minorVal(cellfun(@isempty, minorVal)) = [];
            end

            labels(majorVal) = minorVal;
        end
        categories{loopSet}.majorLabel = majorAttr;
        categories{loopSet}.minorLabel = minorAttr;
        categories{loopSet}.labelMap = labels;
    end
    categories = [categories{:}];
    
end

