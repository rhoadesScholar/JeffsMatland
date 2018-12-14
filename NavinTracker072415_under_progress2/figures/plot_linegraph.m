function h = plot_linegraph(BinData, stimulus, plot_rows, plot_columns, xmin, xmax, ymin, ymax, xlabelstring, ylabelstring, attribute, color, panel_number)

err_field = sprintf('%s_err',attribute);

attrib = BinData(1).(attribute);

err = [];
if(isfield(BinData(1),err_field))
    err = BinData(1).(err_field);
end

if(length(BinData)>1)
    attrib = []; err =[];
    for(i=1:length(BinData))
        attrib = [attrib; BinData.(attribute)];
    end
    err = nanstderr(attrib);
    attrib = nanmean(attrib);
end

ymin_line = ymin;
if(ymin~=0)
    ymin_line = min(ymin, (min(attrib - err)) );
end

ymax_line = max(ymax, (max(attrib + err)) );
ymax_line = custom_round(ymax_line, 0.005,'ceil');


% linegraph
h = errorshade_stimshade_lineplot_BinData(BinData, stimulus, plot_rows, plot_columns, panel_number, ...
    [xmin xmax ymin_line ymax_line], ...
    attribute, color, ...
    xlabelstring, ylabelstring);

return;
end
