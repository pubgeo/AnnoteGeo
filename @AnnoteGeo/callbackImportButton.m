function callbackImportButton(obj, handles, eventdata)
% CALLBACKIMPORTBUTTON
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
     obj.logger.trace(mfilename, 'Enter')
     
     title(obj.hFigure.CurrentAxes, 'Importing...', 'FontWeight', 'Normal'); drawnow
      
      pts = [1 1; obj.metadata.Height obj.metadata.Width; 1 obj.metadata.Width; obj.metadata.Height 1];
      [ outPts ] = geoTiffProj(obj.metadata, pts, 0);

     
      [FileName,PathName,FilterIndex] = uigetfile('*.SHP', 'Import', obj.lastImportDir);
      
      if isnumeric(FileName) 
        title(obj.hFigure.CurrentAxes, ''); drawnow
        obj.logger.info(mfilename,   sprintf('Exit - No file selected'));
        return;
      end
      
      obj.lastImportDir = PathName;
      
      
      obj.logger.trace(mfilename, sprintf('Loading shapefile: %s', fullfile(PathName,FileName)))
      try
        [shp, attr] = shaperead(fullfile(PathName,FileName));
      catch
        title(obj.hFigure.CurrentAxes, ''); drawnow
        obj.logger.error(mfilename, 'Failed to read shapefile');                  
        return;
      end
      
      % TODO: Functionize
      % ===================================================================
      [a, b] = fileparts(fullfile(PathName,FileName));
      prjFN = fullfile(a,[b '.prj']);
      
      fid = fopen(prjFN, 'r');
      str = fread(fid, '*char')';
      fclose(fid);
      
      tmp = regexp(str, 'PROJCS\["(\w+)",', 'tokens');
      if isempty(tmp)
      	% TODO: Do something
      end
      proj = tmp{1};
      
      tmp = regexp(str, 'PROJECTION\["(\w+)"\]', 'tokens');
      projType = tmp{1};
      
      prj = [];
      prj.name = proj{1};
      prj.type = projType{1};  
      if strcmp(projType, 'Transverse_Mercator')
          tmp = textscan(proj{1}, '%s %d  %s %s %d%c', 'Delimiter', '_');
          prj.zone = double(tmp{5});
          if strcmp(tmp{6}, 'S')
              prj.zone = -prj.zone;
          end    
          
          tmp = regexp(str, 'SPHEROID\["(\w+)",([0-9.]+),([0-9.]+)', 'tokens');
          eName    = tmp{1}{1};
          eMajor   = str2double(tmp{1}{2});
          eInvFlat = str2double(tmp{1}{3});
          eMinor   = (1- 1/eInvFlat)*eMajor;
          eEccSqrd = (eMajor.^2  - eMinor.^2)/eMajor.^2;
         
          prj.eModel.name                = eName;
          prj.eModel.semiMajorAxis       = eMajor;
          prj.eModel.semiMinorAxis       = eMinor;
          prj.eModel.inverseFlattening   = eInvFlat;
          prj.eModel.eccentricitySquared = eEccSqrd;
          
      end
      
     
      
      if strcmp(obj.metadata.ModelType,'ModelTypeGeographic') && strcmp(prj.type, 'Transverse_Mercator')

          % UTM -> Geographic
          [my, mx] = arrayfun(@(x) utm2ell(x.Y,x.X,repmat(prj.zone,size(x.X)),prj.eModel.semiMajorAxis,prj.eModel.eccentricitySquared), shp, 'UniformOutput', false);

          my = cellfun(@(x) x.*180./pi, my, 'UniformOutput', false);
          mx = cellfun(@(x) x.*180./pi, mx, 'UniformOutput', false);
          
          
   
      elseif strcmp(obj.metadata.ModelType,'ModelTypeProjected') && strcmp(prj.type, 'Transverse_Mercator') ...
              && strcmp(obj.metadata.CTProjection, 'CT_TransverseMercator')
            
          tmp = textscan(obj.metadata.Projection, 'UTM zone %d%c');
          zone = tmp{1};
          if strcmp(tmp{2}, 'S')
              zone = -zone;
          end
            
          if zone ~= prj.zone
            title(obj.hFigure.CurrentAxes, ''); drawnow
            obj.logger.warn(mfilename,   sprintf('Exit - UTM zones do not match: %d == %d',  zone,  prj.zone));
            return
          end
          
          
          mx = {shp.X};
          my = {shp.Y};
          
      else
         
          title(obj.hFigure.CurrentAxes, ''); drawnow
          obj.logger.warn(mfilename,  sprintf('Exit - Unsupported model conversion requested: %s -> %s',  obj.metadata.ModelType, prj.type));
          return
      end
      
               
       % Model -> Image

       t = cellfun(@(x,y) geoTiffProj(obj.metadata, [x' y'], 1, 1), mx, my, 'UniformOutput', false);
       obj.logger.info(mfilename, sprintf('%d shapes found in file', numel(t)))

       % Remove for any shape with a vertex outsize the image
       remove = cellfun(@(x) any( x(:,1) < 1 |  x(:,2) < 1 | x(:,1) > obj.metadata.Width |  x(:,2) >  obj.metadata.Height ), t);
       obj.logger.info(mfilename, sprintf('%d shapes removed due to being outside the image bounds', sum(remove)))
       obj.removedPolygons = [];
       obj.removedInd = [];
       obj.removedPolygons = t(remove);
       obj.removedInd = remove;
       t(remove) = [];
       
       % Shift vertices to current image space
       yShift = -obj.currentRows(1);
       xShift = -obj.currentCols(1);
       t = cellfun(@(x) bsxfun(@plus, x, [xShift yShift]), t, 'UniformOutput', false);
      
       % Split at Nans into subpolys
       [tx, ty] = cellfun(@(x)  polysplit(x(:,1), x(:,2)), t, 'UniformOutput', false);
       n = cellfun(@numel, tx);
       
       hole_flags = cellfun(@(x,y) ispolycw(x,y), tx, ty, 'UniformOutput', false);
      % ===================================================================
    
       
      labels = containers.Map;
      for p = 1:numel(t)
        
        
        % First annotation is always a building
        labels('Type') = obj.table.getTypeTagName('building');  % TODO: keyname of tag should not be hardcoded
        obj.addAnnotation(tx{p}{1}, ty{p}{1}, labels);
        
        
      
        for q = 2:n(p)  
           
            if hole_flags{p}(q)
                labels('Type') = obj.table.getTypeTagName('notbuilding'); % TODO: keyname of tag should not be hardcoded
            else
                labels('Type') = obj.table.getTypeTagName('building');    % TODO: keyname of tag should not be hardcoded
            end
            obj.addAnnotation(tx{p}{q}, ty{p}{q}, labels);
            
        end
      end
      
      title(obj.hFigure.CurrentAxes, ''); drawnow

      obj.logger.trace(mfilename, 'Exit')
end

