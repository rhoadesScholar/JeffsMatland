function comparison_plot_v1(inputBinData_array, stimulus, fieldnames, time_window, localpath, prefix, stats_flag)
% comparison_plot(inputBinData_array, stimulus, fieldnames, time_window, localpath, prefix, stats_flag)

if(nargin<1)
    disp('usage: comparison_plot_v1(inputBinData_array, stimulus, fieldnames, time_window, localpath, prefix, stats_flag)')
    disp('stats_flag = ''no'' for no stats, ''per-worm'' or ''per-movie'' (default)')
    return;
end

fignum_start = 1;

if(nargin<7)
    stats_flag='per-movie';
end

global Prefs;
Prefs = define_preferences(Prefs);

if(~isempty(time_window))
    BinData_array = extract_BinData_array(inputBinData_array, time_window(1), time_window(2));
else
    BinData_array = inputBinData_array;
end

% if any of the BinData_array only has a single movie, do per-worm
% for stats
if(isempty(regexpi(stats_flag,'no')) || (nargin<7))
    for(i=1:length(BinData_array))
        if(BinData_array(i).num_movies <= 2)
            stats_flag = 'per-worm';
            disp(sprintf('%s has <=2 movies, so using per-worm for stats',BinData_array(i).Name))
        end
    end
end


BinData_array_length = length(BinData_array);

if(size(stimulus,1)>1)
    stats_flag = 'no';
end

% autosplit if BinData_array_length is long
if(BinData_array_length>6)
    k=1;
    i=0;
    while(BinData_array_length>0)
        close all
        local_binData_array = [];
        while(length(local_binData_array)<6 && BinData_array_length>0)
            local_binData_array = [local_binData_array BinData_array(k)];
            k=k+1;
            BinData_array_length = BinData_array_length-1;
        end
        i=i+1;
        temp_prefix = sprintf('comp_plot.%d.%d',Prefs.PID,i);
        comparison_plot(local_binData_array, stimulus, fieldnames, time_window, tempdir, temp_prefix,'no_stats');
        clear('local_binData_array');
    end
    
    temp_prefix = sprintf('comp_plot.%d',Prefs.PID);
    pool_temp_pdfs(i, localpath, prefix, temp_prefix);
    
    return;
end

xlabelstring = 'Time (sec)';
xmin = min(0,floor(min(BinData_array(1).time)-2/Prefs.FrameRate));
xmax = ceil(max(BinData_array(1).time)+2/Prefs.FrameRate);

if(nargin < 2)
    stimulus = [];
end

if(isempty(stimulus))
    Prefs.graph_no_stim_width = 300;
    stimlength = 1;
else
    stimlength = length(stimulus(:,1));
end



if(nargin < 3)
    fieldnames = [];
end

if(isempty(fieldnames))
    fieldnames = {'speed','body_angle','head_angle','tail_angle','ecc_omegaupsilon','revlength','curv','revSpeed', ...
        'Rev_freq','lRev_freq','sRev_freq','omegaUpsilon_freq','omega_freq','upsilon_freq',...
        'pure_lRev_freq','pure_sRev_freq','pure_omega_freq','pure_upsilon_freq', ...
        'lRevUpsilon_freq','lRevOmega_freq','sRevUpsilon_freq','sRevOmega_freq'};
end

if(nargin>3)
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



close all;

disp([sprintf('comparison_plot\t%s',timeString())])

temp_prefix = sprintf('page.%d',randint(1000));

plot_columns = BinData_array_length;
plot_rows = 4;

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

ff=1;
while(ff<=length(fieldnames))
    
    ff_end = min(ff+(plot_rows-1), length(fieldnames));
    
    for(i=ff:ff_end)
        
        field = fieldnames{i};
        
        ymin_line_vector = [];
        ymax_line_vector = [];
        ymin_bar_vector = [];
        ymax_bar_vector = [];
        
        plot_location = 1 + (mod(i,plot_rows)-1)*plot_columns;
        if(mod(i,plot_rows)==0) 
            plot_location = 1 + (plot_rows-1)*plot_columns; 
        end
        
        for(j=1:BinData_array_length)
            
            BinData = BinData_array(j);
            
            
            % linegraphs on page fignum
            figure(fignum);
            panel_number = [plot_location 0];
            plot_attribute(BinData, stimulus, plot_rows, plot_columns, xmin, xmax, ymin, ymax, xlabelstring, ylabelstring, field, color, panel_number);
            
            
            % bargraphs on page fignum+1
            figure(fignum+1);
            panel_number = [0 plot_location];
            [ymin_line, ymax_line, ymin_bar, ymax_bar, barhandles(plot_location) ] = plot_attribute(BinData, stimulus, plot_rows, plot_columns, xmin, xmax, ymin, ymax, xlabelstring, ylabelstring, field, color, panel_number);
            % delete within-strain stats marks
            for(rr=1:length(barhandles(plot_location).stat_symbols))
                if(barhandles(plot_location).stat_symbols(rr) > 0)
                    delete(barhandles(plot_location).stat_symbols(rr));
                    barhandles(plot_location).stat_symbols(rr) = -10;
                end
            end
            
            ymin_line_vector = [ymin_line_vector ymin_line];
            ymax_line_vector = [ymax_line_vector ymax_line];
            ymin_bar_vector = [ymin_bar_vector ymin_bar];
            ymax_bar_vector = [ymax_bar_vector ymax_bar];
            
            
            plot_location = plot_location+1;
        end
        
        ymin_line = min(ymin_line_vector);
        ymin_line = ymin_line(1);
        
        ymax_line = max(ymax_line_vector);
        ymax_line = ymax_line(1);
        
        ymin_bar = min(ymin_bar_vector);
        ymin_bar = ymin_bar(1);
        
        ymax_bar = max(ymax_bar_vector);
        ymax_bar = ymax_bar(1);
        
%         if(~isempty(strfind(field,'freq')))
%             ymax_line = 2.5;
%             ymax_bar = 2.5;
%         end
        
        % set all the y-axes to be equal and label only the leftmost y-axes
        plot_location = 1 + (mod(i,plot_rows)-1)*plot_columns;
        if(mod(i,plot_rows)==0) 
            plot_location = 1 + (plot_rows-1)*plot_columns; 
        end
        fontsize = scaled_fontsize_for_subplot(1, 1);
        for(j=1:BinData_array_length)
            
            for(q=0:1)
                figure(fignum+q);
                plot_handle = subplot(plot_rows, plot_columns, plot_location);
                
                if(q==0) % line graph
                    panel_number = [plot_location 0];
                    plot_attribute(BinData_array(j), stimulus, plot_rows, plot_columns, xmin, xmax, ymin_line, ymax_line, xlabelstring, ylabelstring, field, color, panel_number);
                    axis normal
                else % bar graph
                    ylim([ymin_bar, ymax_bar]);
                    axis normal
                end
                
                if(diff_flag == 1)
                    set(gca,'XColor','w');
                end
                
                if(i==ff)
                    h = text(0.5,1.2,fix_title_string(BinData_array(j).Name),'FontSize',scaled_fontsize_for_subplot(plot_rows, plot_columns),'FontName','Helvetica','HorizontalAlignment','center','units','normalized');
                    set(h,'HandleVisibility','off');
                end
                
                if(j>1)
                    ylabel('');
                    set(gca,'YTickLabel',[]);
                    if(q==1) % turn off y-axis for bargraphs in column > 1
                        set(gca,'YColor','w');
                    end
                    box off
                end
                if(j==1)
                    hy = get(gca, 'ylabel');
                    set(hy, 'FontSize', fontsize);
                end
                if(i<ff_end)
                    xlabel('');
                    set(gca,'XTickLabel',[]);
                    box off
                end
                
                if(i==ff_end)
                    if(q==0) % turn on x-axis for linegraph
                        set(gca,'XColor','k');
                    end
                    hx = get(gca, 'xlabel');
                    set(hx, 'FontSize', fontsize);
                end
                
            end
            plot_location = plot_location+1;
        end
    end
    
    % put symbols indicating significant differences from BinData_array(1) strain
    % on a per-bar basis
    
    
    if(isempty(regexpi(stats_flag,'no'))) % calculate stats
        [values, stddev, errors, n] = stimulus_summary_stats(BinData_array(1), stimulus, field);
        
        stimsummary_length = length(values(1,:));
        figure(fignum+1);
        for(f=ff:ff_end)
            field = fieldnames{f};
            
            mean_matrix=zeros(stimlength, BinData_array_length, stimsummary_length) + NaN;
            stddev_matrix=mean_matrix;
            n_matrix=mean_matrix;
            
            for(i=1:BinData_array_length)
                [values, stddev, errors, n] = stimulus_summary_stats(BinData_array(i), stimulus, field);
                for(s=1:stimlength)
                    mean_matrix(s,i,:) = values;
                    stddev_matrix(s,i,:) = stddev;
                    if(~isempty(regexpi(stats_flag,'mov'))) % per-movie stats
                        n_matrix(s,i,:) = BinData_array(i).num_movies;
                    else
                        n_matrix(s,i,:) = n;
                    end
                end
            end
            
            for(s=1:stimlength)
                for(k=1:stimsummary_length)
                    means=[];
                    stddevs=[];
                    n=[];
                    strainnames=[];
                    for(i=1:BinData_array_length)
                        means = [means mean_matrix(s,i,k)];
                        stddevs = [stddevs stddev_matrix(s,i,k)];
                        n = [n n_matrix(s,i,k)];
                        strainnames{i} = BinData_array(i).Name;
                    end
                    
                    % Tukey-Kramer for multiple comparisons
                    p_value_vector = multicompare_to_base_value(means, stddevs, n, strainnames);
                    signif_symbols = p_value_vector_to_significance_thresh(p_value_vector);
                    
                    plot_location = 1 + (mod(f,plot_rows)-1)*plot_columns;
                    if(mod(f,plot_rows)==0)
                        plot_location = 1 + (plot_rows-1)*plot_columns;
                    end
                    plot_location=plot_location+1;
                    for(i=2:BinData_array_length)
                        subplot(plot_rows, plot_columns, plot_location);
                        x = get(barhandles(plot_location).errors(k), 'xdata'); 
                        x=x(1);
                        y = max(get(gca,'ylim')); y=y(1);
                        h = text(x,y, sprintf('%s',signif_symbols{i}), 'fontsize',scaled_fontsize_for_subplot(plot_rows, plot_columns), 'FontName','Helvetica','HorizontalAlignment','center' );
                        set(h,'HandleVisibility','off');
                        plot_location=plot_location+1;
                    end
                    
                end
            end
            
            clear('mean_matrix'); clear('stddev_matrix'); clear('n_matrix');
        end
    end
    fignum = fignum+2;
    ff=ff_end+1;
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
