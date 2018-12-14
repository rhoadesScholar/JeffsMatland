function leaving_events_per_min_on_lawn = lawn_leaving_analysis(Moviename, framerate, timerbox_flag)
% leaving_events_per_min_on_lawn = lawn_leaving_analysis(Moviename, framerate, timerbox_flag)

global Prefs;
Prefs = define_preferences(Prefs);

if(nargin<1)
    disp('leaving_events_per_min_on_lawn = lawn_leaving_analysis(Moviename, [framerate], [timerbox_flag])')
    disp('if framerate not defined, default to 1 frame/sec');
    disp('set timerbox_flag if there is a timer box in the corner (default blank)');
    return;
end

if(nargin<2)
    framerate = 1;
end

[~, FilePrefix] = fileparts(Moviename);

Prefs.Ringtype = 'holepunch';

Ring = find_ring(Moviename);
lawn_edge = horzcat(Ring.RingX, Ring.RingY);
lawn_center = mean(lawn_edge);
len_lawn_edge = length(lawn_edge);

linkedTracks_filename = sprintf('%s.linkedTracks.mat', FilePrefix);

if(does_this_file_need_making(linkedTracks_filename))
    if(nargin>2)
        TrackerAutomatedScript(Moviename,'holepunch','framerate',framerate,'timerbox');
    else
        TrackerAutomatedScript(Moviename,'holepunch','framerate',framerate);
    end
end




Prefs = CalcPixelSizeDependencies(Prefs,Ring.PixelSize);

linkedTracks = load_Tracks(linkedTracks_filename);

lawnTracks = lawn_edge_to_stimulus_vector(linkedTracks, lawn_edge);

for(i=1:length(lawnTracks))
    lawnTracks(i).InLawn = zeros(1,length(lawnTracks(i).Frames));
    idx = find(lawnTracks(i).stimulus_vector == Prefs.LawnCode);
    lawnTracks(i).InLawn(idx) = 1;
    
    for(j=1:length(lawnTracks(i).Frames))
        XPos = lawnTracks(i).SmoothX(j)*ones(len_lawn_edge,1);
        YPos = lawnTracks(i).SmoothY(j)*ones(len_lawn_edge,1);
        LawnEdgeD = CalcDist(XPos,YPos,lawn_edge(:,1),lawn_edge(:,2));
        lawnTracks(i).LawnDist(j) = min(LawnEdgeD);
        lawnTracks(i).DistFromCenter(j) = CalcDist(lawnTracks(i).SmoothX(j),lawnTracks(i).SmoothY(j),lawn_center(1),lawn_center(2));
    end
    lawnTracks(i).LawnDist = lawnTracks(i).LawnDist.*lawnTracks(i).PixelSize;
    lawnTracks(i).DistFromCenter = lawnTracks(i).DistFromCenter.*lawnTracks(i).PixelSize;
    
    lawnTracks(i).LawnInterval = lawn_intervals(lawnTracks(i));
end
dummystring = sprintf('%s.lawnTracks.mat', FilePrefix);
save_Tracks(dummystring,lawnTracks);

leaving_events_per_min_on_lawn = LawnLeavingResults(lawnTracks);
    
return;
end

function LI = lawn_intervals(lawnTrack)

% identifies lawn-leaving events (LI) in the lawnTrack data.
% Identified LIs are stored in Track as two columns of indices - the first
% indicating LI start indices, the second indicating corresponding
% LI end indices. 

LIThresh = 5*lawnTrack.FrameRate;

LawnFrame = find(lawnTrack.InLawn == 1);

if isempty(LawnFrame)
    LI = [];
else
    LawnEndI = find(diff(LawnFrame) > LIThresh);
    if isempty(LawnEndI)
        if max(LawnFrame) <= lawnTrack.NumFrames - LIThresh
            LI = [LawnFrame(1), LawnFrame(length(LawnFrame))];
        else
            LI = [];
        end
    else
        LI = [LawnFrame(1), LawnFrame(LawnEndI(1))];
        for j = 1:length(LawnEndI)-1
            LI = [LI; LawnFrame(LawnEndI(j)+1), LawnFrame(LawnEndI(j+1))];
        end

            LI = [LI; LawnFrame(LawnEndI(length(LawnEndI))+1), LawnFrame(length(LawnFrame))];
    end
end

return;
end

function leaving_events_per_min_on_lawn = LawnLeavingResults(lawnTracks)


FrameRate = lawnTracks(1).FrameRate;

% Process Reorientations Data
% -----------------------
Len = max([lawnTracks.Frames]);
% BinNum = round(Len/(FrameRate*30));


LL = [];
LRsingletrack = [];
LR = [];
Time_close_to_border = 0;
TotalTimeOnLawn = [];
TOA = [];


[~, t] = hist([lawnTracks.Time], [1:Len]/FrameRate);
%     lawnTracksHistRecalc = lawnTracksHist;
LTime = [];
Speed = [];
DistFromCenter = [];
OnLawnTimeIndex = [];
OffLawnTimeIndex = [];

for i = 1:length(lawnTracks)
    OnLawn = lawnTracks(i).LawnInterval;
    
    if ~isempty(OnLawn)
        % Collect all Lawn-leaving events
        LL = [LL, lawnTracks(i).Time(OnLawn(:,2))];
        
        % lawnTracks(i).Time(OnLawn(:,2))
        
        if LL(length(LL)) == lawnTracks(i).Time(lawnTracks(i).NumFrames)
            LL(length(LL)) = [];
        end
        
        %Collect all Lawn-return events
        if length(lawnTracks(i).Time) > 5
            LRsingletrack = lawnTracks(i).Time(OnLawn(:,1));
            if LRsingletrack(1) < lawnTracks(i).Time(6) %DO not count as return event if Lawn-interval starts in the first 6 seconds (frames) of the track, because that is probably not a return event.
                LRsingletrack(1) = [];
            end
            LR = [LR, LRsingletrack];
        end
    end
    
    
    %lawnTracks that start close to lawn
    if lawnTracks(i).InLawn(1) == 0
        if lawnTracks(i).LawnDist(1) < 2
            LL = [LL, lawnTracks(i).Time(1)];
        end
    end
    
    %lawnTracks that end close to lawn
    LastFrame = length(lawnTracks(i).InLawn);
    if lawnTracks(i).InLawn(LastFrame) == 0
        if lawnTracks(i).LawnDist(LastFrame) < 2
            LR = [LR, lawnTracks(i).Time(LastFrame)];
        end
    end
    
    %Frames close to border of lawn
    for n = 1:length(lawnTracks(i).DistFromCenter)
        if lawnTracks(i).DistFromCenter(n) > 3
            Time_close_to_border = Time_close_to_border + lawnTracks(i).InLawn(n);
        end
    end
    
    %collect time when animal is on lawn
    OnLawnNum = size(OnLawn);
    OnLawnI = [];
    for n = 1:OnLawnNum(1)
        LIndex = [OnLawn(n,1):OnLawn(n,2)];
        LTime = [LTime,lawnTracks(i).Time(LIndex)];
        
        %collect frames when animal is on lawn
        OnLawnI = [OnLawnI,LIndex];
    end
    
    %Collect time when animal is on lawn based on number of animals per
    %track
    TotalTimeOnLawn = [TotalTimeOnLawn, sum(lawnTracks(i).InLawn)];
    
    
    % Computations for non-clump lawnTracks
    
    %   Average speed vs. distance from center of lawn
    Speed = [Speed, lawnTracks(i).Speed];
    DistFromCenter = [DistFromCenter, lawnTracks(i).DistFromCenter];
end

%Display total time inside lawn (in mins) based number of animals per track
TotalTimeOnLawn = sum(TotalTimeOnLawn)/(lawnTracks(1).FrameRate*60);

Time_close_to_border = Time_close_to_border/(lawnTracks(1).FrameRate*60);  %Converted to minutes

%Display total time inside lawn (calculated based on leaving and returns), leaving events, and probability of leaving
[timeinlawn, leavingevents, PofLeaving, PofLeavingClump, PofLeavingBorder] = probabilityofleaving(LL, LR, TotalTimeOnLawn, Time_close_to_border, lawnTracks);

%Average Speed On Lawn vs Off Lawn
SpeedOnLawn = [];
SpeedOffLawn = [];
for(i=1:length(lawnTracks))
    SpeedOnLawn = [SpeedOnLawn lawnTracks(i).Speed.*lawnTracks(i).InLawn];
    SpeedOffLawn = [SpeedOffLawn lawnTracks(i).Speed.*(~lawnTracks(i).InLawn)];
end
AverageSpeedOnLawn = nanmean(SpeedOnLawn);
AverageSpeedOffLawn = nanmean(SpeedOffLawn);
%----------------

[lawnTracksOnLawnHist, t] = hist([OnLawnTimeIndex], [1:Len]/FrameRate);
LawnFrameHistRecalc = lawnTracksOnLawnHist;

[lawnTracksOffLawnHist, t] = hist([OffLawnTimeIndex], [1:Len]/FrameRate);
OffLawnFrameHistRecalc = lawnTracksOffLawnHist;

LawnHist = hist(LTime, t);
LLHist = hist(LL, t);

trx = find_Track(lawnTracks,'Frames','==1');
NumWormsOnLawnFrame1 = 0;
for(i=1:length(trx))
    NumWormsOnLawnFrame1 = NumWormsOnLawnFrame1 + lawnTracks(trx(i).track_idx).InLawn(trx(i).frame_idx);
end

x = track_field_to_matrix(lawnTracks, 'InLawn');
num_animals_on_lawn = nansum(x);

leaving_events_per_min_on_lawn = PofLeavingClump/nanmean(num_animals_on_lawn);

% %     % Plot Results
% %     % ------------
% %
%     [~,prefix] = fileparts(lawnTracks(1).Name);
% 
%     SpeedFigH = figure(1);
% 
%     str1a(1) = {'Total time on lawn based on area: '};
%     str1b(1) = {num2str(TotalTimeOnLawn)};
%     str1c(1) = {' mins'};
%     str1(1) = strcat(str1a(1), str1b(1), str1c(1));
%     str1a(2) = {'Total time on lawn based on leaving and returning events: '};
%     str1b(2) = {num2str(timeinlawn)};
%     str1(2) = strcat(str1a(2), str1b(2), str1c(1));
%     str1a(3) = {'Total time on lawn close to border: '};
%     str1b(3) = {num2str(Time_close_to_border)};
%     str1(3) = strcat(str1a(3), str1b(3), str1c(1));
%     str1a(4) = {'Number of leaving events: '};
%     str1b(4) = {num2str(leavingevents)};
%     str1(4) = strcat(str1a(4), str1b(4));
%     str1a(5) = {'Probability of leaving based on area-time: '};
%     str1b(5) = {num2str(PofLeavingClump)};
%     str1c(5) = {' events/min'};
%     str1(5) = strcat(str1a(5), str1b(5), str1c(5));
%     str1a(6) = {'Probability of leaving based on leave-return-time: '};
%     str1b(6) = {num2str(PofLeaving)};
%     str1(6) = strcat(str1a(6), str1b(6), str1c(5));
%     str1a(7) = {'Probability of leaving based on time close to border: '};
%     str1b(7) = {num2str(PofLeavingBorder)};
%     str1(7) = strcat(str1a(7), str1b(7), str1c(5));
%     str1a(8) = {'Average speed on lawn: '};
%     str1b(8) = {num2str(AverageSpeedOnLawn)};
%     str1c(8) = {' mm/sec'};
%     str1(8) = strcat(str1a(8), str1b(8), str1c(8));
%     str1a(9) = {'Average speed off lawn: '};
%     str1b(9) = {num2str(AverageSpeedOffLawn)};
%     str1(9) = strcat(str1a(9), str1b(9), str1c(8));
%     str1a(10) = {'Number of worms on lawn at beginning of assay: '};
%     str1b(10) = {num2str(NumWormsOnLawnFrame1)};
%     str1(10) = strcat(str1a(10), str1b(10));
%     subplot(2,1,2), text(-0.08,0.7,str1,'FontName','Courier','FontSize',12);
%     axis off;

%     %Display all lawnTracks
%     hold off
%
%     lawnTracksFigH = figure('Name', ['All lawnTracks for file ' prefix], ...
%         'NumberTitle', 'off', ...
%         'Tag', 'lawnTracksFIG',...
%         'Position',[scrsz(3)/1.4 scrsz(4)/2 scrsz(3)/3 scrsz(4)/2]);
%     imshow(background, 'InitialMagnification', 67);
%     title(FileNameTEXT);
%     hold on;
%     for i = 1:length(lawnTracks)
%         figure(lawnTracksFigH);
%         plot(lawnTracks(i).SmoothX, lawnTracks(i).SmoothY, 'r');
%     end
%     hold off;

return;
end

function [timeinlawn, leavingevents, PofLeaving, PofLeavingClump, PofLeavingBorder] = probabilityofleaving(LL, LR, TotalTimeOnLawn, Time_close_to_border, lawnTracks)

%Calculates the time spent inside the lawn based on leaving and returning
%events

trx = find_Track(lawnTracks,'Frames','==1');
w0 = 0;
for(i=1:length(trx))
    w0 = w0 + lawnTracks(trx(i).track_idx).InLawn(trx(i).frame_idx);
end

sf = 1;

% leaving array (la) example
la = LL';
la = la - sf;
m = size(la,1);
Y = ones(m,1);
Y = -1.*Y;
Z = zeros(m,1);
lawithones = horzcat(la, Y, Z);

% returning array (ra) example
ra = LR';
ra = ra - sf;
m = size(ra,1);
Y = ones(m,1);
Z = zeros(m,1);
rawithones = horzcat(ra, Y, Z);

endframe = max_struct_array(lawnTracks,'Frames');

% Concatenate leaving array with returning array
lastframe = [endframe 0 0];
events = vertcat(lawithones, rawithones, lastframe);

% Sort events according to the order in which they happened
events = sortrows(events);

% Incorporate number of initial worms into array
events(1, 3) = w0;

% Actualize number of worms at each interval
for i = 1:(size(events,1) - 1)
    events((1 + i), 3) = events(i, 3) + events(i, 2);
end

% Calculate duration of each interval
for i = 1:(size(events,1) - 1)
    events((1 + i), 4) = events(1 + i, 1) - events(i, 1);
end

events(1, 4) = [events(1, 1)];

% Calculate time inside lawn per interval
events(:,5) = events(:,3).*events(:,4);

% Total time inside lawn
timeinlawn = sum(events(:,5)) /(lawnTracks(1).FrameRate*60); %Convert from seconds to minutes

%Number of leaving events
leavingevents = size(la,1);

%Probability of leaving in events per minute
PofLeaving = leavingevents / timeinlawn;

%Probability of leaving in events per minute based on time calculated by
%animals on each track
PofLeavingClump = leavingevents / TotalTimeOnLawn;

%Probability of leaving in events per minutes spent close to the border
PofLeavingBorder = leavingevents / Time_close_to_border;

return;
end





