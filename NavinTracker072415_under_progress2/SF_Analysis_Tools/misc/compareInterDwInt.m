function compareInterDwInt(folderWithBoth)
    PathofFolder = sprintf('%s',folderWithBoth);
    display(PathofFolder)
    dirList = ls(PathofFolder);
    display(dirList)
    dirList = dirList(3:4,:);

   string1 = deblank(dirList(1,:)); 
    
   folder = sprintf('%s/%s/',PathofFolder,string1);
   
 
   
   PathofFolder = sprintf('%s',folder);
    
    dirList = ls(PathofFolder);
    
    NumFolders = length(dirList(:,1));
    display(dirList)
    display(NumFolders)
    allTracks = [];
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
        allTracks = [allTracks finalTracks];
    end
    
    [interDwellIntervals_folder1 interRoamIntervals_folder1 AvgDwellSpeed_folder1 AvgDwellAngSpeed_folder1 AvgRoamSpeed_folder1 AvgRoamAngSpeed_folder1 allDataRafterD_folder1 allDataDafterR_folder1 AvgDwellSpeedError_folder1] = interDwellInterval(allTracks);
    
    PathofFolder = sprintf('%s',folderWithBoth);
    display(PathofFolder)
    dirList = ls(PathofFolder);
    display(dirList)
    dirList = dirList(3:4,:);

    
    string2 = deblank(dirList(2,:)); 
    folder = [];
   folder = sprintf('%s/%s/',PathofFolder,string2);
   
 
   
   PathofFolder = sprintf('%s',folder);
    
    dirList = ls(PathofFolder);
    
    NumFolders = length(dirList(:,1));
    display(dirList)
    display(NumFolders)
    allTracks = [];
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
        display(fileList)
        fileName = deblank(fileList(fileIndex,:));
        fileToOpen = sprintf('%s%s',PathName,fileName);
        display(fileToOpen)
        load(fileToOpen);
        allTracks = [allTracks finalTracks];
    end
    
    [interDwellIntervals_folder2 interRoamIntervals_folder2 AvgDwellSpeed_folder2 AvgDwellAngSpeed_folder2 AvgRoamSpeed_folder2 AvgRoamAngSpeed_folder2 allDataRafterD_folder2 allDataDafterR_folder2 AvgDwellSpeedError_folder2] = interDwellInterval(allTracks);
    
    subplot(1,2,1);
    plotTwoHists_LogScale(interDwellIntervals_folder1,interDwellIntervals_folder2,2);
    subplot(1,2,2);
    plotTwoHists_LogScale(interRoamIntervals_folder1,interRoamIntervals_folder2,2);
end

    
    