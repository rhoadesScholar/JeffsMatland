function [DwellRevRate RoamRevRate Dwell_sRev Roam_sRev Dwell_lRev Roam_lRev] = splitRevsDetailed(finalTracks)
Rev_Dwell = [];
Rev_Roam = [];
finalTracks2 = finalTracks;
[stateList startingStateMap] = getStateSliding(finalTracks,finalTracks2,450,30,3,45,3);
%[stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurations(stateList,.333);
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

for(j = 1:length(finalTracks))
    Revs = finalTracks(j).Reversals(:,1)
    
    DwellFrames = find(stateList(j).finalstate==1);
    DwellFrames = DwellFrames + finalTracks(j).Frames(1)-1;
    
    for (i=1:length(Revs))
        a = find(DwellFrames==Revs(i));
        
        if(a>0)
            %DwellIndex = [DwellIndex i];
            DwellIndexLength = [DwellIndexLength finalTracks(j).Reversals(i,3)];
        else
            %RoamIndex = [RoamIndex i];
            RoamIndexLength = [RoamIndexLength finalTracks(j).Reversals(i,3)];
        end
        
    end
    %Rev_Dwell = [Rev_Dwell; Revs(DwellIndex,1)];
   % Rev_Roam = [Rev_Roam; Revs(RoamIndex,1)];
   
end
display(DwellIndexLength)
display(RoamIndexLength)
 DwellRevRate = (length(DwellIndexLength))/DwellTime;
 Dw_sRevs = find(DwellIndexLength<0.3);
 num_Dw_sRevs = length(Dw_sRevs);
 num_Dw_lRevs = length(DwellIndexLength) - num_Dw_sRevs;
 Dwell_sRev = num_Dw_sRevs/DwellTime;
 Dwell_lRev = num_Dw_lRevs/DwellTime;
 RoamRevRate = (length( RoamIndexLength))/RoamTime;
Ro_sRevs = find(RoamIndexLength<0.3);
 num_Ro_sRevs = length(Ro_sRevs);
 num_Ro_lRevs = length(RoamIndexLength) - num_Ro_sRevs;
 Roam_sRev = num_Ro_sRevs/RoamTime;
 Roam_lRev = num_Ro_lRevs/RoamTime;
end
