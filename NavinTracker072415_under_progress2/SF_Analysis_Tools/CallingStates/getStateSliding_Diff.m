function [stateList startingStateMap] = getStateSliding_Diff(trackDataforSp,trackDataforAngSp,ratio,binSize,slideSize,minStateDuration_Dw,minStateDuration_Ro,fps)
    stateList = [];
    
    binnedSpeedData = binSpeedSliding(trackDataforSp, binSize, slideSize);
    binnedAngSpeedData = binAngSpeedSliding(trackDataforAngSp, binSize, slideSize);
    
    startingStateMap = getState(binnedSpeedData,binnedAngSpeedData,ratio);
    
    minStateDurationFrames_Dw = minStateDuration_Dw * fps;
    minConsecDataPoints_Dw = (round((minStateDurationFrames_Dw-binSize)/slideSize) + 1);
    
    minStateDurationFrames_Ro = minStateDuration_Ro * fps;
    minConsecDataPoints_Ro = (round((minStateDurationFrames_Ro-binSize)/slideSize) + 1);
    
    for(j=1:(length(trackDataforSp)))
       
    currentState = startingStateMap(j).state(1);
    stateStart = 1;
    lastState = startingStateMap(j).state(1);
    currentStateDuration = 1;
    stateList(j).finalstate = [];
    firstCall = 1;
    for (i=2:(length(startingStateMap(j).state)))
        if (startingStateMap(j).state(i) == currentState)
            currentStateDuration = currentStateDuration + 1;
            if(i==length(startingStateMap(j).state))
                stateEnd = i-1;
                startInd = 1 + ((stateStart-1) * slideSize) + (round((binSize-slideSize)/2));
                stopInd_Prec = 1 + ((stateEnd-1) * slideSize);
                stopInd = stopInd_Prec + (binSize-1);
                stateList(j).finalstate(startInd:stopInd) = currentState;
            end
        else 
            stateEnd = i-1;
            startInd = 1 + ((stateStart-1) * slideSize) + (round((binSize-slideSize)/2));
            stopInd_Prec = 1 + ((stateEnd-1) * slideSize);
            stopInd = stopInd_Prec + (binSize-1);
            if (currentState==1)
                if (currentStateDuration >= minConsecDataPoints_Dw)
                    if (firstCall == 1)
                        stateList(j).finalstate(1:stopInd) = currentState;
                        lastState = currentState;
                        firstCall = 0;
                    else
                   stateList(j).finalstate(startInd:stopInd) = currentState;
                   lastState = currentState;
                   end
                else 
                    stateList(j).finalstate(startInd:stopInd) = lastState;

                end
            else
                if (currentStateDuration >= minConsecDataPoints_Ro)
                    if (firstCall == 1)
                        stateList(j).finalstate(1:stopInd) = currentState;
                        lastState = currentState;
                        firstCall = 0;
                    else
                   stateList(j).finalstate(startInd:stopInd) = currentState;
                   lastState = currentState;
                   end
                else 
                    stateList(j).finalstate(startInd:stopInd) = lastState;

                end
            end
            currentStateDuration = 1;
            currentState = startingStateMap(j).state(i);
            stateStart = i;
            
        end
    end
end
