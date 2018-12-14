function showChOPHits_ByStim(folder,stimulusfile,ROImovie)
    AllChOPHits = summarizeChOPdata(folder,stimulusfile,ROImovie);
    
    stimulus = load(stimulusfile);
    numStimuli = length(stimulus(:,1));
    for(l=1:numStimuli)
        hitsToIncl = [];
        AllChOPHitsForThis = [];
        for (i=1:length(AllChOPHits(:,1)))
                if(AllChOPHits(i,2)==l)
                    hitsToIncl = [hitsToIncl i];
                end

        end
    figure(l)
        %%%%%ONly proceed if there are tracks to analyze
    if(length(hitsToIncl)>0)
        
        
        
        AllChOPHitsForThis = AllChOPHits(hitsToIncl,:);


    %%%%%Get the data for states that start in a dwell state
        DwellStartIndices = find(AllChOPHitsForThis(:,3)==1);
        if(length(DwellStartIndices)>0)
        AllChOPHitsDw = AllChOPHitsForThis(DwellStartIndices,:);
        DwSpeed =[];
        DwAngSpeed = [];
        DwStates =[];
        for(i=1:810)
            DwSpeed(i) = nanmean(AllChOPHitsDw(:,i+4));
            DwAngSpeed(i) = nanmean(abs(AllChOPHitsDw(:,i+814)));
            DwStates(i) = nanmean(AllChOPHitsDw(:,i+1624));
            %DwRatio(i) = DwSpeed(i)/DwAngSpeed(i);
        end

        DwSpeedMatrixTemp = AllChOPHitsForThis(DwellStartIndices,5:814);
        DwAngSpeedMatrixTemp = abs(AllChOPHitsForThis(DwellStartIndices,815:1624));
        DwStateMatrixTemp = AllChOPHitsForThis(DwellStartIndices,1625:2434);
        DwStateMatrix = [];
        DwSpeedMatrix = [];
        DwAngSpeedMatrix = [];
        for (i=1:(810/3))
            for(j=1:length(DwellStartIndices))
                DwSpeedMatrix(j,i) = mean(DwSpeedMatrixTemp(j,((i*3)-2):(i*3)));
                DwAngSpeedMatrix(j,i) = mean(DwAngSpeedMatrixTemp(j,((i*3)-2):(i*3)));
                DwStateMatrix(j,i) = round(mean(DwStateMatrixTemp(j,((i*3)-2):(i*3))));
            end
        end
        subplot(5,2,1);
        imagesc(DwStateMatrix)
        xlabel('seconds')
        subplot(5,2,3);
        imagesc(DwSpeedMatrix);
        xlabel('seconds')
        subplot(5,2,5);
        x = [120 150 1 1 0];
        ymaxest = max(DwSpeed);
        ymaxest = ymaxest*100;
        ymaxest = ymaxest+2;
        ymax = ceil(ymaxest)/100;
        axis([0 (810/3) 0 ymax]);
        stimulusShade(x,0,0.3);
        hold on; plot((1:810)/3,DwSpeed);
        xlabel('seconds')
        subplot(5,2,7);
        imagesc(DwAngSpeedMatrix)
        set(gca,'CLim',[0 20]);
        xlabel('seconds')
        subplot(5,2,9);
        axis([0 (810/3) 0 100]);
        stimulusShade(x,0,100);
        hold on; plot((1:810)/3,DwAngSpeed);
        end





    %%%%%Get the data for states that start in a roam state
        RoamStartIndices = find(AllChOPHitsForThis(:,3)==2);
        if(length(RoamStartIndices)>0)
        AllChOPHitsRo = AllChOPHitsForThis(RoamStartIndices,:);
        RoSpeed =[];
        RoAngSpeed = [];
        RoStates =[];
        for(i=1:810)
            RoSpeed(i) = nanmean(AllChOPHitsRo(:,i+4));
            RoAngSpeed(i) = nanmean(abs(AllChOPHitsRo(:,i+814)));
            RoStates(i) = nanmean(AllChOPHitsRo(:,i+1624));
            %RoRatio(i) = RoSpeed(i)/RoAngSpeed(i);
        end
        RoSpeedMatrixTemp = AllChOPHitsForThis(RoamStartIndices,5:814);
        RoAngSpeedMatrixTemp = abs(AllChOPHitsForThis(RoamStartIndices,815:1624));
        RoStateMatrixTemp = AllChOPHitsForThis(RoamStartIndices,1625:2434);
        RoStateMatrix = [];
        RoSpeedMatrix = [];
        RoAngSpeedMatrix = [];
        for (i=1:(810/3))
            for(j=1:length(RoamStartIndices))
                RoSpeedMatrix(j,i) = mean(RoSpeedMatrixTemp(j,((i*3)-2):(i*3)));
                RoAngSpeedMatrix(j,i) = mean(RoAngSpeedMatrixTemp(j,((i*3)-2):(i*3)));
                RoStateMatrix(j,i) = round(mean(RoStateMatrixTemp(j,((i*3)-2):(i*3))));
            end
        end


        subplot(5,2,2);
        imagesc(RoStateMatrix)
        xlabel('seconds')
        subplot(5,2,4);
        imagesc(RoSpeedMatrix);
        xlabel('seconds')
        subplot(5,2,6);
        x = [120 150 1 1 0];
        ymaxest = max(RoSpeed);
        ymaxest = ymaxest*100;
        ymaxest = ymaxest+2;
        ymax = ceil(ymaxest)/100;
        axis([0 (810/3) 0 ymax]);
        stimulusShade(x,0,0.3);
        hold on; plot((1:810)/3,RoSpeed);
        xlabel('seconds')
        subplot(5,2,8);
        imagesc(RoAngSpeedMatrix)
        set(gca,'CLim',[0 20]);
        xlabel('seconds')
        subplot(5,2,10);
        axis([0 (810/3) 0 100]);
        stimulusShade(x,0,100);
        hold on; plot((1:810)/3,RoAngSpeed);
        end
        NameofChart = sprintf('%s.stimulus=%d',folder,l);
        set(1,'Name',NameofChart);
        end
    end
end
