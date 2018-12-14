function Prefs = CalcPixelSizeDependencies(Prefs, PixelSize)
% Prefs = CalcPixelSizeDependencies(Prefs, PixelSize), PixelSize in mm/pixel

Prefs.RingEffectDurationFrames = Prefs.RingEffectDuration*Prefs.FrameRate;
Prefs.MinTrackLengthFrames = Prefs.MinTrackLengthSeconds*Prefs.FrameRate;
Prefs.MaxTrackLinkFrames = Prefs.MaxTrackLinkSeconds*Prefs.FrameRate;
Prefs.PlotFrameRateInteractive = Prefs.FrameRate;

Prefs.RingDistanceCutoffPixels = Prefs.RingDistanceCutoff/(PixelSize);

Prefs.MaxInterFrameDistance = (Prefs.MaxCentroidShift_mm_per_sec/Prefs.FrameRate)/(PixelSize);

Prefs.MaxTrackCreateFrameDistance = (Prefs.track_create_Max_mm_per_sec/Prefs.FrameRate)/(PixelSize);
if(isnan(Prefs.MaxTrackCreateFrameDistance))
   Prefs.MaxTrackCreateFrameDistance = sqrt(2); 
end

Prefs.MaxTrackLinkDistance  = Prefs.MaxTrackLinkFrames*Prefs.MaxInterFrameDistance;

Prefs.MinWormArea = Prefs.MinWormArea_mm/(PixelSize^2);
Prefs.MaxWormArea = Prefs.MaxWormArea_mm/(PixelSize^2);
Prefs.MidWormArea = (Prefs.MinWormArea + Prefs.MaxWormArea)/2; % for estimations

Prefs.SizeChangeThreshold = (Prefs.MaxWormArea - Prefs.MinWormArea)/Prefs.SizeChangeRatio;

Prefs.MinWormLength = Prefs.MinWormLength_mm/(PixelSize);
Prefs.MaxWormLength = Prefs.MaxWormLength_mm/(PixelSize);

Prefs.MaxBoundingBoxArea = (Prefs.MaxWormLength_mm*Prefs.MaxWormWidth_mm)/(PixelSize^2);

Prefs.MaxWormClumpArea = Prefs.max_worm_collision_size*(Prefs.MinWormArea+Prefs.MaxWormArea)/2;

return;
end
