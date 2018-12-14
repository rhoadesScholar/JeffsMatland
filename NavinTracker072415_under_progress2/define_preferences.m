function [Prefs, actually_defined_flag] = define_preferences(Prefs)

actually_defined_flag = 0;

if(isempty(Prefs))

    actually_defined_flag = 1;
    
% Initialize Preferences
Prefs = struct('matlab_exec_path','MATLAB.exe -minimize -nosplash  -r',...  % -nodisplay  -nodesktop -minimize -noawt -noFigureWindows path for launching child matlab processess 
    'FrameRate', 3, ...                            % Movie frame rate (frames/sec)
    'DefaultMicrofluidicsFrameRate', 2, ...        % Default frame rate for microfluidics movies
    'DefaultPixelSize', 8/136.5, ...               % mm/pixel default for 512x512 movies
    'DefaultResolution',[512 512], ...             % resolution assumed for DefaultPixelSize
    'Ringtype', 'square', ...
    'RingSideLength', 28, ...                      % sidelength of copper-soaked paper in mm
    'holepunch_diameter', 6, ...                   % diameter of holepunch circle
    'quad_microfluidics_arena_sidelength', 16.1, ... % side of quad microfluidics arena model M6
    'timerbox_flag', 0, ...
    'timerbox_thresh', 5, ...
    'timestamp_thresh',200,...
    'MinCopperRingArea',67, ...                    % 67 mm^2 min area of the copper-ring paper 28x28mm2 window with  0.586mm rim window
    'MaxCopperRingArea',120, ...                   % 120 mm^2 max area of the copper-ring paper 28x28mm2 window with  0.586mm rim window
    'use_centroid_location_flag', 0, ...           % if 1 use the centroid to define the location of the animal
    'body_contour_flag', 1, ...                    % if 1, calculate body contour and body angle values, also identify head and tail
    'DefaultNumWormRange',[8 35], ...             % most experiments have 20 to 30 animals
    'aggressive_wormfind_flag',1, ...              % be aggressive about finding worms ... do local dynamic thresholding
... % chemotaxis
    'circular_chemotaxis_plate_diameter',90, ...   % in mm
    'chemotaxis_lid_height', 7, ...                % agar to plate lid distance
    'model_diffusion_const',5, ...                 % 0.05 cm2/sec -> 5 mm2/sec
... % Track linkage parameters    
    'track_create_Max_mm_per_sec', NaN, ...        % used for creating tracks; ~1% of overlapping worms have centroids 0.33mm apart
    'MaxCentroidShift_mm_per_sec', 0.125, ...        % 0.3 used for linking tracks; empirically determined
    'MaxTrackLinkSeconds',108,...                   % 10 max time (sec ... convert to frames below) between the end of a track and the start of another for linkage
    'MaxTrackLinkDistance',0, ...                  % calc below; Max distance between the end of a track and the start of another to join them
    'MaxTrackLinkDirectionDiff',60, ...            % 60 max difference in direction (deg) between two tracks that are to be linked
    'TrigMaxTrackLinkDirectionDiff',0, ...         % calc below sqrt(2*(1-cosd(Prefs.MaxTrackLinkDirectionDiff)))       
    'MaxLinkTracks', 512, ...                      % 512 max number of tracks that can be linked before splitting
    'aggressive_linking', 0, ...                   % permitted speed 0 = average speed, 1 = max speed, 2 = MaxCentroidShift_mm_per_sec 
... % worm as 1mm x 0.1mm rectangle; min and max areas for animals w/ dimensions multipled 0.5 and 1.25 fold ... convert to pixels below
    'MinWormArea_mm', ((2/3)*1)*((2/3)*0.1), ...          % 1/2 Min area for object to be a valid worm ... in mm^2 convert to pixels below
    'MaxWormArea_mm', ((3/2)*1)*((3/2)*0.1), ...          % 4/3 Max area for object to be a valid worm ... in mm^2 convert to pixels below
    'MinWormLength_mm', 0.5, ...                          % Min worm length in  mm ... convert to pixels below
    'MaxWormLength_mm', (3/2), ...
    'MaxWormWidth_mm', 0.5, ...    
    'SizeChangeRatio', 3, ...                      % 3 relative max frame-to-frame size change for a worm ... 
    'swim_flag', 0, ...                            % set to 1 if worms are swimming in liquid
    'max_worm_collision_size', 4, ...              % max worms in a collision/clump
    'no_collisions_flag', 0, ...                   % if 1, clump objects are treated as worms ... use for very sparse plates only 
... % Tracker preferences
    'MinTrackLengthSeconds', 2, ...                % minimum length of valid track (in seconds convert below to frames)
    'use_global_background_flag',1,...             % 0 = use temporally local background when parallelizing tracking 
    'BackgroundCalcInterval', 5, ...               % in percent of movielength ... sampling rate for calculating the background
    'PlotFrameRateInteractive', 1, ...             % 10 Display tracking on screen every PlotFrameRate frames for Interactive mode
    'PlotDataRateInteractive', 10, ...             % 10 Display tracking data every PlotDataRate frames for Interactive mode
    'PlotFrameRateBatch', 100000, ...              %  Display tracking on screen every PlotFrameRate frames for batch
    'PlotDataRateBatch', 100, ...                  % Display tracking data every PlotDataRate frames for batch
    'PlotFrameRate', 100000, ...                   %  Display tracking on screen every PlotFrameRate ... set by the tracker 
    'PlotDataRate', 100, ...                       % Display tracking data every PlotDataRate  ... set by the tracker 
    'LightDarkCutoff', 50000, ...                  % if the difference between dark and light frames is < this, then use only one background
    'trackerbirthday', '10/12/12', ...
    'track_analysis_date','9/6/11', ... 
... % ring effect variables ... used to define Tracks.RingEffect
    'ignoreRingFlag',0,...                       % if 1, ignore Ring
    'RingDistanceCutoff', 3, ...                 % fit me % 3mm off-food converted to pixels below; how close the animal has to be to be affected by the ring
    'FoodRingDistanceCutoff', 2, ...             % 2mm on-food converted to pixels below; how close the animal has to be to be affected by the ring
    'RingEffectDuration', 10, ...                % fit me % 10 refractory period in seconds after reversal induced by copper ring; convert to frames below
... % smoothing and stepsize parameters
    'BinData_smoothing_size', 3, ...               % if 0,  do not smooth
    'SmoothWinSize', 1, ...                        % Size of Window for smoothing track data (in seconds)
    'StepSize', 1, ...                             % Size of step for calculating changes in X and Y coordinates (in seconds)
    'curvStep',1, ...                              % window in mm for calculating path curvature
    'LawnCode',10, ...
    'BodyBendWindowLength',10, ...                 % window in sec for estimating body bend freq
... % plotting preferences
    'BinSize',10,...                               % default binsize for frequencies, etc
    'FreqBinSize',10,...                           % binsize for averaging frequencies, in seconds
    'psthFreqBinSize',2,...                        % for psth, binsize for averaging frequencies, in seconds
    'SpeedEccBinSize',1,...                        % binsize for instantaneous speed and eccentricities 
    'averaging_type','per-movie',...               % 'per-worm' stats or 'per-movie' stats ... similar numbers, but per-worm has unambig errorbars
    'minFracLongTrack',4/5, ...                    % 4/5 fraction of max frames for ethograms
    'MaxNumEthogramTracks', 100, ...
    'timeunits','sec', ...                         % units for plotting time; default to sec for most
    'psth_pre_stim_period', 50, ...
    'psth_post_stim_period', 100, ...
    'graph_no_stim_width', 60, ...                  % in percent or seconds
    'graph_no_stim_width_units', 'seconds', ...     %  'seconds' 'percent'
    'bargraph_metric', 'mean', ...
    'ethogram_orientation', 'vertical', ...         % orientation of the ethogram; 'horizontal' or 'vertical'
    'max_psth_Tracks_array',2000, ...
    'error_plot_type','line', ...                   % 'line' or 'shade'
    'missing_frame_ethogram_color',[], ...          % color for missing frames in ethograms ;[0.95 0.95 0.95]
    'plot_marker','', ...                           % 
    'num_contour_points', 50, ...                   % number of body contour points for internal body angles
... % fitting 
    'num_random_fits',25, ...                       % number of random data sets fitted for estimating fitting paramter error
    'max_error_calc_time',600, ...                  % number of seconds to spend making random fits for parameter error estimation
... % reversal, omega parameters to be fitted
    'LargeReversalThreshold', 0.5, ...              % 0.345 fraction of body length threshold between small and large reversals; 
...                                                 % from fitting N2 revlength dist w/ double gaussian; point where they are equal
    'RevLengthLimit',3, ...                         % maximum reversal length in fraction body length; 
    'RevOmegaMaxGap',1.5,...                        % maximal gap between a reversal and an omega or turn for them to be in the same event; in seconds
    'pauseSpeedThresh',0.015,...                    % 0.015 in mm/sec worm w/ speed below this is "paused"
    'AngSpeedThreshold', 60, ...                    % fitted % minimum angspeed for identifying an omega or reversal
    'RevAngSpeedThreshold', 75, ...                 % fitted % angspeed threshold for detecting Reversals
    'SmallReversalThreshold', 0.092,...           	% fitted % threshold between small and non reversals; fraction of body length
    'MaxRevDuration',8.8,...                        % fitted % max duration of a reversal; in seconds 
    'MaxUpsilonOmegaDuration',8.8,...               % fitted % max duration of an omega; in seconds 
    'MinOmegaDuration',1.6, ...                     % fitted % min duration of an omega; in seconds
    'UpsilonEccThresh', 0.905, ...                  % fitted % eccentricity for turning animals
    'OmegaEccThresh', 0.875, ...                    % fitted % Cutoff for omega turns
    'OmegaMajorAxesThresh',0.79,...                 % fitted % relative major axis of an animal in an omega
    'MinDeltaHeadingOmega', 20,...                 	% fitted % minimal change in direction between the path from the start to finish of an omega
    'MinDeltaHeadingUpsilon',40,...                 % fitted % minimal change in direction between the path from the start to finish of an turn
    'RevOmegaUpsilonDeltaHeadingThresh',135,...     % fitted % rev-upsilon w/ delta-dir-turn > than this are classified as omegas
    'ForwardEcc',0.9349,...                         % measured; if ecc is the only measure between manually scored events vs fwd, use this threshold
    'MinDeltaHeadingRevOmega',20,...               	% fitted
    'MinDeltaHeadingRevUpsilon',40);                % fitted
    
% default fieldnames for summary plots
Prefs.fieldnames = {'speed','curv','angspeed','ecc','body_angle','head_angle','tail_angle',...
        'delta_dir_omegaupsilon','delta_dir_rev','revlength','revSpeed', ...
        'pure_lRev_freq','pure_sRev_freq','pure_omega_freq','pure_upsilon_freq', ...
        'lRevUpsilon_freq','lRevOmega_freq','sRevUpsilon_freq','sRevOmega_freq'};  

Prefs.TrigMaxTrackLinkDirectionDiff = sqrt(2*(1-cosd(Prefs.MaxTrackLinkDirectionDiff)));

Prefs = CalcPixelSizeDependencies(Prefs, Prefs.DefaultPixelSize);

Prefs.TrackProcessChunkSize = 2700; % in frames; size of movie segments for parallel processing
Prefs.NumCPU = ceil(str2num(getenv('NUMBER_OF_PROCESSORS'))*0.5); % number of CPUs that can be used 
Prefs.PID = randi(10000);

% navin_code_setup;

end

return;
