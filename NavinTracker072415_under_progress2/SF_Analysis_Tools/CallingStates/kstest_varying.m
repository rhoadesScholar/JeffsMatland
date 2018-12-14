function [dwells_hold_dwell47 roams_hold_dwell47 dwells_hold_roam51 roams_hold_roam51] = kstest_varying(allTracks)
    index = 1;
dwells_hold_dwell47 = [];
roams_hold_dwell47 = [];
for (i=[47])
    for (j=10:90)
        display(j)
        %dummystring = sprintf('dsd_%d_%d',i,j);
        %dummystring2 = sprintf('rsd_%d_%d',i,j);
        dwells(index).dwell = [];
        roams(index).roam = [];
        [dwells_hold_dwell47(index).dwell roams_hold_dwell47(index).roam] = specifyRandDMins(allTracks,i,j)
        index = index+1;
    end
end

index = 1;
dwells_hold_roam51 = [];
roams_hold_roam51 = [];
for (j=[51])
    for (i=10:90)
        display(j)
        %dummystring = sprintf('dsd_%d_%d',i,j);
        %dummystring2 = sprintf('rsd_%d_%d',i,j);
        dwells(index).dwell = [];
        roams(index).roam = [];
        [dwells_hold_roam51(index).dwell roams_hold_roam51(index).roam] = specifyRandDMins(allTracks,i,j)
        index = index+1;
    end
end
end