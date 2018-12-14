function [h_on, h_off] = stim_on_off_lineplot(fignum, onBinData, onStimulus, offBinData, offStimulus, ...
                                plot_rows, plot_columns, on_loc, ...
                                xlabelstring, ylabelstring, ...
                                xmin, xmax, ymin, ymax, ...
                                attribute, color)
                                
off_loc = on_loc+1;

err_field = sprintf('%s_err',attribute);


if(isfield(onBinData,err_field))
    ymin_line = min( min(ymin, (min(onBinData.(attribute)) - min(onBinData.(err_field)))) , min(ymin, (min(offBinData.(attribute)) - min(offBinData.(err_field)))) );
    ymax_line = max( max(ymax, (max(onBinData.(attribute)) + max(onBinData.(err_field)))) , max(ymax, (max(offBinData.(attribute)) + max(offBinData.(err_field)))) );
else
    ymin_line = ymin;
    ymax_line = ymax;
end

if(ymin_line >= ymax_line)
    ymax_line = ymin_line + 0.5;
end

h_on = errorshade_stimshade_lineplot_BinData(onBinData, onStimulus, plot_rows, plot_columns, on_loc(1), ...
                                        [xmin xmax ymin_line ymax_line], ...
                                        attribute, color, ...
                                        xlabelstring, ylabelstring);
                                    
h_off = errorshade_stimshade_lineplot_BinData(offBinData, offStimulus, plot_rows, plot_columns, off_loc(1), ...
                                        [xmin xmax ymin_line ymax_line], ...
                                        attribute, color, ...
                                        xlabelstring, ylabelstring);
            
side_by_side_subplots(h_on, h_off, [xmin xmax], [ymin_line ymax_line]);



if(isfield(onBinData,err_field))
    b_on = bargraph_BinData(onBinData, onStimulus, plot_rows, plot_columns, on_loc(2), ...
        [ymin ymax], ...
        attribute, ...
        ylabelstring);
    
    b_off = bargraph_BinData(offBinData, offStimulus, plot_rows, plot_columns, off_loc(2), ...
        [ymin ymax], ...
        attribute, ...
        ylabelstring);
    
    
    side_by_side_subplots(b_on, b_off, [], [ymin_line ymax_line]);

end

return;
end
