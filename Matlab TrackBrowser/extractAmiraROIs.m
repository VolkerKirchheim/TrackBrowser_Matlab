function analysisInfo = extractAmiraROIs(selectedTracks,analysisInfo)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%
%
tic
channel2 =  ~isequal(analysisInfo.channel2Path,"");
channel3 =  ~isequal(analysisInfo.channel3Path,"");
channelFrameNumber = false;  % tag to allocate ROIs for channels 2 and 3 according to frame number (true) or channel 1 frame number (false)
imageName = analysisInfo.filenames(1);
imagePath = strcat(string(analysisInfo.channel1Path),'/',string(imageName));
imageData = bfopen(char(imagePath));
omeMeta = imageData{1, 4};
xMax = omeMeta.getPixelsSizeX(0).getValue(); % image width, pixels
yMax = omeMeta.getPixelsSizeY(0).getValue(); % image height, pixels
if analysisInfo.confocal
    zMax = omeMeta.getPixelsSizeZ(0).getValue();
else
    zMax = omeMeta.getPixelsSizeT(0).getValue(); % number of Z slices  for whatever reason Z is saved in T
end

%seriesCount = size(data, 1);
imageSize = [xMax yMax zMax];
%series1 = imageData{1, 1};
xMax = imageSize(1);
yMax = imageSize(2);
zMax = imageSize(3);
mode = 1;
%
channels = 1+channel2*2+channel3*4;   %binary code for which channels are used
% Creating Folder Name from Timestamp
resultFolder = strcat(string(analysisInfo.analysisPath),"/",datestr(now,'yyyymmdd_HHMM_'),"ROIS",string(analysisInfo.nameAddon));
mkdir(char(resultFolder));
resultFileName1 = strcat(resultFolder,"/",datestr(now,'yyyymmdd_HHMM_'),"ROIS",string(analysisInfo.nameAddon));
resultFileName2 = strcat(resultFolder,"/",datestr(now,'yyyymmdd_HHMM_'),"SLTR",string(analysisInfo.nameAddon));
analysisInfoFileName = strcat(resultFolder,"/","analysisInfo",string(analysisInfo.nameAddon));
save(char(analysisInfoFileName),'analysisInfo');
% ROI size in pixel (odd number with central pixel being the
% determined position
width = floor(analysisInfo.roiWidth / 2);
roiSize = 2*width+1;
if roiSize > xMax
    roiSizeX = xMax;
else 
    roiSizeX = roiSize;
end
if roiSize > yMax
    roiSizeY = yMax;
else 
    roiSizeY = roiSize;
end
if roiSize > zMax
    roiSizeZ = zMax;
else 
    roiSizeZ = roiSize;
end
depth = floor(analysisInfo.roiWidthP / 2);
if zMax ==1
    depth = 0;
end

% 2D arrays (rows: # of images, collumn: # of selected
% trajectories)  for x, y, and z positions
% and trackTime with frame number
%
tracksToExtract = size(selectedTracks,2);
nFrames = size(analysisInfo.filenames,2);
trackTime = zeros(nFrames,tracksToExtract);
%
xC = zeros(nFrames,tracksToExtract);
yC = zeros(nFrames,tracksToExtract);
zC = zeros(nFrames,tracksToExtract);
%


%
for index = 1:tracksToExtract

    startindex = selectedTracks(index).start;
    endindex = selectedTracks(index).end;
    trackLength = endindex - startindex +1;
    trackTimes = (1:trackLength)';
    trackTime(startindex:endindex,index) = trackTimes;
    xC(startindex:endindex,index) = selectedTracks(index).x(1:trackLength,1);
    yC(startindex:endindex,index) = selectedTracks(index).y(1:trackLength,1);
    zC(startindex:endindex,index) = selectedTracks(index).z(1:trackLength,1);
    %
    % adding first and last coordinates if all frames of experiment
    % should be extracted
    %
    if analysisInfo.allROIs
        if endindex < nFrames
            trackTime(endindex:nFrames, index) = (endindex+1 : nFrames)';
            xC(endindex:nFrames, index) = xC(endindex, index) * ones(endindex:nFrames,1);       
            yC(endindex:nFrames, index) = yC(endindex, index) * ones(endindex:nFrames,1);
            zC(endindex:nFrames, index) = zC(endindex, index) * ones(endindex:nFrames,1);
        end
       
        if startindex >1
            trackTime(1:startindex-1, index) = (-(startindex-1) : (-1))';
            xC(1:startindex, index) = xC(startindex, index) * ones(1:startindex,1);
            yC(1:startindex, index) = yC(startindex, index) * ones(1:startindex,1);
            zC(1:startindex, index) = zC(startindex, index) * ones(1:startindex,1);
        end
    end
    %
    % Prepare and initialize Structure with Arrays for ROI data
    %
    allROIs(index).xy = zeros(roiSizeY, roiSizeX, trackLength);
    allROIs(index).xz = zeros(roiSizeZ, roiSizeX, trackLength);
    allROIs(index).yz = zeros(roiSizeY, roiSizeZ, trackLength);
    %
    sXsize = selectedTracks(index).staticROIlimits(2) - selectedTracks(index).staticROIlimits(1) + 2 * width+1;
    sYsize = selectedTracks(index).staticROIlimits(4) - selectedTracks(index).staticROIlimits(3) + 2 * width+1;
    % check if xy dimensions of static ROIs should be the same
    if analysisInfo.identicalsROIxy
        sXsize = max(sXsize,sYsize);
        sYsize = sXsize;
    end
    
    sZsize = selectedTracks(index).staticROIlimits(6) - selectedTracks(index).staticROIlimits(5) + 2 * width+1;
    if sZsize > zMax
        sZsize = zMax;
    end
    if sXsize > xMax
        sXsize = xMax;
    end
    if sYsize > yMax
        sYsize = yMax;
    end
    %
    allROIs(index).xyS = zeros(sYsize,sXsize, trackLength);
    allROIs(index).xzS = zeros(sZsize, sXsize, trackLength);
    allROIs(index).yzS = zeros(sYsize,sZsize,trackLength);
    %
    selectedTracks(index).roisizes = [roiSizeX roiSizeY roiSizeZ sXsize sYsize sZsize trackLength];
    selectedTracks(index).channels = channels;
end
%  2. Channel ?
if channel2
    %
   
    nFrames2 = size(analysisInfo.imageFileNamesChannel2,2);

    xC2 = zeros(nFrames,tracksToExtract);
    yC2 = zeros(nFrames,tracksToExtract);
    zC2 = zeros(nFrames,tracksToExtract);
    %
    %
    for index = 1:tracksToExtract
        startindex = selectedTracks(index).start;
        endindex = selectedTracks(index).end;
        trackLength = endindex - startindex +1;
        trackTimes = (1:trackLength)';
        trackTime(startindex:endindex,index) = trackTimes;
        if analysisInfo.nChannels > 1
            xC2(startindex:endindex,index) = selectedTracks(index).x2(1:trackLength,1);
            yC2(startindex:endindex,index) = selectedTracks(index).y2(1:trackLength,1);
            zC2(startindex:endindex,index) = selectedTracks(index).z2(1:trackLength,1);  
        else
            xC2(startindex:endindex,index) = selectedTracks(index).x(1:trackLength,1);
            yC2(startindex:endindex,index) = selectedTracks(index).y(1:trackLength,1);
            zC2(startindex:endindex,index) = selectedTracks(index).z(1:trackLength,1); 
        end
        %  x/y correction for Amira only
        xC2 = xC2 + analysisInfo.Ch2dx;
        yC2 = yC2 + analysisInfo.Ch2dy;

        %
        %  extractions from all frames
        if analysisInfo.allROIs
            if endindex < nFrames
                trackTime(endindex:nFrames, index) = (endindex+1 : nFrames)';
                xC2(endindex:nFrames, index) = xC2(endindex, index) * ones(endindex:nFrames,1);       
                yC2(endindex:nFrames, index) = yC2(endindex, index) * ones(endindex:nFrames,1);
                zC2(endindex:nFrames, index) = zC2(endindex, index) * ones(endindex:nFrames,1);
            end
       
            if startindex >1
                trackTime(1:startindex-1, index) = (-(startindex-1) : (-1))';
                xC2(1:startindex, index) = xC2(startindex, index) * ones(1:startindex,1);
                yC2(1:startindex, index) = yC2(startindex, index) * ones(1:startindex,1);
                zC2(1:startindex, index) = zC2(startindex, index) * ones(1:startindex,1);
            end
        end
        %
        % Prepare and initialize Structure with Arrays for ROI data
        %

        allROIs(index).xy2 = zeros(roiSizeY, roiSizeX, trackLength);
        allROIs(index).xz2 = zeros(roiSizeZ, roiSizeX, trackLength);
        allROIs(index).yz2 = zeros(roiSizeY, roiSizeZ, trackLength);
        %
        sXsize = selectedTracks(index).roisizes(4);
        sYsize = selectedTracks(index).roisizes(5);
        sZsize = selectedTracks(index).roisizes(6);
        %
        allROIs(index).xyS2 = zeros(sYsize,sXsize, trackLength);
        allROIs(index).xzS2 = zeros(sZsize, sXsize, trackLength);
        allROIs(index).yzS2 = zeros(sYsize,sZsize,trackLength);
        %
        %selectedTracks(index).roisizes = [roiSize sXsize sYsize sZsize trackLength];
    end %  of track iteration
end     %  of Channel 2
%  3. Channel?
if channel3
    %
    startindex = selectedTracks(index).start;
    endindex = selectedTracks(index).end;
    trackLength = endindex - startindex +1;
    trackTimes = (1:trackLength)';
    trackTime(startindex:endindex,index) = trackTimes;

    nFrames3 = size(analysisInfo.imageFileNamesChannel3,2);

    xC3 = zeros(nFrames,tracksToExtract);
    yC3 = zeros(nFrames,tracksToExtract);
    zC3 = zeros(nFrames,tracksToExtract);
    %
   
    %
    for index = 1:tracksToExtract
        startindex = selectedTracks(index).start;
        endindex = selectedTracks(index).end;
        trackLength = endindex - startindex +1;
        trackTimes = (1:trackLength)';
        trackTime(startindex:endindex,index) = trackTimes;
        if analysisInfo.nChannels > 2
            xC3(startindex:endindex,index) = selectedTracks(index).x3(1:trackLength,1);
            yC3(startindex:endindex,index) = selectedTracks(index).y3(1:trackLength,1);
            zC3(startindex:endindex,index) = selectedTracks(index).z3(1:trackLength,1);  
        else
            xC3(startindex:endindex,index) = selectedTracks(index).x(1:trackLength,1);
            yC3(startindex:endindex,index) = selectedTracks(index).y(1:trackLength,1);
            zC3(startindex:endindex,index) = selectedTracks(index).z(1:trackLength,1); 
        end
        %  x/y correction for Amira only
%        if mode == 1
        xC3 = xC3 + analysisInfo.Ch3dx;
        yC3 = yC3 + analysisInfo.Ch3dy;
        %end
        
        if analysisInfo.allROIs
            if endindex < nFrames
                trackTime(endindex:nFrames, index) = (endindex+1 : nFrames)';
                xC3(endindex:nFrames, index) = xC3(endindex, index) * ones(endindex:nFrames,1);       
                yC3(endindex:nFrames, index) = yC3(endindex, index) * ones(endindex:nFrames,1);
                zC3(endindex:nFrames3, index) = zC3(endindex, index) * ones(endindex:nFrames3,1);
            end
       
            if startindex >1
                trackTime(1:startindex-1, index) = (-(startindex-1) : (-1))';
                xC3(1:startindex, index) = xC3(startindex, index) * ones(1:startindex,1);
                yC3(1:startindex, index) = yC3(startindex, index) * ones(1:startindex,1);
                zC3(1:startindex, index) = zC3(startindex, index) * ones(1:startindex,1);
            end
        end
        %
        % Prepare and initialize Structure with Arrays for ROI data
        %
        allROIs(index).xy3 = zeros(roiSizeY, roiSizeX, trackLength);
        allROIs(index).xz3 = zeros(roiSizeZ, roiSizeX, trackLength);
        allROIs(index).yz3 = zeros(roiSizeY, roiSizeZ, trackLength);
        %
        sXsize = selectedTracks(index).roisizes(4);
        sYsize = selectedTracks(index).roisizes(5);
        sZsize = selectedTracks(index).roisizes(6);
        %
        allROIs(index).xyS3 = zeros(sYsize,sXsize, trackLength);
        allROIs(index).xzS3 = zeros(sZsize, sXsize, trackLength);
        allROIs(index).yzS3 = zeros(sYsize,sZsize,trackLength);
        %
        %selectedTracks(index).roisizes = [roiSize sXsize sYsize sZsize trackLength];
    end %of track iteration
end     % of Channel 3
%save('/Volumes/T7/Alex/allROISTEST1','allROIs');
%------------------------------------------------------------------------------------------------------------------
%Extracting bitmaps by going through all images
%
%nFrames
%
for index = 1 : nFrames  %    Image counter
    %index
    if (sum(trackTime(index,:)) ~= 0) && (index <= nFrames)  %  check if any tracks are found in this image

    imageName = analysisInfo.filenames(index);
    %pat = "_" + digitsPattern;
    %numFilename = extract(extract(string(imageName),pat),digitsPattern);
    %timeIndex = str2double(numFilename(1));
    imagePath = strcat(string(analysisInfo.channel1Path),'/',string(imageName));
    %imageData = bfopen(char(imagePath));
    %omeMeta = imageData{1, 4};
    %xMax = omeMeta.getPixelsSizeX(0).getValue(); % image width, pixels
    %yMax = omeMeta.getPixelsSizeY(0).getValue(); % image height, pixels
    %zMax = omeMeta.getPixelsSizeT(0).getValue(); % number of Z slices  for whatever reason Z is saved in T
    %seriesCount = size(data, 1);
    %series1 = imageData{1, 1};
    %series1_planeCount = size(series1, 1);
    [series1, imageSize] = loadStack(char(imagePath),analysisInfo.confocal);%                         loadStack is the function that loads one stack and can be adapted
    xMax = imageSize(1);
    yMax = imageSize(2);
    zMax = imageSize(3);
    series1_planeCount = zMax;
    imageStack = zeros(yMax, xMax, zMax);
    for zIndex = 1 : series1_planeCount  %  building 3D image stack
        imageStack(:,:,series1_planeCount-zIndex+1) = series1{zIndex,1};
    end
            
        
        if analysisInfo.Wholeimageprojection
                proImg.XY = max(imageStack,[],3);
                proImg.XZ = (squeeze(max(imageStack,[],1)))';
                proImg.YZ = squeeze(max(imageStack,[],2));
                saveProjectedImages(proImg,1,resultFolder,index);
        end
        %  Open 2. channel stack if necessary
        if channel2 && (index <= nFrames2)

          imageName2 = analysisInfo.imageFileNamesChannel2(index);
          %pat = "_" + digitsPattern;
          %numFilename2 = extract(extract(string(imageName2),pat),digitsPattern);
          %timeIndex2 = str2double(numFilename2(1));
          imagePath2 = strcat(string(analysisInfo.channel2Path),'/',string(imageName2));
          [series2, imageSize] = loadStack(char(imagePath2),analysisInfo.confocal);
          %
          xMax = imageSize(1);
          yMax = imageSize(2);
          zMax = imageSize(3);
          imageStack2 = zeros(yMax, xMax, zMax);
          series2_planeCount = zMax;
          for zIndex = 1 : series2_planeCount
              imageStack2(:,:,series2_planeCount-zIndex+1) = series2{zIndex,1};
          end
%                 case 2
%                   folder = string(app.Path_3.Value);
%                   filename = app.ImageCZIselected.Value;
%                   path = strcat(folder,"/",filename);
%                   xMax = app.XEditField.Value;
%                   yMax = app.YEditField.Value;
%                   zMax = app.ZEditField.Value;
%                   limits = [xMax yMax zMax];
%                   imageStack2 = loadCZIstack(app, path , limits, app.channel2nums, index);
    
            
        if analysisInfo.Wholeimageprojection
            proImg.XY = max(imageStack2,[],3);
            proImg.XZ = (squeeze(max(imageStack2,[],1)))';
            proImg.YZ = squeeze(max(imageStack2,[],2));
            saveProjectedImages(proImg,2,resultFolder,index);
        end
            
        end
        % Open 3. channel stack if necessary
        if channel3 && (index <= nFrames3)
          
            imageName3 = analysisInfo.imageFileNamesChannel3(index);
            %pat = "_" + digitsPattern;
            %numFilename3 = extract(extract(string(imageName3),pat),digitsPattern);
            %timeIndex3 = str2double(numFilename3(1));
            imagePath3 = strcat(string(analysisInfo.channel3Path),'/',string(imageName3));
            %
            [series3, imageSize] = loadStack(char(imagePath3),analysisInfo.confocal);
            xMax = imageSize(1);
            yMax = imageSize(2);
            zMax = imageSize(3);
            imageStack3 = zeros(yMax, xMax, zMax);
            series3_planeCount = zMax;
            for zIndex = 1 : series3_planeCount
                imageStack3(:,:,series3_planeCount-zIndex+1) = series3{zIndex,1};
            end
%                 case 2
%                     folder = string(app.Path_3.Value);
%                     filename = app.ImageCZIselected.Value;
%                     path = strcat(folder,"/",filename);
%                     xMax = app.XEditField.Value;
%                     yMax = app.YEditField.Value;
%                     zMax = app.ZEditField.Value;
%                     limits = [xMax yMax zMax];
%                     imageStack3 = loadCZIstack(app, path , limits, app.channel3nums, index);
            
            if analysisInfo.Wholeimageprojection
                proImg.XY = max(imageStack3,[],3);
                proImg.XZ = (squeeze(max(imageStack3,[],1)))';
                proImg.YZ = squeeze(max(imageStack3,[],2));
                saveProjectedImages(proImg,3,resultFolder,index);
            end
            
        end
        %series1_plane10 = series1{10, 1};
        %imshow(series1_plane10, []);
        for index2 = 1 : tracksToExtract
            %index2
        %    app.TrackNumberEditField.Value = index2;
        %    drawnow;
            if (trackTime(index, index2) ~= 0) &&  (~isnan(xC(index, index2))) 
                x = round(xC( index, index2));
                y = round(yC( index, index2));
                z = round(zC( index, index2));
                %  Determin ROI limits
                roiLimits12 = roiLimits(width,depth,xMax,yMax,zMax,x,y,z);
                xStart = roiLimits12(1);
                xEnd = roiLimits12(2);
                xRange = xEnd-xStart+1;
                yStart = roiLimits12(3);
                yEnd = roiLimits12(4);
                yRange = yEnd-yStart+1;
                zStart = roiLimits12(5);
                zEnd = roiLimits12(6);
                zRange = zEnd-zStart+1;
                xPStart = roiLimits12(7);
                xPEnd = roiLimits12(8);
                yPStart = roiLimits12(9);
                yPEnd = roiLimits12(10);
                zPStart = roiLimits12(11);
                zPEnd = roiLimits12(12);
                %
                %
                sectionXY = imageStack(yStart:yEnd,xStart:xEnd,zPStart:zPEnd);
                allROIs(index2).xy(1:yRange,1:xRange,trackTime(index, index2)) = max(sectionXY,[],3);
                sectionXZ = imageStack(yPStart:yPEnd,xStart:xEnd,zStart:zEnd);
                allROIs(index2).xz(1:zRange,1:xRange,trackTime(index, index2)) = (squeeze(max(sectionXZ,[],1)))';
                sectionYZ = imageStack(yStart:yEnd,xPStart:xPEnd,zStart:zEnd);
                allROIs(index2).yz(1:yRange,1:zRange,trackTime(index, index2)) = squeeze(max(sectionYZ,[],2));
                %
                %  Channel 2
                if channel2 && (index <= nFrames2)
                    %
                    sectionXY2 = imageStack2(yStart:yEnd,xStart:xEnd,zPStart:zPEnd);
                    allROIs(index2).xy2(1:yRange,1:xRange,trackTime(index, index2)) = max(sectionXY2,[],3);
                    sectionXZ2 = imageStack2(yPStart:yPEnd,xStart:xEnd,zStart:zEnd);
                    allROIs(index2).xz2(1:zRange,1:xRange,trackTime(index, index2)) =(squeeze(max(sectionXZ2,[],1)))';
                    sectionYZ2 = imageStack2(yStart:yEnd,xPStart:xPEnd,zStart:zEnd);
                    allROIs(index2).yz2(1:yRange,1:zRange,trackTime(index, index2)) = squeeze(max(sectionYZ2,[],2));
                    %
                end
                %  Channel 3
                if channel3 && (index <= nFrames3)
                    %
                    sectionXY3 = imageStack3(yStart:yEnd,xStart:xEnd,zPStart:zPEnd);
                    allROIs(index2).xy3(1:yRange,1:xRange,trackTime(index, index2)) = max(sectionXY3,[],3);
                    sectionXZ3 = imageStack3(yPStart:yPEnd,xStart:xEnd,zStart:zEnd);
                    allROIs(index2).xz3(1:zRange,1:xRange,trackTime(index, index2)) =(squeeze(max(sectionXZ3,[],1)))';
                    sectionYZ3 = imageStack3(yStart:yEnd,xPStart:xPEnd,zStart:zEnd);
                    allROIs(index2).yz3(1:yRange,1:zRange,trackTime(index, index2)) = squeeze(max(sectionYZ3,[],2));
                    %
                end
                % static ROI sizes
                if (selectedTracks(index2).staticROIlimits(1) - width) < 1
                    xSStart = 1;
                else
                    xSStart = selectedTracks(index2).staticROIlimits(1) - width;
                end
                if (selectedTracks(index2).staticROIlimits(2) + width) > xMax
                    xSEnd = xMax;
                else
                    xSEnd = selectedTracks(index2).staticROIlimits(2) + width;
                end
                if (selectedTracks(index2).staticROIlimits(3) - width) < 1
                    ySStart = 1;
                else
                    ySStart = selectedTracks(index2).staticROIlimits(3) - width;
                end
                if (selectedTracks(index2).staticROIlimits(4) + width) > yMax
                    ySEnd = yMax;
                else
                    ySEnd = selectedTracks(index2).staticROIlimits(4) + width;
                end
                if (selectedTracks(index2).staticROIlimits(5) - width) < 1
                    zSStart = 1;
                else
                    zSStart = selectedTracks(index2).staticROIlimits(5) - width;
                end
                if (selectedTracks(index2).staticROIlimits(6) + width) > zMax
                    zSEnd = zMax;
                else
                    zSEnd = selectedTracks(index2).staticROIlimits(6) + width;
                end
                %
                xSRange = xSEnd-xSStart+1;
                ySRange = ySEnd-ySStart+1;
                zSRange = zSEnd-zSStart+1;
                %
                sectionXY = imageStack(ySStart:ySEnd,xSStart:xSEnd,zPStart:zPEnd);
                allROIs(index2).xyS(1:ySRange,1:xSRange,trackTime(index, index2)) =  max(sectionXY,[],3);
                sectionXZ = imageStack(yPStart:yPEnd,xSStart:xSEnd,zSStart:zSEnd);
                allROIs(index2).xzS(1:zSRange,1:xSRange,trackTime(index, index2)) = (squeeze(max(sectionXZ,[],1)))';
                sectionYZ = imageStack(ySStart:ySEnd,xPStart:xPEnd,zSStart:zSEnd);
                allROIs(index2).yzS(1:ySRange,1:zSRange,trackTime(index, index2)) = squeeze(max(sectionYZ,[],2));
                %
                %  Channel 2 static ROI
                if channel2 && (index <= nFrames2)
                    %2
                    sectionXY2 = imageStack2(ySStart:ySEnd,xSStart:xSEnd,zPStart:zPEnd);
                    allROIs(index2).xyS2(1:ySRange,1:xSRange,trackTime(index, index2)) =  max(sectionXY2,[],3);
                    sectionXZ2 = imageStack2(yPStart:yPEnd,xSStart:xSEnd,zSStart:zSEnd);
                    allROIs(index2).xzS2(1:zSRange,1:xSRange,trackTime(index, index2)) = (squeeze(max(sectionXZ2,[],1)))';
                    sectionYZ2 = imageStack2(ySStart:ySEnd,xPStart:xPEnd,zSStart:zSEnd);
                    allROIs(index2).yzS2(1:ySRange,1:zSRange,trackTime(index, index2)) = squeeze(max(sectionYZ2,[],2));
                end
                %  Channel 3 static ROI
                if channel3 && (index <= nFrames3)
                    %3
                    sectionXY3 = imageStack3(ySStart:ySEnd,xSStart:xSEnd,zPStart:zPEnd);
                    allROIs(index2).xyS3(1:ySRange,1:xSRange,trackTime(index, index2)) = max(sectionXY3,[],3);
                    sectionXZ3 = imageStack3(yPStart:yPEnd,xSStart:xSEnd,zSStart:zSEnd);
                    allROIs(index2).xzS3(1:zSRange,1:xSRange,trackTime(index, index2)) = (squeeze(max(sectionXZ3,[],1)))';
                    sectionYZ3 = imageStack3(ySStart:ySEnd,xPStart:xPEnd,zSStart:zSEnd);
                    allROIs(index2).yzS3(1:ySRange,1:zSRange,trackTime(index, index2)) = squeeze(max(sectionYZ3,[],2));
                end
            end
        end
    end
    %app.Progress.Value = 100 * index/nFrames;
end
%app.StatusTextArea.Value = 'DONE';
%
%SAVING RESULTS
%
selectTracks = selectedTracks;
save(char(resultFileName1),'allROIs');
save(char(resultFileName2),'selectTracks');
if analysisInfo.SaveTracksasTXTCheckBox
    resultFileName3 = strcat(resultFileName2,".txt");
    saveTracksText(char(resultFileName3),selectTracks);
end
%
% save for LabView            %
saveResultsForLabView(selectTracks,allROIs,resultFolder,mode, analysisInfo);

analysisInfo.Run = 1;
analysisInfo.Time = datetime;
save(char(analysisInfoFileName),'analysisInfo');
toc
end