function [stateDurationMaster dwellStateDurations roamStateDurations intermediateStateDurations] = getStateDurations_HMM_3state(stateData,binSize)
    
    roamStateDurations = [];
    dwellStateDurations = [];
    intermediateStateDurations = [];
    dwellStateDurationsAnimNumb = [];
    roamStateDurationsAnimNumb = [];
    intermediateStateDurationsAnimNumb = [];
    
    for (j=1:length(stateData))
        
        nBins = length(stateData(j).states);
        currentState = stateData(j).states(1);
        currentStateDuration = 1;
        stateNumb = 1;
        stateDurationMaster(j).stateCalls = [];
        firstCall = 1;
        for (i=2:nBins)
            if (stateData(j).states(i) == currentState)
                currentStateDuration = currentStateDuration + 1;
            else 
                lastState = stateData(j).states(i-1);
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
                    if (lastState==2)
                        if (firstCall == 1)
                        firstCall = 0;
                        else
                            intermediateStateDurationsAnimNumb = [intermediateStateDurationsAnimNumb j];    
                            intermediateStateDurations = [intermediateStateDurations lastStatesecs];
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
                        %%%%%%%%%%%%%%%%%%%%%%
                end
                currentStateDuration = 1;
                currentState = stateData(j).states(i);
            end
        end
    end
    dwellStateDurations = [dwellStateDurations; dwellStateDurationsAnimNumb];
    roamStateDurations = [roamStateDurations; roamStateDurationsAnimNumb];
    intermediateStateDurations = [intermediateStateDurations; intermediateStateDurationsAnimNumb];
end

