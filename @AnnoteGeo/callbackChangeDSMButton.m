function callbackChangeDSMButton(obj, eventdata,handles)
% CALLBACKCHANGESDMBUTTON
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

obj.dsmFlag = ~obj.dsmFlag;        

% Prompt for DSM/DTM filenames if not "auto-discovered"
if obj.dsmFlag
    
	if( ~obj.metaMap.isKey('DSM') )
	   [FileName,PathName,~] = uigetfile(obj.getSupportedImageFileFilter(), 'Select DSM', obj.lastImageDir);
	    if ~ischar(FileName) 
	        return
	    end
	    filename  = fullfile(PathName, FileName);
        
        info2 = imfinfo(filename);
        meta2 = geotiffinfo(filename);
        
        meta = obj.metaMap('IMG');
        
        if ( all(all(meta.RefMatrix == meta2.RefMatrix )) && ...
             (meta.Height == info2.Height) && (meta.Width == info2.Width) )
        
            meta2.ImageFormat             = meta.ImageFormat;
            meta2.NumImageRows            = meta.NumImageRows;
            meta2.NumImageColumns         = meta.NumImageColumns;
            meta2.NumColumnBlocks         = meta.NumColumnBlocks;
            meta2.NumRowBlocks            = meta.NumRowBlocks;
            meta2.NumColumnPixelsPerBlock = meta.NumColumnPixelsPerBlock;
            meta2.NumRowPixelsPerBlock    = meta.NumRowPixelsPerBlock;
            
            obj.metaMap('DSM') = meta2;
         
        else
            errordlg('DSM metadata did not match')
            return;
        end
	end

	if( ~obj.metaMap.isKey('DTM') )
	   [FileName,PathName,~] = uigetfile(obj.getSupportedImageFileFilter(), 'Select DTM', obj.lastImageDir);
	    if ~ischar(FileName) 
	        return
	    end
	    filename  = fullfile(PathName, FileName);
        
        info2 = imfinfo(filename);
        meta2 = geotiffinfo(filename);
        
        meta = obj.metaMap('IMG');
        
        if ( all(all(meta.RefMatrix == meta2.RefMatrix )) && ...
             (meta.Height == info2.Height) && (meta.Width == info2.Width) )
        
            meta2.ImageFormat             = meta.ImageFormat;
            meta2.NumImageRows            = meta.NumImageRows;
            meta2.NumImageColumns         = meta.NumImageColumns;
            meta2.NumColumnBlocks         = meta.NumColumnBlocks;
            meta2.NumRowBlocks            = meta.NumRowBlocks;
            meta2.NumColumnPixelsPerBlock = meta.NumColumnPixelsPerBlock;
            meta2.NumRowPixelsPerBlock    = meta.NumRowPixelsPerBlock;
            
            obj.metaMap('DTM') = meta2;
         
        else
            errordlg('DTM metadata did not match')
            return;
        end

	end
end

title(obj.hFigure.CurrentAxes, 'Swapping Background Image...', 'FontWeight', 'Normal'); drawnow
blockImage = obj.loadImageData([], [], [], [], true);
set(obj.hFigure.CurrentAxes.Children(end),'CData',blockImage);
title(obj.hFigure.CurrentAxes, ''); drawnow
     

