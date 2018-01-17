function callbackExportButton( obj, handles, eventdata)
% CALLBACKEXPORTBUTTON
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
      title(obj.hFigure.CurrentAxes, 'Exporting...', 'FontWeight', 'Normal'); drawnow
        
      
      [FileName,PathName,FilterIndex] = uiputfile('*.kml', 'Export', obj.getDefaultSaveName());
      
      if isnumeric(FileName) 
        return;
      end
      
      tableData = obj.table.getData();
     
      
      poly = cell(1,numel(obj.hPolys));
      for p = 1:numel(obj.hPolys)
        poly{p} = [get(obj.hPolys(p), 'XData') get(obj.hPolys(p), 'YData')];
      end
      
      img = get(obj.hImage, 'CData');
      
      [s, tableData0, poly0, img0] = obj.saveData(tableData, poly, img);

      % if standard data was changed, update what is saved
      if ~isempty(tableData0)
          tableData = tableData0;
      end
         
      if ~isempty(poly0)
          poly = poly0;
      end
      
      if ~isempty(img0)
          img = img0;
      end
      
      %%
      gs = geoshape();
      for p = 1:numel(s.geoPoly)
        
        % Take a stab at converting to lat/lon
        if strcmp(obj.metadata.ModelType, 'ModelTypeGeographic')
            gs(p).Latitude = s.geoPoly{p}(:,2);
            gs(p).Longitude = s.geoPoly{p}(:,1);
        elseif strcmp(obj.metadata.ModelType, 'ModelTypeProjected') && strcmp(obj.metadata.Projection(1:3), 'UTM')
           tmp = textscan(obj.metadata.Projection, '%s %s %d%c');
           thisPoly = s.geoPoly{p};
           E = thisPoly(:,1)+0.0;
           N = thisPoly(:,2)+0.0;
           Z = double(tmp{3});
           if strcmp(tmp{4}, 'S')
               Z = -Z;
           end
           [lat lon] = utm2ell(N, E, repmat(Z, size(thisPoly,1), 1));
           gs(p).Latitude  = rad2deg(lat);
           gs(p).Longitude = rad2deg(lon);
        else
            warning('Unknown geographic model: %s\n', obj.metadata.ModelType);
            title(obj.hFigure.CurrentAxes, ''); drawnow
            return;
        end
      end 
      if verLessThan('matlab', '8.5')  % this may not be the correct version (R2014b doesn't have 'FaceColor')
        kmlwrite(fullfile(PathName, FileName), gs, 'Color', repmat([1 0 0], size(s.geoPoly,2), 1), 'Color', 'red', 'Width', 2);
      else
        kmlwrite(fullfile(PathName, FileName), gs, 'Color', repmat([1 0 0], size(s.geoPoly,2), 1), 'FaceColor', 'none', 'LineWidth', 2);
      end
      
      
      %%
      title(obj.hFigure.CurrentAxes, ''); drawnow
     
    end

