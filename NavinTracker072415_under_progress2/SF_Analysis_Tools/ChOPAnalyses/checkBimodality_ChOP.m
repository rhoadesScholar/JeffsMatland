function checkBimodality_ChOP(AllBinnedData,startStim,stopStim)
    lowBins = find(AllBinnedData(:,1)<stopStim);
    AllBinnedData_int = AllBinnedData(lowBins,:);
    highBins = find(AllBinnedData_int(:,1)>startStim);
    AllBinnedData_Stim = AllBinnedData_int(highBins,:);
    
    hist2(AllBinnedData_Stim(:,2),AllBinnedData_Stim(:,3),0.003,2);
    ylabel('Speed (mm/sec)')
    xlabel('Angular Speed (deg/sec)')
     axis([0 180 0 0.25]);
     cmap = [hot(255)]
     colormap(cmap);
     set(findobj(gcf,'type','axes'),'Color',[0 0 0]);
end