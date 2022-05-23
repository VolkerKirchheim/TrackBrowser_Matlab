function [analysisInfo, selectedTracks] = organizeAmiraDetection(selpath, analysisInfo, isPSF8bit)
%Organize the Detection results from Amira for ROI extraction
% Creates a 'selectedTracks' file which works as input for ROI extraction.
% Modifies the analysisInfo structure with information needed for ROI
% extraction
%  
%   load Detection track file
    trackFileData = load(selpath);
    if analysisInfo.confocal
        rawTracks = trackFileData.pstruct;
    else
        rawTracks = trackFileData.frameInfo;
    end
    %
    % Determine size and number of tracked channels
    s=size(rawTracks,2);
    trackstoextract = s;
    analysisInfo.mode = 0;
    %app.resultFrames.Value = s;
    nChannels = size(rawTracks(1).x,1);
    analysisInfo.nChannels = nChannels;
    trackedChannels = 1;
    if nChannels > 1
        trackedChannels =2;
    end
    if nChannels > 2
        trackedChannels =3;
    end
    %
    % new (empty) selectedTracks structure array
    selectedTracks=struct([]);
    for index = 1:s  %build a track with detection results for each frame
        %
        j=index;
        %
        numberDetections = size(rawTracks(index).isPSF,2);
        if bitand(isPSF8bit,1) == 1
            isPSF1 = rawTracks(index).isPSF(1,:);
        else
            isPSF1 = ones(1,numberDetections);
        end
        
        if (nChannels > 1) && (bitand(isPSF8bit,2) == 2) 
            isPSF2 = rawTracks(index).isPSF(2,:);
        else
            isPSF2 = ones(1,numberDetections);
        end
        if (nChannels > 2) && (bitand(isPSF8bit,4) == 4)  
            isPSF3 = rawTracks(index).isPSF(3,:);
        else
            isPSF3 = ones(1,numberDetections);
        end
        switch selectionMode
            case "AND"
                DetectionIndices = find(isPSF1 & isPSF2 & isPSF3);
            case "OR"
                DetectionIndices = find(isPSF1 | isPSF2 | isPSF3);
        end
        detectionTrackLength = size(DetectionIndices,2);
        %
        selectedTracks(index).originalIndex = index;
        selectedTracks(index).f = (1:detectionTrackLength)';
        selectedTracks(index).trackChannels = trackedChannels;
        %
        %
        selectedTracks(index).x = (rawTracks(j).x(1,DetectionIndices))';
        selectedTracks(index).y = (rawTracks(j).y(1,DetectionIndices))';
        selectedTracks(index).z = (rawTracks(j).z(1,DetectionIndices))';
        selectedTracks(index).A = (rawTracks(j).A(1,DetectionIndices))';
        %
        selectedTracks(index).dx = (rawTracks(j).x_pstd(1,DetectionIndices))';
        selectedTracks(index).dy = (rawTracks(j).y_pstd(1,DetectionIndices))';
        selectedTracks(index).dz = (rawTracks(j).z_pstd(1,DetectionIndices))';
        selectedTracks(index).dA = (rawTracks(j).A_pstd(1,DetectionIndices))';
        %
        if (nChannels > 1) && (bitand(isPSF8bit,2) == 2)
            selectedTracks(index).x2 = (rawTracks(j).x(2,DetectionIndices))';
            selectedTracks(index).y2 = (rawTracks(j).y(2,DetectionIndices))';
            selectedTracks(index).z2 = (rawTracks(j).z(2,DetectionIndices))';
            selectedTracks(index).A2 = (rawTracks(j).A(2,DetectionIndices))';
            %
            selectedTracks(index).dx2 = (rawTracks(j).x_pstd(2,DetectionIndices))';
            selectedTracks(index).dy2 = (rawTracks(j).y_pstd(2,DetectionIndices))';
            selectedTracks(index).dz2 = (rawTracks(j).z_pstd(2,DetectionIndices))';
            selectedTracks(index).dA2 = (rawTracks(j).A_pstd(2,DetectionIndices))';
        end
        if (nChannels > 2) && (bitand(isPSF8bit,4) == 4)
            selectedTracks(index).x3 = (rawTracks(j).x(3,DetectionIndices))';
            selectedTracks(index).y3 = (rawTracks(j).y(3,DetectionIndices))';
            selectedTracks(index).z3 = (rawTracks(j).z(3,DetectionIndices))';
            selectedTracks(index).A3 = (rawTracks(j).A(3,DetectionIndices))';
            %
            selectedTracks(index).dx3 = (rawTracks(j).x_pstd(3,DetectionIndices))';
            selectedTracks(index).dy3 = (rawTracks(j).y_pstd(3,DetectionIndices))';
            selectedTracks(index).dz3 = (rawTracks(j).z_pstd(3,DetectionIndices))';
            selectedTracks(index).dA3 = (rawTracks(j).A_pstd(3,DetectionIndices))';
        end
        %selectedTracks(index).catIdx = rawTracks(j).catIdx;
        selectedTracks(index).tag = 0;
        selectedTracks(index).mode = 0;
        %
        xMin = round(min((rawTracks(j).x(1,DetectionIndices))'));
        xMax = round(max((rawTracks(j).x(1,DetectionIndices))'));
        yMin = round(min((rawTracks(j).y(1,DetectionIndices))'));
        yMax = round(max((rawTracks(j).y(1,DetectionIndices))'));
        zMin = round(min((rawTracks(j).z(1,DetectionIndices))'));
        zMax = round(max((rawTracks(j).z(1,DetectionIndices))'));
        selectedTracks(index).staticROIlimits = [xMin xMax yMin yMax zMin zMax];
        selectedTracks(index).start = 1;
        selectedTracks(index).end = detectionTrackLength;
        selectedTracks(index).channels = 1;
    end

end