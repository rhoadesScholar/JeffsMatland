function [dsd rsd] = specifyRandDMins_InclEnds(tracks,Dw_Min,Ro_Min)
    [stateList startingStateMap] = getStateSliding_Diff(tracks,tracks,450,30,3,Dw_Min,Ro_Min,3);
    [stateDurationMaster dsd rsd] = getStateDurationsInclEnds(stateList,0.333);
end
