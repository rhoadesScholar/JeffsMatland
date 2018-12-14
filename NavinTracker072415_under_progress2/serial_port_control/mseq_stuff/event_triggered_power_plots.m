function event_triggered_power_plots(inputTracks, powers, event_class)

global Prefs;
Prefs = define_preferences(Prefs);
Prefs.BinSize = 1/3;
Prefs.psthFreqBinSize = 1/3;
Prefs.SpeedEccBinSize = 1/3;
Prefs.FreqBinSize = 1/3;

for(i=1:length(inputTracks))
    t1 = inputTracks(i);
    t1.power = powers(t1.Frames);
    Tracks(i) = t1;
end

[event_triggered_psthTracks, event_triggered_BinData] = event_triggered_Tracks(Tracks, event_class);

errorshade_stimshade_lineplot_BinData(event_triggered_BinData, [], 2, 2, 1, [], 'power', 'b', 'Time (sec)', 'power');


return;
end
  