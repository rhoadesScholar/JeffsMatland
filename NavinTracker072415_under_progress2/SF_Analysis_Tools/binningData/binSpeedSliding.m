%%%slideSize and binSize are in frames

function binnedSpeedSliding = binSpeedSliding(trackData, binSize, slideSize)
    
    
    for (i=1:length(trackData)) 
        speedData = trackData(i).Speed;
        binnedSpeedSliding(i).Speed = [];
        j= 1;
        while((j+(binSize-1)) <= (length(speedData)))
            startIn = j;
            stopIn = j + (binSize-1);
            currentData = speedData(startIn:stopIn);
            
            binnedSpeedSliding(i).Speed = [binnedSpeedSliding(i).Speed mean(currentData)];
            j = j + slideSize;
        end
    end
    
end






