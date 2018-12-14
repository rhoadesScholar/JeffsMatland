%%%%%%%Take a finalTracks file and systematically vary minimum State
%%%%%%%Duration...examine effects of this variable of distribution of
%%%%%%%roam/dwell times

function analyzeBothRandD(finalTracks)
    cmap = [jet(255)];
    colormap(cmap);
    binsize = 30;
    finalTracks2 = finalTracks;
    index = 1;
    holdDwell = [30 35 40 45 50 55]
    for (j = holdDwell)
        
        [xaxis yaxis_dwell yaxis_roam] = checkHistsVaryRo(finalTracks,finalTracks2,450,binsize,3,3,holdDwell);
        subplot(4,6,index);
        scatter(xaxis,yaxis_dwell);
        if(index == 1)
            label = sprintf('percent of dwell states with \n durations within 30 sec of minimum');
            ylabel(label);
        end
        xlabel('minimum state duration (sec)');
        title(sprintf('binSize = %d sec',binsize/3));
        axis([0 90 0 1])
        subplot(4,6,index+1);
        scatter(xaxis, yaxis_roam);
        if(index == 1)
            label = sprintf('percent of roam states with \n durations within 30 sec of minimum');
            ylabel(label);
        end
        xlabel('minimum state duration (sec)');
        title(sprintf('binSize = %d sec',binsize/3));
        axis([0 90 0 1])
        index = index + 2;
    end
    for (j = holdDwell)
        
        [xaxis yaxis_dwell yaxis_roam] = checkHistsVaryDw(finalTracks,finalTracks2,450,binsize,3,3,holdDwell);
        subplot(4,6,index);
        scatter(xaxis,yaxis_dwell);
        if(index == 1)
            label = sprintf('percent of dwell states with \n durations within 30 sec of minimum');
            ylabel(label);
        end
        xlabel('minimum state duration (sec)');
        title(sprintf('binSize = %d sec',binsize/3));
        axis([0 90 0 1])
        subplot(4,6,index+1);
        scatter(xaxis, yaxis_roam);
        if(index == 1)
            label = sprintf('percent of roam states with \n durations within 30 sec of minimum');
            ylabel(label);
        end
        xlabel('minimum state duration (sec)');
        title(sprintf('binSize = %d sec',binsize/3));
        axis([0 90 0 1])
        index = index + 2;
    end
   



[filepath,fileprefix,extension,version] = fileparts(finalTracks(1).Name);

set(1,'Name',fileprefix);
save_figure(1,'',fileprefix,'minDurAnalysis');

end