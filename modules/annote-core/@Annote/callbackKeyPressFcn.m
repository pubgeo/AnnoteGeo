function keyUsed = callbackKeyPressFcn(obj, h, event)
% CALLBACKKEYPRESSFCN 
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

  % Check if right or less mouse is pressed
  if ~isempty(obj.mouseClick) && ~isempty( cell2mat(   intersect(obj.mouseClick, {'normal', 'alt'}) ) )  
      keyUsed = false;
      return;
  else
      obj.mouseClick = [];
  end


  keyUsed = true;
  if  isempty(event.Modifier)
    switch (event.Key)
      case 'uparrow'
        obj.pan(1);
      case 'e'
        obj.pan(1);
      case 'leftarrow'
        obj.pan(-2);
      case 's'
        obj.pan(-2);
      case 'rightarrow'
        obj.pan(2);
      case 'f'
        obj.pan(2);
      case 'downarrow'
        obj.pan(-1);
      case 'd'
        obj.pan(-1);
      case 'r'
        obj.zoom(1);   %Zoom in
      case 'w'
        obj.zoom(-1); % Zoom out
      case 'backquote'
        obj.adjustClim();
      case '1'
        obj.adjustClim(-1,-1);
      case '2'
        obj.adjustClim(-1,+1);
      case '3'
        obj.adjustClim(+1,-1);
      case '4'
        obj.adjustClim(+1,+1);
      case 'escape'
        rtn = questdlg('Do you really want to reset the draw state?', ...
          obj.toolTitle, 'Yes', 'No', 'Yes');
        if strcmp(rtn, 'Yes')
          obj.isDrawActive = false;
        end
      otherwise
        keyUsed = false;
    end
    
    if keyUsed
        return
    end
    
    if obj.ENABLE_HOTKEY_FNUM_ADD
        if strcmp(event.Key(1), 'f') && numel(event.Key) > 1
            
            fnum = textscan(event.Key, 'f%d'); fnum = fnum{1};
            
            % Get labels of first category
            labels = obj.table.getTypeNames;
            
            if fnum <= numel(labels{1})
                
                columnIndex = obj.ENABLE_HOTKEY_FNUM_ADD;
                
                title(sprintf('Labeling: %s', labels{columnIndex}{fnum}))
                callbackAddButton(obj, [], [])

                % Update table
                entryMap = containers.Map;
                colName = obj.table.getColumnName(1);
                entryMap(colName) = labels{columnIndex}{fnum};
                obj.table.updateEntry(entryMap, 1)  
                
                % Update color
                eventdata.Indices = [1 1];
                eventdata.NewData = labels{columnIndex}{fnum};
                obj.callbackCellEditCallback([], eventdata)

                title('')
            end
            
        else
                keyUsed = false;
        end
    end
    
  elseif  strcmp(event.Modifier, 'shift')
    switch  (event.Key)
      case 'w'
      	obj.zoom(0); %Reset Zoom
        
      case 'd'
        if obj.ENABLE_HOTKEY_DELETE
            callbackDeleteButton(obj, [], []) 
        end
        
      case 'a'
        if obj.ENABLE_HOTKEY_ADD
            callbackAddButton(obj, [], [])
        end
        
      otherwise
      	keyUsed = false;
    end
    
    
    
  else
    keyUsed = false;
  end

end