function cmenu = setAnnotationContextMenu(obj, hPoly )
% SETANNOTATIONCONTEXTMENU 
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

    cmenu = uicontextmenu('Parent', obj.hFigure);
    
    uimenu(cmenu, 'label', 'Edit',  'Callback', {@Annote.callbackAnnotationContextMenu, obj}, 'Tag', 'annote.edit');
    
    if obj.ENABLE_POLYSPLIT
        uimenu(cmenu, 'label', 'Split', 'Callback', {@Annote.callbackAnnotationContextMenu, obj}, 'Tag', 'annote.split');
    end

    menuDelete = uimenu(cmenu, 'label', 'Delete', 'Separator', 'off');
    uimenu(menuDelete, 'label', 'Delete',  'Callback', {@Annote.callbackAnnotationContextMenu, obj}, 'Tag', 'annote.delete');
   
    
    map = obj.table.getTypeMap;
    tag = 'annote.category';
    for loopCats = 1:numel(map); 
        thisCat = map(loopCats);
        
        menuLabel = uimenu(cmenu, 'label', map(loopCats).majorLabel);
        
        if loopCats == 1
            menuLabel.Separator = 'on';
        end
        
        for loopMajor =  1:size(thisCat.labelMap,1)
        
            
            s = [];
            s.category = thisCat.majorLabel;
            s.major    = thisCat.labelMap{loopMajor,1};
            s.minor    = '';
            menuMajor = uimenu(menuLabel, 'label', thisCat.labelMap{loopMajor,1});
            
            if numel(thisCat.labelMap{loopMajor,2}) == 0
                set(menuMajor, 'Callback', {@Annote.callbackAnnotationContextMenu, obj});
                set(menuMajor, 'Tag', tag);
                set(menuMajor, 'UserData', s);
            end
            
            for loopMinor = 1:numel(thisCat.labelMap{loopMajor,2})
                 s.minor = thisCat.labelMap{loopMajor,2}{loopMinor};
                 menuMinor = uimenu(menuMajor, 'label', thisCat.labelMap{loopMajor,2}{loopMinor}, 'Tag', tag, 'Callback', {@Annote.callbackAnnotationContextMenu, obj});
                 set(menuMinor, 'UserData', s);
            end
            
        end
    end
    
    set(hPoly, 'UIContextMenu',cmenu);
    
end

