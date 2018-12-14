%%%%%Use this script to ramp minDuration for roam/dwell together and collect the dwell/roam
%%%%%distributions


index = 1
dwells_ramptogether = [];
roams_ramptogether = [];
for (i=10:80)
        display(i)
        dwells_ramptogether(index).dwell = [];
        roams_ramptogether(index).roam = [];
        [dwells_ramptogether(index).dwell roams_ramptogether(index).roam] = specifyRandDMins(allTracks,i,i)
        index = index+1;
end
    
%%%%%Use this script to ramp minDuration for roam/dwell independently and collect the dwell/roam
%%%%%distributions

index = 1;
dwells_hold_dwell35 = [];
roams_hold_dwell35 = [];
for (i=[35])
    for (j=10:75)
        display(j)
        %dummystring = sprintf('dsd_%d_%d',i,j);
        %dummystring2 = sprintf('rsd_%d_%d',i,j);
        dwells(index).dwell = [];
        roams(index).roam = [];
        [dwells_hold_dwell35(index).dwell roams_hold_dwell35(index).roam] = specifyRandDMins(allTracks,i,j)
        index = index+1;
    end
end

index = 1;
dwells_hold_roam57 = [];
roams_hold_roam57 = [];
for (j=[57])
    for (i=10:75)
        display(j)
        %dummystring = sprintf('dsd_%d_%d',i,j);
        %dummystring2 = sprintf('rsd_%d_%d',i,j);
        dwells(index).dwell = [];
        roams(index).roam = [];
        [dwells_hold_roam57(index).dwell roams_hold_roam57(index).roam] = specifyRandDMins(allTracks,i,j)
        index = index+1;
    end
end
%%%%%%%%%Use this script to take the output from above and compare
%%%%%%%%%consecutive data points by KS test - the kstest p values are
%%%%%%%%%returned in "allpvalues"

    
database = roams_hold_dwell35;

pvalues = [];

for (i=1:61)
    display(i)
   
        data1 = database(i).roam;
        data2 = database(i+5).roam;
        [h,p] = kstest2(data1,data2);
        pvalues(i) = p;
    
   
end



pvalues = [];
minobserv = length(database(50).roam);
for (i=1:45)
    display(i)
    pvaluesList = [];
        for (j=1:1000)
        data1 = randsample(database(i).roam,minobserv);
        data2 = randsample(database(i+5).roam,minobserv);
        [h,p] = kstest2(data1,data2);
        pvaluesList(j) = p;
        end
        pvalues(i) = mean(pvaluesList);
        %pvalues(22:66) = 1;
end
    
    