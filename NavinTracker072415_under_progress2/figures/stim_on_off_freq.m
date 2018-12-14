function stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
                                plot_rows, plot_columns, on_loc, ...
                                xlabelstring, ...
                                xmin, xmax, ...
                                mvt, color)
                            
freq_field = sprintf('%s_freq',mvt);
freq_s_field = sprintf('%s_freq_s',mvt);
freq_err_field = sprintf('%s_freq_err',mvt);

ymin=0;

% freq
ylabelstring = sprintf('freq\n%s\n(/min)', mvt);
ymax = 1.5; 
[h_on, h_off] = stim_on_off_lineplot(fignum, onBinData, onStimulus, offBinData, offStimulus, ...
    plot_rows, plot_columns, on_loc(2:3), ...
    '', ylabelstring, ...
    xmin, xmax, ymin, ymax, ...
    freq_field, color);
on_pos = get(h_on, 'Position');
off_pos = get(h_off, 'Position');


% frac

frac_field = sprintf('frac_%s',mvt);
frac_s_field = sprintf('frac_%s',mvt);
frac_err_field = sprintf('frac_%s_err',mvt);

ylabelstring = sprintf('frac\n%s',mvt);
ymax = max( max(0.2, max(onBinData.(frac_field)) + max(onBinData.(frac_err_field))) , max(0.2, max(offBinData.(frac_field)) + max(offBinData.(frac_err_field))) );

stim_on_off_lineplot(fignum, onBinData, onStimulus, offBinData, offStimulus, ...
                                plot_rows, plot_columns, on_loc(4:5), ...
                                '', ylabelstring, ...
                                xmin, xmax,  ymin, ymax , ...
                                frac_field, color);   



% raster plots
[g_on, y_max_on, ymin_on] = mvt_init_ethogram(onTracks, onStimulus, plot_rows, plot_columns, on_loc(1), mvt,'k',[xmin xmax]);
[g_off, y_max_off, ymin_off] = mvt_init_ethogram(offTracks, offStimulus, plot_rows, plot_columns, on_loc(1)+1, mvt,'k',[xmin xmax]);
side_by_side_subplots(g_on, g_off, [xmin, xmax], [min(1, min(ymin_on, ymin_off)) max(y_max_on, y_max_off)] );

set(g_on,'Position',[on_pos(1), on_pos(2) + on_pos(4), on_pos(3), on_pos(4)]);
set(g_off,'Position',[off_pos(1), off_pos(2) + off_pos(4), off_pos(3), off_pos(4)]);

return;
end
