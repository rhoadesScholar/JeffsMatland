function track = make_single_track(inputTracks)

global Prefs; 
Prefs = define_preferences(Prefs);
Prefs.FrameRate = inputTracks(1).FrameRate;
Prefs = CalcPixelSizeDependencies(Prefs, inputTracks(1).PixelSize);

join_flag = 'interpolate';
verbose_flag = 1;
dir_flag = 0;
dist_flag = 0;

track = link_tracks(sort_tracks_by_startframe(inputTracks), verbose_flag, dir_flag, dist_flag, join_flag);

return;
end
