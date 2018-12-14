function compareThreeGenotypes_HMM_useN2HMM(folderWithBoth,Date)
    PathofFolder = sprintf('%s',folderWithBoth);
    display(PathofFolder)
    dirList = ls(PathofFolder);
    display(dirList)
    dirList = dirList(3:5,:);

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
   
   [dsd1_InclEnds rsd1_InclEnds FracDwell1_InclEnds FracRoam1_InclEnds N2_TR_InclEnds N2_E_InclEnds] = AutomatedRoamDwellAnalysis_Pool_InclEnds_HMM_collectN2HMM(PathName,Date,string1);
   
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
   
   
   [dsd2_InclEnds rsd2_InclEnds FracDwell2_InclEnds FracRoam2_InclEnds] = AutomatedRoamDwellAnalysis_Pool_InclEnds_HMM_useN2HMM(PathName,Date,string2,N2_TR_InclEnds,N2_E_InclEnds);
   
      string3 = deblank(dirList(3,:)); 

   PathName = sprintf('%s/%s/',PathofFolder,string3);

   [dsd3 rsd3 FracDwell3 FracRoam3 TrackInfo3] = AutomatedRoamDwellAnalysis_Pool_HMM_useN2HMM(PathName,Date,string3,N2_TR,N2_E);
   dwellrev3 = TrackInfo3.Reversal_Info.DwellRevRate;
   roamrev3 = TrackInfo3.Reversal_Info.RoamRevRate;
   dwell_s_rev3 = TrackInfo3.Reversal_Info.Dwell_sRevRate;
   dwell_l_rev3 = TrackInfo3.Reversal_Info.Dwell_lRevRate;
   roam_s_rev3 = TrackInfo3.Reversal_Info.Roam_sRevRate;
   roam_l_rev3 = TrackInfo3.Reversal_Info.Roam_lRevRate;
   dwellspeedmean3 = TrackInfo3.Reversal_Info.dwellspeedmean;
   roamspeedmean3 = TrackInfo3.Reversal_Info.roamspeedmean;
   
   
   [dsd3_InclEnds rsd3_InclEnds FracDwell3_InclEnds FracRoam3_InclEnds] = AutomatedRoamDwellAnalysis_Pool_InclEnds_HMM_useN2HMM(PathName,Date,string3,N2_TR_InclEnds,N2_E_InclEnds);
   
   
%          string4 = deblank(dirList(4,:)); 
% 
%    PathName = sprintf('%s/%s/',PathofFolder,string4);
% 
%    [dsd4 rsd4 FracDwell4 FracRoam4 TrackInfo4] = AutomatedRoamDwellAnalysis_Pool_HMM_useN2HMM(PathName,Date,string4,N2_TR,N2_E);
%    dwellrev4 = TrackInfo4.Reversal_Info.DwellRevRate;
%    roamrev4 = TrackInfo4.Reversal_Info.RoamRevRate;
%    dwell_s_rev4 = TrackInfo4.Reversal_Info.Dwell_sRevRate;
%    dwell_l_rev4 = TrackInfo4.Reversal_Info.Dwell_lRevRate;
%    roam_s_rev4 = TrackInfo4.Reversal_Info.Roam_sRevRate;
%    roam_l_rev4 = TrackInfo4.Reversal_Info.Roam_lRevRate;
%    dwellspeedmean4 = TrackInfo4.Reversal_Info.dwellspeedmean;
%    roamspeedmean4 = TrackInfo4.Reversal_Info.roamspeedmean;
%    
%    
%    [dsd4_InclEnds rsd4_InclEnds FracDwell4_InclEnds FracRoam4_InclEnds] = AutomatedRoamDwellAnalysis_Pool_InclEnds_HMM(PathName,Date,string4);
%    
   
   
    a = zeros(3,2);
    a(1,1:2) = [FracDwell1 FracRoam1];
    a(2,1:2) = [FracDwell2 FracRoam2];
    a(3,1:2) = [FracDwell3 FracRoam3];
%     a(4,1:2) = [FracDwell4 FracRoam4];
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,4,1);
    
    bar(a,'stack');
    legend('dwelling','roaming');
    ylabel('fraction of time');
    set(gca,'XTickLabel',{string1;string2;string3});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,4,2);
    
    plotThreeHists(dsd1(1,:),dsd2(1,:),dsd3(1,:),string1,string2,string3,10);
    title('Dwell States');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(2,4,3);
    
    plotThreeHists(rsd1(1,:),rsd2(1,:),rsd3(1,:),string1,string2,string3,10);
    title('Roam States');
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,4,4);
    
    plotThreeHists(dsd1_InclEnds(1,:),dsd2_InclEnds(1,:),dsd3_InclEnds(1,:),string1,string2,string3,10);
    title('Dwell States, First/Last included');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    subplot(2,4,5);
    
    plotThreeHists(rsd1_InclEnds(1,:),rsd2_InclEnds(1,:),rsd3_InclEnds(1,:),string1,string2,string3,10);
    title('Roam States, FirstLast included');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%     subplot(2,4,6);
%     
%     x = [1 2 3 4 5 6 7 8 9 10 11 ]
%     y = [dwellrev1(1) dwellrev2(1) dwellrev3(1) 0 dwell_s_rev1(1) dwell_s_rev2(1) dwell_s_rev3(1) 0 dwell_l_rev1(1) dwell_l_rev2(1) dwell_l_rev3(1) ];
%     yerr = [dwellrev1(2) dwellrev2(2) dwellrev3(2) 0 dwell_s_rev1(2) dwell_s_rev2(2) dwell_s_rev3(2) 0 dwell_l_rev1(2) dwell_l_rev2(2) dwell_l_rev3(2)];
%     errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
%     title('Reversals During Dwell States');
%     set(gca,'XTickLabel',{'';'';'all Revs';'';'';'';'';'sRevs';'';'';'';'';'lRevs';''});
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% 
%     subplot(2,4,7);
%     
%     x = [1 2 3 4 5 6 7 8 9 10 11 12 13 14]
%     y = [roamrev1(1) roamrev2(1) roamrev3(1) roamrev4(1) 0 roam_s_rev1(1) roam_s_rev2(1) roam_s_rev3(1) roam_s_rev4(1) 0 roam_l_rev1(1) roam_l_rev2(1) roam_l_rev3(1) roam_l_rev4(1)];
%     yerr = [roamrev1(2) roamrev2(2) roamrev3(2) roamrev4(2) 0 roam_s_rev1(2) roam_s_rev2(2) roam_s_rev3(2) roam_s_rev4(2) 0 roam_l_rev1(2) roam_l_rev2(2) roam_l_rev3(2) roam_l_rev4(2)];
%     errorbar_bargraph(x,y,yerr,[0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156;1 1 1;0.5156 0 0;0 0 0.5156])
%     title('Reversals During Roam States');
%     set(gca,'XTickLabel',{'';'';'all Revs';'';'';'';'';'sRevs';'';'';'';'';'lRevs';''});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% 
%     subplot(2,4,8);
%     
%     
%     time = [0 0.333 0.666 1 1.333 1.666 2 2.333 2.666];
%     if(length(roamspeedmean1>0))
%             if(length(roamspeedmean2>0))
%                 if(length(roamspeedmean3>0))
%                     if(length(roamspeedmean4>0))
%     plot(time,dwellspeedmean1,time,dwellspeedmean2,time,dwellspeedmean3,time,dwellspeedmean4,time,roamspeedmean1,time,roamspeedmean2,time,roamspeedmean3,time,roamspeedmean4);
%                     end
%                 end
%             end
%     end
%     legend1 = sprintf('%s.Dwell',string1);
%     legend2 = sprintf('%s.Dwell',string2);
%     legend3 = sprintf('%s.Dwell',string3);
%     legend4 = sprintf('%s.Dwell',string4);
%     legend5 = sprintf('%s.Roam',string1);
%     legend6 = sprintf('%s.Roam',string2);
%     legend7 = sprintf('%s.Roam',string3);
%     legend8 = sprintf('%s.Roam',string4);
%     
%     legend(legend1,legend2,legend3,legend4,legend5,legend6,legend7,legend8);
%     title('Speed after Reversing');
%     xlabel('time (sec)');
%     ylabel('speed (mm/sec)');
    
    
    %%%%Save Figure
    CompName = sprintf('%s.%s.%s.%s',Date,string1,string2,string3);
    save_figure(1,'',CompName,'comparison');
end

    
    
    
    
    
    
    
    
    