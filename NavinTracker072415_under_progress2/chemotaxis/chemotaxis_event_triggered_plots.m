function chemotaxis_event_triggered_plots(tracks, event_class)

[~, event_triggered_BinData] = event_triggered_Tracks(tracks, event_class);

errorshade_stimshade_lineplot_BinData(event_triggered_BinData, [], 2, 2, 1, [], 'model_odor_gradient', 'b', 'Time (sec)', 'model_odor_gradient');

errorshade_stimshade_lineplot_BinData(event_triggered_BinData, [], 2, 2, 2, [], 'model_odor_conc', 'b', 'Time (sec)', 'model_odor_conc');

errorshade_stimshade_lineplot_BinData(event_triggered_BinData, [], 2, 2, 3, [], 'odor_angle', 'b', 'Time (sec)', 'odor_angle');
ylim([50 150]);
errorshade_stimshade_lineplot_BinData(event_triggered_BinData, [], 2, 2, 4, [], 'odor_distance', 'b', 'Time (sec)', 'odor_distance');
ylim([0 60]);

return;
end
  