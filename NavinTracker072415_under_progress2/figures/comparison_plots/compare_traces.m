function compare_traces(BinData_array, stimulus, fieldnames, plot_type, localpath, prefix, fignum_start)
% compare_traces(BinData_array, stimulus, plot_type, localpath, prefix, fignum_start)
% traces on page i, bargraphs on i+1
% each page has the same field

if(nargin<1)
    disp('usage: compare_traces(BinData_array, stimulus, fieldnames, plot_type, localpath, prefix, fignum_start')
    return;
end

plot_columns = 6;
plot_rows = 4;

global Prefs;
Prefs = define_preferences(Prefs);

if(nargin<7)
    fignum_start = 1;
end

if(nargin < 4)
    plot_type = '';
end

if(isempty(plot_type))
    temp_prefix = sprintf('comp_plot.%d.%d',Prefs.PID,101);
    compare_traces(BinData_array, stimulus, fieldnames, 'line', tempdir, temp_prefix, fignum_start);
    temp_prefix = sprintf('comp_plot.%d.%d',Prefs.PID,102);
    compare_traces(BinData_array, stimulus, fieldnames, 'bar', tempdir, temp_prefix, fignum_start);
    
    temp_prefix = sprintf('comp_plot.%d',Prefs.PID);
    pool_temp_pdfs([101 102], localpath, prefix, temp_prefix);
    return;
end

BinData_array_length = length(BinData_array);

% autosplit if BinData_array_length is long
if(BinData_array_length>plot_columns*plot_rows)
    stats_flag=0;
    k=1;
    i=0;
    while(BinData_array_length>0)
        close all
        local_binData_array = [];
        while(length(local_binData_array)<plot_columns*plot_rows && BinData_array_length>0)
            local_binData_array = [local_binData_array BinData_array(k)];
            k=k+1;
            BinData_array_length = BinData_array_length-1;
        end
        i=i+1;
        temp_prefix = sprintf('comp_plot.%d.%d',Prefs.PID,i);
        compare_traces(local_binData_array, stimulus, fieldnames, plot_type, tempdir, temp_prefix);
        clear('local_binData_array');
    end
    
    temp_prefix = sprintf('comp_plot.%d',Prefs.PID);
    pool_temp_pdfs(i, localpath, prefix, temp_prefix);
    
    return;
end

if(nargin < 2)
    stimulus = [];
end
if(nargin < 3)
    fieldnames = [];
end
if(nargin>4)
    if(~isempty(localpath) || ~isempty(prefix))
        if(isempty(localpath))
            localpath=pwd;
        end
        localpath = sprintf('%s%s',localpath,filesep);
    end
else
    localpath='';
    prefix='';
end


xlabelstring = 'Time (sec)';
xmin = min(0,floor(min(BinData_array(1).time)-2/Prefs.FrameRate));
xmax = ceil(max(BinData_array(1).time)+2/Prefs.FrameRate);

if(isempty(stimulus))
    stimlength=0;
else
    stimlength = length(stimulus(:,1));
end


if(isempty(fieldnames))
    fieldnames = Prefs.fieldnames;
end

close all;

disp([sprintf('comparison_plot\t%s',timeString())])

temp_prefix = sprintf('page.%d',randint(1000));


color='';
ymin=0;
ymax=0;
ylabelstring = '';

% is the input actually baseline-subtracted BinData
diff_flag=0;
for(i=1:BinData_array_length)
    if(sum(BinData_array(i).speed<0)>0 || sum(BinData_array(i).ecc<0)>0 || sum(BinData_array(i).Rev_freq<0)>0 || sum(BinData_array(i).omegaUpsilon_freq<0)>0 || sum(BinData_array(i).revlength<0)>0)
        ymin=-0.001;
        ymax=0.001;
        diff_flag=1;
        %        disp([BinData_array(i).Name ' '...
        %            num2str([sum(BinData_array(i).speed<0) sum(BinData_array(i).ecc<0) sum(BinData_array(i).Rev_freq<0) sum(BinData_array(i).omegaUpsilon_freq<0) ...
        %            sum(BinData_array(i).revlength<0)] ) ])
        break;
    end
end

fignum = fignum_start;

for(i=1:length(fieldnames))
        
        field = fieldnames{i};
        
        ymin_line_vector = [];
        ymax_line_vector = [];
        ymin_bar_vector = [];
        ymax_bar_vector = [];
        
        ymin_line = []; 
        ymax_line = []; 
        ymin_bar = []; 
        ymax_bar = [];
        
        figure(fignum);
        
        plot_location = 1;
        for(j=1:BinData_array_length)
            
            BinData = BinData_array(j);
            
            % linegraphs
            if(strcmpi(plot_type,'line'))
                panel_number = [plot_location 0];
                [ymin_line, ymax_line] = plot_attribute(BinData, stimulus, plot_rows, plot_columns, xmin, xmax, ymin, ymax, xlabelstring, ylabelstring, field, color, panel_number);
            else
                % bargraphs
                panel_number = [0 plot_location];
                [ymin_line, ymax_line, ymin_bar, ymax_bar] = plot_attribute(BinData, stimulus, plot_rows, plot_columns, xmin, xmax, ymin, ymax, xlabelstring, ylabelstring, field, color, panel_number);
                ymin_bar_vector = [ymin_bar_vector ymin_bar];
                ymax_bar_vector = [ymax_bar_vector ymax_bar];
            end
            
            ymin_line_vector = [ymin_line_vector ymin_line];
            ymax_line_vector = [ymax_line_vector ymax_line];
            
            
            
            plot_location = plot_location+1;
        end
        
        ymin_line = min(ymin_line_vector);
        ymin_line = ymin_line(1);
        
        ymax_line = max(ymax_line_vector);
        ymax_line = ymax_line(1);
        
        if(~isempty(ymin_bar))
            ymin_bar = min(ymin_bar_vector);
            ymin_bar = ymin_bar(1);
            
            ymax_bar = max(ymax_bar_vector);
            ymax_bar = ymax_bar(1);
        end
        
        % set all the y-axes to be equal and label only the leftmost y-axes
        plot_location = 1;
        fontsize = scaled_fontsize_for_subplot(plot_rows, plot_columns);
        for(j=1:BinData_array_length)
            
            plot_handle = subplot(plot_rows, plot_columns, plot_location);
            
            if(strcmpi(plot_type,'line'))
                panel_number = [plot_location 0];
                plot_attribute(BinData_array(j), stimulus, plot_rows, plot_columns, xmin, xmax, ymin_line, ymax_line, xlabelstring, ylabelstring, field, color, panel_number);
                
                axis normal
                set(gca,'XColor','k');
            else
                ylim([ymin_bar, ymax_bar]);
                axis normal
            end
            if(diff_flag == 1)
                set(gca,'XColor','w');
            end
            h = text(0.5,1.1,fix_title_string(BinData_array(j).Name),'FontSize',scaled_fontsize_for_subplot(plot_rows, plot_columns),'FontName','Helvetica','HorizontalAlignment','center','units','normalized');
            set(h,'HandleVisibility','off');
            hy = get(gca, 'ylabel');
            set(hy, 'FontSize', fontsize);
            hx = get(gca, 'xlabel');
            set(hx, 'FontSize', fontsize);
            
            plot_location = plot_location+1;
        end
        fignum = fignum+1;
    end
    
fignum = fignum-1;

for(i=fignum_start:fignum)
    figure(i);
    h = axes('Position',[0 0 1 1],'Visible','off');
    set(gcf,'CurrentAxes',h);
    title_string = fix_title_string(sprintf('%s.%d',prefix,i));
    % text(0.5,0.975,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
    orient landscape;
    set(gcf,'renderer','painters');
    if(~isempty(prefix))
        filename = sprintf('%s%s.%s', tempdir, temp_prefix, num2str(i));
        save_pdf(gcf, filename, 1);
        disp([sprintf('page %d saved\t%s',i, timeString())]);
        % close(i);
    else
        show_figure(i);
    end
end

if(~isempty(prefix))
    pool_temp_pdfs([fignum_start fignum], localpath, prefix, temp_prefix);
end

return;
end
