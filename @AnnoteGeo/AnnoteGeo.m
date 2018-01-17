classdef AnnoteGeo < Annote
% ANNOTEGEO
% 
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
% See also ANNOTE
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

  properties
    
     toolTitle  = 'AnnoteGeo';
    
     hFigSnail
     hImgSnail
     
     snailTrailMask
     snailTrailZoomLevel 
     
     % Keeps tracks of loaded polygons that are outside of image bounds
     removedPolygons
     removedInd
     removedTable
     removedGeoPoly
     
     dsmFlag = false
     metaKey  % Key of currently loaded image, maps to metaMat
     metaMap = containers.Map;
     metadata % Metadata of currently displayed image  
     
     lastImportDir
     lastExportDir
     
  end
  
  methods (Static = true)
      [tableDesc, typeNames, typeColors] = initTableFormat(obj);
  end
 
  
  methods

    function obj = AnnoteGeo(image_file)
        
        if ~exist('image_file', 'var')
            image_file = [];
        end
        
        if ~ischar(image_file)
            image_file = [];
        end
        
        obj@Annote(image_file);
        
        image_file = obj.imageFilename;
        
        % Check if known sensor model exist. For this tool exit, if not
        if  ~obj.checkValidMetadata(image_file)
            obj.logger.error(mfilename, 'Invalid Image Metadata: exiting');
            obj.exit()
            return
        end
        % =================================================================
        
        % Add jump to button
        thisName = 'Jump';
        h = uicontrol('Style', 'pushbutton', 'String', thisName, 'Units', 'Pixels');
        set(h, 'Callback', eval(sprintf('@obj.callback%sButton', thisName)))
        obj.table.addButton(h);

        % Add custom import button
        thisName = 'Import';
        h = uicontrol('Style', 'pushbutton', 'String', thisName, 'Units', 'Pixels');
        set(h, 'Callback', eval(sprintf('@obj.callback%sButton', thisName)))
        obj.table.addButton(h);
        
        % Add custom export button
        thisName = 'Export';
        h = uicontrol('Style', 'pushbutton', 'String', thisName, 'Units', 'Pixels');
        set(h, 'Callback', eval(sprintf('@obj.callback%sButton', thisName)))
        obj.table.addButton(h);
    
        
        % Add custom save button
        thisName = 'SaveGT';
        h = uicontrol('Style', 'pushbutton', 'String', thisName, 'Units', 'Pixels');
        set(h, 'Callback', eval(sprintf('@obj.callback%sButton', thisName)))
        obj.table.addButton(h);
        
        
        
        % Add custom background image swapping button
        thisName = 'ChangeDSM';
        h = uicontrol('Style', 'pushbutton', 'String', thisName, 'Units', 'Pixels');
        set(h, 'Callback', eval(sprintf('@obj.callback%sButton', thisName)))
        obj.table.addButton(h);
        
        % =================================================================
        
        % ------ Add info panel ---------
        hInfoPanel       = uipanel('Parent', obj.table.addPanel(), 'BorderType', 'beveledin', 'Visible', 'on', 'Position', [1 1 1 1]);
     
        hLayoutInfoPanel = layout.GridBagLayout(hInfoPanel, 'HorizontalGap', 2, 'VerticalGap', 2);

        [~,b,c] = fileparts(image_file);
        h = uicontrol('Parent', hInfoPanel, 'Style', 'text', 'String', [b c], 'Units', 'Pixels', 'HorizontalAlignment', 'left');
        while ~exist('jH', 'var') || isempty(jH)
            jH = findjobj(h);   % findjobj doesn't work if handle is set ot Visible = 'off'
            pause(0.1);
        end
        jH.VerticalAlignment = 0;
        hLayoutInfoPanel.add(h, 1, 1, 'MinimumWidth', 80, 'Fill', 'Horizontal', 'MinimumHeight', 35);
        h = uicontrol('Parent', hInfoPanel, 'Style', 'pushbutton', 'String', 'Info', 'Units', 'Pixels', 'Enable', 'off');
        hLayoutInfoPanel.add(h, 1, 2, 'MinimumWidth', 50, 'Fill', 'Horizontal', 'MinimumHeight', 35, 'Anchor', 'NorthEast');
        hLayoutInfoPanel.HorizontalWeights = [1 0];

        obj.table.addPanel(hInfoPanel, 3, 30);
        % ----------------
        
        obj.initOverviews(image_file);
       
        % TODO: Make max viewing size configurable
        obj.zoomMaxAxisX = obj.metadata.NumColumnPixelsPerBlock*2;
        obj.zoomMaxAxisY = obj.metadata.NumRowPixelsPerBlock*2;
        
        obj.xBlockBuffer = obj.metadata.NumColumnPixelsPerBlock./2;
        obj.yBlockBuffer = obj.metadata.NumRowPixelsPerBlock./2;
        
        % Initialize Zoom Level;
        xlim = obj.hFigure.CurrentAxes.XLim;
        ylim = obj.hFigure.CurrentAxes.YLim;
        
        newxlim = mean(xlim) + obj.zoomMaxAxisX.*[-1 1]./2;
        newylim = mean(ylim) + obj.zoomMaxAxisY.*[-1 1]./2;
        
        % Check if buffer sized is larger than image itself
        if newxlim(1) < 1; newxlim(1) = 1; end
        if newylim(1) < 1; newylim(1) = 1; end
        if newxlim(2) > obj.imWidth;  newxlim(2) = obj.imWidth;  end
        if newylim(2) > obj.imHeight; newylim(2) = obj.imHeight; end
        
        obj.hFigure.CurrentAxes.XLim = newxlim;
        obj.hFigure.CurrentAxes.YLim = newylim;
        

        obj.updateSnailTrail(1);    % Loaded image block
        obj.updateSnailTrail(0);   % Current view

        if exist('file_to_load', 'var')
           obj.loadDataIntoTool(file_to_load);
        end

    end

   function snailTrailCallbackWindowButtonMotionFcn(obj, h, event)
        pos = get(obj.hFigSnail.CurrentAxes, 'CurrentPoint');
        
        pX = round(pos(1,1));
        pY = round(pos(1,2));
        
        if false
            if pX < 1 || pY < 1 || pX > size(obj.hImgSnail.CData,2) || pY > size(obj.hImgSnail.CData,1)
                if ~isempty(obj.hSnailTrailTextCurrentLocation)
                    obj.hSnailTrailTextCurrentLocation.Visible = 'off';
                end
            else
                str = sprintf('(%d, %d)', pX*obj.snailTrailZoomLevel, pY*obj.snailTrailZoomLevel);
                pX= pX+0.01;
                pY= pY+0.01;
                if isempty(obj.hSnailTrailTextCurrentLocation)
                    obj.hSnailTrailTextCurrentLocation = text(obj.hFigSnail.CurrentAxes, pX, pY, str);
                    obj.hSnailTrailTextCurrentLocation.BackgroundColor = 'w';
                else
                    obj.hSnailTrailTextCurrentLocation.Visible = 'on';
                    obj.hSnailTrailTextCurrentLocation.Position = [7 12 1];
                    obj.hSnailTrailTextCurrentLocation.String = str;
                end

            end
        else
             if pX < 1 || pY < 1 || pX > size(obj.hImgSnail.CData,2) || pY > size(obj.hImgSnail.CData,1)
                 pX = nan;
                 pY = nan;
             end
             
             str = sprintf('(%d, %d)  ', pX*obj.snailTrailZoomLevel, pY*obj.snailTrailZoomLevel);
             
             obj.hFigSnail.UserData.jPixelPos.setText(str);
        end
   end  
    
    
   function locaCallbackWindowButtonMotionFcn(obj, h, event)
     obj.callbackWindowButtonMotionFcn(h, event)
   end  
    
   function localCallbackKeyPressFcn(obj, h, event)
     
      keyUsed = obj.callbackKeyPressFcn(h, event);
      
      if keyUsed
        obj.updateSnailTrail(false)  
      end
   end

    function entries = createDerivedEntries(obj, x, y)
          entries = containers.Map;
          entries('Row') = obj.currentRows(1) + round(mean(y)) - 1;
          entries('Col') = obj.currentCols(1) + round(mean(x)) - 1;  
    end
    
    function name = getDefaultSaveName(obj)     
        if ~isempty(obj.imageFilename)
            [~,name] = fileparts(obj.imageFilename);
        end
    end
    
    
  end
end

