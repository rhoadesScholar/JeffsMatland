function [mean_dw_stab mean_dw_stab_err mean_dw_stab_vector mean_ro_stab mean_ro_stab_err mean_ro_stab_vector all_dw_speed_info all_ro_speed_info] = analyzeStateStability(expNewSeq, expStates, allTracks)
mean_dw_stab_vector = [];
mean_ro_stab_vector = [];

PixelSizeVideo = allTracks(1).PixelSize;

%Convert speed to 1-s stepsize
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
    Xdif = CalcDif(allTracks(i).SmoothX, 3) * 3; % At StepSize=5sec
    Ydif = -CalcDif(allTracks(i).SmoothY, 3) * 3; % At StepSize=5sec
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
    allTracks(i).Speed = sqrt(Xdif.^2 + Ydif.^2)*PixelSizeVideo; % don't hard code pixelsize
    allTracks(i).Speed(1:10) = NaN;
end
    

for(i=1:length(expStates))
        DwellFrames = find(expStates(i).states==1);
        numDwellFrames = length(DwellFrames);
        RoamFrames = find(expStates(i).states==2);
        numRoamFrames = length(RoamFrames);
        NewSeqDuringDw = expNewSeq(i).states(DwellFrames);
        NewSeqDuringRo = expNewSeq(i).states(RoamFrames);
        SpeedDuringDw = allTracks(i).Speed(DwellFrames);
        SpeedDuringRo = allTracks(i).Speed(RoamFrames);
        NumNewSeqDw_duringDw = length(find(NewSeqDuringDw==1));
        NumNewSeqRo_duringRo = length(find(NewSeqDuringRo==2));
        percentTimeDwDuringDw = NumNewSeqDw_duringDw/numDwellFrames;
        percentTimeRoDuringRo = NumNewSeqRo_duringRo/numRoamFrames;
        if(NumNewSeqDw_duringDw>0)
        mean_dw_stab_vector = [mean_dw_stab_vector percentTimeDwDuringDw];
        all_dw_speed_info{i} = SpeedDuringDw;
        end
        if(NumNewSeqRo_duringRo>0)
        mean_ro_stab_vector = [mean_ro_stab_vector percentTimeRoDuringRo];
        all_ro_speed_info{i} = SpeedDuringRo;
        end
end
    
mean_dw_stab = mean(mean_dw_stab_vector);
mean_dw_stab_err = (std(mean_dw_stab_vector))/(sqrt(length(mean_dw_stab_vector)));

mean_ro_stab = mean(mean_ro_stab_vector);
mean_ro_stab_err = (std(mean_ro_stab_vector))/(sqrt(length(mean_ro_stab_vector)));
end
