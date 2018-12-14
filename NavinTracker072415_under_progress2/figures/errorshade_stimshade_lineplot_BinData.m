function [hh, av] = errorshade_stimshade_lineplot_BinData(BinData, stimulus, ...
                                                plot_rows, plot_columns, plot_location, ...
                                                axis_vector, ...
                                                field, linecolor, ...
                                                xlabelstring, ylabelstring)
% hh = errorshade_stimshade_lineplot_BinData(BinData, stimulus, ...
%                                                 plot_rows, plot_columns, plot_location, ...
%                                                 axis_vector, ...
%                                                 field, linecolor, ...
%                                                 xlabelstring, ylabelstring)
 

global Prefs;

xlabelstring = fix_title_string(xlabelstring);
ylabelstring = fix_title_string(ylabelstring);
                                            
                                            
errfield = sprintf('%s_err',field);

if(~isempty(axis_vector))
    xmin = axis_vector(1);
    xmax = axis_vector(2);
    ymin = axis_vector(3);
    ymax = axis_vector(4);
else
    [ymin, ymax] = default_ylim(field);
    if(ymin == 0 && ymax == 0)
        ymin = min(BinData.(field));
        ymax = max(BinData.(field)) + max(BinData.(errfield));
    end
    xmin = floor(min(BinData.time));
    xmax = ceil(max(BinData.time));
end

if( length(BinData(1).(field)) == length(BinData(1).time) ) % instantaneous values speed, ecc, frac_state, etc
    t = BinData(1).time;
else  % frequencies, etc
    t = BinData(1).freqtime;
end

%idx = non_nan_indicies(BinData.(field));
idx = 1:length(BinData(1).(field));

x = t(idx);

y_matrix = [];
y = BinData(1).(field)(idx);
y_err=[];
if(isfield(BinData(1),errfield))
    y_err = BinData(1).(errfield)(idx);
end

if(length(BinData)>1)
    y=[]; y_matrix = [];
    for(i=1:length(BinData))
        y_matrix = [y_matrix; BinData(i).(field)(idx)];
    end
    y_err=[];
    if(isfield(BinData(1),errfield)==1)
        y_err = nanstderr(y_matrix);
    end
    if(strcmp(field,'n') || strcmp(field(1:2),'n_')) % add up n's
        y = nansum(y_matrix);
    else
        y = nanmean(y_matrix);
    end
    
    y_err=[];
end
hh = subplot(plot_rows,plot_columns,plot_location);

stimulusShade(stimulus, ymin, ymax); 
hold on;

for(i=1:size(y_matrix,1))
    plot(x,y_matrix(i,:),'color','k','LineWidth',0.5); 
end

if(~isempty(y_err))
    if(strcmp(Prefs.error_plot_type,'shade')==1)
        errorshade(x, y + y_err, y - y_err,linecolor);
    else
        eL = errorline(x,y, y_err,Prefs.plot_marker);
        set(eL,'color',linecolor);
    end
else
    plot(x,y,'color',linecolor,'LineWidth',2); 
end

if(ymin >= ymax)
    ymax=1e-4;
end


av = [xmin xmax ymin ymax];
axis([xmin xmax ymin ymax]);
box('off');

hy = ylabel(ylabelstring);
hx = xlabel(xlabelstring);
fontsize = scaled_fontsize_for_subplot(plot_rows, plot_columns);
set(gca,'FontSize',fontsize);
set(hy,'FontSize',fontsize);
set(hx,'FontSize',fontsize);

set(gca, 'color', 'none');

return;

end

