function [dwellStateDurations roamStateDurations FractionDwelling FractionRoaming] = GetHistsAndRatio_HMM(finalTracks,Date,Genotype)
    cmap = [jet(255)];
    colormap(cmap);
    finalTracks2 = finalTracks;
    %[stateList startingStateMap] = getStateSliding_Diff(finalTracks,finalTracks2,450,30,3,35,57,3);
    [expNewSeq expStates estTR estE] = getHMMStates(finalTracks,30)
    %%%%%%%%%%%%%%%%%CHANGE BACK
    [stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurations_HMM(expStates,.333);
    allStateCalls = []
    for(j = 1:(length(expStates)))
        
        allStateCalls = [allStateCalls expStates(j).states];
    end
    TotalBins = length(allStateCalls);
    numDwellBins = length(find(allStateCalls==1));
    FractionDwelling = numDwellBins/TotalBins;
    FractionRoaming = 1 - FractionDwelling;
    a = zeros(2,2);
    a(1,1:2) = [FractionDwelling FractionRoaming];
    subplot(1,3,1);
    bar(a,'stack');
    legend('dwelling','roaming');
    ylabel('fraction of time');
    subplot(1,3,2);
    hist(dwellStateDurations(1,:)/180,150);
%     ax_hdl = get(gcf,'CurrentAxes');
%     current = axis(ax_hdl);
%     axis([0 (4500/180) 0 current(4)])
    title('Dwell State Durations');
    xlabel('duration of dwell state (min)');
    ylabel('number of observed states');
    subplot(1,3,3);
    hist(roamStateDurations(1,:)/180,150);
%     ax_hdl = get(gcf,'CurrentAxes');
%     current = axis(ax_hdl);
%     axis([0 (4500/180) 0 current(4)])
    title('Roam State Durations');
    xlabel('duration of roam state (min)');
    ylabel('number of observed states');
    
    VidName = sprintf('%s.%s',Date,Genotype);

    set(1,'Name',VidName);
    save_figure(1,'',VidName,'hists');

end
