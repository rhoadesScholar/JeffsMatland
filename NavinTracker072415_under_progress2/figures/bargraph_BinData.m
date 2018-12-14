function [h, ymin, ymax, barhandles] = bargraph_BinData(BinData, stimulus, ...
                                                plot_rows, plot_columns, plot_location, ...
                                                axis_vector, ...
                                                field, ...
                                                ylabelstring)
% function bargraph_BinData(BinData, stimulus, ...
%                                                 plot_rows, plot_columns, plot_location, ...
%                                                 axis_vector, ...
%                                                 field, ...
%                                                 ylabelstring);

if(~isempty(stimulus))
    h = subplot(plot_rows,plot_columns,plot_location);
    [ymin, ymax, barhandles] = stimulus_bargraphs(BinData, stimulus, field, axis_vector, ylabelstring);
else
   [h, ymin, ymax, barhandles] = plot_long_bins(BinData, field, axis_vector, 'k', plot_rows, plot_columns, plot_location, 'time (sec)', ylabelstring);
end
    
fontsize = scaled_fontsize_for_subplot(plot_rows, plot_columns);
set(gca,'FontSize',fontsize);
set(gca, 'color', 'none');
hx = get(gca, 'xlabel');
set(hx, 'FontSize', fontsize);
hy = get(gca, 'ylabel');
set(hy, 'FontSize', fontsize);

box('off');

return;
end
