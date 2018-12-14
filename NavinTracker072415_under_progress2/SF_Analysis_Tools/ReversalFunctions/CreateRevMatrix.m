function [RevMatrix DwellRevRate RoamRevRate Dwell_sRevRate Dwell_lRevRate Roam_sRevRate Roam_lRevRate] = CreateRevMatrix(finalTracks)
Rev_Dwell = [];
Rev_Roam = [];
 finalTracks2 = finalTracks;
 [stateList startingStateMap] = getStateSliding_Diff(finalTracks,finalTracks2,450,30,3,35,57,3);
% %[stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurations(stateList,.333);
 allStateCalls = [];
 for(j = 1:(length(stateList)))
 
     allStateCalls = [allStateCalls stateList(j).finalstate];
 end
 TotalBins = length(allStateCalls);
 numDwellBins = length(find(allStateCalls==1));
 numRoamBins =length(find(allStateCalls==2));
 DwellTime = numDwellBins/180;
 RoamTime = numRoamBins/180;

DwellIndex = [];
DwellIndexLength = []; 
RoamIndex = [];
RoamIndexLength = [];
indexRevMatrix = 1;
for(j = 1:length(finalTracks))
    Revs = finalTracks(j).Reversals(:,1);
    
    DwellFrames = find(stateList(j).finalstate==1);
    %DwellFrames = DwellFrames + finalTracks(j).Frames(1)-1;
    
    for (i=1:length(Revs))
        a = find(DwellFrames==Revs(i));
        
        if(a>0)
            %DwellIndex = [DwellIndex i];
            RevMatrix(indexRevMatrix,1) = 1;
            RevMatrix(indexRevMatrix,2) = j;
            RevMatrix(indexRevMatrix,3) =  finalTracks(j).Reversals(i,2);
            RevMatrix(indexRevMatrix,4) =  finalTracks(j).Reversals(i,3);
            indexRevMatrix = indexRevMatrix + 1;
            
        else
            %RoamIndex = [RoamIndex i];
            RevMatrix(indexRevMatrix,1) = 2;
            RevMatrix(indexRevMatrix,2) = j;
            RevMatrix(indexRevMatrix,3) =  finalTracks(j).Reversals(i,2);
            RevMatrix(indexRevMatrix,4) =  finalTracks(j).Reversals(i,3);
            indexRevMatrix = indexRevMatrix + 1;
           
        end
        
    end
    
Num_Total_Revs = length(RevMatrix(:,1));
RevIndex = RevMatrix(:,1);
Num_Dwell_Revs = length(find(RevIndex == 1));
Num_Roam_Revs = length(find(RevIndex == 2));
DwellRevRate = Num_Dwell_Revs/DwellTime;
RoamRevRate = Num_Roam_Revs/RoamTime;

DwellIndex = find(RevIndex == 1);
RoamIndex = find(RevIndex == 2);
RevMatrix_Dwell = RevMatrix(DwellIndex,:);
RevMatrix_Roam = RevMatrix(RoamIndex,:);

RevLengths_Dwell = RevMatrix_Dwell(:,4);
Num_Dwell_sRevs = length(find(RevLengths_Dwell < 0.3));
Num_Dwell_lRevs = Num_Dwell_Revs - Num_Dwell_sRevs;
Dwell_sRevRate = Num_Dwell_sRevs/DwellTime;
Dwell_lRevRate = Num_Dwell_lRevs/DwellTime;

RevLengths_Roam = RevMatrix_Roam(:,4);
Num_Roam_sRevs = length(find(RevLengths_Roam < 0.3));
Num_Roam_lRevs = Num_Roam_Revs - Num_Roam_sRevs;
Roam_sRevRate = Num_Roam_sRevs/RoamTime;
Roam_lRevRate = Num_Roam_lRevs/RoamTime;

   
end