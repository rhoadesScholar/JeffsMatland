%%%%%%%Take a finalTracks file and systematically vary minimum State
%%%%%%%Duration...examine effects of this variable of distribution of
%%%%%%%roam/dwell times

function analyzeMinDuration(finalTracks)
    cmap = [jet(255)];
    colormap(cmap);
    x = [9 15 30];
    finalTracks2 = finalTracks;
    index = 0;
    for (binsize = x)
        index = index + 1;
        [xaxis yaxis_dwell yaxis_roam] = checkHists(finalTracks,finalTracks2,450,binsize,3,3);
        subplot(2,3,index);
        scatter(xaxis,yaxis_dwell);
        if(index == 1)
            label = sprintf('percent of dwell states with \n durations within 30 sec of minimum');
            ylabel(label);
        end
        xlabel('minimum state duration (sec)');
        title(sprintf('binSize = %d sec',binsize/3));
        axis([0 60 0 1])
        subplot(2,3,index+3);
        scatter(xaxis, yaxis_roam);
        if(index == 1)
            label = sprintf('percent of roam states with \n durations within 30 sec of minimum');
            ylabel(label);
        end
        xlabel('minimum state duration (sec)');
        title(sprintf('binSize = %d sec',binsize/3));
        axis([0 60 0 1])
    end



[filepath,fileprefix,extension,version] = fileparts(finalTracks(1).Name);

set(1,'Name',fileprefix);
save_figure(1,'',fileprefix,'minDurAnalysis');

end