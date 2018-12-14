function [DwSpeedTest DwAngSpeedTest RoSpeedTest RoAngSpeedTest p_chi_Dw p_chi_Ro st_checkDw st_checkRo AllIndivData_Dw AllIndivData_Ro AllChOPHits FullControlChOPHits AllChOPInfo_forBinnedData] = showChOPHits_CopperRing_comparePoolsToN2_useN2HMM_1minSurround(n2_folders,N2_stimulusfile,exp_folders,exp_stimulusfile,stimtoIncl,C128SFlag)
    FullControlChOPHits = [];
    AllChOPHits = [];
    AllChOPInfo_forBinnedData = [];

    %%%%% Make exp folders and stimfiles into Cell arrays, then go through
    %%%%% them and concat the ChOP hits together

    
    

    
    


    
    for(i=1:(length(n2_folders)))
        
        N2_stimulus = load(N2_stimulusfile{i});
        
        if(stimtoIncl==0)
        stimtoIncl_N2 = 1:1:length(N2_stimulus(:,1));
        end
        
        AllChOPHitsTemp = [];
        [AllChOPHitsTemp NumberofFOI estTR estE] = summarizeChOPdata_Copper_collectHMM_1minSurround(n2_folders{i},N2_stimulusfile{i},C128SFlag,stimtoIncl_N2);
        FullControlChOPHits = [FullControlChOPHits; AllChOPHitsTemp];
    end
      
    


    for(i=1:(length(exp_folders)))
        
        exp_stimulus = load(exp_stimulusfile{i});
    
        if(stimtoIncl==0)
            %stimtoIncl_N2 = 1:1:length(N2_stimulus(:,1));
            stimtoIncl_exp = 1:1:length(exp_stimulus(:,1));
        end
  
        AllChOPHitsTemp = [];
        AllChOPInfo_forBinnedDataTemp = [];
        [AllChOPHitsTemp AllChOPInfo_forBinnedDataTemp NumberofFOI] = summarizeChOPdata_Copper_useHMM_1minSurround(exp_folders{i},exp_stimulusfile{i},C128SFlag,stimtoIncl_exp,estTR,estE);
        AllChOPHits = [AllChOPHits; AllChOPHitsTemp];
        AllChOPInfo_forBinnedData = [AllChOPInfo_forBinnedData; AllChOPInfo_forBinnedDataTemp];
    end
    
    
    
    
    % ADD these variables above: ControlChOPHits FullControlChOPHits ?
    hitsToIncl = [];
    lengthofStimFrames = ((N2_stimulus(stimtoIncl_N2(1),2)-N2_stimulus(stimtoIncl_N2(1),1)) * 3)/3; % in seconds
    lengthofGreenFrames = ((N2_stimulus(stimtoIncl_N2(1)+1,2)-N2_stimulus(stimtoIncl_N2(1)+1,1)) * 3)/3; % in seconds
    
    
    %%%%%%%% Uncomment this if you only want to view certain stimuli
%     for (i=1:length(AllChOPHits(:,1)))
%         flag=0;
%         for (j=1:length(stimtoIncl))
%             if(AllChOPHits(i,2)==stimtoIncl(j))
%                 flag=1;
%             end
%             
%         end
%         if(flag==1)
%                 hitsToIncl = [hitsToIncl i];
%         end
%     end
%         
%     AllChOPHits = AllChOPHits(hitsToIncl,:);
   
    


%%%%%Get the data for states that start in a dwell state
    DwellStartIndices = find(AllChOPHits(:,3)==1);
    AllChOPHitsDw = AllChOPHits(DwellStartIndices,:);
    AllChOPInfo_forBinnedData_Dw = AllChOPInfo_forBinnedData(DwellStartIndices,:);
    AllIndivData_Dw = gatherBinnedDataChOP(AllChOPHitsDw,AllChOPInfo_forBinnedData_Dw);
    
%    ControlChOPHitsDw = ControlChOPHits(DwellStartIndices,:);
    FullCntrlDwellStartIndices = find(FullControlChOPHits(:,3)==1);
    FullControlChOPHitsDw = FullControlChOPHits(FullCntrlDwellStartIndices,:);
    
    for(i=1:NumberofFOI)
        DwSpeed(i) = nanmean(AllChOPHitsDw(:,i+4));
        
        DwAngSpeed(i) = nanmean(abs(AllChOPHitsDw(:,i+(NumberofFOI+4))));
        NumDw = length(find(AllChOPHitsDw(:,i+((2*NumberofFOI)+4))==1));
        NumRo = length(find(AllChOPHitsDw(:,i+((2*NumberofFOI)+4))==2));
        NumRo_ForChi(i) = NumRo;
        NumTotal = NumDw+NumRo;
        DwStates(i) = NumRo/NumTotal;
   %     ControlDwSpeed(i) = nanmean(ControlChOPHitsDw(:,i+4));
    %    ControlDwAngSpeed(i) = nanmean(abs(ControlChOPHitsDw(:,i+(NumberofFOI+4))));
     %   ControlDwStates(i) = nanmean(ControlChOPHitsDw(:,i+((2*NumberofFOI)+4)));
        FullControlDwSpeed(i) = nanmean(FullControlChOPHitsDw(:,i+4));
        FullControlDwAngSpeed(i) = nanmean(abs(FullControlChOPHitsDw(:,i+(NumberofFOI+4))));
        FullControlNumDw = length(find(FullControlChOPHitsDw(:,i+((2*NumberofFOI)+4))==1));
        FullControlNumRo = length(find(FullControlChOPHitsDw(:,i+((2*NumberofFOI)+4))==2));
        FullControlNumTotal = FullControlNumDw+FullControlNumRo;
        FullControlDwStates(i) = FullControlNumRo/FullControlNumTotal;
        %DwRatio(i) = DwSpeed(i)/DwAngSpeed(i);
    end
    
    %%%%%%%%%  Do 5s binning on FullControlRo, and NumRo
    
    for(i=21:43)
        StartInd = (i*3*3)-8;
        
        StopInd = (i*3*3);
        
        FullCon_NumRo_ForChi(i-20) = nanmean(FullControlDwStates(StartInd:StopInd));
        
        Observed_Dw(i-20) = nanmean(NumRo_ForChi(StartInd:StopInd));
        
    end
    
    Expected_Dw = FullCon_NumRo_ForChi*NumTotal;
    bins = 0:22;
    [h,p_chi_Dw,st_checkDw] = chi2gof(bins,'ctrs',bins,'frequency',Observed_Dw,'expected',Expected_Dw,'emin',0);
        
        
    
    
    
        DwSpeedMatrixTemp = AllChOPHits(DwellStartIndices,5:(NumberofFOI+4));
    DwAngSpeedMatrixTemp = abs(AllChOPHits(DwellStartIndices,(NumberofFOI+5):((2*NumberofFOI)+4)));
    DwStateMatrixTemp = AllChOPHits(DwellStartIndices,((2*NumberofFOI)+5):((3*NumberofFOI)+4));
    
   % ControlDwSpeedMatrixTemp = ControlChOPHits(DwellStartIndices,5:(NumberofFOI+4));
    %ControlDwAngSpeedMatrixTemp = abs(ControlChOPHits(DwellStartIndices,(NumberofFOI+5):((2*NumberofFOI)+4)));
    %ControlDwStateMatrixTemp = ControlChOPHits(DwellStartIndices,((2*NumberofFOI)+5):((3*NumberofFOI)+4));
    
    FullControlDwSpeedMatrixTemp = FullControlChOPHits(FullCntrlDwellStartIndices,5:(NumberofFOI+4));
    FullControlDwAngSpeedMatrixTemp = abs(FullControlChOPHits(FullCntrlDwellStartIndices,(NumberofFOI+5):((2*NumberofFOI)+4)));
    FullControlDwStateMatrixTemp = FullControlChOPHits(FullCntrlDwellStartIndices,((2*NumberofFOI)+5):((3*NumberofFOI)+4));
    
    
    for (i=1:length(DwStateMatrixTemp(1,:)))
        numbRoam = length(find(DwStateMatrixTemp(:,i)==2));
        numbDwell = length(find(DwStateMatrixTemp(:,i)==1));
        totalCalls = numbRoam + numbDwell;
        DwFractRoaming(i) = numbRoam/totalCalls;
    end
    
%%%%%Smoothen by 1sec

    for (i=1:(NumberofFOI/3))
        for(j=1:length(DwellStartIndices))
            DwSpeedMatrixTemp2(j,i) = mean(DwSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            DwAngSpeedMatrixTemp2(j,i) = mean(DwAngSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            DwStateMatrixTemp2(j,i) = round(mean(DwStateMatrixTemp(j,((i*3)-2):(i*3))));
        %    ControlDwSpeedMatrixTemp2(j,i) = mean(ControlDwSpeedMatrixTemp(j,((i*3)-2):(i*3)));
          %  ControlDwAngSpeedMatrixTemp2(j,i) = mean(ControlDwAngSpeedMatrixTemp(j,((i*3)-2):(i*3)));
        %    ControlDwStateMatrixTemp2(j,i) = round(mean(ControlDwStateMatrixTemp(j,((i*3)-2):(i*3))));
            
        end
    end
    
    for(i=1:NumberofFOI)
        DwSpeedError(i) = (nanstd(AllChOPHitsDw(:,i+4)))/(sqrt(length(DwellStartIndices)));
        DwAngSpeedError(i) = (nanstd(abs(AllChOPHitsDw(:,i+(NumberofFOI+4)))))/(sqrt(length(DwellStartIndices)));
        FullControlDwSpeedError(i) = (nanstd(FullControlChOPHitsDw(:,i+4)))/(sqrt(length(FullCntrlDwellStartIndices)));
        FullControlDwAngSpeedError(i) = (nanstd(abs(FullControlChOPHitsDw(:,i+(NumberofFOI+4)))))/(sqrt(length(FullCntrlDwellStartIndices)));
      %  ControlDwSpeedError(i) = (nanstd(ControlChOPHitsDw(:,i+4)))/(sqrt(length(DwellStartIndices)));
     %   ControlDwAngSpeedError(i) = (nanstd(abs(ControlChOPHitsDw(:,i+(NumberofFOI+4)))))/(sqrt(length(DwellStartIndices)));
    end
    
    for(i=1:length(DwellStartIndices))
        DwSpeedDuringChOP(i) = nanmean(AllChOPHitsDw(i,184:364));
        DwAngSpeedDuringChOP(i) = nanmean(abs(AllChOPHitsDw(i,(184+NumberofFOI):(364+NumberofFOI))));
    end
    
    for(i=1:length(FullCntrlDwellStartIndices))
        FullControlDwSpeedDuringChOP(i) = nanmean(FullControlChOPHitsDw(i,184:364));
        FullControlDwAngSpeedDuringChOP(i) = nanmean(abs(FullControlChOPHitsDw(i,(184+NumberofFOI):(364+NumberofFOI))));
    end
    
    [h,DwSpeedTest,ci] = ttest2(DwSpeedDuringChOP,FullControlDwSpeedDuringChOP);
    [h,DwAngSpeedTest,ci] = ttest2(DwAngSpeedDuringChOP,FullControlDwAngSpeedDuringChOP);
    
    
    
    for (i=1:length(DwellStartIndices))
        avgspeedpostled(i) = nanmean(DwSpeedMatrixTemp2(i,(60+lengthofStimFrames):(60+lengthofStimFrames+60)));
    end
    
    %display(avgspeedpostled)
    [B, IX] = sort(avgspeedpostled)
    for(i=1:length(DwellStartIndices))
        indexhere = find(avgspeedpostled==B(i));
        
        DwSpeedMatrix(i,1:round(NumberofFOI/3)) = DwSpeedMatrixTemp2(indexhere,1:round(NumberofFOI/3));
        DwAngSpeedMatrix(i,1:round(NumberofFOI/3)) = DwAngSpeedMatrixTemp2(indexhere,1:round(NumberofFOI/3));
        DwStateMatrix(i,1:round(NumberofFOI/3)) = DwStateMatrixTemp2(indexhere,1:round(NumberofFOI/3));
    end

    %%%%%%Smoothen by 10secs
    for (i=1:(NumberofFOI/30))
        for(j=1:length(DwellStartIndices))
            DwSpeedMatrixTemp3(j,i) = mean(DwSpeedMatrixTemp(j,((i*30)-29):(i*30)));
            DwAngSpeedMatrixTemp3(j,i) = mean(DwAngSpeedMatrixTemp(j,((i*30)-29):(i*30)));
            DwStateMatrixTemp3(j,i) = round(mean(DwStateMatrixTemp(j,((i*30)-29):(i*30))));
            DwFractRoamingTemp3(i) = mean(DwFractRoaming(((i*30)-29):(i*30)));
            
         %   ControlDwSpeedMatrixTemp3(j,i) = mean(ControlDwSpeedMatrixTemp(j,((i*30)-29):(i*30)));
        %    ControlDwAngSpeedMatrixTemp3(j,i) = mean(ControlDwAngSpeedMatrixTemp(j,((i*30)-29):(i*30)));
            

            
        end
%        display(FullCntrlDwellStartIndices)
        for(j=1:length(FullCntrlDwellStartIndices))
            
            FullControlDwSpeedMatrixTemp3(j,i) = mean(FullControlDwSpeedMatrixTemp(j,((i*30)-29):(i*30)));
            FullControlDwAngSpeedMatrixTemp3(j,i) = mean(FullControlDwAngSpeedMatrixTemp(j,((i*30)-29):(i*30)));
        end
    
    end
    
        %%%%%%Smoothen by 3secs
    for (i=1:(NumberofFOI/9))
        for(j=1:length(DwellStartIndices))
            DwSpeedMatrixTemp3_3sec(j,i) = mean(DwSpeedMatrixTemp(j,((i*9)-8):(i*9)));
            DwAngSpeedMatrixTemp3_3sec(j,i) = mean(DwAngSpeedMatrixTemp(j,((i*9)-8):(i*9)));
            DwStateMatrixTemp3_3sec(j,i) = round(mean(DwStateMatrixTemp(j,((i*9)-8):(i*9))));
            DwFractRoamingTemp3_3sec(i) = mean(DwFractRoaming(((i*9)-8):(i*9)));
            
         %   ControlDwSpeedMatrixTemp3(j,i) = mean(ControlDwSpeedMatrixTemp(j,((i*30)-29):(i*30)));
        %    ControlDwAngSpeedMatrixTemp3(j,i) = mean(ControlDwAngSpeedMatrixTemp(j,((i*30)-29):(i*30)));
            

            
        end
%        display(FullCntrlDwellStartIndices)
        for(j=1:length(FullCntrlDwellStartIndices))
            
            FullControlDwSpeedMatrixTemp3_3sec(j,i) = mean(FullControlDwSpeedMatrixTemp(j,((i*9)-8):(i*9)));
            FullControlDwAngSpeedMatrixTemp3_3sec(j,i) = mean(FullControlDwAngSpeedMatrixTemp(j,((i*9)-8):(i*9)));
        end
    
    end
                
    
    for(h=1:length(DwSpeedMatrixTemp3(1,:)))
        RealSpeedData = DwSpeedMatrixTemp3(:,h);
        %TestAvgSpeed(h) = nanmean(RealSpeedData);
        ControlSpeedData = FullControlDwSpeedMatrixTemp3(:,h);
        %TestControlSpeed(h) = nanmean(ControlSpeedData);
        RealAngSpeedData = DwAngSpeedMatrixTemp3(:,h);
        ControlAngSpeedData = FullControlDwAngSpeedMatrixTemp3(:,h);
        
       [SpeedTests(h),p,ci] = ttest2(RealSpeedData,ControlSpeedData,0.0014,[],'unequal');
        [AngSpeedTests(h),p,ci] = ttest2(RealAngSpeedData,ControlAngSpeedData,0.0014,[],'unequal');

    end
    
    
    
    for(i=1:NumberofFOI/30)
        DwSpeedError3(i) = (nanstd(DwSpeedMatrixTemp3(:,i)))/(sqrt(length(DwellStartIndices)));
        DwAngSpeedError3(i) = (nanstd(DwAngSpeedMatrixTemp3(:,i)))/(sqrt(length(DwellStartIndices)));
        FullControlDwSpeedError3(i) = (nanstd(FullControlDwSpeedMatrixTemp3(:,i)))/(sqrt(length(FullCntrlDwellStartIndices)));
        FullControlDwAngSpeedError3(i) = (nanstd(FullControlDwAngSpeedMatrixTemp3(:,i)))/(sqrt(length(FullCntrlDwellStartIndices)));
        
        
        
        DwFractRoamingError(i) = 0;
    end
    
    
    for(i=1:NumberofFOI/30)
        DwSpeedAve(i) = nanmean(DwSpeedMatrixTemp3(:,i));
        DwAngSpeedAve(i) = nanmean(DwAngSpeedMatrixTemp3(:,i));
        FullControlDwSpeedAve(i) = nanmean(FullControlDwSpeedMatrixTemp3(:,i));
        FullControlDwAngSpeedAve(i) = nanmean(FullControlDwAngSpeedMatrixTemp3(:,i));
    end
    
    
    
    for(i=1:NumberofFOI/9)
        DwSpeedError3_3sec(i) = (nanstd(DwSpeedMatrixTemp3_3sec(:,i)))/(sqrt(length(DwellStartIndices)));
        DwAngSpeedError3_3sec(i) = (nanstd(DwAngSpeedMatrixTemp3_3sec(:,i)))/(sqrt(length(DwellStartIndices)));
        FullControlDwSpeedError3_3sec(i) = (nanstd(FullControlDwSpeedMatrixTemp3_3sec(:,i)))/(sqrt(length(FullCntrlDwellStartIndices)));
        FullControlDwAngSpeedError3_sec(i) = (nanstd(FullControlDwAngSpeedMatrixTemp3_3sec(:,i)))/(sqrt(length(FullCntrlDwellStartIndices)));
        
        
        
        DwFractRoamingError(i) = 0;
    end
    for(i=1:NumberofFOI/9)
        DwSpeedAve_3sec(i) = nanmean(DwSpeedMatrixTemp3_3sec(:,i));
        DwAngSpeedAve_3sec(i) = nanmean(DwAngSpeedMatrixTemp3_3sec(:,i));
        FullControlDwSpeedAve_3sec(i) = nanmean(FullControlDwSpeedMatrixTemp3_3sec(:,i));
        FullControlDwAngSpeedAve_3sec(i) = nanmean(FullControlDwAngSpeedMatrixTemp3_3sec(:,i));
    end
    
    
    
    subplot(6,2,1);
    imagesc(DwStateMatrix)
    set(gca,'Xtick',[0 60 120 180 240],'XTickLabel',{'-60', '0', '60', '120' '180'});
    xlabel('seconds')
    subplot(6,2,3);
    if(C128SFlag==1)
             x_10 = [12 (12+(lengthofStimFrames/10)) 1 1 0];
             y_10 = [(12+(lengthofStimFrames/10)) (12+((lengthofStimFrames+lengthofGreenFrames)/10)) 2 1 0];
         else
             x_10 = [12 (12+(lengthofStimFrames/10)) 1 1 0];
    end
    
    

    axis([0 (NumberofFOI/3) 0 1]);
    x = [60 (60+lengthofStimFrames) 1 1 0];
    %stimulusShade(x,0,1,[0 0 1])
%     if(C128SFlag==1)
%         stimulusShade(y_10,0,1,[0 0.95 0]); hold on;
%     end
    %hold on; errorshade((1:NumberofFOI)/3,FullControlupper,FullControllower,[0.95 0.95 0.95]);
    
    hold on; area((1:NumberofFOI)/3,DwStates,'FaceColor',[1 .2 .051]);
    set(gca,'Color','b');
    hold on; plot((1:NumberofFOI)/3,FullControlDwStates,'LineWidth',2,'color',[.6 .6 .6]);
    set(gca,'Xtick',[0 60 120 180 240],'XTickLabel',{'-60', '0', '60', '120' '180'});
    %hold on; errorshade((1:NumberofFOI)/3,upper,lower,[0.8 0.8 0.8]);
    
    %hold on; errorbar_bargraph(1:(length(DwFractRoamingTemp3)),DwFractRoamingTemp3,DwFractRoamingError);
    subplot(6,2,5);
    clims = [0 0.15];
    imagesc(DwSpeedMatrix,clims);
    set(gca,'Xtick',[0 60 120 180 240],'XTickLabel',{'-60', '0', '60', '120' '180'});
    xlabel('seconds')

    
    subplot(6,2,7);
    
    ymaxest = max(DwSpeed);
    ymaxest = ymaxest*100;
    ymaxest = ymaxest+2;
    ymax = ceil(ymaxest)/100;
    axis([0 (NumberofFOI/3) 0 ymax]);
    x = [60 (60+lengthofStimFrames) 1 1 0];
    stimulusShade(x,0,0.3,[0.678 0.922 1]); hold on;
%     if(C128SFlag==1)
%         stimulusShade(y_10,0,0.3,[0 0.95 0]); hold on;
%     end

     upper = DwSpeedAve_3sec+DwSpeedError3_3sec;
     lower = DwSpeedAve_3sec-DwSpeedError3_3sec;
     

     
     FullControlupper = FullControlDwSpeedAve_3sec+FullControlDwSpeedError3_3sec;
     FullControllower = FullControlDwSpeedAve_3sec-FullControlDwSpeedError3_3sec;
     
     hold on; errorshade((1:NumberofFOI/9)*3,FullControlupper,FullControllower,[0.95 0.95 0.95]);
     hold on; plot((1:NumberofFOI/9)*3,FullControlDwSpeedAve_3sec,'LineWidth',2,'color',[.6 .6 .6]);
     
     hold on; errorshade((1:NumberofFOI/9)*3,upper,lower,[0.8 0.8 0.8]);
     hold on; plot((1:NumberofFOI/9)*3,DwSpeedAve_3sec,'LineWidth',2,'color','black');
     
     hold on; scatter(AllIndivData_Dw(:,1),AllIndivData_Dw(:,2),'k','o','filled','SizeData',2);

    %hold on; errorbar(1:(length(DwSpeedAve)),FullControlDwSpeedAve,FullControlDwSpeedError3,'k','LineWidth',2);
%     statsign = find(SpeedTests==1);
%      for(k=1:length(statsign))
%          text(statsign(k),0.08,'*');
%      end
    xlabel('seconds')
    set(gca,'Xtick',[0 60 120 180 240],'XTickLabel',{'-60', '0', '60', '120' '180'});


    subplot(6,2,9);
    clims2 = [0 180];
    imagesc(DwAngSpeedMatrix,clims2);
    set(gca,'Xtick',[0 60 120 180 240],'XTickLabel',{'-60', '0', '60', '120' '180'});
    set(gca,'CLim',[0 20]);
    xlabel('seconds')
    
    %%%%%%%%%Show at 1sec resolution
%     subplot(6,2,9);
%     axis([0 (NumberofFOI/3) 0 100]);
%       if(C128SFlag==1)
%          x = [120 (120+lengthofStimFrames) 1 1 0];
%          y = [(120+lengthofStimFrames) (120+lengthofStimFrames+lengthofGreenFrames) 2 1 0];
%      else
%          x = [120 (120+lengthofStimFrames) 1 1 0];
%      end
%           
%     stimulusShade(x,0,100,[0 0 1]); hold on;
%     if(C128SFlag==1)
%         stimulusShade(y,0,100); hold on;
%     end
%     hold on; errorshade((1:NumberofFOI)/3,DwAngSpeed+DwAngSpeedError,DwAngSpeed-DwAngSpeedError,[0.6 0.6 0.6]);
%     hold on; plot((1:NumberofFOI)/3,DwAngSpeed,'LineWidth',1);
    
    %%%%%%Show at 10sec resolution
    subplot(6,2,11);
    
    
    axis([0 (NumberofFOI/3) 0 100]);
    stimulusShade(x,0,100,[0.678 0.922 1]); hold on;
%     if(C128SFlag==1)
%         stimulusShade(y_10,0,100,[0 0.95 0]); hold on;
%     end



     
     hold on; errorshade((1:NumberofFOI/9)*3,FullControlDwAngSpeedAve_3sec+FullControlDwAngSpeedError3_sec,FullControlDwAngSpeedAve_3sec-FullControlDwAngSpeedError3_sec,[0.95 0.95 0.95]);
     hold on; plot((1:NumberofFOI/9)*3,FullControlDwAngSpeedAve_3sec,'LineWidth',2,'color',[.6 .6 .6]);
     
     hold on; errorshade((1:NumberofFOI/9)*3,DwAngSpeedAve_3sec+DwAngSpeedError3_3sec,DwAngSpeedAve_3sec-DwAngSpeedError3_3sec,[0.8 0.8 0.8]);
     hold on; plot((1:NumberofFOI/9)*3,DwAngSpeedAve_3sec,'LineWidth',2,'color','black');
     hold on; scatter(AllIndivData_Dw(:,1),AllIndivData_Dw(:,3),'k','o','filled','SizeData',2);
    set(gca,'Xtick',[0 60 120 180 240],'XTickLabel',{'-60', '0', '60', '120' '180'});
    %hold on; errorbar_bargraph(1:(length(DwAngSpeedAve)),DwAngSpeedAve,DwAngSpeedError3);
    %hold on; errorbar(1:(length(DwAngSpeedAve)),FullControlDwAngSpeedAve,FullControlDwAngSpeedError3,'k','LineWidth',2);
%     statsign = [];
%      statsign = find(AngSpeedTests==1);
%      for(k=1:length(statsign))
%          text(statsign(k),70,'*');
%      end
     
    


%%%%%Get the data for states that start in a roam state
    RoamStartIndices = find(AllChOPHits(:,3)==2);
    AllChOPHitsRo = AllChOPHits(RoamStartIndices,:);
    AllChOPInfo_forBinnedData_Ro = AllChOPInfo_forBinnedData(RoamStartIndices,:);
    AllIndivData_Ro = gatherBinnedDataChOP(AllChOPHitsRo,AllChOPInfo_forBinnedData_Ro);
 %   ControlChOPHitsRo = ControlChOPHits(RoamStartIndices,:);
    
    FullCntrlRoamStartIndices = find(FullControlChOPHits(:,3)==2);
    FullControlChOPHitsRo = FullControlChOPHits(FullCntrlRoamStartIndices,:);
    
    
    for(i=1:NumberofFOI)
        RoSpeed(i) = nanmean(AllChOPHitsRo(:,i+4));
        RoAngSpeed(i) = nanmean(abs(AllChOPHitsRo(:,i+(NumberofFOI+4))));
        NumDw = length(find(AllChOPHitsRo(:,i+((2*NumberofFOI)+4))==1));
        NumRo = length(find(AllChOPHitsRo(:,i+((2*NumberofFOI)+4))==2));
        NumRo_ForChi(i) = NumRo;
        NumTotal = NumDw+NumRo;
        RoStates(i) = NumRo/NumTotal;
        FullControlRoSpeed(i) = nanmean(FullControlChOPHitsRo(:,i+4));
        FullControlRoAngSpeed(i) = nanmean(abs(FullControlChOPHitsRo(:,i+(NumberofFOI+4))));       
        FullControlNumDw = length(find(FullControlChOPHitsRo(:,i+((2*NumberofFOI)+4))==1));
        FullControlNumRo = length(find(FullControlChOPHitsRo(:,i+((2*NumberofFOI)+4))==2));
        FullControlNumTotal = FullControlNumDw+FullControlNumRo;
        FullControlRoStates(i) = FullControlNumRo/FullControlNumTotal;
        
   %     ControlRoSpeed(i) = nanmean(ControlChOPHitsRo(:,i+4));
   %     ControlRoAngSpeed(i) = nanmean(abs(ControlChOPHitsRo(:,i+(NumberofFOI+4))));
   %    ControlRoStates(i) = nanmean(ControlChOPHitsRo(:,i+((2*NumberofFOI)+4)));
        %RoRatio(i) = RoSpeed(i)/RoAngSpeed(i);
    end
    
    
        %%%%%%%%%  Do 10s binning on FullControlRo, and NumRo
    
    for(i=21:43)
        StartInd = (i*3*3)-8;
        StopInd = (i*3*3);
        FullCon_NumRo_ForChi(i-20) = nanmean(FullControlRoStates(StartInd:StopInd));
        Observed_Ro(i-20) = nanmean(NumRo_ForChi(StartInd:StopInd));
    end
    
    Expected_Ro = FullCon_NumRo_ForChi*NumTotal;
    bins = 0:22;
    [h,p_chi_Ro,st_checkRo] = chi2gof(bins,'ctrs',bins,'frequency',Observed_Ro,'expected',Expected_Ro,'emin',0);
    
    
    
        
    for(i=1:length(RoamStartIndices))
        RoSpeedDuringChOP(i) = nanmean(AllChOPHitsRo(i,184:364));
        RoAngSpeedDuringChOP(i) = nanmean(abs(AllChOPHitsRo(i,(184+NumberofFOI):(364+NumberofFOI))));
    end
    
    for(i=1:length(FullCntrlRoamStartIndices))
        FullControlRoSpeedDuringChOP(i) = nanmean(FullControlChOPHitsRo(i,184:364));
        FullControlRoAngSpeedDuringChOP(i) = nanmean(abs(FullControlChOPHitsRo(i,(184+NumberofFOI):(364+NumberofFOI))));
    end
    RoSpeedTest = [];
    [h,RoSpeedTest,ci] = ttest2(RoSpeedDuringChOP,FullControlRoSpeedDuringChOP);
    RoAngSpeedTest = [];
    [h,RoAngSpeedTest,ci] = ttest2(RoAngSpeedDuringChOP,FullControlRoAngSpeedDuringChOP);
    
    
    
    RoSpeedMatrixTemp = AllChOPHits(RoamStartIndices,5:(NumberofFOI+4));
    RoAngSpeedMatrixTemp = abs(AllChOPHits(RoamStartIndices,(NumberofFOI+5):((2*NumberofFOI)+4)));
    RoStateMatrixTemp = AllChOPHits(RoamStartIndices,((2*NumberofFOI)+5):((3*NumberofFOI)+4));
    
%    ControlRoSpeedMatrixTemp = ControlChOPHits(RoamStartIndices,5:(NumberofFOI+4));
 %   ControlRoAngSpeedMatrixTemp = abs(ControlChOPHits(RoamStartIndices,(NumberofFOI+5):((2*NumberofFOI)+4)));
 %   ControlRoStateMatrixTemp = ControlChOPHits(RoamStartIndices,((2*NumberofFOI)+5):((3*NumberofFOI)+4));
    
    FullControlRoSpeedMatrixTemp = FullControlChOPHits(FullCntrlRoamStartIndices,5:(NumberofFOI+4));
    FullControlRoAngSpeedMatrixTemp = abs(FullControlChOPHits(FullCntrlRoamStartIndices,(NumberofFOI+5):((2*NumberofFOI)+4)));
    FullControlRoStateMatrixTemp = FullControlChOPHits(FullCntrlRoamStartIndices,((2*NumberofFOI)+5):((3*NumberofFOI)+4));
    
    
    for (i=1:length(RoStateMatrixTemp(1,:)))
        numbRoam = length(find(RoStateMatrixTemp(:,i)==2));
        numbDwell = length(find(RoStateMatrixTemp(:,i)==1));
        totalCalls = numbRoam + numbDwell;
        RoFractRoaming(i) = numbRoam/totalCalls;
    end
    
    
    RoSpeedMatrix = [];
    RoAngSpeedMatrix = [];
    RoStateMatrix = [];
    
    for (i=1:(NumberofFOI/3))
        for(j=1:length(RoamStartIndices))
            RoSpeedMatrixTemp2(j,i) = mean(RoSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            RoAngSpeedMatrixTemp2(j,i) = mean(RoAngSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            RoStateMatrixTemp2(j,i) = round(mean(RoStateMatrixTemp(j,((i*3)-2):(i*3))));
        end
    end
    
    avgspeedpostled2 = [];
    for (i=1:length(RoamStartIndices))
        avgspeedpostled2(i) = nanmean(RoSpeedMatrixTemp2(i,(60+lengthofStimFrames):(60+lengthofStimFrames+60)));
    end
    [B2, IX2] = sort(avgspeedpostled2)
    for(i=1:length(RoamStartIndices))
        indexhere = find(avgspeedpostled2==B2(i));
        RoSpeedMatrix(i,1:round(NumberofFOI/3)) = RoSpeedMatrixTemp2(indexhere,1:round(NumberofFOI/3));
        RoAngSpeedMatrix(i,1:round(NumberofFOI/3)) = RoAngSpeedMatrixTemp2(indexhere,1:round(NumberofFOI/3));
        RoStateMatrix(i,1:round(NumberofFOI/3)) = RoStateMatrixTemp2(indexhere,1:round(NumberofFOI/3));
    end
    
    for(i=1:NumberofFOI)
        RoSpeedError(i) = (nanstd(AllChOPHitsRo(:,i+4)))/(sqrt(length(RoamStartIndices)));
        RoAngSpeedError(i) = (nanstd(abs(AllChOPHitsRo(:,i+(NumberofFOI+4)))))/(sqrt(length(RoamStartIndices)));
        FullControlRoSpeedError(i) = (nanstd(FullControlChOPHitsRo(:,i+4)))/(sqrt(length(FullCntrlRoamStartIndices)));
        FullControlRoAngSpeedError(i) = (nanstd(abs(FullControlChOPHitsRo(:,i+(NumberofFOI+4)))))/(sqrt(length(FullCntrlRoamStartIndices)));
        
    end
    
  %%%%%%Smoothen by 10secs
    for (i=1:(NumberofFOI/30))
        for(j=1:length(RoamStartIndices))
            RoSpeedMatrixTemp3(j,i) = mean(RoSpeedMatrixTemp(j,((i*30)-29):(i*30)));
            RoAngSpeedMatrixTemp3(j,i) = mean(RoAngSpeedMatrixTemp(j,((i*30)-29):(i*30)));
            RoStateMatrixTemp3(j,i) = round(mean(RoStateMatrixTemp(j,((i*30)-29):(i*30))));
            RoFractRoamingTemp3(i) = mean(RoFractRoaming(((i*30)-29):(i*30)));
            
 %           ControlRoSpeedMatrixTemp3(j,i) = mean(ControlRoSpeedMatrixTemp(j,((i*30)-29):(i*30)));
 %           ControlRoAngSpeedMatrixTemp3(j,i) = mean(ControlRoAngSpeedMatrixTemp(j,((i*30)-29):(i*30)));
        end
        for(j=1:length(FullCntrlRoamStartIndices))
            FullControlRoSpeedMatrixTemp3(j,i) = mean(FullControlRoSpeedMatrixTemp(j,((i*30)-29):(i*30)));
            FullControlRoAngSpeedMatrixTemp3(j,i) = mean(FullControlRoAngSpeedMatrixTemp(j,((i*30)-29):(i*30)));
            
        end
    end
    
      %%%%%%Smoothen by 3secs
    for (i=1:(NumberofFOI/3))
        for(j=1:length(RoamStartIndices))
            RoSpeedMatrixTemp3_3sec(j,i) = mean(RoSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            RoAngSpeedMatrixTemp3_3sec(j,i) = mean(RoAngSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            RoStateMatrixTemp3_3sec(j,i) = round(mean(RoStateMatrixTemp(j,((i*3)-2):(i*3))));
            RoFractRoamingTemp3_3sec(i) = mean(RoFractRoaming(((i*3)-2):(i*3)));
            
 %           ControlRoSpeedMatrixTemp3(j,i) = mean(ControlRoSpeedMatrixTemp(j,((i*30)-29):(i*30)));
 %           ControlRoAngSpeedMatrixTemp3(j,i) = mean(ControlRoAngSpeedMatrixTemp(j,((i*30)-29):(i*30)));
        end
        for(j=1:length(FullCntrlRoamStartIndices))
            FullControlRoSpeedMatrixTemp3_3sec(j,i) = mean(FullControlRoSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            FullControlRoAngSpeedMatrixTemp3_3sec(j,i) = mean(FullControlRoAngSpeedMatrixTemp(j,((i*3)-2):(i*3)));
            
        end
    end
    
    for(i=1:NumberofFOI/30)
        RoSpeedError3(i) = (nanstd(RoSpeedMatrixTemp3(:,i)))/(sqrt(length(RoamStartIndices)));
        RoAngSpeedError3(i) = (nanstd(RoAngSpeedMatrixTemp3(:,i)))/(sqrt(length(RoamStartIndices)));
        
        FullControlRoSpeedError3(i) = (nanstd(FullControlRoSpeedMatrixTemp3(:,i)))/(sqrt(length(FullCntrlRoamStartIndices)));
        FullControlRoAngSpeedError3(i) = (nanstd(FullControlRoAngSpeedMatrixTemp3(:,i)))/(sqrt(length(FullCntrlRoamStartIndices)));
        
        RoFractRoamingError(i) = 0;
    end
    for(i=1:NumberofFOI/30)
        RoSpeedAve(i) = nanmean(RoSpeedMatrixTemp3(:,i));
        RoAngSpeedAve(i) = nanmean(RoAngSpeedMatrixTemp3(:,i));
        
        FullControlRoSpeedAve(i) = nanmean(FullControlRoSpeedMatrixTemp3(:,i));
        FullControlRoAngSpeedAve(i) = nanmean(FullControlRoAngSpeedMatrixTemp3(:,i));
    end
    
     for(i=1:NumberofFOI/3)
        RoSpeedError3_3sec(i) = (nanstd(RoSpeedMatrixTemp3_3sec(:,i)))/(sqrt(length(RoamStartIndices)));
        RoAngSpeedError3_3sec(i) = (nanstd(RoAngSpeedMatrixTemp3_3sec(:,i)))/(sqrt(length(RoamStartIndices)));
        
        FullControlRoSpeedError3_3sec(i) = (nanstd(FullControlRoSpeedMatrixTemp3_3sec(:,i)))/(sqrt(length(FullCntrlRoamStartIndices)));
        FullControlRoAngSpeedError3_3sec(i) = (nanstd(FullControlRoAngSpeedMatrixTemp3_3sec(:,i)))/(sqrt(length(FullCntrlRoamStartIndices)));
        
        RoFractRoamingError(i) = 0;
    end
    for(i=1:NumberofFOI/3)
        RoSpeedAve_3sec(i) = nanmean(RoSpeedMatrixTemp3_3sec(:,i));
        RoAngSpeedAve_3sec(i) = nanmean(RoAngSpeedMatrixTemp3_3sec(:,i));
        
        FullControlRoSpeedAve_3sec(i) = nanmean(FullControlRoSpeedMatrixTemp3_3sec(:,i));
        FullControlRoAngSpeedAve_3sec(i) = nanmean(FullControlRoAngSpeedMatrixTemp3_3sec(:,i));
    end
    
    for(h=1:length(RoSpeedMatrixTemp3(1,:)))
        RealSpeedDataRo = RoSpeedMatrixTemp3(:,h);
        %TestAvgSpeed(h) = nanmean(RealSpeedData);
        ControlSpeedDataRo = FullControlRoSpeedMatrixTemp3(:,h);
        %TestControlSpeed(h) = nanmean(ControlSpeedData);
        RealAngSpeedDataRo = RoAngSpeedMatrixTemp3(:,h);
        ControlAngSpeedDataRo = FullControlRoAngSpeedMatrixTemp3(:,h);
        
        [SpeedTestsRo(h),p,ci] = ttest2(RealSpeedDataRo,ControlSpeedDataRo,0.0014,[],'unequal');
        [AngSpeedTestsRo(h),p,ci] = ttest2(RealAngSpeedDataRo,ControlAngSpeedDataRo,0.0014,[],'unequal');

    end
    
    
    
    subplot(6,2,2);
    imagesc(RoStateMatrix);
    set(gca,'Xtick',[0 60 120 180 240],'XTickLabel',{'-60', '0', '60', '120' '180'});
    xlabel('seconds')
    subplot(6,2,4);
    if(C128SFlag==1)
             x_10 = [12 (12+(lengthofStimFrames/10)) 1 1 0];
             y_10 = [(12+(lengthofStimFrames/10)) (12+((lengthofStimFrames+lengthofGreenFrames)/10)) 2 1 0];
         else
             x_10 = [12 (12+(lengthofStimFrames/10)) 1 1 0];
    end
    
    

    axis([0 (NumberofFOI/3) 0 1]);
    x = [60 (60+lengthofStimFrames) 1 1 0];
    %stimulusShade(x,0,1,[0 0 1])
%     if(C128SFlag==1)
%         stimulusShade(y_10,0,1,[0 0.95 0]); hold on;
%     end
    %hold on; errorshade((1:NumberofFOI)/3,FullControlupper,FullControllower,[0.95 0.95 0.95]);
    hold on; area((1:NumberofFOI)/3,RoStates,'FaceColor',[1 .2 .051]);
    set(gca,'Color','b');
    hold on; plot((1:NumberofFOI)/3,FullControlRoStates,'LineWidth',2,'color',[.6 .6 .6]);
    set(gca,'Xtick',[0 60 120 180 240],'XTickLabel',{'-60', '0', '60', '120' '180'});
    %hold on; errorshade((1:NumberofFOI)/3,upper,lower,[0.8 0.8 0.8]);
    
    %hold on;
    %errorbar_bargraph(1:(length(DwFractRoamingTemp3)),DwFractRoamingTemp3,DwFractRoamingError);
    subplot(6,2,6);
    imagesc(RoSpeedMatrix,clims);
    set(gca,'Xtick',[0 60 120 180 240],'XTickLabel',{'-60', '0', '60', '120' '180'});
    xlabel('seconds')
    %%%%%%%%Showing 1sec resolution
%     subplot(6,2,6);
%     ymaxest = max(RoSpeed);
%     ymaxest = ymaxest*100;
%     ymaxest = ymaxest+2;
%     ymax = ceil(ymaxest)/100;
%     axis([0 (NumberofFOI/3) 0 ymax]);
%     stimulusShade(x,0,0.3,[0 0 1]); 
%     if(C128SFlag==1)
%         hold on; stimulusShade(y,0,0.3,[0 0.95 0]); 
%     end
%     upper = RoSpeed+RoSpeedError
%     lower = RoSpeed-RoSpeedError
%     hold on; errorshade((1:NumberofFOI)/3,upper,lower,[0.6 0.6 0.6]);
%     hold on; plot((1:NumberofFOI)/3,RoSpeed,'LineWidth',1);
%     xlabel('seconds')

%%%%%%%showing 10sec resolution
    subplot(6,2,8);
    
    ymaxest = max(RoSpeedAve_3sec);
    
    ymaxest = ymaxest*100;
    ymaxest = ymaxest+2;
    ymax = ceil(ymaxest)/100;
    axis([0 (NumberofFOI/3) 0 ymax]);
    stimulusShade(x,0,0.3,[0.678 0.922 1]); hold on;
%     if(C128SFlag==1)
%         stimulusShade(y_10,0,0.3,[0 0.95 0]); hold on;
%     end

     %upper = RoSpeed+RoSpeedError;
     %lower = RoSpeed-RoSpeedError;
     upper = RoSpeedAve_3sec+RoSpeedError3_3sec;
     lower = RoSpeedAve_3sec-RoSpeedError3_3sec;
     

     
     %FullControlupper = FullControlRoSpeed+FullControlRoSpeedError;
     %FullControllower = FullControlRoSpeed-FullControlRoSpeedError;
     FullControlupper = FullControlRoSpeedAve_3sec+FullControlRoSpeedError3_3sec;
     FullControllower = FullControlRoSpeedAve_3sec-FullControlRoSpeedError3_3sec;
     
     
     hold on; errorshade((1:NumberofFOI/3),FullControlupper,FullControllower,[0.95 0.95 0.95]);
     hold on; plot((1:NumberofFOI/3),FullControlRoSpeedAve_3sec,'LineWidth',2,'color',[.6 .6 .6]);
     
     hold on; errorshade((1:NumberofFOI/3),upper,lower,[0.8 0.8 0.8]);
     hold on; plot((1:NumberofFOI/3),RoSpeedAve_3sec,'LineWidth',2,'color','black');
    set(gca,'Xtick',[0 60 120 180 240],'XTickLabel',{'-60', '0', '60', '120' '180'});
     hold on; scatter(AllIndivData_Ro(:,1),AllIndivData_Ro(:,2),'k','o','filled','SizeData',2);


    %hold on; errorbar_bargraph(1:(length(RoSpeedAve)),RoSpeedAve,RoSpeedError3);
    %hold on; errorbar(1:(length(RoSpeedAve)),FullControlRoSpeedAve,FullControlRoSpeedError3,'k','LineWidth',2);
%      statsign = [];
%      statsign = find(SpeedTestsRo==1);
%      for(k=1:length(statsign))
%          text(statsign(k),.17,'*');
%      end

    subplot(6,2,10);
    imagesc(RoAngSpeedMatrix,clims2);
    set(gca,'Xtick',[0 60 120 180 240],'XTickLabel',{'-60', '0', '60', '120' '180'});
    set(gca,'CLim',[0 20]);
    xlabel('seconds')
    
    
    %%%%%%%%Show at 1sec resolution
%     subplot(6,2,10);
%     axis([0 (NumberofFOI/3) 0 100]);
%     stimulusShade(x,0,100,[0 0 1]); hold on;
%     if(C128SFlag==1)
%         stimulusShade(y,0,100,[0 0.95 0]); hold on;
%     end
%     hold on; errorshade((1:NumberofFOI)/3,RoAngSpeed+RoAngSpeedError,RoAngSpeed-RoAngSpeedError,[0.6 0.6 0.6]);
%     hold on; plot((1:NumberofFOI)/3,RoAngSpeed,'LineWidth',1);
%     set(1,'Name',folder);
    
    %%%%%%%%%Show at 10sec resolution
    subplot(6,2,12);
    
    
    axis([0 (NumberofFOI/3) 0 100]);
    stimulusShade(x,0,100,[0.678 0.922 1]); hold on;
    
    

     
     hold on; errorshade((1:NumberofFOI/3),FullControlRoAngSpeedAve_3sec+FullControlRoAngSpeedError3_3sec,FullControlRoAngSpeedAve_3sec-FullControlRoAngSpeedError3_3sec,[0.95 0.95 0.95]);
     hold on; plot((1:NumberofFOI/3),FullControlRoAngSpeedAve_3sec,'LineWidth',2,'color',[.6 .6 .6]);
     
          hold on; errorshade((1:NumberofFOI/3),RoAngSpeedAve_3sec+RoAngSpeedError3_3sec,RoAngSpeedAve_3sec-RoAngSpeedError3_3sec,[0.8 0.8 0.8]);
     hold on; plot((1:NumberofFOI/3),RoAngSpeedAve_3sec,'LineWidth',2,'color','black');
     hold on; scatter(AllIndivData_Ro(:,1),AllIndivData_Ro(:,3),'k','o','filled','SizeData',2);
     set(gca,'Xtick',[0 60 120 180 240],'XTickLabel',{'-60', '0', '60', '120' '180'});
    
%     if(C128SFlag==1)
%         stimulusShade(y_10,0,100,[0 0.95 0]); hold on;
%     end
    %hold on; errorbar_bargraph(1:(length(RoAngSpeedAve)),RoAngSpeedAve,RoAngSpeedError3);
    %hold on; errorbar(1:(length(RoAngSpeedAve)),FullControlRoAngSpeedAve,FullControlRoAngSpeedError3,'k','LineWidth',2);
     %statsign = [];
     %statsign = find(AngSpeedTestsRo==1);
     %for(k=1:length(statsign))
     %    text(statsign(k),40,'*');
     %end
end
