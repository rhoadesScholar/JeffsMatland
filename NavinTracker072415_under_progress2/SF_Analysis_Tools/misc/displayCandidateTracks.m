function displayCandidateTracks(finalTracks)

    [expOrigSeq expStates estTR estE] = getHMMStates(finalTracks,30);
    [stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurationsInclEnds_HMM(expStates,.333);
    longestRoamState(1:length(finalTracks)) = NaN;
    lengthFirstRoamState(1:length(finalTracks)) = NaN;
    secondlongestRoamState(1:length(finalTracks)) = NaN;
    
    for(i=1:length(finalTracks))
        FramesEachVideo(i) = finalTracks(i).NumFrames;
        numStatesEachVideo(i) = length(stateDurationMaster(i).stateCalls(:,1));
        shortestState(i) = min(stateDurationMaster(i).stateCalls(:,2));
        RoamStateIndices = find(stateDurationMaster(i).stateCalls(:,1)==2);
        if(length(RoamStateIndices)>1)
            RoamStateOnly = stateDurationMaster(i).stateCalls(RoamStateIndices,:);
            longestRoamState(i) = max(RoamStateOnly(:,2));
            [svals,idx] = sort(RoamStateOnly(:,2),'descend');
            secondlongestRoamState(i) = svals(2);
            
            lengthFirstRoamState(i) = max(RoamStateOnly(1:2,2));
            
           
            
        end
    end
    
    FLVideoIndex = find(FramesEachVideo>10000);
    NotTooManyStatesIndex = find(numStatesEachVideo<14);
    %NoSuperShortStates = find(shortestState>25);
    AtLeastOneLongRoamState = find(longestRoamState>260);
    DecentFirstRoamState = find(lengthFirstRoamState>90);
    ASecondRoamState = find(secondlongestRoamState>200);
    
    a = intersect(FLVideoIndex,NotTooManyStatesIndex);
    %b = intersect(a,NoSuperShortStates);
    c = intersect(a,AtLeastOneLongRoamState);
    d = intersect(c,DecentFirstRoamState);
    e = intersect(d,ASecondRoamState);

 for (j=1:length(e))
     figure(j);
     display(e(j));
     plotyy(finalTracks(e(j)).Frames,finalTracks(e(j)).Speed,finalTracks(e(j)).Frames,finalTracks(e(j)).AngSpeed);
     pause;
     
 end

end