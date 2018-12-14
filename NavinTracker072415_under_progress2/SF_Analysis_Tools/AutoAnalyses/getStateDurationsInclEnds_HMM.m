function [stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurationsInclEnds_HMM(stateData,binSize)
    
    roamStateDurations = [];
    dwellStateDurations = [];
    dwellStateDurationsAnimNumb = [];
    roamStateDurationsAnimNumb = [];
    
    
    for (j=1:length(stateData))
        
        nBins = length(stateData(j).states);
        currentState = stateData(j).states(1);
        currentStateDuration = 1;
        stateNumb = 1;
        stateDurationMaster(j).stateCalls = [];
        firstCall = 1;
        for (i=2:nBins)
            if (i==nBins)
                lastState = stateData(j).states(i-1);
                lastStatesecs = binSize * currentStateDuration;
                if (lastState ==1)
                    
                    dwellStateDurations = [dwellStateDurations lastStatesecs];
                    dwellStateDurationsAnimNumb = [dwellStateDurationsAnimNumb j];
                    stateDurationMaster(j).stateCalls(stateNumb,:) = [lastState; lastStatesecs];
                    stateNumb = stateNumb + 1;
                    
                elseif(lastState==2)
                    roamStateDurationsAnimNumb = [roamStateDurationsAnimNumb j]; 
                    roamStateDurations = [roamStateDurations lastStatesecs];
                    stateDurationMaster(j).stateCalls(stateNumb,:) = [lastState; lastStatesecs];
                    stateNumb = stateNumb + 1;
                end
            else
            if (stateData(j).states(i) == currentState)
                currentStateDuration = currentStateDuration + 1;
            else 
                lastState = stateData(j).states(i-1);
                lastStatesecs = binSize * currentStateDuration;
                if (lastState ==1)
                    dwellStateDurationsAnimNumb = [dwellStateDurationsAnimNumb j];
                    dwellStateDurations = [dwellStateDurations lastStatesecs];
                    stateDurationMaster(j).stateCalls(stateNumb,:) = [lastState; lastStatesecs];
                    stateNumb = stateNumb + 1;
                    
                elseif(lastState==2)
                    roamStateDurationsAnimNumb = [roamStateDurationsAnimNumb j]; 
                    roamStateDurations = [roamStateDurations lastStatesecs];
                    stateDurationMaster(j).stateCalls(stateNumb,:) = [lastState; lastStatesecs];
                    stateNumb = stateNumb + 1;
                end
                currentStateDuration = 1;
                currentState = stateData(j).states(i);
            end
            end
        end
        
        %If data is all NaN, just fill in one row of NaNs in
        %StateDurationMaster
        numberNaNs = sum(isnan(stateData(j).states));
        lengthData = length(stateData(j).states);
        if (numberNaNs==lengthData)
            stateDurationMaster(j).stateCalls(1,:) = [NaN; NaN];
        end
    end
        dwellStateDurations = [dwellStateDurations; dwellStateDurationsAnimNumb];
    roamStateDurations = [roamStateDurations; roamStateDurationsAnimNumb];
end