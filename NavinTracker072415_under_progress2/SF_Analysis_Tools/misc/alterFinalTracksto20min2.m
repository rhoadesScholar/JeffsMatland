function alterFinalTracksto20min2(mastermasterfolder)
global Prefs; 
Prefs = define_preferences(Prefs);
PathofMasterMasterFolder = sprintf('%s',mastermasterfolder);
MasterMasterdirList = ls(PathofMasterMasterFolder);
MasterMasterNumFolders = length(MasterMasterdirList(:,1));
for(q=3:MasterMasterNumFolders)
    string1 = deblank(MasterMasterdirList(q,:)); 
    MasterPathName = sprintf('%s/%s/',PathofMasterMasterFolder,string1);
    MasterdirList = ls(MasterPathName);
    display(MasterdirList)
    MasterNumFolders = length(MasterdirList(:,1)); %%%%2 folders cuz 2 genotypes
for (j=3:MasterNumFolders)
    string1 = deblank(MasterdirList(j,:)); 
    NestedPathName = sprintf('%s/%s/',MasterPathName,string1);
    NesteddirList = ls(NestedPathName);
    display(NesteddirList)
    FinalNumFolders = length(NesteddirList(:,1)); %%%%2 folders cuz 2 genotypes
    for (l=3:FinalNumFolders)
        
                string3 = deblank(NesteddirList(l,:)); 

                PathName = sprintf('%s/%s/',NestedPathName,string3);
                fileList = ls(PathName);
                display(PathName)
                display(fileList)
                numFiles = length(fileList(:,1));

                for(l=3:1:numFiles)
                    string4 = deblank(fileList(l,:));
                    [pathstr, FilePrefix, ext, versn] = fileparts(string4);
                    [pathstr2, FilePrefix2, ext2, versn2] = fileparts(FilePrefix);

                    if(strcmp(ext2,'.finalTracks')==1)
                        finalTracksfileIndex = l;
                    end

                    if(strcmp(ext2,'.leftoverTracks')==1)
                        leftoverTracksfileIndex = l;
                    end

                end
                finalTracksfileName = deblank(fileList(finalTracksfileIndex,:));
                
                fileToOpen = sprintf('%s%s',PathName,finalTracksfileName);
                display(fileToOpen);
                load(fileToOpen);

                for (i = 1:(length(finalTracks)))
    %%%Calculate the final AngSpeed for this track at stepsize = 1sec
    Xdif = CalcDif(finalTracks(i).SmoothX, 3) * Prefs.FrameRate; % At StepSize=1sec
    Ydif = -CalcDif(finalTracks(i).SmoothY, 3) * Prefs.FrameRate; % At StepSize=1sec
    Direction = atan(Xdif./Ydif) * 360/(2*pi);
    % direction 0 = Up/North
    ZeroYdifIndexes = find(Ydif == 0);
    Ydif(ZeroYdifIndexes) = eps;     % Avoid division by zero in direction calculation

    Direction = atan(Xdif./Ydif) * 360/(2*pi);	    % In degrees, 0 = Up ("North")

    NegYdifIndexes = find(Ydif < 0);
    Index1 = find(Direction(NegYdifIndexes) <= 0);
    Index2 = find(Direction(NegYdifIndexes) > 0);
    Direction(NegYdifIndexes(Index1)) = Direction(NegYdifIndexes(Index1)) + 180;
    Direction(NegYdifIndexes(Index2)) = Direction(NegYdifIndexes(Index2)) - 180;
    finalTracks(i).AngSpeed = CalcAngleDif(Direction, 3)*Prefs.FrameRate;
    finalTracks(i).AngSpeed(1:3) = NaN;
    %%%Calculate the final Speed for this track at StepSize = 5sec
    Xdif = CalcDif(finalTracks(i).SmoothX, 15) * Prefs.FrameRate; % At StepSize=5sec
    Ydif = -CalcDif(finalTracks(i).SmoothY, 15) * Prefs.FrameRate; % At StepSize=5sec
    Direction = atan(Xdif./Ydif) * 360/(2*pi);
    % direction 0 = Up/North
    ZeroYdifIndexes = find(Ydif == 0);
    Ydif(ZeroYdifIndexes) = eps;     % Avoid division by zero in direction calculation

    Direction = atan(Xdif./Ydif) * 360/(2*pi);	    % In degrees, 0 = Up ("North")

    NegYdifIndexes = find(Ydif < 0);
    Index1 = find(Direction(NegYdifIndexes) <= 0);
    Index2 = find(Direction(NegYdifIndexes) > 0);
    Direction(NegYdifIndexes(Index1)) = Direction(NegYdifIndexes(Index1)) + 180;
    Direction(NegYdifIndexes(Index2)) = Direction(NegYdifIndexes(Index2)) - 180;
    finalTracks(i).Speed = sqrt(Xdif.^2 + Ydif.^2)*Prefs.DefaultPixelSize;
    finalTracks(i).Speed(1:10) = NaN;
end

              
               

                movieName = finalTracks(1).Name;
                [filepath,filePrefix,extension,version] = fileparts(sprintf('%s',movieName));
                dummystring = sprintf('%s%s.finalTracks.mat',PathName,filePrefix);
                save(dummystring,'finalTracks');
                
        end
    end
end

end
