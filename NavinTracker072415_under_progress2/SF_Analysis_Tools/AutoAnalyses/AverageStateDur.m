function [mean_statedur stderr_statedur collectedMeans] = AverageStateDur(dsd)

    numContrAnim = length(unique(dsd(2,:)));
    uniqueContrTracks = unique(dsd(2,:));
    NumTracks = max(dsd(2,:));
    for(i=1:numContrAnim)
        TrackHere = uniqueContrTracks(i);
        IndicesHere = find(dsd(2,:) == TrackHere);
        collectedMeans(i) = mean(dsd(1,IndicesHere));
    end
    
    mean_statedur = mean(collectedMeans);
    stderr_statedur = (std(collectedMeans))/(sqrt(length(collectedMeans)));
end