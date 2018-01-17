classdef Annote < handle
% ANNOTE 
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
  properties(Abstract  = true)
    
    toolTitle
   
  end
  
  methods (Static = true)
      [tableDesc, typeNames, typeColors] = initTableFormat(obj);
      callbackAnnotationContextMenu(source,callbackdata,obj);
  end

  
  properties
    
    logger@AnnoteLogger
      
    % Properties for Image Figure
    hFigure
    hAxis
    hImage
    
    imWidth
    imHeight
    imRowRange
    imColRange
    
    mousePos
    mouseClick  % currently pressed mouse buttons
    
    % Properties for Table
    table@AnnoteTable
    
    % Listeners
    hTableListenerSelectedRow
    hFigureListenerCurrentObject
    
    hPolys
    multiSelectedPoly
    selectedPoly
    prevSelectedPoly
    
    % Stores colormap for each drop-down in table
    colormapMap = containers.Map;  
    % Idenitfied select colormaps (ex: 'Face' and 'Edge' colors for polys)
    colorKeyMap = containers.Map; 
    colorUnassignedKey = 'UNK';
    
    colorFaceAlphaShade = 0.5;
    
    % Status
    isDrawActive = false;
    
    %
    lastSaveDir = '';
    lastLoadDir = '';
    lastImageDir = '';
    
    
    zoomMaxAxisX
    zoomMaxAxisY
    zoomMinAxisX = 3;
    zoomMinAxisY = 3;
    
    
    % ----- START: Configuration settings  --------------------------------
    ENABLE_POLYSPLIT        = true;  
    ENABLE_HOTKEY_DELETE    = true;  
    ENABLE_HOTKEY_ADD       = true;
    ENABLE_HOTKEY_FNUM_ADD  = true;
    
    LOGGER_STDOUT_LEVEL = 0;  % Verbose
    LOGGER_FILE_LEVEL   = Inf; % OFF
    
    USES_CLOSED_POLYS = true
    DISABLE_BUTTONS = {}    
    
    % ----- END: Configuration settings  --------------------------------
    
   
    % ----- START: Variables used for data buffering -----------------------
    % Blocks currently loaded
    currentBlockRows
    currentBlockCols

    % Start/End pixel in full image of image block currently loaded
    currentRows
    currentCols

      
    % Distance from edge of curred image block to trigger loading more data
    xBlockBuffer
    yBlockBuffer

    % TODO: Is this still needed?
    dataSource  
     
     % ----- END: Variables used for data buffering -------------------------
     
  end
  
  
   properties (SetObservable)
    imageFilename = ''; 
   end

  
  
  methods
    
    function obj = Annote(image, varargin)
       
       if verLessThan('matlab', '8.4')
           errordlg('Matlab version R2014b, or later, is required.');
       end
       
       status = obj.initSettings(); 
       
       logPath = pwd;
       logFilename = fullfile(logPath, sprintf('%s.%s.log', class(obj), datestr(now, 'yyyy.mm.dd.HH.MM.SS.FFF')));
       obj.logger = log4m.getLogger(logFilename, class(obj.logger));
       
       obj.logger.setCommandWindowLevel(obj.LOGGER_STDOUT_LEVEL); % all = 0  =>  off = 7
       obj.logger.setLogLevel(obj.LOGGER_FILE_LEVEL);
      
       obj.logger.info(class(obj),sprintf('Log file: %s', logFilename));
       obj.logger.info(class(obj),sprintf('Command window log level: %d', obj.logger.commandWindowLevel));
       obj.logger.info(class(obj),sprintf('Log file level: %d', obj.logger.logLevel));
       
       if isempty(obj.lastSaveDir); obj.lastSaveDir = pwd; end
       if isempty(obj.lastLoadDir); obj.lastLoadDir = pwd; end
       if isempty(obj.lastImageDir); obj.lastImageDir = pwd; end
        
       % Select file, if image was not directly provided
       image = obj.selectImageFile(image);
       
       % TODO: Image setup is messy...
       
       % Load and pre-process image
       image = obj.initImageData(image);
       image = obj.preprocessImage(image);
       
       % Initialized Image Window
       obj.initImageDisplay(image);
    
       
       % Initialized Table Window
       status = obj.initTable();
       
       if ~status
           delete(obj.hFigure);
           return
       end
     
       obj.createColormap();
       
    end
    
    function delete(obj)
        obj.exit()
    end
    
    function exit(obj)
        delete(obj.hFigure);
        obj.table.delete      
    end
    
    function localCallbackActionPostCallbackPanFcn(obj, src, event)
        fprintf('pan\n')
    end

    function localCallbackActionPostCallbackZoomFcn(obj, src, event)
          fprintf('zoom\n')
    end
    
    function localCallbackCloseRequestFcn(obj,src,callbackdata)
      % Disable Matlab Default  'control+w' from closing this window
      % This is to prevent accidental closing when using the 'shift+w'
      % keyboard shortcut that resets the zoom in this tool
      if ~isempty(get(gcf,'currentModifier')) && ...
        (strcmp(get(gcf, 'CurrentKey'), 'w') && strcmp(get(gcf,'currentModifier'), 'control'))
        return;
      end
     
      delete(gcf)
      delete(obj.hTableListenerSelectedRow);
      delete(obj.hFigureListenerCurrentObject);
      
      return 
   
    end

    function localCallbackKeyPressFcn(obj, h, event)
      obj.callbackKeyPressFcn(h, event);
    end
    
    function localCallbackWindowButtonMotionFcn(obj, h, event)
      obj.callbackWindowButtonMotionFcn(h, event);
    end  
    
    function localCallbackWindowButtonUpFcn(obj, h, event)
      obj.callbackWindowButtonUpFcn(h, event);
    end  
    
    function localCallbackWindowButtonDownFcn(obj, h, event)
      obj.callbackWindowButtonDownFcn(h, event);
    end  
    
    function initImageDisplay(obj, image)
        
      obj.imWidth  = size(image,2);
      obj.imHeight = size(image,1);
        
      % Custom imRowRange/imColRange should be set initImageData.m
      if  isempty(obj.imRowRange)
          obj.imRowRange =  [1 obj.imHeight];
      end
      
      if  isempty(obj.imColRange)
          obj.imColRange = [1 obj.imWidth];
      end
      
      
      % ===================================================================
      %      Setup Figure for Image Display
      imageTag = obj.toolTitle;
      if isempty(findobj('Tag',imageTag))
        h = figure('Tag', imageTag, 'Visible','off');
        set(gcf, 'Name', imageTag);
        set(gcf, 'NumberTitle', 'off')
      else
        h = figure(findobj('Tag',imageTag));
        cla(h)
      end
      
      obj.hFigure = h;
      obj.hAxis   = gca;
      
      set(obj.hFigure,'KeyPressFcn',@obj.localCallbackKeyPressFcn);
      set(obj.hFigure,'WindowButtonMotionFcn', @obj.localCallbackWindowButtonMotionFcn);
      set(obj.hFigure,'WindowButtonUpFcn', @obj.localCallbackWindowButtonUpFcn);
      set(obj.hFigure,'WindowButtonDownFcn', @obj.localCallbackWindowButtonDownFcn);
      set(obj.hFigure, 'CloseRequestFcn',@obj.localCallbackCloseRequestFcn)
      
      set(zoom(obj.hFigure),'ActionPostCallback',@(src,event) obj.localCallbackActionPostCallbackZoomFcn(src,event));
      set(pan(obj.hFigure),'ActionPostCallback',@(src,event)  obj.localCallbackActionPostCallbackPanFcn(src,event));
      
      % ===================================================================
      %      Setup the Image Axes
    
 
      obj.hImage = findobj(obj.hFigure, 'Type', 'Image');
      if isempty(obj.hImage)
          if exist('rowRange', 'var')
            obj.hImage  = imagesc(colRange, rowRange, image);
          else
            obj.hImage  = imagesc(obj.hAxis, image);
          end
      else    
          obj.hImage.CData = image;
           if exist('rowRange', 'var')
            obj.hImage.YData = rowRange;
            obj.hImage.XData = colRange;
           end
      end
      
      if ~verLessThan('matlab', '9.0.0')  % 2016a
          obj.hAxis.YAxis.Exponent = 0;
          obj.hAxis.XAxis.Exponent = 0;
          obj.hAxis.YAxis.TickLabelFormat = '%d';
          obj.hAxis.XAxis.TickLabelFormat = '%d';
      end
      
      
      if size(image, 3) == 1
        colormap gray
      end
      axis image ij

      
      % Make adjustments to image display
      obj.customizeImageDisplay();
      
      
      set(obj.hFigure, 'Visible','on');
      
    end
    
    function thisTable = createTable(obj)
        thisTable = AnnoteTable();
    end
    
    function status = initTable(obj)
      
      obj.table = obj.createTable();
      status = obj.table.init(obj);
      
      if ~status
        obj.logger.error(mfilename, 'Failed to initialize table');
        return
      end
      
      obj.hTableListenerSelectedRow = addlistener(obj.table, 'selectedRow',...
          'PostSet', @obj.listenTableSelectedRow);
    end
    
    

%% START: CALLBACKS AND LISTENERS
    
    function callbackAddButton(obj, eventdata, handles)

      if obj.isDrawActive == false
      
        obj.isDrawActive = true;
        
        % Get user polygon
        figure(obj.hFigure)
          
        [x, y] = roiPolygonEdit([], [], gca, obj.USES_CLOSED_POLYS);

        % For non-standard axes. 
        xData = obj.hImage.XData;
        yData = obj.hImage.YData;
        if (numel(xData) == obj.imWidth) && (numel(yData) == obj.imHeight)
            x = interp1(1:numel(xData), xData, x, [], 'extrap');
            y = interp1(1:numel(yData), yData, y, [], 'extrap');
        end
        
        if ~isempty(x)
          obj.addAnnotation(x, y);
        end
        
        title(obj.hFigure.CurrentAxes, '');
        obj.isDrawActive = false;
      end
    end
    
    
    function callbackEditButton(obj, eventdata, handles)
      if isempty(obj.selectedPoly)
          return;
      end
        
      if obj.isDrawActive == false
      
        obj.isDrawActive = true;
     

        h = obj.hPolys(obj.selectedPoly);

        set(h, 'Visible', 'off')

        x = get(h, 'XData');
        y = get(h, 'YData');

        figure(obj.hFigure)
        [x, y] = roiPolygonEdit(x, y, gca, obj.USES_CLOSED_POLYS);
        
        % For non-standard axes. 
        xData = obj.hImage.XData;
        yData = obj.hImage.YData;
        if (numel(xData) == obj.imWidth) && (numel(yData) == obj.imHeight)
            x = interp1(1:numel(xData), xData, x, [], 'extrap');
            y = interp1(1:numel(yData), yData, y, [], 'extrap');
        end
        
        if isempty(x)
          set(h, 'Visible', 'on');
          return
        end

        % Update vertices
        obj.updateAnnotation(h,x,y);
        set(h, 'Visible', 'on');
        
        obj.isDrawActive = false;
      end
    end
    
   function callbackShadeButton(obj, handles, eventdata)
    
      state = get(handles,'Value');
      
      for p = 1:numel(obj.hPolys)
        if state == get(handles,'Max')
          alpha = obj.colorFaceAlphaShade;
        elseif state == get(handles,'Min')
          alpha = 0;
        end
        set(obj.hPolys(p), 'FaceAlpha', alpha);
      end
      
    end
     
   
   
     function callbackHelpButton(obj, handles, eventdata)
            obj.showHelp();
    end 
    
   
    function callbackDeleteButton(obj, eventdata, handles)
       if isempty(obj.selectedPoly)
        return;
       end
     
       removeIndex = obj.selectedPoly;
       
       obj.deleteAnnotation(removeIndex);
       
       obj.selectedPoly = [];

       obj.table.deleteEntry(removeIndex);
       
    end
    
    
    function saveFilename = callbackSaveButton(obj, params, ~)
     
      title(obj.hFigure.CurrentAxes, 'Saving...', 'FontWeight', 'Normal'); drawnow
        
      saveFilename = [];
      if ~exist(obj.lastSaveDir, 'file')
        try
            mkdir(obj.lastSaveDir);
        catch
            obj.lastSaveDir = pwd;
        end
      end
      
      defaultSaveName =  fullfile(obj.lastSaveDir, obj.getDefaultSaveName());
      if exist('params', 'var') && ~isempty(params) && isstruct(params)
        if isfield(params, 'saveSuffix')
            [a,b,c] = fileparts(defaultSaveName);
            defaultSaveName = fullfile(a,[b params.saveSuffix c]);
        end
      end
    
      [FileName,PathName] = uiputfile('*.mat', 'Save', defaultSaveName );
      
      if isnumeric(FileName)    
        title(obj.hFigure.CurrentAxes, ''); drawnow
        return;
      end
    
      obj.lastSaveDir = PathName;
      
      table = obj.table.getData();
      
      poly = cell(1,numel(obj.hPolys));
      for p = 1:numel(obj.hPolys)
        x = get(obj.hPolys(p), 'XData');
        y = get(obj.hPolys(p), 'YData');
        poly{p} = [x(:) y(:)];  % patch/plot vectors are oriented differently
      end
      
      img = get(obj.hImage, 'CData');
      
      % Continue saving out, call custom save processing
      [s, table0, poly0, img0] = obj.saveData(table, poly, img, fullfile(PathName, FileName), params);
     
      % Map dropDowns back to back to category labels
      majorLabels = {obj.table.getTypeMap.majorLabel};
      
      labels.map   = obj.table.getTypeMap;
      labels.tags  = obj.table.getTypeTags;
      labels.cats  = obj.table.getTypeCats;
      labels.names = obj.table.getTypeNames;
   
      for loopMajor = 1:numel(majorLabels)
          colInd = obj.table.getColumnIndex(majorLabels{loopMajor});
          thisData = table(:,colInd);
          for p = 1:numel(thisData)
              labels.data{loopMajor}{p} = obj.table.getTypeCatFromName(thisData{p}, colInd);
              if isempty(labels.data{loopMajor}{p})
                  labels.data{loopMajor}{p} =  {'',''};
              end
          end
          labels.data{loopMajor} = cat(1,  labels.data{loopMajor}{:});
      end
      
      
      % if standard data was changed, update what is saved
      if ~isempty(table0)
          table = table0;
      end
         
      if ~isempty(poly0)
          poly = poly0;
      end
      
      if ~isempty(img0)
          img = img0;
      end
      
      saveFilename = fullfile(PathName, FileName);
      if img == false
        save(saveFilename, 'table', 'poly', 'labels')
      else
        save(saveFilename, 'table', 'poly', 'labels', 'img')
      end
      save(saveFilename, '-struct', 's', '-append');
      
      
      title(obj.hFigure.CurrentAxes, ''); drawnow
     
    end
  
   function callbackLoadButton(obj, eventdata, handles)
     
       
     if ~exist(obj.lastLoadDir, 'file')
        obj.lastLoadDir = pwd;
     end

     
     [FileName,PathName,FilterIndex] = uigetfile('*.mat', 'Load', fullfile(obj.lastLoadDir, obj.getDefaultSaveName()) );
     
      if ~ischar(FileName) 
        return
      end
      obj.lastLoadDir = PathName;
      
      obj.loadDataIntoTool(fullfile(PathName, FileName));

   end
      
    function listenTableSelectedRow(obj, src, event)
        obj.selectAnnotation(obj.table.getSelectedRow());
    end
    
%  END: CALLBACKS AND LISTENERS 

%% START: MISC FUNCTIONS
    function createCustomColormap(obj)
        % For overriding default colormaps
        % Called from createColormap.m
    end

    function highLightAnnotations(obj, hIndex)

      obj.selectedPoly = hIndex;
      
      mask = true(1,numel(obj.hPolys));
      mask(hIndex) = false;

      set(obj.hPolys(mask), 'LineWidth', 1);
      set(obj.hPolys(hIndex), 'LineWidth', 3);
    end


    function highLightMultiAnnotations(obj, hIndices)
        mask = true(1,numel(obj.hPolys));
        mask(hIndices) = false;
        set(obj.hPolys(mask), 'LineWidth', 1);
        for i=1:length(hIndices)
            set(obj.hPolys(hIndices(i)), 'LineWidth', 3);
        end
    end
    
    function callbackAnnotationButtonDownFcn(obj, eventdata, handles)
        
        srcInd = find(obj.hPolys == handles.Source);
        
        obj.selectedPoly = srcInd;
        
        % Check if shift is pressed
        mods= get(gcf,'currentModifier');
        selType = get(gcf,'SelectionType');
        shiftPressed = ismember('shift',mods);
        if shiftPressed
            if(~ismember(obj.selectedPoly,obj.multiSelectedPoly))
                if(isempty(obj.multiSelectedPoly))
                    obj.multiSelectedPoly = [obj.multiSelectedPoly obj.prevSelectedPoly];
                end
                obj.selectMultipleAnnotation(srcInd);
                obj.prevSelectedPoly = srcInd;
            end
        else
            if(strcmp(selType,'alt')&& ~isempty(obj.multiSelectedPoly))
                obj.selectMultipleAnnotation(srcInd);
                obj.prevSelectedPoly = srcInd;
            else
                obj.multiSelectedPoly = [];
                obj.selectAnnotation(srcInd);
                obj.prevSelectedPoly = srcInd;
            end
            
        end
        
        % Update context menu
        cmenu = get(obj.hPolys(obj.selectedPoly), 'UIContextMenu');
        entry = obj.table.getEntryMap(obj.selectedPoly);
        
        hMenu = findobj(cmenu, 'Tag', 'annote.category');
        
        userData = [hMenu.UserData];
        
        cats = {userData.category};
        ucats = unique(cats);
        
        for p = 1:numel(ucats)
            thisCat   = ucats{p};
            if isempty(entry(thisCat))
               set(hMenu(strcmp(cats,thisCat)), 'Checked', 'off')
            else
                
               currentCat = obj.table.getTypeCatFromName(entry(thisCat));
               
               enable = strcmp({userData.major}, currentCat{1}) & strcmp({userData.minor}, currentCat{2}) & strcmp(cats,thisCat);
               disable = ~enable & strcmp(cats,thisCat);
               set(hMenu(enable), 'Checked', 'on')
               set(hMenu(disable), 'Checked', 'off')
            end
        end
    end
    
    

    function selectAnnotation(obj, selectedInd)
      obj.table.setSelectedRow(selectedInd);
      obj.highLightAnnotations(selectedInd);
    end
    
    function selectMultipleAnnotation(obj, selectedInd)
        obj.multiSelectedPoly = [obj.multiSelectedPoly selectedInd];
        obj.highLightMultiAnnotations(obj.multiSelectedPoly);
    end
    
    function h = drawAnnotation(obj,x,y)	
    
        if obj.USES_CLOSED_POLYS
            h = patch(x, y, 'k', 'linewidth', 1.5, 'edgecolor', obj.getAnnotationColor(), 'facecolor', 'none', 'parent', obj.hImage.Parent, 'FaceAlpha', 0);
        else
            h = plot(x, y, 'k', 'linewidth', 1.5, 'color', obj.getAnnotationColor(), 'parent', obj.hImage.Parent);
        end
    end
    
    function updateAnnotation(obj,h,x,y)
        entries = obj.createDerivedEntries(x,y);
        obj.table.updateEntry(entries, find(obj.hPolys == h)); %#ok<FNDSB>
        set(h, 'XData', x);
        set(h, 'YData', y);
    end
    
    function loadAnnotations(obj, data)

      obj.hPolys = nan(1,size(data.poly,1));

      figure(obj.hFigure); hold on;
      for p = 1:numel(data.poly)
        x = data.poly{p}(:,1);
        y = data.poly{p}(:,2);
       
        obj.hPolys(p) = obj.drawAnnotation(x,y);
       
        set(obj.hPolys(p), 'Interruptible', 'off')
        set(obj.hPolys(p), 'ButtonDownFcn', @obj.callbackAnnotationButtonDownFcn)
        
        obj.setAnnotationContextMenu(obj.hPolys(p));
	obj.setAnnotationColor(obj.hPolys(p), data.table(p,:))
      end
      hold off
    end
    
    
    function deleteAnnotation(obj, removeIndex)       
       delete(obj.hPolys(removeIndex));
       obj.hPolys(removeIndex) = [];
    end
    
    function entries = createDerivedEntries(obj, x, y)      
      entries = containers.Map;
    end
    
    function imageOut = preprocessImage(obj, imageIn)
      imageOut = imageIn;
    end
    
    function clearTable(obj)
        obj.deleteAnnotation(1:numel(obj.hPolys));
        obj.selectedPoly = [];
        obj.table.resetData();
    end

    function loadDataIntoTool(obj, filename)
      
      [tmp] = obj.loadData(filename);

      clearTable(obj)

      obj.table.initData(tmp.table);
      
      obj.loadAnnotations(tmp);
      
    end
    
    
    function name = getDefaultSaveName(obj)     
        name = '';
    end
    
    
    function status = initSettings(obj, varargin)
        status = true;
        
        % Select column for colorizing annotations
        % Can be index or name of column
        % TODO: Should consolidates all annotation settings and functions
        obj.colorKeyMap('Face') = 1;
        obj.colorKeyMap('Edge') = 1;
    end
    
  end
  

  
  
end

