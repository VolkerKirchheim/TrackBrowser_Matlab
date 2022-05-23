function [allFilenames, allFoldernames] = readFilesFolders(parentfolder)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

folderInfo=dir(char(parentfolder));
isFiles=~[folderInfo.isdir];
allFilenames=string({folderInfo.name});
allFilenames=allFilenames(isFiles);
isFolder=[folderInfo.isdir];
allFoldernames=string({folderInfo.name});
allFoldernames=allFoldernames(isFolder);
isFolder = ~[(allFoldernames == '.') | (allFoldernames == '..')];
allFoldernames=allFoldernames(isFolder);
end

