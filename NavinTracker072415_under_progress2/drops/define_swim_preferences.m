function Prefs = define_swim_preferences(Prefs)


Prefs.well_width = 6.485; % in mm

Prefs.swim_flag = 1;
Prefs.FrameRate = 25;
Prefs.DefaultPixelSize = Prefs.well_width/970;  % 6.485/936.3835; % well-diameter mm/pixel

Prefs.FreqBinSize = 1;

% for worms in drops
Prefs.OmegaEccThresh = 0.75;
Prefs.MinOmegaDuration = 0.2;


% very aggressive track joining and linking parameters for swimming worms
Prefs.SizeChangeRatio = 0.1; Prefs.MaxCentroidShift_mm_per_sec = 5; Prefs.track_create_Max_mm_per_sec = 5;

Prefs.graph_no_stim_width = 1;
Prefs.body_contour_flag = 0;
Prefs.RingEffectDurationFrames = Prefs.RingEffectDuration*Prefs.FrameRate;
Prefs.MinTrackLengthFrames = Prefs.MinTrackLengthSeconds*Prefs.FrameRate;
Prefs.MaxTrackLinkFrames = Prefs.MaxTrackLinkSeconds*Prefs.FrameRate;
Prefs.PlotFrameRateInteractive = Prefs.FrameRate;

Prefs = CalcPixelSizeDependencies(Prefs, Prefs.DefaultPixelSize);

end
