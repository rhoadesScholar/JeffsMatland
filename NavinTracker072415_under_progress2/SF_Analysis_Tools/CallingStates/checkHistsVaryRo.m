function [xaxis yaxis_dwell yaxis_roam] = checkHistsVaryRo(trackDataforSp,trackDataforAngSp,ratio,binSize,slideSize,fps,DwConst)
    nBins = 90-(binSize/3)+1;
    binNumb = 1;
    for (i=(binSize/3):1:90)
        display(i);
        stateDurationMaster(binNumb).state = [];
        dwellStateDurations(binNumb).dwell = [];
        roamStateDurations(binNumb).roam = [];
        [stateList startingStateMap] = getStateSliding_Diff(trackDataforSp,trackDataforAngSp,ratio,binSize,slideSize,DwConst,i,fps);
        [stateDurationMaster(binNumb).state dwellStateDurations(binNumb).dwell roamStateDurations(binNumb).roam] = getStateDurations(stateList,0.333);
        binNumb = binNumb+1;
    end
    xaxis = (binSize/3):1:90;
    for (i=1:nBins)
        yaxis_dwell(i) = (length(find(dwellStateDurations(i).dwell<(xaxis(i)+30)))) / (length(dwellStateDurations(i).dwell));
        yaxis_roam(i) = (length(find(roamStateDurations(i).roam<(xaxis(i)+30)))) / (length(roamStateDurations(i).roam));
       % yaxis_dwell(i) = (length(find(dwellStateDurations(i).dwell<80))) / (length(dwellStateDurations(i).dwell));
       % yaxis_roam(i) = (length(find(roamStateDurations(i).roam<80))) / (length(roamStateDurations(i).roam));
    
    
    end
end

%yaxis_dwell(i) = (length(find(dwellStateDurations(i).dwell<80))) / (length(dwellStateDurations(i).dwell));
%yaxis_roam(i) = (length(find(roamStateDurations(i).roam<80))) / (length(roamStateDurations(i).roam));
