function Track = AnalyseTrack(inputTrack, firstframe, lastframe)

% This function calculates and extracts the major parameters for Track

global Prefs;

OPrefs = Prefs;

if(nargin<2)
    Track = inputTrack;
else
    Track = extract_track_segment(inputTrack, firstframe, lastframe, 'frame');
end

if(length(Track)>1)
    inputTrack = Track;
    clear('Track');
    for(i=1:length(inputTrack))
        Track(i) = AnalyseTrack(inputTrack(i));
    end
    return;
end

Prefs.FrameRate = Track.FrameRate;
Prefs = CalcPixelSizeDependencies(Prefs, Track.PixelSize);

SmoothWinSize = Prefs.SmoothWinSize*Prefs.FrameRate;
StepSize = Prefs.StepSize*Prefs.FrameRate;

Track.NumFrames = length(Track.Frames);		    % Number of frames

if(~isfield(Track,'Time'))
    Track.Time = Track.Frames/Track.FrameRate;		% Calculate time of each frame
end

% Smooth Track data by sliding window of size SmoothWinSize;
if(isfield(Track,'Path'))
    Track.SmoothX = RecSlidingWindow(Track.Path(:,1)', SmoothWinSize);
    Track.SmoothY = RecSlidingWindow(Track.Path(:,2)', SmoothWinSize);
    Track = rmfield(Track,'Path');
end    
    
    % Calculate Direction & Speed
    Xdif = CalcDif(Track.SmoothX, StepSize) * Prefs.FrameRate;
    Ydif = -CalcDif(Track.SmoothY, StepSize) * Prefs.FrameRate;    % Negative sign allows "correct" direction
    
    % direction 0 = Up/North
    ZeroYdifIndexes = find(Ydif == 0);
    Ydif(ZeroYdifIndexes) = eps;     % Avoid division by zero in direction calculation
    
    Track.Direction = atan(Xdif./Ydif)*360/(2*pi);	    % In degrees, 0 = Up ("North")
    
    NegYdifIndexes = find(Ydif < 0);
    Index1 = find(Track.Direction(NegYdifIndexes) <= 0);
    Index2 = find(Track.Direction(NegYdifIndexes) > 0);
    Track.Direction(NegYdifIndexes(Index1)) = Track.Direction(NegYdifIndexes(Index1)) + 180;
    Track.Direction(NegYdifIndexes(Index2)) = Track.Direction(NegYdifIndexes(Index2)) - 180;
    
    Track.Speed = sqrt(Xdif.^2 + Ydif.^2)*Track.PixelSize;		% In mm/sec
    


Track.Wormlength = nanmedian(Track.MajorAxes)*Track.PixelSize;  % in mm
% contourlength of contour + center/corner pixel effect

if(Track.Wormlength == 0)
    sprintf('Warning: WormLength = 0')
end

% Calculate angular speed
Track.AngSpeed = CalcAngleDif(Track.Direction, StepSize)*Prefs.FrameRate;		% in deg/sec

% Identify Reorientations, Omegas, Reversals
Track = IdentifyRevOmega(Track);

Track.State = AssignLocomotionState(Track);
Track = worm_head_tail(Track);
[Track.body_angle, Track.head_angle, Track.tail_angle] = worm_body_angle(Track);

% deal with turns that were missed by IdentifyRevOmega, but are easily
% detected by body_angle ... IdentifyRevOmega uses delta-direction as a
% proxy for body angle changes, but it can miss things
Track = edit_Reorientations(Track);

Track = edit_weird_reversals(Track);

if(~isfield(Track,'curvature_vs_body_position_matrix')) % already exists ... likely reanalyzing linkedTracks to clean up junctions
    [curvature_vs_body_position_matrix, Track.midbody_angle] = curvature_vs_body_position(Track);
    Track.curvature_vs_body_position_matrix = curvature_vs_body_position_matrix';
end

% track curvature
if(~isfield(Track,'Curvature')) % already exists ... likely reanalyzing linkedTracks to clean up junctions
    Track.Curvature = track_curvature(Track);
end

% Ring Effect stuff
if(Prefs.ignoreRingFlag == 0)
    Track = ring_effects(Track);
end

Track.mvt_init = mvt_init_vector(Track);
Track = body_bends_per_sec(Track);


Track = make_single(Track);

Prefs = OPrefs;

return;
end
