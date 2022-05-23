function saveProjectedImages(proImg,ch,resultfolder,imageIndex)
    XY=proImg.XY;
    xyName = strcat(resultfolder,"/wholeimages/",num2str(imageIndex),"_","XY",num2str(ch));
    save(xyName,'XY');
    XZ=proImg.XZ;
    xyName = strcat(resultfolder,"/wholeimages/",num2str(imageIndex),"_","XZ",num2str(ch));
    save(xzName,'XZ');
    YZ=proImg.YZ;
    xyName = strcat(resultfolder,"/wholeimages/",num2str(imageIndex),"_","YZ",num2str(ch));
    save(yzName,'YZ'); 
end