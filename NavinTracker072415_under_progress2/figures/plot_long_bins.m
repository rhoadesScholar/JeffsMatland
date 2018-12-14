function [h, ymin, ymax, barhandles] = plot_long_bins(inputBinData, attribute, axis_vector, color, plot_rows, plot_columns, panel_number,xlabelstring, ylabelstring)

global Prefs;

BinData = inputBinData(1);

xlabelstring = fix_title_string(xlabelstring);
ylabelstring = fix_title_string(ylabelstring);

plot_location = panel_number(find(panel_number>0));

h = subplot(plot_rows, plot_columns, plot_location);

if( length(BinData.(attribute)) == length(BinData.time) ) % instantaneous values speed, ecc, frac_state, etc
    t = BinData.time;
else  % frequencies, etc
    t = BinData.freqtime;
end

%idx = non_nan_indicies(BinData.(attribute));
%idx = 1:length(barvalues);
% x = t(idx);
% y = BinData.(attribute)(idx);
% plot(x,y,'color',color,'LineWidth',1); 
% hold on;


maxtime = ceil(max(BinData.time));
mintime = floor(min(BinData.time));

if(strcmpi(Prefs.graph_no_stim_width_units,'percent')==1)
    stepsize = maxtime*(Prefs.graph_no_stim_width/100);
else
    stepsize = Prefs.graph_no_stim_width;
    if(Prefs.graph_no_stim_width > (ceil(t(end))-floor(t(1)))/10)
        stepsize = (ceil(t(end))-floor(t(1)))/10;
    end
end

t1 = mintime;
t2 = mintime + stepsize;
i=1;
t=[];
y_matrix = []; 
while(t2<=maxtime)
    t(i) = mean(t1+t2)/2;
    
    
    
    
    % inputBinData is BinData_array, so calc segment mean for each, then average, etc
    if(length(inputBinData)>1)
        n = [];
        for(j=1:length(inputBinData))
            [y_matrix(j,i), ~, ~, n(j)] = segment_statistics(inputBinData(j), attribute, 'mean', t1, t2);
        end
        weights = n./nansum(n); weights=weights';
        barvalues(i) = nansum(weights.*y_matrix(:,i));
        barerrors(i) = nanstderr(y_matrix(:,i));
    else
        [barvalues(i), stddev, barerrors(i), n] = segment_statistics(inputBinData, attribute, 'mean', t1, t2);
    end
    
    
    i=i+1;
    t1=t1+stepsize;
    t2=t2+stepsize;
end

%idx = non_nan_indicies(barvalues);
idx = 1:length(barvalues);

xmin = axis_vector(1);
xmax = axis_vector(2);
ymin = axis_vector(3);
ymax = axis_vector(4);


for(j=1:size(y_matrix,1))
    plot(t(idx), y_matrix(j,idx),'marker','none','color','k','LineWidth',0.5);
    hold on;
end
hold on;


plot(t(idx), barvalues(idx),'marker','none','color',color,'LineWidth',2);
hold on;
errorline(t(idx), barvalues(idx), barerrors(idx), color);
axis([xmin xmax ymin ymax]);
hold off;

bw_title = '';
bw_ylabel = attribute;
bw_legend=[];
bw_xlabel = '';
groupname{1} = '';
cmap = [0.5 0.5 0.5];

barhandles.bars = [];
barhandles.stat_symbols = [];
barhandles.errors = [];
barhandles.title = [];
barhandles.xlabel = [];
barhandles.ylabel = [];
barhandles.legend = [];
barhandles.ca = [];
% barhandles = barweb(barvalues(idx), barerrors(idx), 1, groupname, bw_title, bw_xlabel, bw_ylabel, cmap, bw_legend);


if( (max(max(barvalues)) + max(max(barerrors))) > ymax )
    ymax = (max(max(barvalues)) + max(max(barerrors)));
    ymax = ymax(1);
    if(~isempty(regexpi(attribute,'freq')))
        ymax=custom_round(ymax, 0.25, 'ceil');
    end
end

if( (min(min(barvalues)) - max(max(barerrors))) < ymin )
    ymin = (min(min(barvalues)) - max(max(barerrors)));
    ymin = ymin(1);
    if(~isempty(regexpi(attribute,'freq')))
        ymin=0; % custom_round(ymin, 0.25, 'ceil');
    end
end


if(ymin<0) % since ymin is already defined as being negative, we can go even more negative if need be
    if( min(min(barvalues)) - max(max(barerrors)) < ymin )
        ymin = min(min(barvalues)) - max(max(barerrors));
        ymin = ymin(1);
        %         if(abs(ymin)>0.25)
        %             ymin=custom_round(ymin, 0.25);
        %         else
        %             if(abs(ymin)>0.1)
        %                 ymin=custom_round(ymin, 0.1);
        %             end
        %         end
    end
    
    if(ymax<0)
        ymax=0;
    end
end

if(ymax<=ymin)
    if(abs(ymin)>1e-4)
        ymax = 1.1*ymin;
    else
        ymax = 0.1;
    end
end

ylim([ymin ymax]);
box('off');

hy = ylabel(ylabelstring);
hx = xlabel(xlabelstring);
fontsize = scaled_fontsize_for_subplot(plot_rows, plot_columns);
set(gca,'FontSize',fontsize);
set(hy,'FontSize',fontsize);
set(hx,'FontSize',fontsize);

return;
end

