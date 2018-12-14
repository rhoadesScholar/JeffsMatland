function meanState = statesOverTime(folder,NumFrames)
%Read in data
    PathofFolder = sprintf('%s/',folder);
    dirList = ls(PathofFolder);
    NumFolders = length(dirList(:,1));
    allTracks = [];
    for(i = 3:NumFolders)
        string1 = deblank(dirList(i,:)); 
        
        PathName = sprintf('%s/%s/',PathofFolder,string1);
        fileList = ls(PathName);
       
        numFiles = length(fileList(:,1));
       
        for(j=3:1:numFiles)
            string2 = deblank(fileList(j,:));
            [pathstr, FilePrefix, ext] = fileparts(string2);
            [pathstr2, FilePrefix2, ext2] = fileparts(FilePrefix);
           
            if(strcmp(ext2,'.finalTracks')==1)
                fileIndex = j;
            end
        end
        fileName = deblank(fileList(fileIndex,:));
        fileToOpen = sprintf('%s%s',PathName,fileName);
        display(fileToOpen)
        load(fileToOpen);
        allTracks = [allTracks finalTracks]; % concatenate all tracks
    end
    %%%%%%%%%%%%%%%%%
    [expNewSeq expStates estTR estE] = getHMMStates(allTracks,30);
    
    %%Make R/D matrix
    RD_Matrix = NaN(length(allTracks),NumFrames);
    for(i=1:length(allTracks))
        startFrame = allTracks(i).Frames(1);
        numframes = length(expStates(i).states);
        RD_Matrix(i,startFrame:(startFrame+numframes-1)) = expStates(i).states;
    end
    
    for(i=1:NumFrames)
        meanState(i) = nanmean(RD_Matrix(:,i)); %1=dwelling, 2=roaming 
    end
    
end