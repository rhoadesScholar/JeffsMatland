function showHMMStateCalls(finalTracks,vectToAnalyze,binSize)
    finalTracks2 = finalTracks;
    
    numTracks = length(vectToAnalyze);
    xaxis_1 = 1:1:16200;
    xaxis_2 = xaxis_1/180;
    for(i=1:numTracks)
        NumFrames = finalTracks(vectToAnalyze(i)).NumFrames;
        xaxis_1 = 1:1:NumFrames;
        xaxis_2 = xaxis_1/180;
        subplot(4,1,1)
        ax = plotyy(xaxis_2,finalTracks(vectToAnalyze(i)).AngSpeed,xaxis_2,finalTracks(vectToAnalyze(i)).Speed);
        axis(ax(1),[0 90 -500 200]);
        axis(ax(2),[0 90 0 .3]);
        xlabel('time (min)');
        ylabel('Angular Speed (deg/sec)');
        
        [expOrigSeq expStates estTR estE] = getHMMStates(finalTracks,binSize);
        
        xaxis_7 = 1:1:length(expOrigSeq(vectToAnalyze(i)).states);
            xaxis_8 = xaxis_7/180;
            subplot(4,1,2);
            plot(xaxis_8,expOrigSeq(vectToAnalyze(i)).states);
            axis([0 90 -1 3]);
            dummystring = sprintf('Original Bins');
            title(dummystring);
            %%%maybe set color, etc.
            
    
%         [stateList startingStateMap] = getStateSliding_Diff(finalTracks,finalTracks2,450,30,3,35,57,3);
%             xaxis_3 = 1:1:length(stateList(vectToAnalyze(i)).finalstate);
%             xaxis_4 = xaxis_3/180;
%             subplot(4,1,2);
%             plot(xaxis_4,stateList(vectToAnalyze(i)).finalstate);
%             axis([0 90 -1 3]);
%             dummystring = sprintf('OldVersion');
%             title(dummystring);
            %%%maybe set color, etc.
            
            
            xaxis_5 = 1:1:length(expStates(vectToAnalyze(i)).states);
            xaxis_6 = xaxis_5/180;
            subplot(4,1,3);
            plot(xaxis_6,expStates(vectToAnalyze(i)).states);
            axis([0 90 -1 3]);
            dummystring = sprintf('HMM Calls');
            title(dummystring);
            %%%maybe set color, etc.
            
            
            
            
        
       % [filepath,fileprefix,extension,version] = fileparts(finalTracks(i).Name);
       % display(fileprefix)

        %fullName = sprintf('%s_%d',fileprefix,(vectToAnalyze(i)));
        %save_figure(1,'',fullName,'states');
        if(i<numTracks)
            pause;
        end
    end
end