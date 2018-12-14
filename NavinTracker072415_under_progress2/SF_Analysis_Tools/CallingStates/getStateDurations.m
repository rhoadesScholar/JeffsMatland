function [stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurations(stateData,binSize)
    
    roamStateDurations = [];
    dwellStateDurations = [];
    dwellStateDurationsAnimNumb = [];
    roamStateDurationsAnimNumb = [];
    
    for (j=1:length(stateData))
        
        nBins = length(stateData(j).finalstate);
        currentState = stateData(j).finalstate(1);
        currentStateDuration = 1;
        stateNumb = 1;
        stateDurationMaster(j).stateCalls = [];
        firstCall = 1;
        for (i=2:nBins)
            if (stateData(j).finalstate(i) == currentState)
                currentStateDuration = currentStateDuration + 1;
            else 
                lastState = stateData(j).finalstate(i-1);
                lastStatesecs = binSize * currentStateDuration;
                if (lastState ==1)
                    if (firstCall == 1)
                        firstCall = 0;
                    else
                    dwellStateDurationsAnimNumb = [dwellStateDurationsAnimNumb j];
                    dwellStateDurations = [dwellStateDurations lastStatesecs];
                    stateDurationMaster(j).stateCalls(stateNumb,:) = [lastState; lastStatesecs];
                    stateNumb = stateNumb + 1;
                    end
                else
                    if (firstCall == 1)
                        firstCall = 0;
                    else
                    roamStateDurationsAnimNumb = [roamStateDurationsAnimNumb j];    
                    roamStateDurations = [roamStateDurations lastStatesecs];
                    stateDurationMaster(j).stateCalls(stateNumb,:) = [lastState; lastStatesecs];
                    stateNumb = stateNumb + 1;
                    end
                end
                currentStateDuration = 1;
                currentState = stateData(j).finalstate(i);
            end
        end
    end
    dwellStateDurations = [dwellStateDurations; dwellStateDurationsAnimNumb];
    roamStateDurations = [roamStateDurations; roamStateDurationsAnimNumb];
end
