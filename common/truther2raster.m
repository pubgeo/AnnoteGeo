% [bin_raster_img,indx_raster_img,class_raster_img,geotiffparts,colorized_raster] = truther2raster(gt_path,varargin)
%
% Converts a Mat file from the truther tool to an indexed raster, colorized
% raster, binary raster, and geotiff components. Also has options to save
% those outputs locally using parameter arguments.
%
% Input Variables
%**************************************************************************
% gt_path: gt_path can either be a direct file path to the .mat file or
% a .mat struct loaded into the MATLAB workspace via load() following the same format.
%
% resolution: There is an optional input, resolution, which is the pixel spacing. Default is 0.5 meters.
%
% 'SaveFlag' Can use logical parameter 'SaveFlag' to save out an indexed geotiff and
% colorized tiff file
%
% 'SaveName': Can use parameter 'SaveName' to specify the filename of the saved out
% images
%
% 'ClassImg': Parameter 'ClassImg' is a classification geotiff that is used to define
% the size of the output raster.
%
%'refMat: Parameter 'refMat' is a reference matrix that replaces the
% reference matrix stored in the .mat file. Use this if you want to change
% the reference matrix to another one. (i.e. you have a geotiff that you
% want to overlay with your ground truth but they have different reference
% matrices
%
% 'ImageSize': Parameter 'ImageSize' is a matrix [m n] that specifies the image size of
% the output raster.
%
% Output Variables
% **********************************************
% bin_raster_img: binary raster image raster
%
% indx_raster_img: raster image with each building labeled as its own value
% to differentiate building footprints.
%
% class_raster: raster image that follows LAS standard classification
% labeling
%
% geotiffparts: struct that contains the necessary components to save out a
% geotiff of the indexed raster image.
%
% colorized_raster: colorized raster that is colored to be more presentable
% in presentation scenarios
%
% Examples
% **********************************************
% Example 1: Simple usage
%
% [bin_raster_img,indx_raster_img,class_raster_img,geotiffparts,colorized_raster] = truther2raster('.\truth.mat',0.5)
%
% This example uses a .mat path as the input and also uses the
% optional resolution input variable, 0.5, so each pixel will correspond to 0.5 meters.
% The outputs will be what are described above.
%
% Example 2: Saving output
%
% [bin_raster_img,indx_raster_img,raster_img,geotiffparts,colorized_raster] = truther2raster('.\truth.mat',0.5,'SaveFlag',true,'SaveName','Saved_File')
% 
% This example uses the 'SaveFlag' parameter and passes in a value of true.
% This will cause the function to save out a geotiff, a colorized raster,
% and a classification labeled raster with the file name
% matching the 'SaveName' parameter with '_indx_geo.tif', '_class_color.tif'
% and '_class_label.tif' appended to the end. In this case, it would be
% Saved_File_indx_geo.tif, Saved_File_class_color.tif, and
% Saved_File_class_label.tif saved to the current working directory.
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

function [bin_raster_img,indx_raster_img,class_raster_img,geotiffparts,colorized_raster] = truther2raster(gt_path,varargin)
    ip = inputParser;
    defaultSaveFlag = false;
    defaultMaterialFlag=  false;
    defaultSaveName = 'Result';
    defaultResolution = 0.5;
    defaultClassImg = NaN;
    defaultImageSize = NaN;
    defaultrefMat = NaN;
    defaultSavePath = '.\';
    addRequired(ip,'gt_path');
    addOptional(ip,'resolution',defaultResolution,@isnumeric);
    addParameter(ip,'SavePath',defaultSavePath,@isstr);
    addParameter(ip,'MaterialFlag',defaultMaterialFlag,@islogical);
    addParameter(ip,'SaveFlag',defaultSaveFlag,@islogical);
    addParameter(ip,'SaveName',defaultSaveName,@isstr);
    addParameter(ip,'ClassImg',defaultClassImg,@ismatrix);
    addParameter(ip,'refMat',defaultrefMat,@ismatrix);
    addParameter(ip,'ImageSize',defaultImageSize,@ismatrix);
    parse(ip,gt_path,varargin{:});
    
    if(ischar(ip.Results.gt_path))
        disp('Now loading in GT file...');
        gt_polys = load(ip.Results.gt_path);
    else
        gt_polys = ip.Results.gt_path;
    end
    if isnan(ip.Results.ImageSize)
        origImgRows = gt_polys.metadata.NumImageRows;
        origImgCols = gt_polys.metadata.NumImageColumns;
    else
        origImgRows = ip.Results.ImageSize(1);
        origImgCols = ip.Results.ImageSize(2);
    end
    tic
        %Load the AOI used for GT
        gt_aoi = gt_polys.metadata;
        %Extract the ref matrix
        if ~isnan(ip.Results.refMat) 
            refMatIndx = ip.Results.refMat;
        else
            refMatIndx = gt_polys.metadata.RefMatrix; 
        end
        %Extract original resolution
        origRes = abs(refMatIndx(2));
        % Use refMat from input for conversion
        R = refMatIndx;
        R(2) = R(2)*ip.Results.resolution/abs(R(2));
        R(4) = R(4)*ip.Results.resolution/abs(R(4));
        %{
        scalingFactor = origRes/ip.Results.resolution;
        imgSize = [ceil(origImgRows*scalingFactor) ceil(origImgCols*scalingFactor)];
        %}
        imgSize = [origImgRows origImgCols];
        if isnan(ip.Results.ClassImg)
            if isnan(ip.Results.ImageSize)
                imgSize = imgSize(1:2);  
            else
                imgSize = ip.Results.ImageSize;
                R = refMatIndx;
            end
        else
            imgSize = size(ip.Results.ClassImg);
            R = refMatIndx;
        end
        numR = imgSize(1);
        numC = imgSize(2);
        disp('Converting....')
        %Create a blank image that is the size of the AOI
        bldg_mask = false(numR, numC);
        l_veg_mask  = (zeros(numR, numC));
        m_veg_mask = (zeros(numR, numC));
        h_veg_mask = (zeros(numR, numC));
        hole_mask  = false(numR, numC);
        clutter_mask = (zeros(numR, numC));
        water_mask = (zeros(numR, numC));
        bridge_mask = (zeros(numR, numC));
        rail_mask = (zeros(numR, numC));
        vehicle_mask = (zeros(numR, numC));
        indx_raster_img = zeros(numR, numC);
        unclass_mask = zeros(numR, numC);
        unlab_mask = zeros(numR,numC);
        % Create blank image for materials
        if(ip.Results.MaterialFlag == true)
            unclass_mat_mask = zeros(numR, numC);
            asphalt_mask = zeros(numR, numC);
            concrete_mask = zeros(numR, numC);
            glass_mask = zeros(numR, numC);
            tree_mask = zeros(numR, numC);
            non_tree_mask = zeros(numR, numC);
            metal_mask = zeros(numR, numC);
            red_ceram_mas = zeros(numR, numC);
            soil_mask = zeros(numR, numC);
            sol_pan_mask = zeros(numR, numC);
            water_mat_mask = zeros(numR, numC);
            mat_mask = zeros(numR,numC);
        end
        % Generate Rasters
        checkpoint = 1;
        for p = 1:numel(gt_polys.poly)
            if p >= checkpoint
                fprintf('%d out of %d\n',p,numel(gt_polys.poly)); 
                checkpoint = p+numel(gt_polys.poly)/4;
            end
            
            %Get the label of this polygon 
            [tokens, match] = regexp(gt_polys.table{p,1}, '[\S. ]*\((\d+)\)\S*$', 'tokens', 'match');
            if(ip.Results.MaterialFlag == true)
                [tokensMat, matchMat] = regexp(gt_polys.table{p,3}, '[\S. ]*\(((\d)+)\)\S*$', 'tokens', 'match');
                if(isempty(tokensMat))
                    material = 0;
                else
                    material = str2num(cell2mat(tokensMat{1}));
                end
            end
            
            category = str2num(cell2mat(tokens{1}));

            [latcells]={gt_polys.geoPoly{p}(:,1)'};
            [loncells]={gt_polys.geoPoly{p}(:,2)'};

            % material classification raster
            if(ip.Results.MaterialFlag == true)
                for j=1:length(latcells)
                    [r_bldg, c_bldg] = map2pix(R, latcells{j}, loncells{j}); 
                    tempMask = double(roipoly(numR,numC, c_bldg(1:end), r_bldg(1:end)));
                    tempMask(tempMask == 1) = material;
                    mat_mask = (mat_mask+tempMask); 
                end
            end
            
            switch category
                case 0 % Not Labeled/classified
                    for j=1:length(latcells)
                        [r_bldg, c_bldg] = map2pix(R, latcells{j}, loncells{j}); 
                        tempMask = double(roipoly(numR,numC, c_bldg(1:end), r_bldg(1:end)));
                        tempMask(tempMask == 1) = 0;
                        unlab_mask = (unlab_mask+tempMask); %
                    end
                case 1 % Unclassified
                    for j=1:length(latcells)
                        [r_bldg, c_bldg] = map2pix(R, latcells{j}, loncells{j}); 
                        tempMask = double(roipoly(numR,numC, c_bldg(1:end), r_bldg(1:end)));
                        tempMask(tempMask == 1) = 1;
                        unclass_mask = (unclass_mask+tempMask); %
                    end
                case 2 % Ground/Holes
                    for j=1:length(latcells)  % Just to know # of parts in the polygon              
                        [r_bldg, c_bldg] = map2pix(R, latcells{j}, loncells{j}); 
                        tempMask = roipoly(numR,numC, c_bldg(1:end), r_bldg(1:end));
                        hole_mask = hole_mask | tempMask; %Add the new raster pixels to the existing raster
                    end
                case 3 % Low Vegetation
                    for j=1:length(latcells)
                        [r_bldg, c_bldg] = map2pix(R, latcells{j}, loncells{j}); 
                        tempMask = double(roipoly(numR,numC, c_bldg(1:end), r_bldg(1:end)));
                        tempMask(tempMask == 1) = 3;
                        l_veg_mask = (l_veg_mask+tempMask); %
                    end
                case 4 % Medium vegetation
                    for j=1:length(latcells)
                        [r_bldg, c_bldg] = map2pix(R, latcells{j}, loncells{j}); 
                        tempMask = double(roipoly(numR,numC, c_bldg(1:end), r_bldg(1:end)));
                        tempMask(tempMask == 1) = 4
                        m_veg_mask = (m_veg_mask+tempMask); %
                    end
                case 5 % High vegetation
                    for j=1:length(latcells)
                        [r_bldg, c_bldg] = map2pix(R, latcells{j}, loncells{j}); 
                        tempMask = double(roipoly(numR,numC, c_bldg(1:end), r_bldg(1:end)));
                        tempMask(tempMask == 1) = 5;
                        h_veg_mask = (h_veg_mask+tempMask); %
                    end
                case 6 % Building
                    for j=1:length(latcells)  % Just to know # of parts in the polygon              
                        [r_bldg, c_bldg] = map2pix(R, latcells{j}, loncells{j}); 
                        tempMask = roipoly(numR,numC, c_bldg(1:end), r_bldg(1:end));
                        bldg_mask = bldg_mask | tempMask; %Add the new raster pixels to the existing raster
                        % Index each building for indexed raster
                        indx_bldg_mask = double(tempMask);
                        indx_bldg_mask(indx_bldg_mask==1) = p;
                        indx_raster_img = indx_raster_img + indx_bldg_mask; % Add images because we know there is no overlap
                    end
                case 9 % Water
                    for j=1:length(latcells)
                        [r_bldg, c_bldg] = map2pix(R, latcells{j}, loncells{j}); 
                        tempMask = double(roipoly(numR,numC, c_bldg(1:end), r_bldg(1:end)));
                        tempMask(tempMask == 1) = 9;
                        water_mask = (water_mask+tempMask); %
                    end
                case 10 % Rail
                    for j=1:length(latcells)
                        [r_bldg, c_bldg] = map2pix(R, latcells{j}, loncells{j}); 
                        tempMask = double(roipoly(numR,numC, c_bldg(1:end), r_bldg(1:end)));
                        tempMask(tempMask == 1) = 10;
                        rail_mask = (rail_mask+tempMask); %
                    end
                case 17 % Bridges
                    for j=1:length(latcells)
                        [r_bldg, c_bldg] = map2pix(R, latcells{j}, loncells{j}); 
                        tempMask = double(roipoly(numR,numC, c_bldg(1:end), r_bldg(1:end)));
                        tempMask(tempMask == 1) = 17;
                        bridge_mask = (bridge_mask+tempMask); %
                    end
                case 64 % Vehicle
                    for j=1:length(latcells)
                        [r_bldg, c_bldg] = map2pix(R, latcells{j}, loncells{j}); 
                        tempMask = double(roipoly(numR,numC, c_bldg(1:end), r_bldg(1:end)));
                        tempMask(tempMask == 1) = 64;
                        vehicle_mask = (vehicle_mask+tempMask); %
                    end
                case 65 % Uncertain
                    for j=1:length(latcells)
                        [r_bldg, c_bldg] = map2pix(R, latcells{j}, loncells{j}); 
                        tempMask = double(roipoly(numR,numC, c_bldg(1:end), r_bldg(1:end)));
                        tempMask(tempMask == 1)= 65; % Replace all clutter pixels with 65
                        clutter_mask = (clutter_mask+tempMask); %
                         % Index each building for indexed raster
                        indx_bldg_mask = double(tempMask);
                        indx_bldg_mask(indx_bldg_mask==65) = p;
                        indx_raster_img = indx_raster_img + indx_bldg_mask; % Add images because we know there is no overlap
                    end
            end
        end
        % Create Masks
        % Create holes/ground in bldg_mask
        bldg_mask = bldg_mask & ~hole_mask;
        % Create holes/ground in material mask
        mat_mask = mat_mask.*double(~hole_mask);
        mat_mask = uint8(mat_mask);
        % Create non-binary raster with everything (With number labels)
        cls_bldg_mask = double(bldg_mask);
        cls_bldg_mask(cls_bldg_mask==1)=6;
        % Add together masks to generate classification raster and create
        % holes
        % class_raster_img = (cls_bldg_mask+clutter_mask+bridge_mask+rail_mask+vehicle_mask+unclass_mask+water_mask).*~hole_mask;
        % Priority Scheme Implementation
        % Priority from low to high is: Water, Bridge, Building, Rail,
        % Vehicle, Unclass, Ground
        class_raster_img = water_mask+l_veg_mask+m_veg_mask+h_veg_mask+clutter_mask+unlab_mask;
        class_raster_img(bridge_mask==17) = 17;
        class_raster_img(cls_bldg_mask==6) = 6;
        class_raster_img(rail_mask == 10) = 10;
        class_raster_img(vehicle_mask == 64) = 64;
        class_raster_img(unclass_mask == 1) = 1;
        class_raster_img = class_raster_img.*~hole_mask; % Create Holes
        % Convert unlabled ground to ground classification (2)
        class_raster_img(class_raster_img==0) = 2; % Convert unlabled ground to ground classification (2)
        % Create holes in indexed buildings
        indx_raster_img = indx_raster_img .* ~hole_mask;
        % Convert to Uint16 to save space
        indx_raster_img = uint16(indx_raster_img);
        % Get Binary Building/Ground Raster image
        bin_raster_img = bldg_mask;
        % Save geotiff parts for writing out geotiffs
        geotiffparts.final_img = indx_raster_img;
        geotiffparts.R = R;
        geotiffparts.GeoKey = gt_aoi.GeoTIFFTags.GeoKeyDirectoryTag;
        % Create colorized raster
        [colorized_raster] = change_cmap(class_raster_img);
        colorized_raster = uint8(colorized_raster*255);
        class_raster_img = uint8(class_raster_img);
        % Adjust for Vricon
        try
            geotiffparts.GeoKey = rmfield(geotiffparts.GeoKey,'Unknown')
            geotiffparts.GeoKey.GTRasterTypeGeoKey = 1
        catch
        end
        toc
        % Save out geotiff
        if ip.Results.SaveFlag == true
            TiffTags.Compression = 'none';
            geotiffwrite([ip.Results.SavePath '\' ip.Results.SaveName '_GTI.tif'], geotiffparts.final_img, geotiffparts.R,'GeoKeyDirectoryTag', geotiffparts.GeoKey,'TiffTags',TiffTags); 
            disp('Done saving indexed geotiff...');
            geotiffwrite([ip.Results.SavePath '\' ip.Results.SaveName '_GTC.tif'], colorized_raster, geotiffparts.R,'GeoKeyDirectoryTag', geotiffparts.GeoKey,'TiffTags',TiffTags); 
            disp('Done saving classification colored geotiff...');
            geotiffwrite([ip.Results.SavePath '\' ip.Results.SaveName '_GTL.tif'], class_raster_img, geotiffparts.R,'GeoKeyDirectoryTag', geotiffparts.GeoKey,'TiffTags',TiffTags); 
            disp('Done saving classification label geotiff...');
            if(ip.Results.MaterialFlag == true)
               geotiffwrite([ip.Results.SavePath '\' ip.Results.SaveName '_Material.tif'], mat_mask,geotiffparts.R,'GeoKeyDirectoryTag', geotiffparts.GeoKey,'TiffTags',TiffTags);
               disp('Done saving Material label geotiff...');
            end
        end
end