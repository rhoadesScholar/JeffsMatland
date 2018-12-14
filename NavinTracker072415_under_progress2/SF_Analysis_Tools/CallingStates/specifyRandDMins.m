function [dsd rsd] = specifyRandDMins(tracks,Dw_Min,Ro_Min)
    [stateList startingStateMap] = getStateSliding_Diff(tracks,tracks,450,30,3,Dw_Min,Ro_Min,3);
    [stateDurationMaster dsd rsd] = getStateDurations(stateList,0.333);
end