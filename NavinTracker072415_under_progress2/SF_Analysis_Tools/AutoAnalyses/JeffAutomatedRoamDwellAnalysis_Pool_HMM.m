function [dwellStateDurations, roamStateDurations, FractionDwelling, FractionRoaming, TrackInfo] = JeffAutomatedRoamDwellAnalysis_Pool_HMM(allTracks,Date,Genotype)
%     PathofFolder = sprintf('%s',folder);
%     
%     dirList = ls(PathofFolder);
%     
%     NumFolders = length(dirList(:,1));
%     display(dirList)
%     display(NumFolders)
%     allTracks = [];
%     for(i = 3:NumFolders)
%         string1 = deblank(dirList(i,:)); 
%         
%         PathName = sprintf('%s/%s/',PathofFolder,string1);
%         fileList = ls(PathName);
%        
%         numFiles = length(fileList(:,1));
%         
%         for(j=3:1:numFiles)
%             string2 = deblank(fileList(j,:));
%             [pathstr, FilePrefix, ext] = fileparts(string2);
%             [pathstr2, FilePrefix2, ext2] = fileparts(FilePrefix);
%            
%             if(strcmp(ext2,'.finalTracks')==1)
%                 fileIndex = j;
%             end
%         end
%         fileName = deblank(fileList(fileIndex,:));
%         fileToOpen = sprintf('%s%s',PathName,fileName);
%         display(fileToOpen)
%         load(fileToOpen);
%         allTracks = [allTracks finalTracks];
%     end
        %checkBimodality(allTracks,Date,Genotype);
        %analyzeBothRandD(allTracks);
        ReversalInfo = JeffgetAllRevs_HMM_longSpeed(allTracks);
        [dwellStateDurations roamStateDurations FractionDwelling FractionRoaming] = GetHistsAndRatio_HMM(allTracks,Date,Genotype);
        
    TrackInfo = struct('dwell_state_durations',[],'roam_state_durations',[],'Reversal_Info',[]);
    TrackInfo.dwell_state_durations = dwellStateDurations;
    TrackInfo.roam_state_durations = roamStateDurations;
    TrackInfo.Reversal_Info = ReversalInfo;
    
    VidName = sprintf('%s.%s',Date,Genotype);
    display(VidName)
    NewFilename = sprintf('%s.TrackInfo.mat',VidName);
    display(NewFilename)
%     FullFileName = sprintf('%s/%s',PathofFolder,NewFilename);
%     display(FullFileName)
    save(NewFilename,'TrackInfo');
end