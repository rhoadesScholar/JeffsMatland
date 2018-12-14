%%%%%Take in a folder of data -- within this folder should lie several
%%%%%others, each with a final tracks file - for each of these, the
%%%%%function will (1) check bimodality, (2) analyze Min Duration and (3)
%%%%%return ratio (roam/dwell) and histograms of state durations


function AutomatedRoamDwellAnalysis(folder)
    PathofFolder = sprintf('%s/',folder);
    dirList = ls(PathofFolder);
    NumFolders = length(dirList(:,1));
    for(i = 3:NumFolders)
        string1 = deblank(dirList(i,:)); 
        
        PathName = sprintf('%s/%s/',PathofFolder,string1);
        fileList = ls(PathName);
       
        numFiles = length(fileList(:,1));
       
        for(j=3:1:numFiles)
            string2 = deblank(fileList(j,:));
            [pathstr, FilePrefix, ext, versn] = fileparts(string2);
            [pathstr2, FilePrefix2, ext2, versn2] = fileparts(FilePrefix);
           
            if(strcmp(ext2,'.finalTracks')==1)
                fileIndex = j;
            end
        end
        fileName = deblank(fileList(fileIndex,:));
        fileToOpen = sprintf('%s%s',PathName,fileName);
        display(fileToOpen)
        load(fileToOpen);
        checkBimodality(finalTracks);
        %analyzeMinDuration(finalTracks);
        GetHistsAndRatio(finalTracks,30,45);
    end
end
        