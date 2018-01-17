function [ blockImage, currentRows, currentCols] = loadImageData(obj, image_file, meta, blockRows, blockCols, updateObject)
% LOADIMAGEDATA
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

    if ~exist('blockRows', 'var') || isempty(blockRows)
        blockRows  = obj.currentBlockRows;
    end

    if ~exist('blockCols', 'var') || isempty(blockCols)
        blockCols = obj.currentBlockCols;
    end

    if ~exist('updateObject', 'var') || isempty(updateObject)
        updateObject = false;
    end

    if ~isempty(image_file) && ~isempty(meta)
        
        % Load image data
        [blockImage, currentRows, currentCols] = ReadImageBlock(image_file, meta, blockRows, blockCols, 0);
        blockImage = obj.preprocessImage(blockImage);
    else
    
        % Apply any processing
        if(obj.dsmFlag == false)  %True: RGB, %False: DSM
            
            meta = obj.metaMap('IMG');
            image_file = obj.metaMap('IMG').Filename;
            
            % Load image data
            [blockImage, currentRows, currentCols] = ReadImageBlock(image_file, meta, blockRows, blockCols, 0);

            blockImage = obj.preprocessImage(blockImage);

        else
            
            meta = obj.metaMap('IMG');    
            image_file = obj.metaMap('DSM').Filename;
            [dsmImage, currentRows, currentCols] = ReadImageBlock(image_file, meta, blockRows, blockCols, 0);
            dtmImage = ReadImageBlock(obj.metaMap('DTM').Filename, obj.metaMap('DTM'), blockRows, blockCols, 0);

            blockImage = dsmImage-dtmImage;
            blockImage(blockImage == -32767)=NaN;

        end
    end


    % Update object
    if updateObject
        obj.imageFilename    = image_file;
        obj.metadata         = meta;
        obj.currentRows      = currentRows;
        obj.currentCols      = currentCols;
        obj.currentBlockRows = blockRows;
        obj.currentBlockCols = blockCols;
    end

end

