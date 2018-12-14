function hh = errorshade_stimshade_lineplot_BinData_array(BinData_array, stimulus, plot_rows, plot_columns, plot_location, ...
    axis_vector, attribute, colors, xlabelstring, ylabelstring)

hh = subplot(plot_rows, plot_columns, plot_location);

ymin = axis_vector(3);
ymax = axis_vector(4);

for(bb=1:length(BinData_array))
    [hh, axis_v] = errorshade_stimshade_lineplot_BinData(BinData_array(bb), [], plot_rows, plot_columns, plot_location, ...
        axis_vector, ...
        attribute, colors{bb}, ...
        xlabelstring, ylabelstring);
    hold on;
    
    % ymin
    if(axis_v(3) < ymin)
        ymin = axis_v(3);
    end
    % ymax
    if(axis_v(4) > ymax)
        ymax = axis_v(4);
    end
end
    
sh = stimulusShade(stimulus, ymin, ymax); 
uistack(sh(end:-1:1),'bottom');

hold off;

return;
end
