function [dsd1_InclEnds rsd1_InclEnds dsd2_InclEnds rsd2_InclEnds] = compareTwoGenotypes_HMM_useN2HMM(folderWithBoth,Date)
    PathofFolder = sprintf('%s',folderWithBoth);
    display(PathofFolder)
    dirList = ls(PathofFolder);
    display(dirList)
    dirList = dirList(3:4,:);

   string1 = deblank(dirList(1,:)); 
    
   PathName = sprintf('%s/%s/',PathofFolder,string1);
    display(PathName)
   [dsd1 rsd1 FracDwell1 FracRoam1 TrackInfo1 N2_TR N2_E] = AutomatedRoamDwellAnalysis_Pool_HMM_collectN2HMM(PathName,Date,string1);
   dwellrev1 = TrackInfo1.Reversal_Info.DwellRevRate;
   roamrev1 = TrackInfo1.Reversal_Info.RoamRevRate;
   dwell_s_rev1 = TrackInfo1.Reversal_Info.Dwell_sRevRate;
   dwell_l_rev1 = TrackInfo1.Reversal_Info.Dwell_lRevRate;
   roam_s_rev1 = TrackInfo1.Reversal_Info.Roam_sRevRate;
   roam_l_rev1 = TrackInfo1.Reversal_Info.Roam_lRevRate;
   dwellspeedmean1 = TrackInfo1.Reversal_Info.dwellspeedmean;
   roamspeedmean1 = TrackInfo1.Reversal_Info.roamspeedmean;
   
   [dsd1_InclEnds rsd1_InclEnds FracDwell1_InclEnds FracRoam1_InclEnds N2_TR_InclEnds N2_E_InclEnds mean_dw_stab1 mean_dw_stab_err1 mean_dw_stab_vector1 mean_ro_stab1 mean_ro_stab_err1 mean_ro_stab_vector1  all_dw_speed_info all_ro_speed_info] = AutomatedRoamDwellAnalysis_Pool_InclEnds_HMM_collectN2HMM(PathName,Date,string1);
   
   StateStability1 = struct('mean_dw_stab',[],'mean_dw_stab_err',[],'mean_dw_stab_vector',[],'mean_ro_stab',[],'mean_ro_stab_err',[],'mean_ro_stab_vector',[],'all_dw_speed_info',[],'all_ro_speed_info',[]);
   StateStability1.mean_dw_stab = mean_dw_stab1;
   StateStability1.mean_dw_stab_err = mean_dw_stab_err1;
   StateStability1.mean_dw_stab_vector = mean_dw_stab_vector1;
   StateStability1.mean_ro_stab = mean_ro_stab1;
   StateStability1.mean_ro_stab_err = mean_ro_stab_err1;
   StateStability1.mean_ro_stab_vector = mean_ro_stab_vector1;
   StateStability1.all_dw_speed_info = all_dw_speed_info;
   StateStability1.all_ro_speed_info = all_ro_speed_info;
   
   TrackInfo1.State_stability = StateStability1;
   
   
   TrackInfo1.dwell_state_durations_incl_ends = dsd1_InclEnds;
   TrackInfo1.roam_state_durations_incl_ends = rsd1_InclEnds;
   
    VidName = sprintf('%s.%s',Date,string1);
    %display(VidName)
    NewFilename = sprintf('%s.TrackInfo.mat',VidName);
    %display(NewFilename)
    PathofFolderforSave = sprintf('%s',PathName);
    FullFileName = sprintf('%s/%s',PathofFolderforSave,NewFilename);
    %display(FullFileName)
    save(FullFileName,'TrackInfo1');
    
   [dsd_mean1 dsd_err1 dsd_vector1] = AverageStateDur(TrackInfo1.dwell_state_durations);
   [rsd_mean1 rsd_err1 rsd_vector1] = AverageStateDur(TrackInfo1.roam_state_durations);
   [dsd_mean_incl_ends1 dsd_err_incl_ends1 dsd_vector_incl_ends1] = AverageStateDur(TrackInfo1.dwell_state_durations_incl_ends);
   [rsd_mean_incl_ends1 rsd_err_incl_ends1 rsd_vector_incl_ends1] = AverageStateDur(TrackInfo1.roam_state_durations_incl_ends);
   
   
   
   
   string2 = deblank(dirList(2,:)); 

   PathName = sprintf('%s/%s/',PathofFolder,string2);

   [dsd2 rsd2 FracDwell2 FracRoam2 TrackInfo2] = AutomatedRoamDwellAnalysis_Pool_HMM_useN2HMM(PathName,Date,string2,N2_TR,N2_E);
   dwellrev2 = TrackInfo2.Reversal_Info.DwellRevRate;
   roamrev2 = TrackInfo2.Reversal_Info.RoamRevRate;
   dwell_s_rev2 = TrackInfo2.Reversal_Info.Dwell_sRevRate;
   dwell_l_rev2 = TrackInfo2.Reversal_Info.Dwell_lRevRate;
   roam_s_rev2 = TrackInfo2.Reversal_Info.Roam_sRevRate;
   roam_l_rev2 = TrackInfo2.Reversal_Info.Roam_lRevRate;
   dwellspeedmean2 = TrackInfo2.Reversal_Info.dwellspeedmean;
   roamspeedmean2 = TrackInfo2.Reversal_Info.roamspeedmean;
   
   
   [dsd2_InclEnds rsd2_InclEnds FracDwell2_InclEnds FracRoam2_InclEnds mean_dw_stab2 mean_dw_stab_err2 mean_dw_stab_vector2 mean_ro_stab2 mean_ro_stab_err2 mean_ro_stab_vector2  all_dw_speed_info all_ro_speed_info] = AutomatedRoamDwellAnalysis_Pool_InclEnds_HMM_useN2HMM(PathName,Date,string2,N2_TR_InclEnds,N2_E_InclEnds);
   
   StateStability2 = struct('mean_dw_stab',[],'mean_dw_stab_err',[],'mean_dw_stab_vector',[],'mean_ro_stab',[],'mean_ro_stab_err',[],'mean_ro_stab_vector',[],'all_dw_speed_info',[],'all_ro_speed_info',[]);
   StateStability2.mean_dw_stab = mean_dw_stab2;
   StateStability2.mean_dw_stab_err = mean_dw_stab_err2;
   StateStability2.mean_dw_stab_vector = mean_dw_stab_vector2;
   StateStability2.mean_ro_stab = mean_ro_stab2;
   StateStability2.mean_ro_stab_err = mean_ro_stab_err2;
   StateStability2.mean_ro_stab_vector = mean_ro_stab_vector2;
   StateStability2.all_dw_speed_info = all_dw_speed_info;
   StateStability2.all_ro_speed_info = all_ro_speed_info;
   
   TrackInfo2.State_stability = StateStability2;
   
   
   
   
   
   TrackInfo2.dwell_state_durations_incl_ends = dsd2_InclEnds;
   TrackInfo2.roam_state_durations_incl_ends = rsd2_InclEnds;
   
    VidName = sprintf('%s.%s',Date,string2);
    %display(VidName)
    NewFilename = sprintf('%s.TrackInfo.mat',VidName);
    %display(NewFilename)
    PathofFolderforSave = sprintf('%s',PathName);
    FullFileName = sprintf('%s/%s',PathofFolderforSave,NewFilename);
    %display(FullFileName)
    save(FullFileName,'TrackInfo2');
    if(size(TrackInfo2.dwell_state_durations)>0)
   [dsd_mean2 dsd_err2 dsd_vector2] = AverageStateDur(TrackInfo2.dwell_state_durations);
    end
   [rsd_mean2 rsd_err2 rsd_vector2] = AverageStateDur(TrackInfo2.roam_state_durations);
   [dsd_mean_incl_ends2 dsd_err_incl_ends2 dsd_vector_incl_ends2] = AverageStateDur(TrackInfo2.dwell_state_durations_incl_ends);
   [rsd_mean_incl_ends2 rsd_err_incl_ends2 rsd_vector_incl_ends2] = AverageStateDur(TrackInfo2.roam_state_durations_incl_ends);
    
    
   
    a = zeros(2,2);
    a(1,1:2) = [FracDwell1 FracRoam1];
    a(2,1:2) = [FracDwell2 FracRoam2];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(4,4,1);
    
    bar(a,'stack');
    legend('dwelling','roaming');
    ylabel('fraction of time');
    set(gca,'XTickLabel',{string1;string2});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(size(TrackInfo2.dwell_state_durations)>0)
    subplot(4,4,2);
    
    plotTwoHists(dsd1(1,:),dsd2(1,:),string1,string2,10);
    title('Dwell States');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(size(TrackInfo2.dwell_state_durations)>0)
    subplot(4,4,3)
    
    x = [1 2 3]
    y = [dsd_mean1 0 dsd_mean2]
    yerr = [dsd_err1 0 dsd_err2]
    errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
    title('Dwell States - average each animal');
    set(gca,'XTickLabel',{string1;'';string2});
    ylabel('state length (seconds)');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    if(size(TrackInfo2.dwell_state_durations)>0)
    subplot(4,4,4)
    
    [hsubplot4,pvaluesubplot4] = ttest2(dsd_vector1,dsd_vector2);
    pValue = num2str(pvaluesubplot4);
    outputTextSubplot4 = sprintf('%s%s','pValue is ',pValue);
    text(0,1,outputTextSubplot4);
    
    
    
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    subplot(4,4,5);
    
    plotTwoHists(rsd1(1,:),rsd2(1,:),string1,string2,10);
    title('Roam States');
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(4,4,6)
    
    x = [1 2 3]
    y = [rsd_mean1 0 rsd_mean2]
    yerr = [rsd_err1 0 rsd_err2]
    errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
    title('Roam States - average each animal');
    set(gca,'XTickLabel',{string1;'';string2});
    ylabel('state length (seconds)');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(4,4,7)
    
    [hsubplot7,pvaluesubplot7] = ttest2(rsd_vector1,rsd_vector2);
    pValue = num2str(pvaluesubplot7);
    outputTextSubplot7 = sprintf('%s%s','pValue is ',pValue);
    text(0,1,outputTextSubplot7);
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    subplot(4,4,8);
    
    plotTwoHists(dsd1_InclEnds(1,:),dsd2_InclEnds(1,:),string1,string2,10);
    title('Dwell States, First/Last included');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(4,4,9)
    
    x = [1 2 3]
    y = [dsd_mean_incl_ends1 0 dsd_mean_incl_ends2]
    yerr = [dsd_err_incl_ends1 0 dsd_err_incl_ends2]
    errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
    title('Dwell States (Incl Ends) - average each animal');
    set(gca,'XTickLabel',{string1;'';string2});
    ylabel('state length (seconds)');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(4,4,10)
    
    [hsubplot10,pvaluesubplot10] = ttest2(dsd_vector_incl_ends1,dsd_vector_incl_ends2);
    pValue = num2str(pvaluesubplot10);
    outputTextSubplot10 = sprintf('%s%s','pValue is ',pValue);
    text(0,1,outputTextSubplot10);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(4,4,11);
    
    plotTwoHists(rsd1_InclEnds(1,:),rsd2_InclEnds(1,:),string1,string2,10);
    title('Roam States, FirstLast included');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    subplot(4,4,12)
    
    x = [1 2 3]
    y = [rsd_mean_incl_ends1 0 rsd_mean_incl_ends2]
    yerr = [rsd_err_incl_ends1 0 rsd_err_incl_ends2]
    errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
    title('Roam States (Incl Ends) - average each animal');
    set(gca,'XTickLabel',{string1;'';string2});
    ylabel('state length (seconds)');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(4,4,13)
    
    [hsubplot13,pvaluesubplot13] = ttest2(rsd_vector_incl_ends1,rsd_vector_incl_ends2);
    pValue = num2str(pvaluesubplot13);
    outputTextSubplot13 = sprintf('%s%s','pValue is ',pValue);
    text(0,1,outputTextSubplot13);
    
    
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     subplot(4,4,14);
%     
%     x = [1 2 3 4 5 6 7 8]
%     y = [dwellrev1(1) dwellrev2(1) 0 dwell_s_rev1(1) dwell_s_rev2(1) 0 dwell_l_rev1(1) dwell_l_rev2(1)]
%     yerr = [dwellrev1(2) dwellrev2(2) 0 dwell_s_rev1(2) dwell_s_rev2(2) 0 dwell_l_rev1(2) dwell_l_rev2(2)]
%     errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
%     title('Reversals During Dwell States');
%     set(gca,'XTickLabel',{'all Revs';'';'';'sRevs';'';'';'lRevs';''});
    
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%% 
%     subplot(4,4,15);
%     
%     x = [1 2 3 4 5 6 7 8]
%     y = [roamrev1(1) roamrev2(1) 0 roam_s_rev1(1) roam_s_rev2(1) 0 roam_l_rev1(1) roam_l_rev2(1)]
%     yerr = [roamrev1(2) roamrev2(2) 0 roam_s_rev1(2) roam_s_rev2(2) 0 roam_l_rev1(2) roam_l_rev2(2)]
%     errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
%     title('Reversals During Roam States');
%     set(gca,'XTickLabel',{'all Revs';'';'';'sRevs';'';'';'lRevs';''});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% 
    subplot(4,4,16);
    
    
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

    
    
    
    
    
    
    
    
    