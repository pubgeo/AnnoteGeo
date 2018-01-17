classdef AnnoteTable < handle
% ANNOTETABLE 
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
    properties
    end
    
    properties (Access = private,  Constant = true)
        parentClass = 'Annote';
    end
    
    
    properties (Access = protected)

        hFig
        hButtonPanel

        hTable
        jTable
        
        hLayoutFig
        hLayoutButtonPanel
        
        hButtonMap
        
        % Table Format
        tableDesc
        
        typeNames     % list of dropdown strings
        typeNameMap   % list of major/minor category labels
        typeTags      % mapping between tags and major/minor category labels
        typeMap
        
        
        tableDataArchive  % all table data. rows correspond to hPoly indices
        viewRowList 	  % row indices into tableData of current view
        
        selectedViewRow
        
        resizeCallbackID
       
        ENABLE_UNASSIGNED_LABEL = true;
        
    end
    
    properties (SetObservable, Access = protected)
        selectedRow
    end
    
    methods (Static = true, Access = private)
        [typeNames, typeNamesMap] = makeCategoryStrings( typeMap );
    end
    
    
    methods (Access = private)
        
       function addTableEntry(obj, newEntry, location)
           if ~exist('location', 'var')
               location = 1;
           end
           
           data = obj.tableDataArchive;
           
           if location < 1; location = 1; end
           if location > size(data,1)+1; location = size(data,1)+1; end
           
          % Insert new entry
          if location == 1 
            data = [newEntry; data];
            obj.viewRowList = [1 obj.viewRowList+1];
          else
%               error
          end
          
          obj.tableDataArchive = data;
          
          % Update uitable
          set(obj.hTable, 'data', data(obj.viewRowList,:));

       end
       
       function deleteTableEntry(obj, locations, newActiveRows)
           
          if any(locations < 1); return; end
          if any(locations > size(obj.tableDataArchive,1)); return; end
           
          
          data = obj.tableDataArchive;
          data(locations,:) = [];
          obj.tableDataArchive = data;
        
          
          % Update uitable
          set(obj.hTable, 'data', data);
          
       end
       
       function setTableEntry(obj, entry, rowIndex)
            
            % Update full data
            data = obj.tableDataArchive;
            data(rowIndex,:) = entry;
            obj.tableDataArchive = data;
            
            % Update viewed data
            set(obj.hTable, 'data', data(obj.viewRowList,:));
       end
       
       
       
       function map = rowEntryToMap(obj, entry)
          map = containers.Map;
          for p = 1:numel(entry)
              key = obj.getColumnName(p);
              map(key) = entry{p};
          end
       end
       
    end  %  methods (Access = private)
    
    
% =========================================================================   
%       Getters and Setters
% =========================================================================   
    methods
        function data = get.tableDataArchive(obj)
           
            % Everytime tableDataArchive, update it with current
            % information from the table
            if ~isempty(obj.viewRowList)
                obj.tableDataArchive(obj.viewRowList,:) = get(obj.hTable, 'data');
            end
            data =   obj.tableDataArchive;
        end
        
        function set.tableDataArchive(obj, data)
            obj.tableDataArchive = data; % This needs to be the updated table
        end
        
        function set.selectedViewRow(obj, row)
            
            obj.selectedViewRow = row;
            set(obj.hFig, 'name', sprintf('Selected Row: %d', obj.selectedViewRow))

        end
    end
    
% =========================================================================    
    methods
        function obj = AnnoteTable()
        end
        
        function delete(obj)
            delete(obj.hFig)
        end
        
        function status = init(obj, owner)
            status = false;
            
            if ~any(strcmp(superclasses(owner), obj.parentClass))
                error('AnnoteTable: Argument OWNER must be a subclass of Annote')
            end
            
            
            figSz   = [720 250];


            tableTag = [owner.toolTitle ': Table'];
            tableName = 'Table';
            if isempty(findobj('Tag',tableTag))
                obj.hFig = figure('Tag', tableTag, 'Visible','off');
                set(obj.hFig, 'Name', tableName);
                set(obj.hFig, 'NumberTitle', 'off')    
            else
                obj.hFig = figure(findobj('Tag',tableTag));
                set(obj.hFig, 'Visible','off')
                clf(obj.hFig);
                iptremovecallback(obj.hFig, 'ResizeFcn', obj.resizeCallbackID);
            end

            curPos = get(obj.hFig, 'Position');
            set(obj.hFig, 'Position', [curPos(1) curPos(2) figSz(1) figSz(2)]);
        
            obj.hFig.ToolBar = 'none';
            obj.hFig.MenuBar = 'none';
          
            obj.hLayoutFig = layout.GridBagLayout(obj.hFig, 'HorizontalGap', 5, 'VerticalGap', 5);
            
            obj.hButtonPanel = uipanel('Parent', obj.hFig, 'BorderType', 'beveledin');
            
            obj.hTable = uitable('Parent', obj.hFig);
            tmp = findjobj(obj.hTable); 
          
            % FIXME: Protect against java not being synchronized with the rest of
            % matlab...  Why does this happen????  
            while( isempty(obj.jTable))
               obj.jTable  = tmp.getViewport.getView;
               pause(0.1)
            end

            obj.hLayoutFig.add(obj.hButtonPanel, 1, 1, 'Fill', 'Both', 'MinimumWidth', 200, 'Anchor', 'NorthWest', 'MinimumHeight', 35);
            obj.hLayoutFig.add(obj.hTable,       2, 1, 'Fill', 'Both', 'MinimumWidth', 200, 'Anchor', 'NorthWest');
            
            obj.hLayoutFig.VerticalWeights = [0 1];
       

            % ----- Add standard buttons ---------------------------------------
            buttonNames     = {'Add', 'Edit', 'Delete', 'Save', 'Load'};

            obj.hButtonMap = containers.Map;
            obj.hLayoutButtonPanel = layout.GridBagLayout(obj.hButtonPanel, 'HorizontalGap', 2, 'VerticalGap', 2);
            
            for p = 1:numel(buttonNames)
                if ~any(strcmp(owner.DISABLE_BUTTONS, buttonNames{p}))
                    h = uicontrol('Parent', obj.hButtonPanel, 'Style', 'pushbutton', 'String', buttonNames{p}, 'Units', 'Pixels');
                    set(h, 'Callback', eval(sprintf('@owner.callback%sButton', buttonNames{p})))
                    obj.addButton(h);
                end
                
            end
           

            % ----- Add toggle buttons ----------------------------------------
            thisName = 'Shade';
            if ~any(strcmp(owner.DISABLE_BUTTONS, thisName))
                h = uicontrol('Parent', obj.hButtonPanel, 'Style', 'togglebutton', 'String', thisName, 'Units', 'Pixels');
                set(h, 'Callback', eval(sprintf('@owner.callback%sButton', thisName)))
                obj.addButton(h);
            end
            
            thisName = 'Help';
            if ~any(strcmp(owner.DISABLE_BUTTONS, thisName))
                h = uicontrol('Parent', obj.hButtonPanel, 'Style', 'pushbutton', 'String', thisName, 'Units', 'Pixels');
                set(h, 'Callback', eval(sprintf('@owner.callbackHelpButton')))
                obj.addButton(h);
            end

            set(obj.hTable, 'CellSelectionCallback', @obj.callbackCellSelectionCallback);
            set(obj.hTable, 'CellEditCallback', @owner.callbackCellEditCallback);
      
            % ----- Create Table ----------------------------------------
            [obj.typeMap, obj.typeTags]      = obj.parseCategoryFile(owner);
            if isempty(obj.typeMap)
                delete(obj.hTable)
                return;
            end
            [obj.typeNames, obj.typeNameMap] = obj.makeCategoryStrings(obj.typeMap);

            tableDescs    = owner.initTableFormat();
            tableDefaults = owner.tableCategoryDefaults(obj.typeMap, obj.typeNames);
            
            colSizes = cellfun(@(x) cellfun(@(y) numel(y), x),   obj.typeNames, 'UniformOutput', false);
            colSizes = cellfun(@(x) max(x), colSizes);
            
            % TODO: make configurable
            types = obj.typeNames;
            
            
            if obj.ENABLE_UNASSIGNED_LABEL
                types = cellfun(@(x) [x ' '], types, 'UniformOutput', false);
            end
            
            obj.tableDesc.names        = [{obj.typeMap.majorLabel}     'Display'    tableDescs.names             'Description'];
            obj.tableDesc.format       = [types                        'logical'    tableDescs.format            'char'];
            obj.tableDesc.editable     = [true(1,numel(obj.typeMap))    true        tableDescs.editable          true];
            obj.tableDesc.initialWidth = [num2cell(colSizes*8 )         70          tableDescs.initialWidth      200];
            obj.tableDesc.defaultEntry = [tableDefaults                 true        tableDescs.defaultEntry      {''}];
            % ------------------------------------------------------------- 
            
            set(obj.hTable, 'ColumnName',     obj.tableDesc.names);
            set(obj.hTable, 'ColumnFormat',   obj.tableDesc.format);
            set(obj.hTable, 'ColumnEditable', logical(obj.tableDesc.editable));
            set(obj.hTable, 'ColumnWidth',    obj.tableDesc.initialWidth);

            set(obj.hFig,'Visible','on');  
            
            % Add Callback - Appends callback already exists from GridBackLayout
            obj.resizeCallbackID = iptaddcallback(obj.hFig, 'ResizeFcn', @obj.callbackFigureResizeFcn);
            pause(0.1) % sometimes need to wait until object gets updated?
            obj.callbackFigureResizeFcn();
            
            status = true;
        end
       
        function setVisible(obj, state)
            set(obj.hFig, 'Visible', state)
        end
        
        
        function callbackCellSelectionCallback(obj, handles, eventdata)
            
            if size(eventdata.Indices,1) ~= 1
                return;
            end
            obj.selectedViewRow   = eventdata.Indices(1,1);
            obj.selectedRow         = obj.viewRowList(obj.selectedViewRow);
            
        end
      
        
       function obj = addButton(obj, hButton)
            name = hButton.String;
              
            % Keep track of the button handles
            obj.hButtonMap(lower(name)) = hButton;
            
            
            % Determine next open grid location
            grid = obj.hLayoutButtonPanel.Grid;
            if isempty(grid)
                col = 1;
            else
                col = size(grid,2) + 1;
            end
            row = 1;
            
            
            buttonSz = [80 37];
            obj.hLayoutButtonPanel.add(hButton, row, col, 'MinimumWidth', buttonSz(1), 'Fill', 'Horizontal', 'MinimumHeight', buttonSz(2));
            
            
           % obj.hLayoutButtonPanel.HorizontalWeights = ones(1,numel(buttonNames));
            
       end 
       
       
       
       function hParent = addPanel(obj, hPanel, loc, height)
       
           if nargin == 1 %obj
               hParent = obj.hFig;
               return;
           end
           
           % Keep track of the location of the table
           currentWeights = obj.hLayoutFig.VerticalWeights;
           newWeights = zeros(numel(currentWeights)+1, 1);
           tableInd = find(currentWeights == 1);
           
           if loc <= numel(currentWeights);
                obj.hLayoutFig.insert('row', loc);
                
                if loc <= tableInd;
                    tableInd = tableInd+1;
                end
           end
           newWeights(tableInd) = 1;
           
           if  exist('height', 'var') && ~isempty(height)
               obj.hLayoutFig.add(hPanel, loc, 1, 'Fill', 'Both', 'MinimumWidth', 200, 'Anchor', 'NorthWest', 'MinimumHeight', height);
           end
            
           obj.hLayoutFig.VerticalWeights = newWeights; 
           
       end
       
       function addEntry(obj, entryMap)
         
          newEntry = obj.tableDesc.defaultEntry;
          
          if exist('entryMap', 'var') && ~isempty(entryMap) && isa(entryMap, 'containers.Map')
           
              for p = 1:numel(obj.tableDesc.names)
                if isKey(entryMap, obj.tableDesc.names{p})
                  newEntry{p} = entryMap(obj.tableDesc.names{p});
                end
              end
          end
          
          obj.addTableEntry(newEntry);
        
       end
       
       
       function updateEntry(obj, entryMap, rowIndex)
         
          entry = obj.getEntry(rowIndex);
          
          if exist('entryMap', 'var') && ~isempty(entryMap) && isa(entryMap, 'containers.Map')
           
              for p = 1:numel(obj.tableDesc.names)
                if isKey(entryMap, obj.tableDesc.names{p})
                  entry{p} = entryMap(obj.tableDesc.names{p});
                end
              end
          end
          
          obj.setTableEntry(entry,rowIndex);
       end
       

       % Delete entry from current filtered view
       function deleteEntry(obj, location)
           
           if numel(location) > 1
               
               for p = 1:numel(location)
                   obj.deleteEntry(location(p));
               end
               
           else
               % Index in full table
               loc = obj.viewRowList(location);
               
               % Update active list to reflect change in indices
               newActiveRows = obj.viewRowList;
               newActiveRows(location) = []; 
             
               obj.deleteTableEntry(loc,newActiveRows);
               
               if ~isempty(newActiveRows)
                    newActiveRows(newActiveRows > loc) =   newActiveRows(newActiveRows > loc) - 1;
               end
               obj.viewRowList = newActiveRows;
               
               
           end
   
       end
       
       
       function entryMap = getEntryMap(obj, rowIndex)
            entry = obj.getEntry(rowIndex); 
            entryMap = obj.rowEntryToMap(entry);
       end
       
       function entryMap = getViewEntryMap(obj, rowIndex)
            entry = obj.getViewEntry(rowIndex);
            entryMap = obj.rowEntryToMap(entry);
       end    
       
       % Get entry from full table
       function rowData = getEntry(obj, rowIndex)   
           data = obj.tableDataArchive;
           rowData = data(rowIndex, :);
       end
       
       % Get entry from current view table
       function rowData = getViewEntry(obj, rowIndex)   
           rowData = obj.getEntry(obj.viewRowList(rowIndex));
       end
       
        function colNames = getColumnNames(obj)
           colNames = obj.hTable.ColumnName;
       end
       
       function colName = getColumnName(obj, colIndex)
           colName = [];
           if colIndex > numel(obj.hTable.ColumnName) || colIndex < 0
               return;
           end
           colName = obj.hTable.ColumnName{colIndex};
           
       end
       
       function setSelectedRow(obj, rowIndex)
           obj.selectedViewRow = find(obj.viewRowList == rowIndex);
           obj.selectedRow = rowIndex;
       end
       
       function index = getSelectedRow(obj)
           index =  obj.selectedRow;
       end
       
       function index = getSelectedViewRow (obj, rowIndex)
           index = obj.selectedViewRow;
       end
       
       function colIndex = getColumnIndex(obj, colName)
          
           colIndex = strcmp(colName, obj.hTable.ColumnName);
           
           if sum(colIndex) == 0
             colIndex = [];
           end
           
           colIndex = find(colIndex);
           
       end
       
       function data = getData(obj, currentViewOnly)
           if ~exist('currentViewOnly', 'var') 
              currentViewOnly = false;
           end
           
           if currentViewOnly
               data = obj.hTable.Data(obj.viewRowList,:);
           else
               data = obj.tableDataArchive;
           end
           
       end
       
       function initData(obj, data)
           [m,n] = size(data);
           if(n~=length(obj.tableDesc.format))
               [~,p] = size(obj.tableDesc.format);
               dataFormat = repmat({''},1,n);
               tableFormat= repmat({''},1,p);
               for i=1:n
                   dataFormat(i) = cellstr(class(data{1,i}));
               end
               for i = 1:length(obj.tableDesc.format)
                    try
                         tableFormat(i) = cellstr(class(obj.tableDesc.format{1,i}{1}));
                    catch
                         tableFormat(i) = cellstr(obj.tableDesc.format{1,i});
                    end
               end
               for i = 1:max(n,p)
                   if ~strcmp(tableFormat{i},dataFormat{i})
                       break;
                   end
               end
               tmp = repmat({''},m,length(obj.tableDesc.names)-n);
               if i~=1
                    data = [data(:,1:i-1) tmp data(:,i:end)];
               else
                    data = [tmp data];
               end
           end
           obj.tableDataArchive   = data;
           obj.viewRowList = 1:size(data,1);
           set(obj.hTable, 'data', data);
       end
       
       function resetData(obj)
           obj.tableDataArchive     = [];
           obj.viewRowList        = [];
           set(obj.hTable, 'data', []);
       end
% 
%         typeNames     % list of dropdown strings
%         typeNameMap   % list of major/minor category labels
%         typeTags      % mapping between tags and major/minor category labels
%         typeMap
       
       function typeNames = getTypeNames(obj)
           typeNames = obj.typeNames;
       end
       
       function typeMap = getTypeMap(obj)
           typeMap = obj.typeMap;
       end
       
       function typeCats = getTypeCats(obj)
           typeCats = obj.typeNameMap;
       end
       
       function typeTags = getTypeTags(obj)
           typeTags = obj.typeTags;
       end
       
       function typeName = getTypeNameFromCat(obj, typeCat, column)
           
           typeName = [];
           
           if ~exist('column', 'var') || isempty(column)
               column = 1:numel(obj.typeNames); % Search all of them
           elseif ischar(column)
                column = obj.getColumnIndex(column); % Could be the name
           end
           
           if any(column > numel(obj.typeNames))
               return;
           end
           
           if isempty(typeCat{2})
               typeCat{2} = '';
           end
           
           for p = 1:numel(column)
              found = strcmp(obj.typeNameMap{column(p)}(:,1), typeCat{1}) & strcmp(obj.typeNameMap{column(p)}(:,2), typeCat{2});
              if any(found)
                  typeName = obj.typeNames{column(p)}{found};
                  return
              end    
           end
           
        
       end
       
       function typeCat = getTypeCatFromName(obj, typeName, column)
           
           typeCat = [];
           
           if ~exist('column', 'var') || isempty(column)
               column = 1:numel(obj.typeNames); % Search all of them
           elseif ischar(column)
                column = obj.getColumnIndex(column); % Could be the name
           end
           
           if any(column > numel(obj.typeNames))
               return;
           end
           
           for p = 1:numel(column)
              found = strcmp(obj.typeNames{column(p)}, typeName);
              if any(found)
                  typeCat = obj.typeNameMap{column(p)}(found,:);
                  return
              end    
           end
           
       
       end
       
       function typeName = getTypeTagName(obj, tag)
           
           typeName = [];
           
           if ~obj.typeTags.isKey(tag)
              return;
           end
           
           typeCat = obj.typeTags(tag);
           typeName = obj.getTypeNameFromCat(typeCat);
              
       end       
       
       function index = getDropDownIndex(obj, rowIndex, colIndex)
           
           index = [];
           
           % Check if column is a dropdown
           if ~iscell(obj.hTable.ColumnFormat)
               return
           end
           
           if isnumeric(rowIndex)
                textVal = obj.hTable.Data(rowIndex,colIndex);
           else 
                textVal = rowIndex;
           end
           
           if isempty(textVal)
               textVal = ' ';
           end
           
           index =  strcmp(textVal, obj.typeNames{colIndex});
           
       end
  
    end
    
end

