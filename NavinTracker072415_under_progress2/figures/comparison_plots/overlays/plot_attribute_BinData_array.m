function plot_attribute_BinData_array(fignum, BinData_array, stimulus, plot_rows, plot_columns, xmin, xmax, ymin, ymax, xlabelstring, ylabelstring, attribute, color, panel_number)


if(~isfield(BinData_array(1),attribute))
    return;
end

err_field = sprintf('%s_err',attribute);

max_err = max_struct_array(BinData_array,err_field);

ymin_line = min(ymin, (min_struct_array(BinData_array,attribute) - max_err )); 
ymax_line = max(ymax, (max_struct_array(BinData_array,attribute) + max_err )); 

if(isempty(ymin_line))
    ymin_line=0;
end

if(isempty(ymax_line))
    ymax_line=0.5;
end

if(ymin_line >= ymax_line)
    ymax_line = ymin_line + 0.5;
end

ymin_line=ymin_line(1);
ymax_line=ymax_line(1);


errorshade_stimshade_lineplot_BinData_array(BinData_array, stimulus, plot_rows, plot_columns, panel_number(1), ...
    [xmin xmax ymin_line ymax_line], ...
    attribute, color, ...
    xlabelstring, ylabelstring);

return;
end
