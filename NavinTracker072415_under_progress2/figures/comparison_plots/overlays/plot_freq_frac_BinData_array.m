function plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, mvt, colors, panel_number)
% plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, mvt, colors, panel_number)

freq_field = sprintf('%s_freq',mvt);
freq_s_field = sprintf('%s_freq_s',mvt);
freq_err_field = sprintf('%s_freq_err',mvt);

frac_field = sprintf('frac_%s',mvt);
frac_s_field = sprintf('frac_%s',mvt);
frac_err_field = sprintf('frac_%s_err',mvt);

% freq
ylabelstring = sprintf('freq\n%s\n(/min)', mvt);

ymax = 1.5;
ymin=0;

max_err = max_struct_array(BinData_array,freq_err_field);

min_val = min_struct_array(BinData_array,freq_field);
% BinData likely be a difference structure
if(min_val < 0)
    ymin = min_struct_array(BinData_array,freq_field)-max_err;
    ymax = max_struct_array(BinData_array,freq_field)+max_err;
    del = 0.25; % 10^round(log10((ymax-ymin)/5));
    ymin = custom_round(ymin, del);
    ymax = custom_round(ymax, del);    
end

if(ymax < max_struct_array(BinData_array,freq_field)+max_err)
    ymax = max_struct_array(BinData_array,freq_field)+max_err;
    ymax = custom_round(ymax, 0.25);
end

hh = errorshade_stimshade_lineplot_BinData_array(BinData_array, stimulus, plot_rows, plot_columns, panel_number(2), ...
                                        [xmin xmax ymin ymax], ...
                                        freq_field, colors, ...
                                        xlabelstring, ylabelstring);
                                    
                                    
                                    
% frac
ylabelstring = sprintf('frac\n%s',mvt);

ymax = max(0.2, max_struct_array(BinData_array,frac_field) + max_struct_array(BinData_array,frac_err_field));
ymin = 0;

min_val = min_struct_array(BinData_array,frac_field);
% BinData likely be a difference structure
if(min_val < 0)
    ymin = min_struct_array(BinData_array,frac_field)-max_struct_array(BinData_array,frac_err_field);
    ymax = max_struct_array(BinData_array,frac_field)+max_struct_array(BinData_array,frac_err_field);
    del = 0.05; % 10^round(log10((ymax-ymin)/5));
    ymin = custom_round(ymin, del);
    ymax = custom_round(ymax, del);    
end

if(ymax < max_struct_array(BinData_array,frac_field)+max_struct_array(BinData_array,frac_err_field))
    ymax = max_struct_array(BinData_array,frac_field)+max_struct_array(BinData_array,frac_err_field);
    ymax = custom_round(ymax, 0.05);
end

errorshade_stimshade_lineplot_BinData_array(BinData_array, stimulus, plot_rows, plot_columns, panel_number(3), ...
                                        [xmin xmax ymin ymax], ...
                                        frac_field, colors, ...
                                        xlabelstring, ylabelstring);


% raster plot
% if(~isempty(Track_array_struct))
%     gg = mvt_init_ethogram_Track_array_struct(Track_array_struct, colors, stimulus, plot_rows, plot_columns, panel_number(1), mvt, [xmin xmax]);
%     freq_plot_pos = get(hh, 'Position');  
%     set(gg,'Position',[freq_plot_pos(1), freq_plot_pos(2) + freq_plot_pos(4), freq_plot_pos(3), freq_plot_pos(4)]);
% end

return;
end
