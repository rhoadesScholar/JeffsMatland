function turnMatrix = interTurnInterval(finalTracks,TrackNumber)
    numFrames = finalTracks(TrackNumber).NumFrames;
    matrixIndex = 1;
    TurningFrames = find(finalTracks(TrackNumber).AngSpeed>90);
    for(s=2:length(TurningFrames))
        diff = TurningFrames(s) - TurningFrames(s-1);
        if(diff>3)
            turnMatrix(matrixIndex,:) = [TurningFrames(s) diff/3];
            matrixIndex = matrixIndex +1;
        end
        
    end
end

 
        
        