function [fileListTIF,fileListCZI] = readImageFiles(selpath)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%selpath = uigetdir(app.startpath);
%if selpath ~=0
%app.Path_2.Value = selpath;
%app.Path_3.Value = selpath;
[fileList, ~] = readFilesFolders(selpath);
fileList = fileList';
isValidFile = zeros(size(fileList));
for index = 1 : size(fileList)
    filename = char(fileList(index));
    isValidFile(index) = filename(1) ~= '.';
end
fileList = fileList(logical(isValidFile));

fileListTIF = fileList(contains(fileList,".tif"));
%     nFrames=size(fileListTIF,1);
%app.N_images.Value = app.nFrames;
%     fileIndices = [1:app.nFrames];
%disp(fitsFileList)
%app.Files_2.Items = fileListTIF;
%app.Files_2.ItemsData = fileIndices;
fileListCZI = fileList(contains(fileList,".czi"));
nCZIImages = size(fileListCZI,1);
%     if nCZIImages > 0
%         app.SelectCZIImage.Enable = true;
%     end
%     app.Files_ImagesCZI.Items = fileListCZI;
%     app.Files_ImagesCZI.ItemsData = [1:app.nCZIImages];
%     app.startpath = selpath;
%end
end