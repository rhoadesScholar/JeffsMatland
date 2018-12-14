function [dwellStateDurations roamStateDurations FractionDwelling FractionRoaming mean_dw_stab mean_dw_stab_err mean_dw_stab_vector mean_ro_stab mean_ro_stab_err mean_ro_stab_vector] = AutomatedRoamDwellAnalysis_Pool_InclEnds_HMM_useN2HMM_550(allTracks,Date,Genotype,N2_TR,N2_E)
%     PathofFolder = sprintf('%s/',folder);
%     dirList = ls(PathofFolder);
%     NumFolders = length(dirList(:,1));
%     allTracks = [];
%     for(i = 3:NumFolders)
%         string1 = deblank(dirList(i,:)); 
%         
%         PathName = sprintf('%s/%s/',PathofFolder,string1);
%         display(PathName)
%         fileList = ls(PathName);
%         display(i)
%        display(fileList)
%        if (length(fileList)>0)
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
%        end
%     end
        %checkBimodality(allTracks);
        %analyzeMinDuration(allTracks);
        [dwellStateDurations roamStateDurations FractionDwelling FractionRoaming mean_dw_stab mean_dw_stab_err mean_dw_stab_vector mean_ro_stab mean_ro_stab_err mean_ro_stab_vector] = GetHistsAndRatioInclEnds_HMM_useN2HMM_550(allTracks,Date,Genotype,N2_TR,N2_E);
        
    
end