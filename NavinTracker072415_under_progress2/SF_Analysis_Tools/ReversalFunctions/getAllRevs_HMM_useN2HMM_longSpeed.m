%%%%%% THIS FUNCTION GETS ALL THE REVERSALS IN ALL OF THE FINALTRACKS FILES
%%%%%% IN THE FOLDER CHOSEN.  IT THEN ASSIGNS EACH REV TO THE ROAMING OR
%%%%%% DWELLING STATE AND CALCULATES THE SPEED FOR 3 SECONDS AFTER THE
%%%%%% REVERSAL (FOR CASES WHERE THERE IS NO ADDITIONAL TURNING DURING THIS
%%%%%% TIME WINDOW).  IT ALSO RETURNS THE REVERSAL RATE (INCL lRevs and
%%%%%% sRevs) FOR BOTH ROAMING AND DWELLING STATES.

function [ReversalInfo] = getAllRevs_HMM_useN2HMM_longSpeed(allTracks,N2_TR,N2_E)

%%%%%%%%%Make allTracks file with all tracks in it

%     PathofFolder = sprintf('%s/',folder1);
%     dirList = ls(PathofFolder);
%     NumFolders = length(dirList(:,1));
%     allTracks = [];
%     for(i = 3:NumFolders)
%         string1 = deblank(dirList(i,:)); 
% 
%         PathName = sprintf('%s/%s/',PathofFolder,string1);
%         fileList = ls(PathName);
%         display(string1)
%         numFiles = length(fileList(:,1));
% 
%         for(j=3:1:numFiles)
%             string2 = deblank(fileList(j,:));
%             [pathstr, FilePrefix, ext] = fileparts(string2);
%              [pathstr2, FilePrefix2, ext2] = fileparts(FilePrefix);
% 
%             if(strcmp(ext2,'.finalTracks')==1)
%                 fileIndex = j;
%             end
%         end
%         fileName = deblank(fileList(fileIndex,:));
%         fileToOpen = sprintf('%s%s',PathName,fileName);
%         display(fileToOpen)
%         load(fileToOpen);
%         allTracks = [allTracks finalTracks];
%     end
%  
 %%%Make sure that all speed is at a 5 sec step size in this file
 
Prefs = [];
Prefs = define_preferences(Prefs);
Prefs.PixelSize = allTracks(1).PixelSize;
Prefs = CalcPixelSizeDependencies(Prefs, Prefs.PixelSize);
    
 for (i = 1:(length(allTracks)))
    %%%Calculate the final AngSpeed for this track at stepsize = 1sec
    Xdif = CalcDif(allTracks(i).SmoothX, 3) * 3; % At StepSize=1sec
    Ydif = -CalcDif(allTracks(i).SmoothY, 3) * 3; % At StepSize=1sec
    Direction = atan(Xdif./Ydif) * 360/(2*pi);
    % direction 0 = Up/North
    ZeroYdifIndexes = find(Ydif == 0);
    Ydif(ZeroYdifIndexes) = eps;     % Avoid division by zero in direction calculation

    Direction = atan(Xdif./Ydif) * 360/(2*pi);	    % In degrees, 0 = Up ("North")

    NegYdifIndexes = find(Ydif < 0);
    Index1 = find(Direction(NegYdifIndexes) <= 0);
    Index2 = find(Direction(NegYdifIndexes) > 0);
    Direction(NegYdifIndexes(Index1)) = Direction(NegYdifIndexes(Index1)) + 180;
    Direction(NegYdifIndexes(Index2)) = Direction(NegYdifIndexes(Index2)) - 180;
    allTracks(i).AngSpeed = CalcAngleDif(Direction, 3)*3;
    allTracks(i).AngSpeed(1:3) = NaN;
    %%%Calculate the all Speed for this track at StepSize = 5sec
    display(i)
    Xdif = CalcDif(allTracks(i).SmoothX, 15) * 3; % At StepSize=5sec
    Ydif = -CalcDif(allTracks(i).SmoothY, 15) * 3; % At StepSize=5sec
    Direction = atan(Xdif./Ydif) * 360/(2*pi);
    % direction 0 = Up/North
    ZeroYdifIndexes = find(Ydif == 0);
    Ydif(ZeroYdifIndexes) = eps;     % Avoid division by zero in direction calculation

    Direction = atan(Xdif./Ydif) * 360/(2*pi);	    % In degrees, 0 = Up ("North")

    NegYdifIndexes = find(Ydif < 0);
    Index1 = find(Direction(NegYdifIndexes) <= 0);
    Index2 = find(Direction(NegYdifIndexes) > 0);
    Direction(NegYdifIndexes(Index1)) = Direction(NegYdifIndexes(Index1)) + 180;
    Direction(NegYdifIndexes(Index2)) = Direction(NegYdifIndexes(Index2)) - 180;
    allTracks(i).Speed = sqrt(Xdif.^2 + Ydif.^2)*Prefs.PixelSize;
    allTracks(i).Speed(1:10) = NaN;
 end
   
%%%%%%%%%%Create RevMatrix, which will have all the Reversals with
%%%%%%%%%%(1)Dwell/Roam call (2) trackNumb and (3) EndofRev
 
    %[RevMatrix DwellRevRate RoamRevRate Dwell_sRevRate Dwell_lRevRate Roam_sRevRate Roam_lRevRate DwellRevRate_Vector RoamRevRate_Vector Dwell_sRevRate_Vector Dwell_lRevRate_Vector Roam_sRevRate_Vector Roam_lRevRate_Vector] = CreateRevMatrix2_HMM(allTracks);
     [RevMatrix DwellRevRate RoamRevRate Dwell_sRevRate Dwell_lRevRate Roam_sRevRate Roam_lRevRate DwellRevRate_Vector RoamRevRate_Vector Dwell_sRevRate_Vector Dwell_lRevRate_Vector Roam_sRevRate_Vector Roam_lRevRate_Vector] = CreateRevMatrix2_HMM_useN2HMM(allTracks,N2_TR,N2_E);
   
    %%%%%%Change allTracks file so that speed is now analyzed at 1sec
    %%%%%%resolution
    
for (i = 1:(length(allTracks)))
    %%%Calculate the final AngSpeed for this track at stepsize = 1sec
    Xdif = CalcDif(allTracks(i).SmoothX, 3) * 3; % At StepSize=1sec
    Ydif = -CalcDif(allTracks(i).SmoothY, 3) * 3; % At StepSize=1sec
    Direction = atan(Xdif./Ydif) * 360/(2*pi);
    % direction 0 = Up/North
    ZeroYdifIndexes = find(Ydif == 0);
    Ydif(ZeroYdifIndexes) = eps;     % Avoid division by zero in direction calculation

    Direction = atan(Xdif./Ydif) * 360/(2*pi);	    % In degrees, 0 = Up ("North")

    NegYdifIndexes = find(Ydif < 0);
    Index1 = find(Direction(NegYdifIndexes) <= 0);
    Index2 = find(Direction(NegYdifIndexes) > 0);
    Direction(NegYdifIndexes(Index1)) = Direction(NegYdifIndexes(Index1)) + 180;
    Direction(NegYdifIndexes(Index2)) = Direction(NegYdifIndexes(Index2)) - 180;
    allTracks(i).AngSpeed = CalcAngleDif(Direction, 3)*3;
    allTracks(i).AngSpeed(1:3) = NaN;
    %%%Calculate the all Speed for this track at StepSize = 5sec
    Xdif = CalcDif(allTracks(i).SmoothX, 3) * Prefs.FrameRate; % At StepSize=5sec
    Ydif = -CalcDif(allTracks(i).SmoothY, 3) * Prefs.FrameRate; % At StepSize=5sec
    Direction = atan(Xdif./Ydif) * 360/(2*pi);
    %direction 0 = Up/North
    ZeroYdifIndexes = find(Ydif == 0);
    Ydif(ZeroYdifIndexes) = eps;     % Avoid division by zero in direction calculation

    Direction = atan(Xdif./Ydif) * 360/(2*pi);	    % In degrees, 0 = Up ("North")

    NegYdifIndexes = find(Ydif < 0);
    Index1 = find(Direction(NegYdifIndexes) <= 0);
    Index2 = find(Direction(NegYdifIndexes) > 0);
    Direction(NegYdifIndexes(Index1)) = Direction(NegYdifIndexes(Index1)) + 180;
    Direction(NegYdifIndexes(Index2)) = Direction(NegYdifIndexes(Index2)) - 180;
    allTracks(i).Speed = sqrt(Xdif.^2 + Ydif.^2)*Prefs.PixelSize; % don't hard code pixelsize
    allTracks(i).Speed(1:10) = NaN;
end
    
    %%%%%Go through RevMatrix and get the 3sec after, where there is no additional turning during this time window.
    
    DwellSpeedMatrix = [];
    RoamSpeedMatrix = [];
    indexDwell = 1;
    indexRoam = 1;
    indexDwellsRev = 1;
    indexDwelllRev = 1;
    indexRoamsRev = 1;
    indexRoamlRev = 1;
    lRevRoamSpeedMatrix = [];
    sRevRoamSpeedMatrix = [];
    lRevDwellSpeedMatrix = [];
    sRevDwellSpeedMatrix = [];
    RoamAngSpeedMatrix = [];
    RoamSpeedMatrix =[];
    DwellAngSpeedMatrix =[];
    DwellSpeedMatrix =[];
    NumRevs = length(RevMatrix(:,1));
    for (k = 1:NumRevs)
        StateDuration = RevMatrix(k,5);
        EndofRev = RevMatrix(k,3); % In indices
        trackNumb = RevMatrix(k,2);
        SevenSecAfterPlusOne = (EndofRev+2):(EndofRev+16); %indices
        %if(StateDuration<2000) %%%%%%%%%%%%%%% Figure this out
        if(SevenSecAfterPlusOne(end) <= allTracks(trackNumb).NumFrames)
            %%%adjust for Framestart
            %if (allTracks(trackNumb).Reversals(1,1) < allTracks(trackNumb).Frames(1))
            %else
           %   SevenSecAfterPlusOne = SevenSecAfterPlusOne - allTracks(trackNumb).Frames(1) +1;
           %end
            %FirstFrame = allTracks(trackNumb).Frames(1);
            %display(FirstFrame)
            %ThreeSecAfterPlusOne = ThreeSecAfterPlusOne - FirstFrame + 1;
            %display(ThreeSecAfterPlusOne)
            AngSpeedPostRev = allTracks(trackNumb).AngSpeed(SevenSecAfterPlusOne);
            AngSpeedPostRev = abs(AngSpeedPostRev);
            check1 = find(AngSpeedPostRev>60);
            checkforNans = isnan(AngSpeedPostRev);
            allnans = sum(checkforNans);
            if(allnans == 0)
                if (check1>0)
                else
                    SevenSecAfter = (EndofRev+2):(EndofRev+15);
                    %%%adjust for Framestart
                    
                    %if (allTracks(trackNumb).Reversals(1,1) < allTracks(trackNumb).Frames(1))
                    %else
                    %  SevenSecAfter = SevenSecAfter - allTracks(trackNumb).Frames(1) +1;
                   %end

                    %ThreeSecAfter = ThreeSecAfter - FirstFrame + 1;
                    SpeedPostRev =  allTracks(trackNumb).Speed(SevenSecAfter);
                    AngSpeedPostRev =  allTracks(trackNumb).AngSpeed(SevenSecAfter);
                    if (RevMatrix(k,1) == 1)
                        DwellSpeedMatrix(indexDwell,1) = trackNumb;
                        DwellSpeedMatrix(indexDwell,2:15) = SpeedPostRev;
                        DwellAngSpeedMatrix(indexDwell,2:15) = AngSpeedPostRev;
                        DwellSpeedMatrix(indexDwell,16) = StateDuration;
                        indexDwell = indexDwell + 1;
                    elseif(RevMatrix(k,1) ==2)

                        RoamSpeedMatrix(indexRoam,1) = trackNumb;
                        RoamSpeedMatrix(indexRoam,2:15) = SpeedPostRev;
                        RoamSpeedMatrix(indexRoam,16) = StateDuration;
                        RoamAngSpeedMatrix(indexRoam,2:15) = AngSpeedPostRev;
                        indexRoam = indexRoam + 1;
                    end
                    
%                     if (RevMatrix(k,4) < 0.3)
%                         if (RevMatrix(k,1) == 1)
%                             sRevDwellSpeedMatrix(indexDwellsRev,1) = trackNumb;
%                             sRevDwellSpeedMatrix(indexDwellsRev,2:15) = SpeedPostRev;
%                             sRevDwellSpeedMatrix(indexDwellsRev,16) = StateDuration;
%                             indexDwellsRev = indexDwellsRev + 1;
%                         end
%                     else
%                         if (RevMatrix(k,1) == 1)
%                             lRevDwellSpeedMatrix(indexDwelllRev,1) = trackNumb;
%                             lRevDwellSpeedMatrix(indexDwelllRev,2:15) = SpeedPostRev;
%                             lRevDwellSpeedMatrix(indexDwelllRev,16) = StateDuration;
%                             indexDwelllRev = indexDwelllRev +1;
%                         end
%                     end
%                     
%                     if (RevMatrix(k,4) < 0.3)
%                         if (RevMatrix(k,1) == 2)
%                             sRevRoamSpeedMatrix(indexRoamsRev,1) = trackNumb;
%                             sRevRoamSpeedMatrix(indexRoamsRev,2:15) = SpeedPostRev;
%                             sRevRoamSpeedMatrix(indexRoamsRev,16) = StateDuration;
%                             indexRoamsRev = indexRoamsRev + 1;
%                         end
%                     else
%                         if (RevMatrix(k,1) == 2)
%                             lRevRoamSpeedMatrix(indexRoamlRev,1) = trackNumb;
%                             lRevRoamSpeedMatrix(indexRoamlRev,2:15) = SpeedPostRev;
%                             lRevRoamSpeedMatrix(indexRoamlRev,16) = StateDuration;
%                             indexRoamlRev = indexRoamlRev +1;
%                         end
%                     end
                end 
                end
            end
        %end
    end
    
    %%%%%Put output variables into a structure format
    
    ReversalInfo = struct('DwellSpeedMatrix',[],'RoamSpeedMatrix',[],'sRevDwellSpeedMatrix',[],'lRevDwellSpeedMatrix',[],'sRevRoamSpeedMatrix',[],'lRevRoamSpeedMatrix',[],'DwellAngSpeedMatrix',[],'RoamAngSpeedMatrix',[],'DwellRevRate',[],'RoamRevRate',[],'Dwell_sRevRate',[],'Dwell_lRevRate',[],'Roam_sRevRate',[],'Roam_lRevRate',[],'DwellRevRate_Vector',[],'RoamRevRate_Vector',[],'Dwell_sRevRate_Vector',[],'Dwell_lRevRate_Vector',[],'Roam_sRevRate_Vector',[],'Roam_lRevRate_Vector',[]);
    ReversalInfo.DwellSpeedMatrix = DwellSpeedMatrix;
    ReversalInfo.RoamSpeedMatrix = RoamSpeedMatrix;
    
%     ReversalInfo.sRevDwellSpeedMatrix = sRevDwellSpeedMatrix;
%     ReversalInfo.lRevDwellSpeedMatrix = lRevDwellSpeedMatrix;
%     ReversalInfo.sRevRoamSpeedMatrix = sRevRoamSpeedMatrix;
%     ReversalInfo.lRevRoamSpeedMatrix = lRevRoamSpeedMatrix;

    ReversalInfo.DwellAngSpeedMatrix = DwellAngSpeedMatrix;
    ReversalInfo.RoamAngSpeedMatrix = RoamAngSpeedMatrix;
    dwellspeedmean =[];
    roamspeedmean= [];
    srevdwellspeedmean = [];
    lrevdwellspeedmean = [];
    srevroamspeedmean = [];
    lrevroamspeedmean = [];
    if (length(DwellSpeedMatrix)>1)
    for (i=1:9) dwellspeedmean(i) = nanmean(DwellSpeedMatrix(:,i+1)); end;
    end
    
    if (length(RoamSpeedMatrix)>1)
    for (i=1:9) roamspeedmean(i) = nanmean(RoamSpeedMatrix(:,i+1)); end;
    end
    
%     if (length(sRevDwellSpeedMatrix)>1)
%     for (i=1:9) srevdwellspeedmean(i) = nanmean(sRevDwellSpeedMatrix(:,i+1)); end;
%     end
%     
%     if (length(lRevDwellSpeedMatrix)>1)
%     for (i=1:9) lrevdwellspeedmean(i) = nanmean(lRevDwellSpeedMatrix(:,i+1)); end;
%     end
%     
%     if (length(sRevRoamSpeedMatrix)>1)
%     for (i=1:9) srevroamspeedmean(i) = nanmean(sRevRoamSpeedMatrix(:,i+1)); end;
%     end
%     
%     if (length(lRevRoamSpeedMatrix)>1)
%     for (i=1:9) lrevroamspeedmean(i) = nanmean(lRevRoamSpeedMatrix(:,i+1)); end;
%     end
    
    
    DwellAngSpeedMatrix = abs(DwellAngSpeedMatrix);
    RoamAngSpeedMatrix = abs(RoamAngSpeedMatrix);
    dwellangspeedmean = [];
    roamangspeedmean = [];
    if (length(DwellAngSpeedMatrix)>1)
    for(i=1:9) dwellangspeedmean(i) = mean(DwellAngSpeedMatrix(:,i+1)); end;
    end
    
    if (length(RoamAngSpeedMatrix)>1)
    for(i=1:9) roamangspeedmean(i) = mean(RoamAngSpeedMatrix(:,i+1)); end;
    end
    
    ReversalInfo.dwellspeedmean = dwellspeedmean;
    ReversalInfo.roamspeedmean = roamspeedmean;
    
%     ReversalInfo.srevdwellspeedmean = srevdwellspeedmean;
%     ReversalInfo.lrevdwellspeedmean = lrevdwellspeedmean;
%     ReversalInfo.srevroamspeedmean = srevroamspeedmean;
%     ReversalInfo.lrevroamspeedmean = lrevroamspeedmean;

    ReversalInfo.dwellangspeedmean = dwellangspeedmean;
    ReversalInfo.roamangspeedmean = roamangspeedmean;
    
     ReversalInfo.DwellRevRate = DwellRevRate;
     ReversalInfo.RoamRevRate = RoamRevRate;
%      ReversalInfo.Dwell_sRevRate = Dwell_sRevRate;
%      ReversalInfo.Dwell_lRevRate = Dwell_lRevRate;
%      ReversalInfo.Roam_sRevRate = Roam_sRevRate;
%      ReversalInfo.Roam_lRevRate = Roam_lRevRate;
    
     ReversalInfo.DwellRevRate_Vector = DwellRevRate_Vector;
     ReversalInfo.RoamRevRate_Vector = RoamRevRate_Vector;
%      ReversalInfo.Dwell_sRevRate_Vector = Dwell_sRevRate_Vector;
%      ReversalInfo.Dwell_lRevRate_Vector = Dwell_lRevRate_Vector;
%      ReversalInfo.Roam_sRevRate_Vector = Roam_sRevRate_Vector;
%      ReversalInfo.Roam_lRevRate_Vector = Roam_lRevRate_Vector;
    
    


end
