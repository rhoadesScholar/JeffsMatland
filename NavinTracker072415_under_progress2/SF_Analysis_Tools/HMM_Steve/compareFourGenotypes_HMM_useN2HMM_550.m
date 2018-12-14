function [dsd1_InclEnds rsd1_InclEnds dsd2_InclEnds rsd2_InclEnds dsd3_InclEnds rsd3_InclEnds dsd4_InclEnds rsd4_InclEnds] = compareFourGenotypes_HMM_useN2HMM_550(folderWithBoth,Date)
    PathofFolder = sprintf('%s',folderWithBoth);
    display(PathofFolder)
    dirList = ls(PathofFolder);
    display(dirList)
    dirList = dirList(3:6,:);

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
   
   [dsd1_InclEnds rsd1_InclEnds FracDwell1_InclEnds FracRoam1_InclEnds N2_TR_InclEnds N2_E_InclEnds  mean_dw_stab1 mean_dw_stab_err1 mean_dw_stab_vector1 mean_ro_stab1 mean_ro_stab_err1 mean_ro_stab_vector1] = AutomatedRoamDwellAnalysis_Pool_InclEnds_HMM_collectN2HMM(PathName,Date,string1);
   
   StateStability1 = struct('mean_dw_stab',[],'mean_dw_stab_err',[],'mean_dw_stab_vector',[],'mean_ro_stab',[],'mean_ro_stab_err',[],'mean_ro_stab_vector',[]);
   StateStability1.mean_dw_stab = mean_dw_stab1;
   StateStability1.mean_dw_stab_err = mean_dw_stab_err1;
   StateStability1.mean_dw_stab_vector = mean_dw_stab_vector1;
   StateStability1.mean_ro_stab = mean_ro_stab1;
   StateStability1.mean_ro_stab_err = mean_ro_stab_err1;
   StateStability1.mean_ro_stab_vector = mean_ro_stab_vector1;
   
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
   
   
   [dsd2_InclEnds rsd2_InclEnds FracDwell2_InclEnds FracRoam2_InclEnds  mean_dw_stab2 mean_dw_stab_err2 mean_dw_stab_vector2 mean_ro_stab2 mean_ro_stab_err2 mean_ro_stab_vector2] = AutomatedRoamDwellAnalysis_Pool_InclEnds_HMM_useN2HMM(PathName,Date,string2,N2_TR_InclEnds,N2_E_InclEnds);
   
   StateStability2 = struct('mean_dw_stab',[],'mean_dw_stab_err',[],'mean_dw_stab_vector',[],'mean_ro_stab',[],'mean_ro_stab_err',[],'mean_ro_stab_vector',[]);
   StateStability2.mean_dw_stab = mean_dw_stab2;
   StateStability2.mean_dw_stab_err = mean_dw_stab_err2;
   StateStability2.mean_dw_stab_vector = mean_dw_stab_vector2;
   StateStability2.mean_ro_stab = mean_ro_stab2;
   StateStability2.mean_ro_stab_err = mean_ro_stab_err2;
   StateStability2.mean_ro_stab_vector = mean_ro_stab_vector2;
   
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
   
      [dsd_mean2 dsd_err2 dsd_vector2] = AverageStateDur(TrackInfo2.dwell_state_durations);
   [rsd_mean2 rsd_err2 rsd_vector2] = AverageStateDur(TrackInfo2.roam_state_durations);
   [dsd_mean_incl_ends2 dsd_err_incl_ends2 dsd_vector_incl_ends2] = AverageStateDur(TrackInfo2.dwell_state_durations_incl_ends);
   [rsd_mean_incl_ends2 rsd_err_incl_ends2 rsd_vector_incl_ends2] = AverageStateDur(TrackInfo2.roam_state_durations_incl_ends);
    
      string3 = deblank(dirList(3,:)); 

   PathName = sprintf('%s/%s/',PathofFolder,string3);

   [dsd3 rsd3 FracDwell3 FracRoam3 TrackInfo3] = AutomatedRoamDwellAnalysis_Pool_HMM_useN2HMM_550(PathName,Date,string3,N2_TR,N2_E);
   dwellrev3 = TrackInfo3.Reversal_Info.DwellRevRate;
   roamrev3 = TrackInfo3.Reversal_Info.RoamRevRate;
   dwell_s_rev3 = TrackInfo3.Reversal_Info.Dwell_sRevRate;
   dwell_l_rev3 = TrackInfo3.Reversal_Info.Dwell_lRevRate;
   roam_s_rev3 = TrackInfo3.Reversal_Info.Roam_sRevRate;
   roam_l_rev3 = TrackInfo3.Reversal_Info.Roam_lRevRate;
   dwellspeedmean3 = TrackInfo3.Reversal_Info.dwellspeedmean;
   roamspeedmean3 = TrackInfo3.Reversal_Info.roamspeedmean;
   
   
   [dsd3_InclEnds rsd3_InclEnds FracDwell3_InclEnds FracRoam3_InclEnds  mean_dw_stab3 mean_dw_stab_err3 mean_dw_stab_vector3 mean_ro_stab3 mean_ro_stab_err3 mean_ro_stab_vector3] = AutomatedRoamDwellAnalysis_Pool_InclEnds_HMM_useN2HMM_550(PathName,Date,string3,N2_TR_InclEnds,N2_E_InclEnds);
   
   StateStability3 = struct('mean_dw_stab',[],'mean_dw_stab_err',[],'mean_dw_stab_vector',[],'mean_ro_stab',[],'mean_ro_stab_err',[],'mean_ro_stab_vector',[]);
   StateStability3.mean_dw_stab = mean_dw_stab3;
   StateStability3.mean_dw_stab_err = mean_dw_stab_err3;
   StateStability3.mean_dw_stab_vector = mean_dw_stab_vector3;
   StateStability3.mean_ro_stab = mean_ro_stab3;
   StateStability3.mean_ro_stab_err = mean_ro_stab_err3;
   StateStability3.mean_ro_stab_vector = mean_ro_stab_vector3;
   
   TrackInfo3.State_stability = StateStability3;
   
   
      TrackInfo3.dwell_state_durations_incl_ends = dsd3_InclEnds;
   TrackInfo3.roam_state_durations_incl_ends = rsd3_InclEnds;
   
    VidName = sprintf('%s.%s',Date,string3);
    %display(VidName)
    NewFilename = sprintf('%s.TrackInfo.mat',VidName);
    %display(NewFilename)
    PathofFolderforSave = sprintf('%s',PathName);
    FullFileName = sprintf('%s/%s',PathofFolderforSave,NewFilename);
    %display(FullFileName)
    save(FullFileName,'TrackInfo3');
   
      [dsd_mean3 dsd_err3 dsd_vector3] = AverageStateDur(TrackInfo3.dwell_state_durations);
   [rsd_mean3 rsd_err3 rsd_vector3] = AverageStateDur(TrackInfo3.roam_state_durations);
   [dsd_mean_incl_ends3 dsd_err_incl_ends3 dsd_vector_incl_ends3] = AverageStateDur(TrackInfo3.dwell_state_durations_incl_ends);
   [rsd_mean_incl_ends3 rsd_err_incl_ends3 rsd_vector_incl_ends3] = AverageStateDur(TrackInfo3.roam_state_durations_incl_ends);
   
         string4 = deblank(dirList(4,:)); 

   PathName = sprintf('%s/%s/',PathofFolder,string4);

   [dsd4 rsd4 FracDwell4 FracRoam4 TrackInfo4] = AutomatedRoamDwellAnalysis_Pool_HMM_useN2HMM(PathName,Date,string4,N2_TR,N2_E);
   dwellrev4 = TrackInfo4.Reversal_Info.DwellRevRate;
   roamrev4 = TrackInfo4.Reversal_Info.RoamRevRate;
   dwell_s_rev4 = TrackInfo4.Reversal_Info.Dwell_sRevRate;
   dwell_l_rev4 = TrackInfo4.Reversal_Info.Dwell_lRevRate;
   roam_s_rev4 = TrackInfo4.Reversal_Info.Roam_sRevRate;
   roam_l_rev4 = TrackInfo4.Reversal_Info.Roam_lRevRate;
   dwellspeedmean4 = TrackInfo4.Reversal_Info.dwellspeedmean;
   roamspeedmean4 = TrackInfo4.Reversal_Info.roamspeedmean;
   
   
   [dsd4_InclEnds rsd4_InclEnds FracDwell4_InclEnds FracRoam4_InclEnds  mean_dw_stab4 mean_dw_stab_err4 mean_dw_stab_vector4 mean_ro_stab4 mean_ro_stab_err4 mean_ro_stab_vector4] = AutomatedRoamDwellAnalysis_Pool_InclEnds_HMM_useN2HMM(PathName,Date,string4,N2_TR_InclEnds,N2_E_InclEnds);
   
   StateStability4 = struct('mean_dw_stab',[],'mean_dw_stab_err',[],'mean_dw_stab_vector',[],'mean_ro_stab',[],'mean_ro_stab_err',[],'mean_ro_stab_vector',[]);
   StateStability4.mean_dw_stab = mean_dw_stab4;
   StateStability4.mean_dw_stab_err = mean_dw_stab_err4;
   StateStability4.mean_dw_stab_vector = mean_dw_stab_vector4;
   StateStability4.mean_ro_stab = mean_ro_stab4;
   StateStability4.mean_ro_stab_err = mean_ro_stab_err4;
   StateStability4.mean_ro_stab_vector = mean_ro_stab_vector4;
   
   TrackInfo4.State_stability = StateStability4;
   
   
      TrackInfo4.dwell_state_durations_incl_ends = dsd4_InclEnds;
   TrackInfo4.roam_state_durations_incl_ends = rsd4_InclEnds;
   
    VidName = sprintf('%s.%s',Date,string4);
    %display(VidName)
    NewFilename = sprintf('%s.TrackInfo.mat',VidName);
    %display(NewFilename)
    PathofFolderforSave = sprintf('%s',PathName);
    FullFileName = sprintf('%s/%s',PathofFolderforSave,NewFilename);
    %display(FullFileName)
    save(FullFileName,'TrackInfo4');
   if(length(TrackInfo4.dwell_state_durations)>0)
   [dsd_mean4 dsd_err4 dsd_vector4] = AverageStateDur(TrackInfo4.dwell_state_durations);
   end
   if(length(TrackInfo4.roam_state_durations)>0)
   [rsd_mean4 rsd_err4 rsd_vector4] = AverageStateDur(TrackInfo4.roam_state_durations);
   end
   [dsd_mean_incl_ends4 dsd_err_incl_ends4 dsd_vector_incl_ends4] = AverageStateDur(TrackInfo4.dwell_state_durations_incl_ends);
    if(length(TrackInfo4.roam_state_durations_incl_ends)>0)
   [rsd_mean_incl_ends4 rsd_err_incl_ends4 rsd_vector_incl_ends4] = AverageStateDur(TrackInfo4.roam_state_durations_incl_ends);
    end
   
    a = zeros(4,2);
    a(1,1:2) = [FracDwell1 FracRoam1];
    a(2,1:2) = [FracDwell2 FracRoam2];
    a(3,1:2) = [FracDwell3 FracRoam3];
    a(4,1:2) = [FracDwell4 FracRoam4];
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(4,4,1);
    
    bar(a,'stack');
    legend('dwelling','roaming');
    ylabel('fraction of time');
    set(gca,'XTickLabel',{string1;string2;string3;string4});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(4,4,2);
    if(size(dsd4)>0)
    plotFourHists(dsd1(1,:),dsd2(1,:),dsd3(1,:),dsd4(1,:),string1,string2,string3,string4,10);
    title('Dwell States');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(4,4,3)
    if(size(dsd4)>0)
    x = [1 2 3 4 5 6 7]
    y = [dsd_mean1 0 dsd_mean2 0 dsd_mean3 0 dsd_mean4]
    yerr = [dsd_err1 0 dsd_err2 0 dsd_err3 0 dsd_err4]
    errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
    title('Dwell States - average each animal');
    set(gca,'XTickLabel',{string1;'';string2;'';string3;'';string4});
    ylabel('state length (seconds)');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(4,4,4)
     if(size(dsd4)>0)
    [h1,pvalue1] = ttest2(dsd_vector1,dsd_vector2);
    [h2,pvalue2] = ttest2(dsd_vector1,dsd_vector3);
    [h3,pvalue3] = ttest2(dsd_vector1,dsd_vector4);
    [h4,pvalue4] = ttest2(dsd_vector2,dsd_vector3);
    [h5,pvalue5] = ttest2(dsd_vector2,dsd_vector4);
    [h6,pvalue6] = ttest2(dsd_vector3,dsd_vector4);
    pValue1 = num2str(pvalue1);
    pValue2 = num2str(pvalue2);
    pValue3 = num2str(pvalue3);
    pValue4 = num2str(pvalue4);
    pValue5 = num2str(pvalue5);
    pValue6 = num2str(pvalue6);
    outputText1 = sprintf('%s%s','pValue comparing 1 v. 2 is ',pValue1);
    outputText2 = sprintf('%s%s','pValue comparing 1 v. 3 is ',pValue2);
    outputText3 = sprintf('%s%s','pValue comparing 1 v. 4 is ',pValue3);
    outputText4 = sprintf('%s%s','pValue comparing 2 v. 3 is ',pValue4);
    outputText5 = sprintf('%s%s','pValue comparing 2 v. 4 is ',pValue5);
    outputText6 = sprintf('%s%s','pValue comparing 3 v. 4 is ',pValue6);
    text(0,1,outputText1);
    text(0,.9,outputText2);
    text(0,.8,outputText3);
    text(0,.7,outputText4);
    text(0,.6,outputText5);
    text(0,.5,outputText6);
     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(4,4,5);
    
    plotFourHists(rsd1(1,:),rsd2(1,:),rsd3(1,:),rsd4(1,:),string1,string2,string3,string4,10);
    title('Roam States');
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(4,4,6)
    
    x = [1 2 3 4 5 6 7]
    y = [rsd_mean1 0 rsd_mean2 0 rsd_mean3 0 rsd_mean4]
    yerr = [rsd_err1 0 rsd_err2 0 rsd_err3 0 rsd_err4]
    errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
    title('Roam States - average each animal');
    set(gca,'XTickLabel',{string1;'';string2;'';string3;'';string4});
    ylabel('state length (seconds)');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(4,4,7)
    
    [h1,pvalue1] = ttest2(rsd_vector1,rsd_vector2);
    [h2,pvalue2] = ttest2(rsd_vector1,rsd_vector3);
    [h3,pvalue3] = ttest2(rsd_vector1,rsd_vector4);
    [h4,pvalue4] = ttest2(rsd_vector2,rsd_vector3);
    [h5,pvalue5] = ttest2(rsd_vector2,rsd_vector4);
    [h6,pvalue6] = ttest2(rsd_vector3,rsd_vector4);
    pValue1 = num2str(pvalue1);
    pValue2 = num2str(pvalue2);
    pValue3 = num2str(pvalue3);
    pValue4 = num2str(pvalue4);
    pValue5 = num2str(pvalue5);
    pValue6 = num2str(pvalue6);
    outputText1 = sprintf('%s%s','pValue comparing 1 v. 2 is ',pValue1);
    outputText2 = sprintf('%s%s','pValue comparing 1 v. 3 is ',pValue2);
    outputText3 = sprintf('%s%s','pValue comparing 1 v. 4 is ',pValue3);
    outputText4 = sprintf('%s%s','pValue comparing 2 v. 3 is ',pValue4);
    outputText5 = sprintf('%s%s','pValue comparing 2 v. 4 is ',pValue5);
    outputText6 = sprintf('%s%s','pValue comparing 3 v. 4 is ',pValue6);
    text(0,1,outputText1);
    text(0,.9,outputText2);
    text(0,.8,outputText3);
    text(0,.7,outputText4);
    text(0,.6,outputText5);
    text(0,.5,outputText6);
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,4,8);
    
    plotFourHists(dsd1_InclEnds(1,:),dsd2_InclEnds(1,:),dsd3_InclEnds(1,:),dsd4_InclEnds(1,:),string1,string2,string3,string4,10);
    title('Dwell States, First/Last included');
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(4,4,9)
    
    x = [1 2 3 4 5 6 7]
    y = [dsd_mean_incl_ends1 0 dsd_mean_incl_ends2 0 dsd_mean_incl_ends3 0 dsd_mean_incl_ends4]
    yerr = [dsd_err_incl_ends1 0 dsd_err_incl_ends2 0 dsd_err_incl_ends3 0 dsd_err_incl_ends4]
    errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
    title('Dwell States (Incl Ends) - average each animal');
    set(gca,'XTickLabel',{string1;'';string2;'';string3;'';string4});
    ylabel('state length (seconds)');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(4,4,10)
    
    [h1,pvalue1] = ttest2(dsd_vector_incl_ends1,dsd_vector_incl_ends2);
    [h2,pvalue2] = ttest2(dsd_vector_incl_ends1,dsd_vector_incl_ends3);
    [h3,pvalue3] = ttest2(dsd_vector_incl_ends1,dsd_vector_incl_ends4);
    [h4,pvalue4] = ttest2(dsd_vector_incl_ends2,dsd_vector_incl_ends3);
    [h5,pvalue5] = ttest2(dsd_vector_incl_ends2,dsd_vector_incl_ends4);
    [h6,pvalue6] = ttest2(dsd_vector_incl_ends3,dsd_vector_incl_ends4);
    pValue1 = num2str(pvalue1);
    pValue2 = num2str(pvalue2);
    pValue3 = num2str(pvalue3);
    pValue4 = num2str(pvalue4);
    pValue5 = num2str(pvalue5);
    pValue6 = num2str(pvalue6);
    outputText1 = sprintf('%s%s','pValue comparing 1 v. 2 is ',pValue1);
    outputText2 = sprintf('%s%s','pValue comparing 1 v. 3 is ',pValue2);
    outputText3 = sprintf('%s%s','pValue comparing 1 v. 4 is ',pValue3);
    outputText4 = sprintf('%s%s','pValue comparing 2 v. 3 is ',pValue4);
    outputText5 = sprintf('%s%s','pValue comparing 2 v. 4 is ',pValue5);
    outputText6 = sprintf('%s%s','pValue comparing 3 v. 4 is ',pValue6);
    text(0,1,outputText1);
    text(0,.9,outputText2);
    text(0,.8,outputText3);
    text(0,.7,outputText4);
    text(0,.6,outputText5);
    text(0,.5,outputText6);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(4,4,11);
    
    plotFourHists(rsd1_InclEnds(1,:),rsd2_InclEnds(1,:),rsd3_InclEnds(1,:),rsd4_InclEnds(1,:),string1,string2,string3,string4,10);
    title('Roam States, FirstLast included');
    
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(4,4,12)
    
    x = [1 2 3 4 5 6 7]
    y = [rsd_mean_incl_ends1 0 rsd_mean_incl_ends2 0 rsd_mean_incl_ends3 0 rsd_mean_incl_ends4]
    yerr = [rsd_err_incl_ends1 0 rsd_err_incl_ends2 0 rsd_err_incl_ends3 0 rsd_err_incl_ends4]
    errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
    title('Roam States (Incl Ends) - average each animal');
    set(gca,'XTickLabel',{string1;'';string2;'';string3;'';string4});
    ylabel('state length (seconds)');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(4,4,13)
    
    [h1,pvalue1] = ttest2(rsd_vector_incl_ends1,rsd_vector_incl_ends2);
    [h2,pvalue2] = ttest2(rsd_vector_incl_ends1,rsd_vector_incl_ends3);
    [h3,pvalue3] = ttest2(rsd_vector_incl_ends1,rsd_vector_incl_ends4);
    [h4,pvalue4] = ttest2(rsd_vector_incl_ends2,rsd_vector_incl_ends3);
    [h5,pvalue5] = ttest2(rsd_vector_incl_ends2,rsd_vector_incl_ends4);
    [h6,pvalue6] = ttest2(rsd_vector_incl_ends3,rsd_vector_incl_ends4);
    pValue1 = num2str(pvalue1);
    pValue2 = num2str(pvalue2);
    pValue3 = num2str(pvalue3);
    pValue4 = num2str(pvalue4);
    pValue5 = num2str(pvalue5);
    pValue6 = num2str(pvalue6);
    outputText1 = sprintf('%s%s','pValue comparing 1 v. 2 is ',pValue1);
    outputText2 = sprintf('%s%s','pValue comparing 1 v. 3 is ',pValue2);
    outputText3 = sprintf('%s%s','pValue comparing 1 v. 4 is ',pValue3);
    outputText4 = sprintf('%s%s','pValue comparing 2 v. 3 is ',pValue4);
    outputText5 = sprintf('%s%s','pValue comparing 2 v. 4 is ',pValue5);
    outputText6 = sprintf('%s%s','pValue comparing 3 v. 4 is ',pValue6);
    text(0,1,outputText1);
    text(0,.9,outputText2);
    text(0,.8,outputText3);
    text(0,.7,outputText4);
    text(0,.6,outputText5);
    text(0,.5,outputText6);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    subplot(4,4,14);
    
    x = [1 2 3 4 5 6 7 8 9 10 11 12 13 14]
    y = [dwellrev1(1) dwellrev2(1) dwellrev3(1) dwellrev4(1) 0 dwell_s_rev1(1) dwell_s_rev2(1) dwell_s_rev3(1) dwell_s_rev4(1) 0 dwell_l_rev1(1) dwell_l_rev2(1) dwell_l_rev3(1) dwell_l_rev4(1)];
    yerr = [dwellrev1(2) dwellrev2(2) dwellrev3(2) dwellrev4(2) 0 dwell_s_rev1(2) dwell_s_rev2(2) dwell_s_rev3(2) dwell_s_rev4(2) 0 dwell_l_rev1(2) dwell_l_rev2(2) dwell_l_rev3(2) dwell_l_rev4(2)];
    errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
    title('Reversals During Dwell States');
    set(gca,'XTickLabel',{'';'';'all Revs';'';'';'';'';'sRevs';'';'';'';'';'lRevs';''});
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% 
    subplot(4,4,15);
    
    x = [1 2 3 4 5 6 7 8 9 10 11 12 13 14]
    y = [roamrev1(1) roamrev2(1) roamrev3(1) roamrev4(1) 0 roam_s_rev1(1) roam_s_rev2(1) roam_s_rev3(1) roam_s_rev4(1) 0 roam_l_rev1(1) roam_l_rev2(1) roam_l_rev3(1) roam_l_rev4(1)];
    yerr = [roamrev1(2) roamrev2(2) roamrev3(2) roamrev4(2) 0 roam_s_rev1(2) roam_s_rev2(2) roam_s_rev3(2) roam_s_rev4(2) 0 roam_l_rev1(2) roam_l_rev2(2) roam_l_rev3(2) roam_l_rev4(2)];
    errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
    title('Reversals During Roam States');
    set(gca,'XTickLabel',{'';'';'all Revs';'';'';'';'';'sRevs';'';'';'';'';'lRevs';''});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% 
    subplot(4,4,16);
    
    
    time = [0 0.333 0.666 1 1.333 1.666 2 2.333 2.666];
    if(length(roamspeedmean1>0))
            if(length(roamspeedmean2>0))
                if(length(roamspeedmean3>0))
                    if(length(roamspeedmean4>0))
    plot(time,dwellspeedmean1,time,dwellspeedmean2,time,dwellspeedmean3,time,dwellspeedmean4,time,roamspeedmean1,time,roamspeedmean2,time,roamspeedmean3,time,roamspeedmean4);
                    end
                end
            end
    end
    legend1 = sprintf('%s.Dwell',string1);
    legend2 = sprintf('%s.Dwell',string2);
    legend3 = sprintf('%s.Dwell',string3);
    legend4 = sprintf('%s.Dwell',string4);
    legend5 = sprintf('%s.Roam',string1);
    legend6 = sprintf('%s.Roam',string2);
    legend7 = sprintf('%s.Roam',string3);
    legend8 = sprintf('%s.Roam',string4);
    
    legend(legend1,legend2,legend3,legend4,legend5,legend6,legend7,legend8);
    title('Speed after Reversing');
    xlabel('time (sec)');
    ylabel('speed (mm/sec)');
    
    
    %%%%Save Figure
    CompName = sprintf('%s.%s.%s.%s.%s',Date,string1,string2,string3,string4);
    save_figure(1,'',CompName,'comparison');
end

    
    
    
    
    
    
    
    
    