function [ITI_Dwell ITI_Roam] = splitITIs(finalTracks,TrackNumber)
ITI_Dwell = [];
ITI_Roam = [];
for(j = 1:length(TrackNumber))
    turnMatrix = interTurnInterval(finalTracks,j);
    finalTracks2 = finalTracks;
    [stateList startingStateMap] = getStateSliding(finalTracks,finalTracks2,450,30,3,45,3);
    DwellFrames = find(stateList(j).finalstate==1);
    ITIframes = turnMatrix(:,1)
    DwellIndex = [];
    RoamIndex = [];
    for (i=1:length(ITIframes))
        a = find(DwellFrames==ITIframes(i));
        display(a);
        if(a>0)
            DwellIndex = [DwellIndex i];
        else
            RoamIndex = [RoamIndex i];
        end
        
    end
    ITI_Dwell = [ITI_Dwell; turnMatrix(DwellIndex,:)];
    ITI_Roam = [ITI_Roam; turnMatrix(RoamIndex,:)];
end
