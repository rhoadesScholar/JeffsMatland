function [RevMatrix DwellRevRate RoamRevRate Dwell_sRevRate Dwell_lRevRate Roam_sRevRate Roam_lRevRate DwellRevRate_Vector RoamRevRate_Vector Dwell_sRevRate_Vector Dwell_lRevRate_Vector Roam_sRevRate_Vector Roam_lRevRate_Vector] = CreateRevMatrix2_HMM_useN2HMM(finalTracks,N2_TR,N2_E)
Rev_Dwell = [];
Rev_Roam = [];
 finalTracks2 = finalTracks;
 [expNewSeq expStates estTR estE] = getHMMStatesSpecifyTRandE_2(finalTracks,30,N2_TR,N2_E);
 [stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurationsInclEnds_HMM(expStates,.333);
 
 for(j=1:length(stateDurationMaster))
        startTime = finalTracks(j).Frames(1);
        for(i=1:length(stateDurationMaster(j).stateCalls(:,1)))
            %display(stateDurationMaster(j).stateCalls)
            stopTime = startTime + (stateDurationMaster(j).stateCalls(i,2)*3);
            stateDurationMaster(j).stateCalls(i,3) = startTime; % adjust for startFrame, and seconds to Frames
            stateDurationMaster(j).stateCalls(i,4) = stopTime;
            startTime = stopTime;
            
        end
 end
 %[mean_dw_stab mean_dw_stab_err mean_dw_stab_vector mean_ro_stab mean_ro_stab_err mean_ro_stab_vector] = analyzeStateStability(expNewSeq, expStates);
 %[stateList startingStateMap] = getStateSliding_Diff(finalTracks,finalTracks2,450,30,3,35,57,3);
% %[stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurations(stateList,.333);
 allStateCalls = [];
 for(j = 1:(length(expStates)))
 
     allStateCalls = [allStateCalls expStates(j).states];
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

all_sRev_categories = {'pure_sRev' 'pure_sRev.ring' 'sRevOmega' 'sRevOmega.ring' 'sRevUpsilon' 'sRevUpsilon.ring'};
all_lRev_categories = {'pure_lRev' 'pure_lRev.ring' 'lRevOmega' 'lRevOmega.ring' 'lRevUpsilon' 'lRevUpsilon.ring'};
all_leftover_categories = {'pure_omega' 'pure_omega.ring'  'pure_Upsilon'    'pure_Upsilon.ring'};

%Go through tracks and remove all upsilons/omegas - so that every remaining event
%will be tallied

for(j=1:length(finalTracks))
    deleter_index = [];
    ReOr_Here = finalTracks(j).Reorientations;
    numEventsHere = length(ReOr_Here);
    for(i=1:numEventsHere)
        eventType = finalTracks(j).Reorientations(i).class;
        if(sum(strcmp(eventType,all_leftover_categories))>0) % if it is non-rev
            deleter_index = [deleter_index i];
        end
    end
    finalTracks(j).Reorientations(deleter_index) = [];
end

for(j = 1:length(finalTracks))
    display(j)
    if(length(finalTracks(j).Reorientations)>0)
        Revs = cell2num({finalTracks(j).Reorientations(:).start})+ finalTracks(j).Frames(1)-1; % Rev starts, in frames (not ind)
    
        DwellFrames = find(expStates(j).states==1)+finalTracks(j).Frames(1)-1; % Dwelling frames, in frames (not ind)
        RoamFrames = find(expStates(j).states==2)+finalTracks(j).Frames(1)-1;
       % if (finalTracks(j).Reversals(1,1) < finalTracks(j).Frames(1))
        %else
       %    DwellFrames = DwellFrames + finalTracks(j).Frames(1)-1;
           %stateDurationMaster(j).stateCalls(:,3) = stateDurationMaster(j).stateCalls(:,3)+ finalTracks(j).Frames(1)-1;
           %stateDurationMaster(j).stateCalls(:,4) = stateDurationMaster(j).stateCalls(:,3)+ finalTracks(j).Frames(1)-1;
        %end
        
        for (i=1:length(Revs))
            RevFrame = Revs(i);
            a = find(DwellFrames==RevFrame);
            b = find(RoamFrames==RevFrame);
            %%%%%Find state duration
            for(m=1:length(stateDurationMaster(j).stateCalls(:,1)))
                if(RevFrame<=stateDurationMaster(j).stateCalls(m,4))
                    if(RevFrame>=stateDurationMaster(j).stateCalls(m,3))
                        stateDuration = stateDurationMaster(j).stateCalls(m,4)-stateDurationMaster(j).stateCalls(m,3); % in frames
                        stateDuration = stateDuration/3;

                    end
                end
            end
            if(a>0) % then Rev was during a Dwell
                %DwellIndex = [DwellIndex i];
                RevMatrix(indexRevMatrix,1) = 1; % Rev id #
                RevMatrix(indexRevMatrix,2) = j; % associated track #
                RevMatrix(indexRevMatrix,3) =  finalTracks(j).Reorientations(i).end + finalTracks(j).Frames(1); % Rev End, In frames, not indices
                RevMatrix_class{indexRevMatrix} =  {finalTracks(j).Reorientations(i).class}; % Rev Type
                RevMatrix(indexRevMatrix,4) =  finalTracks(j).Reorientations(i).revLen; % Rev Length
                RevMatrix(indexRevMatrix,5) =  stateDuration;
                indexRevMatrix = indexRevMatrix + 1;

            elseif(b>0)
                %RoamIndex = [RoamIndex i];
                RevMatrix(indexRevMatrix,1) = 2; % Rev id #
                RevMatrix(indexRevMatrix,2) = j; % associated track #
                RevMatrix(indexRevMatrix,3) =  finalTracks(j).Reorientations(i).end + finalTracks(j).Frames(1); % Rev End, In frames, not indices
                RevMatrix_class{indexRevMatrix} =  {finalTracks(j).Reorientations(i).class}; % Rev Type
                RevMatrix(indexRevMatrix,4) =  finalTracks(j).Reorientations(i).revLen; % Rev Type
                RevMatrix(indexRevMatrix,5) =  stateDuration;
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
    ThisTrackRevs = RevMatrix(RevIndforThisTracks,:);
    ThisTrackRevs_class = RevMatrix_class(RevIndforThisTracks);
    ThisTrack_RoDw = ThisTrackRevs(:,1);
    
    ThisTrack_Dw_Ind = find(ThisTrack_RoDw == 1);
    
    %Find #srevs and #lrevs during dwells
    RevClass_Dwell_Temp = ThisTrackRevs_class(ThisTrack_Dw_Ind);
    Num_Dwell_sRevs_Temp = 0;
    Num_Dwell_lRevs_Temp = 0;
    for(l = 1:length(RevClass_Dwell_Temp))
        display(l)
        eventType = RevClass_Dwell_Temp(l);
        celldisp(eventType)
        if(sum(strcmp(eventType{1},all_sRev_categories))>0)
            display('dwell s')
            %then it is a sRev
            Num_Dwell_sRevs_Temp =Num_Dwell_sRevs_Temp+1;
        elseif(sum(strcmp(eventType{1},all_lRev_categories))>0)
            display('dwell l')
            %then it is a lRev
            Num_Dwell_lRevs_Temp = Num_Dwell_lRevs_Temp+1;
        end
    end
    %
     AnimDwellBins = length(find(expStates(j).states==1));
     AnimRoamBins =length(find(expStates(j).states==2));
     DwellTime_Temp = AnimDwellBins/180;
     RoamTime_Temp = AnimRoamBins/180;
    Dwell_sRevRate_Temp(j) = Num_Dwell_sRevs_Temp/DwellTime_Temp;
    Dwell_lRevRate_Temp(j) = Num_Dwell_lRevs_Temp/DwellTime_Temp;
    Dwell_revRate_Temp(j) = Num_Revs_Dw/DwellTime_Temp;
    
    ThisTrack_Ro_Ind = find(ThisTrack_RoDw == 2); 

    
    %Find #srevs and #lrevs during roams
    RevClass_Roam_Temp = ThisTrackRevs_class(ThisTrack_Ro_Ind);
    Num_Roam_sRevs_Temp = 0;
    Num_Roam_lRevs_Temp = 0;
    for(l = 1:length(RevClass_Roam_Temp))
        eventType = RevClass_Roam_Temp(l);
        if(sum(strcmp(eventType{1},all_sRev_categories))>0)
            %then it is a sRev
            Num_Roam_sRevs_Temp =Num_Roam_sRevs_Temp+1;
        elseif(sum(strcmp(eventType{1},all_lRev_categories))>0)
            %then it is a lRev
            Num_Roam_lRevs_Temp = Num_Roam_lRevs_Temp+1;
        end
    end
    
    if(RoamTime_Temp>=1)
    Roam_sRevRate_Temp(j) = Num_Roam_sRevs_Temp/RoamTime_Temp
    Roam_lRevRate_Temp(j) = Num_Roam_lRevs_Temp/RoamTime_Temp
    Roam_revRate_Temp(j) = Num_Revs_Ro/RoamTime_Temp
    else
        Roam_sRevRate_Temp(j) = NaN;
         Roam_lRevRate_Temp(j) = NaN;
       Roam_revRate_Temp(j) = NaN;
    end   
    display(Num_Revs_Ro)
    display(RoamTime_Temp)
    %pause;
end

%Get Rid of NaN entries in Rev Rate measurements
Dwell_revRate_Temp = Dwell_revRate_Temp(~isnan(Dwell_revRate_Temp));
Roam_revRate_Temp = Roam_revRate_Temp(~isnan(Roam_revRate_Temp));
Dwell_sRevRate_Temp = Dwell_sRevRate_Temp(~isnan(Dwell_sRevRate_Temp));
Dwell_lRevRate_Temp = Dwell_lRevRate_Temp(~isnan(Dwell_lRevRate_Temp));
Roam_sRevRate_Temp = Roam_sRevRate_Temp(~isnan(Roam_sRevRate_Temp));
Roam_lRevRate_Temp = Roam_lRevRate_Temp(~isnan(Roam_lRevRate_Temp));


DwellRevRate(1) = mean(Dwell_revRate_Temp);
DwellRevRate(2) = (std(Dwell_revRate_Temp))/(sqrt(length(Dwell_revRate_Temp)));
DwellRevRate_Vector = Dwell_revRate_Temp;
RoamRevRate(1) = mean(Roam_revRate_Temp);
RoamRevRate(2) = (std(Roam_revRate_Temp))/(sqrt(length(Roam_revRate_Temp)));
RoamRevRate_Vector = Roam_revRate_Temp;
Dwell_sRevRate(1) = mean(Dwell_sRevRate_Temp);
Dwell_sRevRate(2) = (std(Dwell_sRevRate_Temp))/(sqrt(length(Dwell_sRevRate_Temp)));
Dwell_sRevRate_Vector = Dwell_sRevRate_Temp;
Dwell_lRevRate(1)  = mean(Dwell_lRevRate_Temp);
Dwell_lRevRate(2) = (std(Dwell_lRevRate_Temp))/(sqrt(length(Dwell_lRevRate_Temp)));
Dwell_lRevRate_Vector = Dwell_lRevRate_Temp;
Roam_sRevRate(1) = mean(Roam_sRevRate_Temp);
Roam_sRevRate(2) = (std(Roam_sRevRate_Temp))/(sqrt(length(Roam_sRevRate_Temp)));
Roam_sRevRate_Vector = Roam_sRevRate_Temp;
Roam_lRevRate(1) = mean(Roam_lRevRate_Temp);
Roam_lRevRate(2) = (std(Roam_lRevRate_Temp))/(sqrt(length(Roam_lRevRate_Temp)));
Roam_lRevRate_Vector = Roam_lRevRate_Temp;
    
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