function compareTwoGenotypes_HMM(folderWithBoth,Date)
    PathofFolder = sprintf('%s',folderWithBoth);
    display(PathofFolder)
    dirList = ls(PathofFolder);
    display(dirList)
    dirList = dirList(3:4,:);

   string1 = deblank(dirList(1,:)); 
    
   PathName = sprintf('%s/%s/',PathofFolder,string1);
    display(PathName)
   [dsd1 rsd1 FracDwell1 FracRoam1 TrackInfo1] = AutomatedRoamDwellAnalysis_Pool_HMM(PathName,Date,string1);
   dwellrev1 = TrackInfo1.Reversal_Info.DwellRevRate;
   roamrev1 = TrackInfo1.Reversal_Info.RoamRevRate;
   dwell_s_rev1 = TrackInfo1.Reversal_Info.Dwell_sRevRate;
   dwell_l_rev1 = TrackInfo1.Reversal_Info.Dwell_lRevRate;
   roam_s_rev1 = TrackInfo1.Reversal_Info.Roam_sRevRate;
   roam_l_rev1 = TrackInfo1.Reversal_Info.Roam_lRevRate;
   dwellspeedmean1 = TrackInfo1.Reversal_Info.dwellspeedmean;
   roamspeedmean1 = TrackInfo1.Reversal_Info.roamspeedmean;
   
   [dsd1_InclEnds rsd1_InclEnds FracDwell1_InclEnds FracRoam1_InclEnds] = AutomatedRoamDwellAnalysis_Pool_InclEnds_HMM(PathName,Date,string1);
   
   string2 = deblank(dirList(2,:)); 

   PathName = sprintf('%s/%s/',PathofFolder,string2);

   [dsd2 rsd2 FracDwell2 FracRoam2 TrackInfo2] = AutomatedRoamDwellAnalysis_Pool_HMM(PathName,Date,string2);
   dwellrev2 = TrackInfo2.Reversal_Info.DwellRevRate;
   roamrev2 = TrackInfo2.Reversal_Info.RoamRevRate;
   dwell_s_rev2 = TrackInfo2.Reversal_Info.Dwell_sRevRate;
   dwell_l_rev2 = TrackInfo2.Reversal_Info.Dwell_lRevRate;
   roam_s_rev2 = TrackInfo2.Reversal_Info.Roam_sRevRate;
   roam_l_rev2 = TrackInfo2.Reversal_Info.Roam_lRevRate;
   dwellspeedmean2 = TrackInfo2.Reversal_Info.dwellspeedmean;
   roamspeedmean2 = TrackInfo2.Reversal_Info.roamspeedmean;
   
   
   [dsd2_InclEnds rsd2_InclEnds FracDwell2_InclEnds FracRoam2_InclEnds] = AutomatedRoamDwellAnalysis_Pool_InclEnds_HMM(PathName,Date,string2);
   
   
    a = zeros(2,2);
    a(1,1:2) = [FracDwell1 FracRoam1];
    a(2,1:2) = [FracDwell2 FracRoam2];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,4,1);
    
    bar(a,'stack');
    legend('dwelling','roaming');
    ylabel('fraction of time');
    set(gca,'XTickLabel',{string1;string2});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,4,2);
    
    plotTwoHists(dsd1(1,:),dsd2(1,:),string1,string2,10);
    title('Dwell States');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(2,4,3);
    
    plotTwoHists(rsd1(1,:),rsd2(1,:),string1,string2,10);
    title('Roam States');
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,4,4);
    
    plotTwoHists(dsd1_InclEnds(1,:),dsd2_InclEnds(1,:),string1,string2,10);
    title('Dwell States, First/Last included');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(2,4,5);
    
    plotTwoHists(rsd1_InclEnds(1,:),rsd2_InclEnds(1,:),string1,string2,10);
    title('Roam States, FirstLast included');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    subplot(2,4,6);
    
    x = [1 2 3 4 5 6 7 8]
    y = [dwellrev1(1) dwellrev2(1) 0 dwell_s_rev1(1) dwell_s_rev2(1) 0 dwell_l_rev1(1) dwell_l_rev2(1)]
    yerr = [dwellrev1(2) dwellrev2(2) 0 dwell_s_rev1(2) dwell_s_rev2(2) 0 dwell_l_rev1(2) dwell_l_rev2(2)]
    errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
    title('Reversals During Dwell States');
    set(gca,'XTickLabel',{'all Revs';'';'';'sRevs';'';'';'lRevs';''});
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% 
    subplot(2,4,7);
    
    x = [1 2 3 4 5 6 7 8]
    y = [roamrev1(1) roamrev2(1) 0 roam_s_rev1(1) roam_s_rev2(1) 0 roam_l_rev1(1) roam_l_rev2(1)]
    yerr = [roamrev1(2) roamrev2(2) 0 roam_s_rev1(2) roam_s_rev2(2) 0 roam_l_rev1(2) roam_l_rev2(2)]
    errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
    title('Reversals During Roam States');
    set(gca,'XTickLabel',{'all Revs';'';'';'sRevs';'';'';'lRevs';''});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% 
    subplot(2,4,8);
    
    
    time = [0 0.333 0.666 1 1.333 1.666 2 2.333 2.666];
    if(length(roamspeedmean1>0))
            if(length(roamspeedmean2>0))
    plot(time,dwellspeedmean1,time,dwellspeedmean2,time,roamspeedmean1,time,roamspeedmean2);
            end
    end
    legend1 = sprintf('%s.Dwell',string1);
    legend2 = sprintf('%s.Dwell',string2);
    legend3 = sprintf('%s.Roam',string1);
    legend4 = sprintf('%s.Roam',string2);
    legend(legend1,legend2,legend3,legend4);
    title('Speed after Reversing');
    xlabel('time (sec)');
    ylabel('speed (mm/sec)');
    
    
    %%%%Save Figure
    CompName = sprintf('%s.%s.%s',Date,string1,string2);
    save_figure(1,'',CompName,'comparison');
end

    
    
    
    
    
    
    
    
    