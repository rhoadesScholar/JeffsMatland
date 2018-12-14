function [ymin_line, ymax_line, ymin_bar, ymax_bar, barhandles] = plot_attribute(BinData, stimulus, plot_rows, plot_columns, xmin, xmax, ymin, ymax, xlabelstring, ylabelstring, attribute, color, panel_number)


global Prefs;


barhandles.bars = [];
barhandles.stat_symbols = [];
barhandles.errors = [];
barhandles.title = [];
barhandles.xlabel = [];
barhandles.ylabel = [];
barhandles.legend = [];
barhandles.ca = [];

err_field = sprintf('%s_err',attribute);

[a, b, c, d] = default_ylim(attribute);
if(ymin==0 && ymax==0)
    ymin = a; 
    ymax = b; 
    
    if(a==0 && b==0)
        ymin = min(BinData.(attribute));
        ymax = max(BinData.(attribute));
    end
end
if(isempty(color))
    color = c;
end
if(isempty(ylabelstring))
    ylabelstring = d;
end
clear('a'); clear('b'); clear('c'); clear('d');

if(xmin == 0 && xmax == 0)
    xmin = floor(min(BinData.time));
    xmax = ceil(max(BinData.time));
end

attrib_vec = BinData(1).(attribute);
err_vec = BinData(1).(err_field);

if(length(BinData)>1)
    attrib_vec = [];
    for(i=1:length(BinData))
        attrib_vec = [attrib_vec; BinData(i).(attribute)];
    end
    err_vec = nanstderr(attrib_vec);
    attrib_vec = nanmean(attrib_vec);
end

ymin_line = ymin;
if(ymin~=0)
    ymin_line = min(ymin, (min(attrib_vec - err_vec)) );
    ymin_line = ymin_line(1);
end
ymax_line = max(ymax, (max(attrib_vec + err_vec)) );
ymax_line = ymax_line(1);

o_lin = ymax_line;
if(~isempty(regexpi(attribute,'freq')))
    ymax_line=custom_round(ymax_line, 0.25, 'ceil');
else
    ymax_line = custom_round(ymax_line, 0.005,'ceil');
    if(ymax_line >= 2*o_lin)
        ymax_line = custom_round(o_lin, 0.001,'ceil');
    end
end

if(isempty(ymax_line))
    ymax_line = ymax;
else
    if(isinf(abs(ymax_line)))
        ymax_line = ymax;
    else
        if(isnan(ymax_line))
            ymax_line = ymax;
        end
    end
end

if(isempty(ymin_line))
    ymin_line = ymin;
else
    if(isinf(abs(ymin_line)))
        ymin_line = ymin;
    else
        if(isnan(ymin_line))
            ymin_line = ymin;
        end
    end
end


% 
% vx=[]; for(i=1:length(Tracks)) vx=[vx 0:maxtime]; end; 
% x = track_field_to_matrix(Tracks, 'Speed');
% vy = matrix_to_vector(x);
% result = hist2D(vx, vy, 1, 0.01); imagesc(0:maxtime, y, log(result')); axis xy; ylim([0 0.4]); colormap ([1 1 1; gray])

ymin_bar = ymin_line;
ymax_bar = ymax_line;

if(panel_number(1)>0)
    errorshade_stimshade_lineplot_BinData(BinData, stimulus, plot_rows, plot_columns, panel_number(1), ...
        [xmin xmax ymin_line ymax_line], ...
        attribute, color, ...
        xlabelstring, ylabelstring);
end

if(length(panel_number)>1)
if(panel_number(2)>0)
    if(~isempty(stimulus))
        [h, ymin_bar, ymax_bar, barhandles] = bargraph_BinData(BinData, stimulus, plot_rows, plot_columns, panel_number(2), ...
            [ymin ymax], ...
            attribute, ...
            ylabelstring);
    else
        if(Prefs.graph_no_stim_width > Prefs.SpeedEccBinSize && (~isfield(BinData,'xlabel')))
            [h, ymin_bar, ymax_bar, barhandles] = plot_long_bins(BinData, attribute, [xmin, xmax, ymin_line, ymax_line], color, plot_rows, plot_columns, panel_number(2), xlabelstring, ylabelstring);
        else
            if(isfield(BinData,'xlabel'))
                [h, ymin_bar, ymax_bar, barhandles] = plot_long_bins(BinData, attribute, [xmin, xmax, ymin_line, ymax_line], color, plot_rows, plot_columns, panel_number(2), xlabelstring, ylabelstring);
            end
        end
    end
end
end


return;
end
