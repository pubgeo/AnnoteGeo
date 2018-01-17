function [filename] = selectImageFile(obj, inputFile)
% SELECTIMAGEFILE
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
    filename = [];
    if ~ischar(inputFile) && ~isempty(inputFile)
      filename = inputFile;
      return;
    end
      
    % Check if file name was given
    if exist(inputFile, 'file') == 2
        filename = inputFile;

    % Check of directory was provided
    elseif exist(inputFile, 'file') == 7
        obj.lastImageDir = inputFile;
        
    end
        
   if isempty(filename)
       
        if ~exist(obj.lastImageDir, 'file')
            obj.lastImageDir = pwd;
        end
        [FileName,PathName,~] = uigetfile(obj.getSupportedImageFileFilter(), 'Select Image File to Annotate', obj.lastImageDir);
     
        if ~ischar(FileName) 
            return
        end

        filename  = fullfile(PathName, FileName);
   end
    
   obj.lastImageDir  = fileparts(filename);
   obj.imageFilename = filename;
   
end

