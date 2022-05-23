function saveTracksText(filename, selectTracks)
            %selectTracks = app.selectedTracks;
            arraysize = size(selectTracks,2);
            fields = fieldnames(selectTracks);
            numberFields = size(fields,1);
            fieldsString = string(fields(1));
            for index = 2:numberFields
                fieldsString = strcat(fieldsString,",",string(fields(index)));
            end
            %filename = 'D:\data\Maya_Data\temp\trackAll2.txt';
            % cellArray = {selectTracks(1).trackChannels,selectTracks(1).f;selectTracks(2).trackChannels,selectTracks(2).f};
            % writecell(cellArray,filename);
            fileID = fopen(filename,'w');
            
            % HEADER
            fprintf(fileID,'%d \n',4);
            fprintf(fileID,'%d \n',arraysize);
            fprintf(fileID,'%d \n',numberFields);
            fprintf(fileID,'%s \n',fieldsString);
            % TRACKS
            for index = 1:arraysize
                fprintf(fileID,'Track: %d \n',index);
                trackField = selectTracks(index);
                for index2 = 1:numberFields
                    var = getfield(trackField,char(fields(index2)))';
                    if isstring(var)
                        fprintf(fileID,'%s \n',var);
                    elseif isscalar(var)
                         fprintf(fileID,'%f \n',var);
                    else
                        fchar = char(sprintf('%f,',var));
                        fprintf(fileID,'%s \n',fchar(1:end-1));
                    end
                end
            %     
            
            end
            fclose(fileID);
        end