function [analysisInfo, selectedTracks] = organizeAmiraTracks(selpath, analysisInfo)
%organizeAmiraTracks creates the selectdTracks structure that contains all
%the relevant information to extract the ROIs. The selectedTracks are later
%saved together with the ROIs and serve as input/entry way for the accompaning
%LabView program that visualizes the ROIs
%   tracks contains the indices (from the rawTracks) of the selected tracks
%   rawTracks contains the track information as it was saved by Amira

%
tic
trackFileData = load(selpath);
rawTracks = trackFileData.tracks;
%
fieldNames = string(fieldnames(rawTracks));
setLength = analysisInfo.setLength;
cat8bit = analysisInfo.cat8bit;
%
%cat8bit=catIdxBinary(app);
s=size(rawTracks,2);
N_rawTracks = s;
analysisInfo.N_rawTracks = N_rawTracks;
nChannels = size(rawTracks(1).x,1);
analysisInfo.nChannels = nChannels;
trackedChannels = 1;
if nChannels > 1
    trackedChannels =2;
    %app.Channel2trackedCheckBox.Value = true;
end
if nChannels > 2
    trackedChannels =3;
    %app.Channel3trackedCheckBox.Value = true;
end

%trackLengths = zeros(1,s,'uint16');
trackSelectTag = zeros(1,s,'logical');
for index = 1:s
    %trackLengths(1,index) = size(app.rawTracks(index).x,2);
    trackSelectTag(1,index) = (rawTracks(index).end-rawTracks(index).start+1) >= setLength;
    catTrue = bitand(2^(rawTracks(index).catIdx-1), cat8bit) >0;
    trackSelectTag(1,index) = trackSelectTag(1,index) && catTrue;
end
trackSelect = find(trackSelectTag);
N_selectLength = size(trackSelect,2);
analysisInfo.N_selectLength = N_selectLength;
%value = app.N_selectLength.Value;
selectedTracks=struct([]);


    for index = 1:N_selectLength
        %
        j=trackSelect(1,index);
        selectedTracks(index).originalIndex = j;
        selectedTracks(index).path = selpath;
        selectedTracks(index).f = (rawTracks(j).f(1,:))';
        tracklength = size(selectedTracks(index).f,1);
        selectedTracks(index).trackChannels = trackedChannels;
        %
        %
        selectedTracks(index).x = (rawTracks(j).x(1,:))';
        selectedTracks(index).y = (rawTracks(j).y(1,:))';
        if find(fieldNames == 'z')
            selectedTracks(index).z = (rawTracks(j).z(1,:))';
            selectedTracks(index).dz = (rawTracks(j).z_pstd(1,:))';
            is3D = true;
        else
            selectedTracks(index).z = ones(tracklength,1);
            selectedTracks(index).dz = zeros(tracklength,1);                   
            is3D = false;
        end
        selectedTracks(index).A = (rawTracks(j).A(1,:))';
        %
        selectedTracks(index).dx = (rawTracks(j).x_pstd(1,:))';
        selectedTracks(index).dy = (rawTracks(j).y_pstd(1,:))';
        
        selectedTracks(index).dA = (rawTracks(j).A_pstd(1,:))';
        %
        if trackedChannels > 1
            selectedTracks(index).x2 = (rawTracks(j).x(2,:))';
            selectedTracks(index).y2 = (rawTracks(j).y(2,:))';
            if is3D
                selectedTracks(index).z2 = (rawTracks(j).z(2,:))';
                selectedTracks(index).dz2 = (rawTracks(j).z_pstd(2,:))';
            else
                selectedTracks(index).z2 = ones(tracklength,1);
                selectedTracks(index).dz2 = zeros(tracklength,1);  
            end
            selectedTracks(index).A2 = (rawTracks(j).A(2,:))';
            %
            selectedTracks(index).dx2 = (rawTracks(j).x_pstd(2,:))';
            selectedTracks(index).dy2 = (rawTracks(j).y_pstd(2,:))';
            
            selectedTracks(index).dA2 = (rawTracks(j).A_pstd(2,:))';
        end
        if trackedChannels > 2
            selectedTracks(index).x3 = (rawTracks(j).x(3,:))';
            selectedTracks(index).y3 = (rawTracks(j).y(3,:))';
            if is3D
                selectedTracks(index).z3 = (rawTracks(j).z(3,:))';
                selectedTracks(index).dz3 = (rawTracks(j).z_pstd(3,:))';
            else
                selectedTracks(index).z3 = ones(tracklength,1);
                selectedTracks(index).dz3 = zeros(tracklength,1);  
            end
            
            selectedTracks(index).A3 = (rawTracks(j).A(3,:))';
            %
            selectedTracks(index).dx3 = (rawTracks(j).x_pstd(3,:))';
            selectedTracks(index).dy3 = (rawTracks(j).y_pstd(3,:))';
            
            selectedTracks(index).dA3 = (rawTracks(j).A_pstd(3,:))';
        end
        selectedTracks(index).catIdx = rawTracks(j).catIdx;
        selectedTracks(index).tag = 0;
        selectedTracks(index).mode = 1;
        %
        xMin = fix(min(selectedTracks(index).x(:,1)));
        xMax = ceil(max(selectedTracks(index).x(:,1)));
        yMin = fix(min(selectedTracks(index).y(:,1)));
        yMax = ceil(max(selectedTracks(index).y(:,1)));
        zMin = fix(min(selectedTracks(index).z(:,1)));
        zMax = ceil(max(selectedTracks(index).z(:,1)));
        selectedTracks(index).staticROIlimits = [xMin xMax yMin yMax zMin zMax];
        selectedTracks(index).start = rawTracks(j).start;
        selectedTracks(index).end = rawTracks(j).end;
        selectedTracks(index).channels = 1;
    end
toc
end