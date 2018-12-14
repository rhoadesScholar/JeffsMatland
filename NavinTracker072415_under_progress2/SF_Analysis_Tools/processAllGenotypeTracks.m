function processAllGenotypeTracks(folderWithBoth)
    PathofFolder = sprintf('%s',folderWithBoth);
    
    dirList = ls(PathofFolder);
    dirList = dirList(3:4,:);
    string1 = deblank(dirList(1,:)); 
    string2 = deblank(dirList(2,:)); 
    PathName1 = sprintf('%s/%s/',PathofFolder,string1);
    PathName2 = sprintf('%s/%s/',PathofFolder,string2);
    
    dirList1 = ls(PathName1);
    dirList1 = dirList1(3:end,:);
    dirList2 = ls(PathName2);
    dirList2 = dirList2(3:end,:);
    
    numFolders1 = length(dirList1(:,1));
    numFolders2 = length(dirList2(:,1));
    
    for(i=1:numFolders1)
        currentFolder = dirList1(i,:);
        PathName_Final = sprintf('%s',PathName1,currentFolder);
        processTracks(PathName_Final);
    end
    
    for(i=1:numFolders2)
        currentFolder = dirList2(i,:);
        PathName_Final = sprintf('%s',PathName2,currentFolder);
        processTracks(PathName_Final);
    end
end