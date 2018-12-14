function showChOPHits_pooled_discordant(folder1,folder2,stimulusfile,ROImovie,stimtoIncl1,stimtoIncl2)
    AllChOPHits1 = summarizeChOPdata(folder1,stimulusfile,ROImovie);
    AllChOPHits2 = summarizeChOPdata(folder2,stimulusfile,ROImovie);
    stimulus = load(stimulusfile);
    
    hitsToIncl1 = [];
    
    if(stimtoIncl1==0)
        stimtoIncl1= 1:1:length(stimulus(:,1));
    end
    for (i=1:length(AllChOPHits1(:,1)))
        flag=0;
        for (j=1:length(stimtoIncl1))
            if(AllChOPHits1(i,2)==stimtoIncl1(j))
                flag=1;
            end
            
        end
        if(flag==1)
                hitsToIncl1 = [hitsToIncl1 i];
        end
    end
        
    AllChOPHits1 = AllChOPHits1(hitsToIncl1,:);
    
     hitsToIncl2 = [];
    
    if(stimtoIncl1==0)
        stimtoIncl2= 1:1:length(stimulus(:,1));
    end
    for (i=1:length(AllChOPHits2(:,1)))
        flag=0;
        for (j=1:length(stimtoIncl2))
            if(AllChOPHits2(i,2)==stimtoIncl2(j))
                flag=1;
            end
            
        end
        if(flag==1)
                hitsToIncl2 = [hitsToIncl2 i];
        end
    end
        
    AllChOPHits2 = AllChOPHits2(hitsToIncl2,:);
    AllChOPHits = [AllChOPHits1; AllChOPHits2];


%%%%%Get the data for states that start in a dwell state
    DwellStartIndices = find(AllChOPHits(:,3)==1);
    AllChOPHitsDw = AllChOPHits(DwellStartIndices,:);
    for(i=1:810)
        DwSpeed(i) = nanmean(AllChOPHitsDw(:,i+4));
        DwAngSpeed(i) = nanmean(abs(AllChOPHitsDw(:,i+814)));
        DwStates(i) = nanmean(AllChOPHitsDw(:,i+1624));
        %DwRatio(i) = DwSpeed(i)/DwAngSpeed(i);
    end
    
    
    DwSpeedMatrixTemp = AllChOPHits(DwellStartIndices,5:814);
    DwAngSpeedMatrixTemp = abs(AllChOPHits(DwellStartIndices,815:1624));
    DwStateMatrixTemp = AllChOPHits(DwellStartIndices,1625:2434);
    
    for (i=1:(810/3))
        for(j=1:length(DwellStartIndices))
            DwSpeedMatrixTemp2(j,i) = mean(DwSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            DwAngSpeedMatrixTemp2(j,i) = mean(DwAngSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            DwStateMatrixTemp2(j,i) = round(mean(DwStateMatrixTemp(j,((i*3)-2):(i*3))));
            
        end
    end
    
    for(i=1:810)
        DwSpeedError(i) = (nanstd(AllChOPHitsDw(:,i+4)))/(sqrt(length(DwellStartIndices)));
        DwAngSpeedError(i) = (nanstd(abs(AllChOPHitsDw(:,i+814))))/(sqrt(length(DwellStartIndices)));
    end
    
    
    
    for (i=1:length(DwellStartIndices))
        avgspeedpostled(i) = nanmean(DwSpeedMatrixTemp2(i,150:270));
    end
    
    display(avgspeedpostled)
    [B, IX] = sort(avgspeedpostled)
    for(i=1:length(DwellStartIndices))
        indexhere = find(avgspeedpostled==B(i));
        display(i)
        display(indexhere)
        display(avgspeedpostled(indexhere))
        DwSpeedMatrix(i,1:270) = DwSpeedMatrixTemp2(indexhere,1:270);
        DwAngSpeedMatrix(i,1:270) = DwAngSpeedMatrixTemp2(indexhere,1:270);
        DwStateMatrix(i,1:270) = DwStateMatrixTemp2(indexhere,1:270);
    end
    

    
    subplot(5,2,1);
    imagesc(DwStateMatrix)
    xlabel('seconds')
    subplot(5,2,3);
    clims = [0 0.15];
    imagesc(DwSpeedMatrix,clims);
    xlabel('seconds')
    subplot(5,2,5);
    x = [120 150 1 1 0];
    ymaxest = max(DwSpeed);
    ymaxest = ymaxest*100;
    ymaxest = ymaxest+2;
    ymax = ceil(ymaxest)/100;
    axis([0 (810/3) 0 ymax]);
    stimulusShade(x,0,0.3);
    upper = DwSpeed+DwSpeedError
    lower = DwSpeed-DwSpeedError
    hold on; errorshade((1:810)/3,upper,lower,[0.6 0.6 0.6]);
    hold on; plot((1:810)/3,DwSpeed,'LineWidth',1);
    xlabel('seconds')
    subplot(5,2,7);
    clims2 = [0 180];
    imagesc(DwAngSpeedMatrix,clims2)
    set(gca,'CLim',[0 20]);
    xlabel('seconds')
    subplot(5,2,9);
    axis([0 (810/3) 0 100]);
    stimulusShade(x,0,100);
    hold on; errorshade((1:810)/3,DwAngSpeed+DwAngSpeedError,DwAngSpeed-DwAngSpeedError,[0.6 0.6 0.6]);
    hold on; plot((1:810)/3,DwAngSpeed,'LineWidth',1);
    
    
    
    


%%%%%Get the data for states that start in a roam state
    RoamStartIndices = find(AllChOPHits(:,3)==2);
    AllChOPHitsRo = AllChOPHits(RoamStartIndices,:);
    for(i=1:810)
        RoSpeed(i) = nanmean(AllChOPHitsRo(:,i+4));
        RoAngSpeed(i) = nanmean(abs(AllChOPHitsRo(:,i+814)));
        RoStates(i) = nanmean(AllChOPHitsRo(:,i+1624));
        %RoRatio(i) = RoSpeed(i)/RoAngSpeed(i);
    end
    RoSpeedMatrixTemp = AllChOPHits(RoamStartIndices,5:814);
    RoAngSpeedMatrixTemp = abs(AllChOPHits(RoamStartIndices,815:1624));
    RoStateMatrixTemp = AllChOPHits(RoamStartIndices,1625:2434);
    RoSpeedMatrix = [];
    RoAngSpeedMatrix = [];
    RoStateMatrix = [];
    for (i=1:(810/3))
        for(j=1:length(RoamStartIndices))
            RoSpeedMatrixTemp2(j,i) = mean(RoSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            RoAngSpeedMatrixTemp2(j,i) = mean(RoAngSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            RoStateMatrixTemp2(j,i) = round(mean(RoStateMatrixTemp(j,((i*3)-2):(i*3))));
        end
    end
    avgspeedpostled2 = [];
    for (i=1:length(RoamStartIndices))
        avgspeedpostled2(i) = nanmean(RoSpeedMatrixTemp2(i,150:270));
    end
    [B2, IX2] = sort(avgspeedpostled2)
    for(i=1:length(RoamStartIndices))
        indexhere = find(avgspeedpostled2==B2(i));
        RoSpeedMatrix(i,1:270) = RoSpeedMatrixTemp2(indexhere,1:270);
        RoAngSpeedMatrix(i,1:270) = RoAngSpeedMatrixTemp2(indexhere,1:270);
        RoStateMatrix(i,1:270) = RoStateMatrixTemp2(indexhere,1:270);
    end
    
    for(i=1:810)
        RoSpeedError(i) = (nanstd(AllChOPHitsRo(:,i+4)))/(sqrt(length(RoamStartIndices)));
        RoAngSpeedError(i) = (nanstd(abs(AllChOPHitsRo(:,i+814))))/(sqrt(length(RoamStartIndices)));
    end
    
    subplot(5,2,2);
    imagesc(RoStateMatrix)
    xlabel('seconds')
    subplot(5,2,4);
    imagesc(RoSpeedMatrix,clims);
    xlabel('seconds')
    subplot(5,2,6);
    x = [120 150 1 1 0];
    ymaxest = max(RoSpeed);
    ymaxest = ymaxest*100;
    ymaxest = ymaxest+2;
    ymax = ceil(ymaxest)/100;
    axis([0 (810/3) 0 ymax]);
    stimulusShade(x,0,0.3);
    upper = RoSpeed+RoSpeedError
    lower = RoSpeed-RoSpeedError
    hold on; errorshade((1:810)/3,upper,lower,[0.6 0.6 0.6]);
    hold on; plot((1:810)/3,RoSpeed,'LineWidth',1);
    xlabel('seconds')
    subplot(5,2,8);
    imagesc(RoAngSpeedMatrix,clims2)
    set(gca,'CLim',[0 20]);
    xlabel('seconds')
    subplot(5,2,10);
    axis([0 (810/3) 0 100]);
    stimulusShade(x,0,100);
    hold on; errorshade((1:810)/3,RoAngSpeed+RoAngSpeedError,RoAngSpeed-RoAngSpeedError,[0.6 0.6 0.6]);
    hold on; plot((1:810)/3,RoAngSpeed,'LineWidth',1);
    set(1,'Name',folder1);
end
