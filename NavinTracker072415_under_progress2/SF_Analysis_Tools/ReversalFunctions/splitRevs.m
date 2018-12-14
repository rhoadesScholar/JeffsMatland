function [DwellRevRate RoamRevRate] = splitRevs(finalTracks)
Rev_Dwell = 0;
Rev_Roam = 0;
finalTracks2 = finalTracks;
[stateList startingStateMap] = getStateSliding(finalTracks,finalTracks2,450,30,3,45,3);
[stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurations(stateList,.333);
allStateCalls = [];
for(j = 1:(length(stateList)))

    allStateCalls = [allStateCalls stateList(j).finalstate];
end
TotalBins = length(allStateCalls);
numDwellBins = length(find(allStateCalls==1));
numRoamBins = TotalBins - numDwellBins;
DwellTime = numDwellBins/180;
display(DwellTime)
RoamTime = numRoamBins/180;
display(RoamTime)
for(j = 1:length(finalTracks))
    Revs = finalTracks(j).Reversals(:,1)
    startFrame = finalTracks(j).Frames(1);
    
    DwellFrames = find(stateList(j).finalstate==1);
    %DwellFrames = DwellFrames +startFrame-1;
    
    DwellIndex = [];
    RoamIndex = [];
    for (i=1:length(Revs))
        display(Revs(i))
        a = find(DwellFrames==Revs(i));
        display(a)
        if(a>0)
            DwellIndex = [DwellIndex i];
            display(DwellIndex)
        else
            RoamIndex = [RoamIndex i];
            display(RoamIndex)
        end
        
    end
    Rev_Dwell = Rev_Dwell + length(DwellIndex)
    display(Rev_Dwell)
    Rev_Roam = Rev_Roam + length(RoamIndex)
    display(Rev_Roam)
   
end
 DwellRevRate = Rev_Dwell/DwellTime;
    RoamRevRate = Rev_Roam/RoamTime;

