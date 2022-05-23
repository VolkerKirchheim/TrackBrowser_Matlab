function saveResultsForLabView(selectTracks,allROIs,resultFolder,mode, analysisInfo)
            %
           switch mode
               case {0,1}
                     channel2 =  ~isequal(analysisInfo.channel2Path,"");
                     channel3 =  ~isequal(analysisInfo.channel3Path,"");
               case 2
                   channel2 =  ~isequal(analysisInfo.channel2Path,"");
                   channel3 =  ~isequal(analysisInfo.channel3Path,"");
               case 5
                   channel2 = false;
                   channel3 = false;
           end

            numberOfTracks =  size(selectTracks,2);
            for index = 1:numberOfTracks    %  Track Counter
                originalIndex = num2str(selectTracks(index).originalIndex, '%05.0f');
                selectIndex = num2str(index,'%05.0f');
                trackfoldername = strcat(selectIndex,"_",originalIndex);
                trackfolder = strcat(resultFolder,"/",trackfoldername);
                mkdir(char(trackfolder));
                trackLength = selectTracks(index).roisizes(7);
                sroi = selectTracks(index).roisizes(1);
                roiX = selectTracks(index).roisizes(1);
                roiY = selectTracks(index).roisizes(2);
                roiZ = selectTracks(index).roisizes(3);
                sX = selectTracks(index).roisizes(4);
                sY = selectTracks(index).roisizes(5);
                sZ = selectTracks(index).roisizes(6);
                if mode ~= 5
                    cROI = zeros(trackLength * sroi, 3*sroi);
                    XY = zeros(trackLength * sY, sX);
                    XZ = zeros(trackLength * sZ, sX);
                    YZ = zeros(trackLength * sY, sZ);
                    %   CHANNEL 2
                    if channel2
                        cROI2 = zeros(trackLength * sroi, 3*sroi);
                        XY2 = zeros(trackLength * sY, sX);
                        XZ2 = zeros(trackLength * sZ, sX);
                        YZ2 = zeros(trackLength * sY, sZ);
                    end
                    %   CHANNEL 3
                    if channel3
                        cROI3 = zeros(trackLength * sroi, 3*sroi);
                        XY3 = zeros(trackLength * sY, sX);
                        XZ3 = zeros(trackLength * sZ, sX);
                        YZ3 = zeros(trackLength * sY, sZ);
                    end
                else
                    cROI = zeros(trackLength * sroi, sroi);
                    XY = zeros(trackLength * sY, sX);
                end
                % making 2D arrays for easy saving
                for index2 = 1:trackLength     
                    %centered ROI
                    cROI((index2-1)*sroi+1:(index2-1)*sroi+roiY, 1:roiX) = allROIs(index).xy(:,:,index2);
                    if mode ~= 5
                        cROI((index2-1)*sroi+1:(index2-1)*sroi+roiZ, sroi+1:sroi+roiX) = allROIs(index).xz(:,:,index2);
                        cROI((index2-1)*sroi+1:(index2-1)*sroi+roiY, 2*sroi+1:2*sroi+roiZ) = allROIs(index).yz(:,:,index2);
                    end
                    
                    if (mode ~= 0) && (mode ~= 5)
                        %static ROI
                        XY((index2-1)*sY+1:(index2-1)*sY+sY, :) = allROIs(index).xyS(:,:,index2);
                        XZ((index2-1)*sZ+1:(index2-1)*sZ+sZ, :) = allROIs(index).xzS(:,:,index2);
                        YZ((index2-1)*sY+1:(index2-1)*sY+sY, :) = allROIs(index).yzS(:,:,index2);
                    end
                    % CHANNEL 2
                    if channel2
                        %centered ROI
                        %index
                        %index2
                        cROI2((index2-1)*sroi+1:(index2-1)*sroi+roiY, 1:roiX) = allROIs(index).xy2(:,:,index2);
                        cROI2((index2-1)*sroi+1:(index2-1)*sroi+roiZ, sroi+1:sroi+roiX) = allROIs(index).xz2(:,:,index2);
                        cROI2((index2-1)*sroi+1:(index2-1)*sroi+roiY, 2*sroi+1:2*sroi+roiZ) = allROIs(index).yz2(:,:,index2);
                        if (mode ~= 0) && (mode ~= 5)
                            %static ROI
                            XY2((index2-1)*sY+1:(index2-1)*sY+sY, :) = allROIs(index).xyS2(:,:,index2);
                            XZ2((index2-1)*sZ+1:(index2-1)*sZ+sZ, :) = allROIs(index).xzS2(:,:,index2);
                            YZ2((index2-1)*sY+1:(index2-1)*sY+sY, :) = allROIs(index).yzS2(:,:,index2);
                        end
                    end
                    % CHANNEL 3
                    if channel3
                        %centered ROI
                        cROI3((index2-1)*sroi+1:(index2-1)*sroi+roiY, 1:roiX) = allROIs(index).xy3(:,:,index2);
                        cROI3((index2-1)*sroi+1:(index2-1)*sroi+roiZ, sroi+1:sroi+roiX) = allROIs(index).xz3(:,:,index2);
                        cROI3((index2-1)*sroi+1:(index2-1)*sroi+roiY, 2*sroi+1:2*sroi+roiZ) = allROIs(index).yz3(:,:,index2);
                        if (mode ~= 0) && (mode ~= 5)
                        %static ROI
                            XY3((index2-1)*sY+1:(index2-1)*sY+sY, :) = allROIs(index).xyS3(:,:,index2);
                            XZ3((index2-1)*sZ+1:(index2-1)*sZ+sZ, :) = allROIs(index).xzS3(:,:,index2);
                            YZ3((index2-1)*sY+1:(index2-1)*sY+sY, :) = allROIs(index).yzS3(:,:,index2);
                        end
                    end
                  end
                %
                sroiName = strcat(trackfolder,"/",selectIndex,"_",originalIndex,"_","cROI1");
                save(sroiName,'cROI');
                if analysisInfo.SaveTracksasTXTCheckBox
                    writematrix(cROI,sroiName);
                end
                %
                
                if (mode ~= 0) && (mode ~= 5)
                    xyName = strcat(trackfolder,"/",selectIndex,"_",originalIndex,"_","sXY1");
                    save(xyName,'XY');
                    if analysisInfo.SaveTracksasTXTCheckBox
                        writematrix(XY,xyName);
                    end
                    xzName = strcat(trackfolder,"/",selectIndex,"_",originalIndex,"_","sXZ1");
                    save(xzName,'XZ');
                    if analysisInfo.SaveTracksasTXTCheckBox
                        writematrix(XZ,xzName);
                    end
                    yzName = strcat(trackfolder,"/",selectIndex,"_",originalIndex,"_","sYZ1");
                    save(yzName,'YZ');
                    if analysisInfo.SaveTracksasTXTCheckBox
                        writematrix(YZ,yzName);
                    end
                end
                % CHANNEL 2
                if channel2
                    sroiName2 = strcat(trackfolder,"/",selectIndex,"_",originalIndex,"_","cROI2");
                    save(sroiName2,'cROI2');
                    if analysisInfo.SaveTracksasTXTCheckBox
                        writematrix(cROI2,sroiName2);
                    end
                    if (mode ~= 0) && (mode ~= 5)
                        xyName2 = strcat(trackfolder,"/",selectIndex,"_",originalIndex,"_","sXY2");
                        save(xyName2,'XY2');
                        if analysisInfo.SaveTracksasTXTCheckBox
                            writematrix(XY2,xyName2);
                        end
                        xzName2 = strcat(trackfolder,"/",selectIndex,"_",originalIndex,"_","sXZ2");
                        save(xzName2,'XZ2');
                        if analysisInfo.SaveTracksasTXTCheckBox
                            writematrix(XZ2,xzName2);
                        end
                        yzName2 = strcat(trackfolder,"/",selectIndex,"_",originalIndex,"_","sYZ2");
                        save(yzName2,'YZ2');
                        if analysisInfo.SaveTracksasTXTCheckBox
                            writematrix(YZ2,yzName2);
                        end
                    end
                end
                % CHANNEL 3
                if channel3
                    sroiName3 = strcat(trackfolder,"/",selectIndex,"_",originalIndex,"_","cROI3");
                    save(sroiName3,'cROI3');
                    if analysisInfo.SaveTracksasTXTCheckBox
                        writematrix(cROI3,sroiName3);
                    end
                    if (mode ~= 0) && (mode ~= 5)
                        xyName3 = strcat(trackfolder,"/",selectIndex,"_",originalIndex,"_","sXY3");
                        save(xyName3,'XY3');
                        if analysisInfo.SaveTracksasTXTCheckBox
                            writematrix(XY3,xyName3);
                        end
                        xzName3 = strcat(trackfolder,"/",selectIndex,"_",originalIndex,"_","sXZ3");
                        save(xzName3,'XZ3');
                        if analysisInfo.SaveTracksasTXTCheckBox
                            writematrix(XZ3,xzName3);
                        end
                        yzName3 = strcat(trackfolder,"/",selectIndex,"_",originalIndex,"_","sYZ3");
                        save(yzName3,'YZ3');
                        if analysisInfo.SaveTracksasTXTCheckBox
                            writematrix(YZ3,yzName3);
                        end
                    end
                end
            end
end