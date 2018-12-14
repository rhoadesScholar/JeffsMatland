function [RevMatrix DwellRevRate RoamRevRate Dwell_sRevRate Dwell_lRevRate Roam_sRevRate Roam_lRevRate] = CreateRevMatrix2(finalTracks)
Rev_Dwell = [];
Rev_Roam = [];
 finalTracks2 = finalTracks;
 [stateList startingStateMap] = getStateSliding_Diff(finalTracks,finalTracks2,450,30,3,35,57,3);
% %[stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurations(stateList,.333);
 allStateCalls = [];
 for(j = 1:(length(stateList)))
 
     allStateCalls = [allStateCalls stateList(j).finalstate];
 end
 TotalBins = length(allStateCalls);
 numDwellBins = length(find(allStateCalls==1));
 numRoamBins =length(find(allStateCalls==2));
 DwellTime = numDwellBins/180;
 RoamTime = numRoamBins/180;

DwellIndex = [];
DwellIndexLength = []; 
RoamIndex = [];
RoamIndexLength = [];
indexRevMatrix = 1;
for(j = 1:length(finalTracks))
    if(length(finalTracks(j).Reversals)>0)
    Revs = finalTracks(j).Reversals(:,1);
    
    DwellFrames = find(stateList(j).finalstate==1);
    
    if (finalTracks(j).Reversals(1,1) < finalTracks(j).Frames(1))
    else
       DwellFrames = DwellFrames + finalTracks(j).Frames(1)-1;
    end
    
    for (i=1:length(Revs))
        a = find(DwellFrames==Revs(i));
        
        if(a>0)
            %DwellIndex = [DwellIndex i];
            RevMatrix(indexRevMatrix,1) = 1;
            RevMatrix(indexRevMatrix,2) = j;
            RevMatrix(indexRevMatrix,3) =  finalTracks(j).Reversals(i,2);
            RevMatrix(indexRevMatrix,4) =  finalTracks(j).Reversals(i,3);
            indexRevMatrix = indexRevMatrix + 1;
            
        else
            %RoamIndex = [RoamIndex i];
            RevMatrix(indexRevMatrix,1) = 2;
            RevMatrix(indexRevMatrix,2) = j;
            RevMatrix(indexRevMatrix,3) =  finalTracks(j).Reversals(i,2);
            RevMatrix(indexRevMatrix,4) =  finalTracks(j).Reversals(i,3);
            indexRevMatrix = indexRevMatrix + 1;
           
        end
        
    end
    end
end
Dwell_sRevRate_Temp = zeros(1,length(finalTracks));
Dwell_lRevRate_Temp = zeros(1,length(finalTracks));
Dwell_revRate_Temp = zeros(1,length(finalTracks));
Roam_sRevRate_Temp = zeros(1,length(finalTracks));
Roam_lRevRate_Temp = zeros(1,length(finalTracks));
Roam_revRate_Temp = zeros(1,length(finalTracks));
    
for(j=1:length(finalTracks))
    RevIndexCol1 = RevMatrix(:,1);
    RevIndexCol2 = RevMatrix(:,2);
    RevIndforThisTracks = find(RevIndexCol2 == j);
    Num_Revs = length(RevIndforThisTracks);
    StatesDurThisTrackRevs = RevIndexCol1(RevIndforThisTracks);
    Num_Revs_Dw = 0;
    Num_Revs_Dw = length(find(StatesDurThisTrackRevs==1));
    Num_Revs_Ro = 0;
    Num_Revs_Ro = length(find(StatesDurThisTrackRevs==2));
    display(Num_Revs_Dw)
    ThisTrackRevs = RevMatrix(RevIndforThisTracks,:);
    ThisTrack_RoDw = ThisTrackRevs(:,1);
    
    ThisTrack_Dw_Ind = find(ThisTrack_RoDw == 1);
    
    RevLengths_Dwell_Temp = ThisTrackRevs(ThisTrack_Dw_Ind,4);
    Num_Dwell_sRevs_Temp = length(find(RevLengths_Dwell_Temp < 0.3));
    Num_Dwell_lRevs_Temp = Num_Revs_Dw - Num_Dwell_sRevs_Temp;
    
     AnimDwellBins = length(find(stateList(j).finalstate==1));
     AnimRoamBins =length(find(stateList(j).finalstate==2));
     DwellTime_Temp = AnimDwellBins/180;
     RoamTime_Temp = AnimRoamBins/180;
     display(DwellTime_Temp)
    
    Dwell_sRevRate_Temp(j) = Num_Dwell_sRevs_Temp/DwellTime_Temp;
    Dwell_lRevRate_Temp(j) = Num_Dwell_lRevs_Temp/DwellTime_Temp;
    Dwell_revRate_Temp(j) = Num_Revs_Dw/DwellTime_Temp;
    
    ThisTrack_Ro_Ind = find(ThisTrack_RoDw == 2);
    display(ThisTrack_Dw_Ind)
    
    RevLengths_Roam_Temp = ThisTrackRevs(ThisTrack_Ro_Ind,4);
    Num_Roam_sRevs_Temp = length(find(RevLengths_Roam_Temp < 0.3));
    Num_Roam_lRevs_Temp = Num_Revs_Ro - Num_Roam_sRevs_Temp;
    if(RoamTime_Temp>3)
    Roam_sRevRate_Temp(j) = Num_Roam_sRevs_Temp/RoamTime_Temp;
    Roam_lRevRate_Temp(j) = Num_Roam_lRevs_Temp/RoamTime_Temp;
    Roam_revRate_Temp(j) = Num_Revs_Ro/RoamTime_Temp;
    else
        Roam_sRevRate_Temp(j) = NaN;
         Roam_lRevRate_Temp(j) = NaN;
       Roam_revRate_Temp(j) = NaN;
    end
    display(j)
    display(Dwell_revRate_Temp)
    
end
Dwell_revRate_Temp = Dwell_revRate_Temp(~isnan(Dwell_revRate_Temp));
Roam_revRate_Temp = Roam_revRate_Temp(~isnan(Roam_revRate_Temp));
Dwell_sRevRate_Temp = Dwell_sRevRate_Temp(~isnan(Dwell_sRevRate_Temp));
Dwell_lRevRate_Temp = Dwell_lRevRate_Temp(~isnan(Dwell_lRevRate_Temp));
Roam_sRevRate_Temp = Roam_sRevRate_Temp(~isnan(Roam_sRevRate_Temp));
Roam_lRevRate_Temp = Roam_lRevRate_Temp(~isnan(Roam_lRevRate_Temp));


DwellRevRate(1) = mean(Dwell_revRate_Temp);
DwellRevRate(2) = (std(Dwell_revRate_Temp))/(sqrt(length(Dwell_revRate_Temp)));
RoamRevRate(1) = mean(Roam_revRate_Temp);
RoamRevRate(2) = (std(Roam_revRate_Temp))/(sqrt(length(Roam_revRate_Temp)));
Dwell_sRevRate(1) = mean(Dwell_sRevRate_Temp);
Dwell_sRevRate(2) = (std(Dwell_sRevRate_Temp))/(sqrt(length(Dwell_sRevRate_Temp)));
Dwell_lRevRate(1)  = mean(Dwell_lRevRate_Temp);
Dwell_lRevRate(2) = (std(Dwell_lRevRate_Temp))/(sqrt(length(Dwell_lRevRate_Temp)));
Roam_sRevRate(1) = mean(Roam_sRevRate_Temp);
Roam_sRevRate(2) = (std(Roam_sRevRate_Temp))/(sqrt(length(Roam_sRevRate_Temp)));
Roam_lRevRate(1) = mean(Roam_lRevRate_Temp);
Roam_lRevRate(2) = (std(Roam_lRevRate_Temp))/(sqrt(length(Roam_lRevRate_Temp)));
    
% Num_Total_Revs = length(RevMatrix(:,1));
% RevIndex = RevMatrix(:,1);
% Num_Dwell_Revs = length(find(RevIndex == 1));
% Num_Roam_Revs = length(find(RevIndex == 2));
% DwellRevRate = Num_Dwell_Revs/DwellTime;
% RoamRevRate = Num_Roam_Revs/RoamTime;
% 
% DwellIndex = find(RevIndex == 1);
% RoamIndex = find(RevIndex == 2);
% RevMatrix_Dwell = RevMatrix(DwellIndex,:);
% RevMatrix_Roam = RevMatrix(RoamIndex,:);
% 
% RevLengths_Dwell = RevMatrix_Dwell(:,4);
% Num_Dwell_sRevs = length(find(RevLengths_Dwell < 0.3));
% Num_Dwell_lRevs = Num_Dwell_Revs - Num_Dwell_sRevs;
% Dwell_sRevRate = Num_Dwell_sRevs/DwellTime;
% Dwell_lRevRate = Num_Dwell_lRevs/DwellTime;
% 
% RevLengths_Roam = RevMatrix_Roam(:,4);
% Num_Roam_sRevs = length(find(RevLengths_Roam < 0.3));
% Num_Roam_lRevs = Num_Roam_Revs - Num_Roam_sRevs;
% Roam_sRevRate = Num_Roam_sRevs/RoamTime;
% Roam_lRevRate = Num_Roam_lRevs/RoamTime;

   
end