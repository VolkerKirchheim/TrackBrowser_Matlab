function [series1, imageSize] =  loadStack(imagePath, confocal)
        imageData = bfopen(char(imagePath));
        omeMeta = imageData{1, 4};
        xMax = omeMeta.getPixelsSizeX(0).getValue(); % image width, pixels
        yMax = omeMeta.getPixelsSizeY(0).getValue(); % image height, pixels
        if confocal
            zMax = omeMeta.getPixelsSizeZ(0).getValue();
        else
            zMax = omeMeta.getPixelsSizeT(0).getValue(); % number of Z slices  for whatever reason Z is saved in T
        end
        
        %seriesCount = size(data, 1);
        imageSize = [xMax yMax zMax];
        series1 = imageData{1, 1};
        %series1_planeCount = size(series1, 1);
end