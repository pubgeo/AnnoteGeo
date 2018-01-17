function [ blockImage ] = initImageData(obj, image_file )
% INITIMAGEDATA
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
%   
    blockImage = [];
    if ~exist(image_file, 'file')
%         errordlg(sprintf('File does not exist:\n%s\n', image_file));
        return
    end

    info = imfinfo(image_file);
    meta = geotiffinfo(image_file);

    % Make to look like result from ReadImagemeta.m
    meta.ImageFormat     = '.TIF';
    
    meta.NumImageRows    = info.Height;
    meta.NumImageColumns = info.Width;
    
    if isempty(info.TileWidth)
        meta.NumRowPixelsPerBlock    = 1024;
        meta.NumColumnPixelsPerBlock = 1024;
    else
        meta.NumRowPixelsPerBlock    = info.TileWidth;
        meta.NumColumnPixelsPerBlock = info.TileLength;
    end
    
    if meta.NumRowPixelsPerBlock > meta.NumImageRows
        meta.NumRowPixelsPerBlock = meta.NumImageRows;
    end
        
    if meta.NumColumnPixelsPerBlock > meta.NumImageColumns
        meta.NumColumnPixelsPerBlock = meta.NumImageColumns;
    end

    
    meta.NumRowBlocks        = ceil(meta.NumImageRows/meta.NumRowPixelsPerBlock);
    meta.NumColumnBlocks     = ceil(meta.NumImageColumns/meta.NumColumnPixelsPerBlock);
    
    blockRow = floor(meta.NumRowBlocks/2);
    blockCol = floor(meta.NumColumnBlocks/2);

    % TODO: Make number of blocks loaded configurable
    blockRows =  blockRow + [-1:1].*2;
    blockCols =  blockCol + [-1:1].*2;
    
    
    if blockRows(1) < 1; blockRows(1) = 1; end
    if blockCols(1) < 1; blockCols(1) = 1; end
    
    if blockRows(end) > meta.NumRowBlocks
        blockRows(end) = meta.NumRowBlocks;
    end
    
    if blockCols(end) > meta.NumColumnBlocks
        blockCols(end) = meta.NumColumnBlocks;
    end
    
    obj.currentBlockRows = blockRows(1):blockRows(end);
    obj.currentBlockCols = blockCols(1):blockCols(end);
    
    % Check if image is large enough for desire blocksize and number of blocks
    expectedBlockImageSize = [numel(obj.currentBlockRows)*meta.NumRowPixelsPerBlock  numel(obj.currentBlockCols)*meta.NumColumnPixelsPerBlock];
    if expectedBlockImageSize(1) >  meta.NumImageRows
        meta.NumRowBlocks         = 5;
        obj.currentBlockRows      = 1:5;
        meta.NumRowPixelsPerBlock = floor(meta.NumImageRows/meta.NumRowBlocks);
    end
    
    if expectedBlockImageSize(2) >  meta.NumImageColumns
        meta.NumColumnBlocks         = 5;
        obj.currentBlockCols         = 1:5;
        meta.NumColumnPixelsPerBlock = floor(meta.NumImageColumns/meta.NumColumnBlocks);
    end
    
    
    [blockImage, obj.currentRows, obj.currentCols] = ReadImageBlock(image_file, meta,  obj.currentBlockRows,   obj.currentBlockCols , 0);
   

    % Current metadata
    obj.metadata = meta;
    
    % Store metadata
    obj.metaKey  = 'IMG';
    obj.metaMap(obj.metaKey) = meta;
    
        
% -------------------------------------------------------------------------
    
    % Check if corresponding DSM or DTM images exist
    % Enforce that reference matrix and image size match
    % This is used for swapping the background image
    filename = [image_file(1:end-7) 'DSM.tif'];
    if exist(filename, 'file')
        info2 = imfinfo(filename);
        meta2 = geotiffinfo(filename);
        
        if ( all(all(meta.RefMatrix == meta2.RefMatrix )) && ...
             (info.Height == info2.Height) && (info.Width == info2.Width) )
        
            meta2.ImageFormat             = meta.ImageFormat;
            meta2.NumImageRows            = meta.NumImageRows;
            meta2.NumImageColumns         = meta.NumImageColumns;
            meta2.NumColumnBlocks         = meta.NumColumnBlocks;
            meta2.NumRowBlocks            = meta.NumRowBlocks;
            meta2.NumColumnPixelsPerBlock = meta.NumColumnPixelsPerBlock;
            meta2.NumRowPixelsPerBlock    = meta.NumRowPixelsPerBlock;
            
            obj.metaMap('DSM') = meta2;
         
        end
    end
    
    filename = [image_file(1:end-7) 'DTM.tif'];  
    if exist(filename, 'file')
        info2 = imfinfo(filename);
        meta2 = geotiffinfo(filename);
        
        if  ( all(all(meta.RefMatrix == meta2.RefMatrix )) && ...
             (info.Height == info2.Height) && (info.Width == info2.Width) )
        
            meta2.ImageFormat             = meta.ImageFormat;
            meta2.NumImageRows            = meta.NumImageRows;
            meta2.NumImageColumns         = meta.NumImageColumns;
            meta2.NumColumnBlocks         = meta.NumColumnBlocks;
            meta2.NumRowBlocks            = meta.NumRowBlocks;
            meta2.NumColumnPixelsPerBlock = meta.NumColumnPixelsPerBlock;
            meta2.NumRowPixelsPerBlock    = meta.NumRowPixelsPerBlock;
         
            obj.metaMap('DTM') = meta2;
         
        end
    else
        obj.dsmFlag = false;
    end
% -------------------------------------------------------------------------
    
    
    
end

