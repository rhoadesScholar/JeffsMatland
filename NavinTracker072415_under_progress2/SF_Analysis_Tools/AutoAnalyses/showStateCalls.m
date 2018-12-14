function showStateCalls(finalTracks,vectToAnalyze,vectMinDurations)
    finalTracks2 = finalTracks;
    
    numTracks = length(vectToAnalyze);
    xaxis_1 = 1:1:16200;
    xaxis_2 = xaxis_1/180;
    for(i=1:numTracks)
        NumFrames = finalTracks(vectToAnalyze(i)).NumFrames;
        xaxis_1 = 1:1:NumFrames;
        xaxis_2 = xaxis_1/180;
        subplot((length(vectMinDurations))+1,1,1)
        plotyy(xaxis_2,finalTracks(vectToAnalyze(i)).AngSpeed,xaxis_2,finalTracks(vectToAnalyze(i)).Speed);
        axis([0 95 -500 200])
        xlabel('time (min)');
        ylabel('Angular Speed (deg/sec)');
        for(j=1:(length(vectMinDurations)))
            
            [stateList startingStateMap] = getStateSliding_Diff(finalTracks,finalTracks2,450,30,3,vectMinDurations(j),vectMinDurations(j+1),3);
            xaxis_3 = 1:1:length(stateList(vectToAnalyze(i)).finalstate);
            xaxis_4 = xaxis_3/180;
            subplot((length(vectMinDurations))+1,1,1+j);
            plot(xaxis_4,stateList(vectToAnalyze(i)).finalstate);
            axis([0 95 -1 3]);
            dummystring = sprintf('minimum state duration = %d', vectMinDurations(j));
            title(dummystring);
            %%%maybe set color, etc.
        end
        [filepath,fileprefix,extension,version] = fileparts(finalTracks(i).Name);
        display(fileprefix)

        fullName = sprintf('%s_%d',fileprefix,(vectToAnalyze(i)));
        save_figure(1,'',fullName,'states');
    end
end