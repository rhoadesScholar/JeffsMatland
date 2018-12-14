function comparison_plot(inputBinData_arrays, stimulus, fieldnames, time_window, localpath, strainnames, stats_flag)
% comparison_plot(inputBinData_array, Tracks_cell_array, stimulus, fieldnames, time_window, localpath, prefix, stats_flag)

if(nargin<1)
    disp('usage: comparison_plot(inputBinData_arrays, stimulus, fieldnames, time_window, localpath, strainnames, stats_flag)')
    disp('stats_flag = ''no'' for no stats, ''per-worm'' or ''per-movie'' (default)')
    return;
end

fignum_start = gcf;

if(nargin<2)
    stimulus=[];
end

if(nargin < 3)
    fieldnames = [];
end

if(nargin < 4)
    time_window = [];
end

if(nargin < 5)
    localpath = '';
end

if(nargin < 6)
   strainnames = [];
end

if(nargin<7)
    stats_flag='per-movie';
end

global Prefs;
Prefs = define_preferences(Prefs);

% convert to cell array if need be
if(~iscell(inputBinData_arrays))
    dummy = inputBinData_arrays;
    clear('inputBinData_arrays');
    for(i=1:length(dummy))
        inputBinData_arrays{i} = dummy(i);
    end
end
    
for(i=1:length(inputBinData_arrays))
    if(~isempty(time_window))
        inputBinData_arrays{i} = extract_BinData_array(inputBinData_arrays{i}, time_window(1), time_window(2));
    else
        inputBinData_arrays{i} = extract_BinData_array(inputBinData_arrays{i});
    end
    BinData_array(i) = mean_BinData_from_BinData_array(inputBinData_arrays{i});
    if(~isempty(strainnames))
        BinData_array(i).Name = strainnames{i};
    end
end

if(isempty(strainnames))
    for(i=1:length(BinData_array))
        strainnames{i} = BinData_array(i).Name;
    end
end

prefix = strainnames{1};
for(i=2:length(strainnames))
    prefix = sprintf('%s.%s',prefix,strainnames{i});
end
prefix = sprintf('%s.compare',prefix);

if(~isempty(time_window))
    BinData_array = extract_BinData_array(BinData_array, time_window(1), time_window(2));
else
    BinData_array = extract_BinData_array(BinData_array);
end

% if any of the BinData_array only has a single movie, do per-worm
% for stats
if(isempty(regexpi(stats_flag,'no')) || (nargin<7))
    for(i=1:length(BinData_array))
        if(BinData_array(i).num_movies <= 2)
            stats_flag = 'per-worm';
            disp(sprintf('%s has <3 movies, so using per-worm for stats',BinData_array(i).Name))
        end
    end
end

BinData_array_length = length(BinData_array);

% autosplit if BinData_array_length is long
if(BinData_array_length>6)
    k=1;
    i=0;
    while(BinData_array_length>0)
        close all
        mm=1;
        while(length(local_binData_array)<6 && BinData_array_length>0)
            local_binData_array{mm} = inputBinData_arrays{k};
            k=k+1; mm=mm+1;
            BinData_array_length = BinData_array_length-1;
        end
        i=i+1;
        temp_prefix = sprintf('comp_plot.%d.%d',Prefs.PID,i);
        comparison_plot(local_binData_array, stimulus, fieldnames, time_window, tempdir, temp_prefix,stats_flag);
        clear('local_binData_array');
    end
    
    temp_prefix = sprintf('comp_plot.%d',Prefs.PID);
    pool_temp_pdfs(i, localpath, prefix, temp_prefix);
    
    return;
end

xlabelstring = 'Time (sec)';
xmin = min(0,floor(min(BinData_array(1).time)-2/Prefs.FrameRate));
xmax = ceil(max(BinData_array(1).time)+2/Prefs.FrameRate);

if(isfield(BinData_array(1),'xlabel'))
    xlabelstring = BinData_array(1).xlabel;
    xmin = min(0, min(BinData_array(1).time));
    xmax = max(BinData_array(1).time);
end
lineplot_BinData_array = BinData_array;
if(isempty(stimulus))
    Prefs.graph_no_stim_width = 300;
    stimlength = 1;
    
    if(isfield(BinData_array(1),'xlabel'))
        Prefs.graph_no_stim_width = BinData_array(1).time(2) - BinData_array(1).time(1);
    end
    
else
    if(isnumeric(stimulus))
        stimlength = length(stimulus(:,1));
    else
        if(strcmp(stimulus,'staring') || strcmp(stimulus,'stare'))
            stimlength = 1; 
            lineplot_BinData_array = alternate_binwidth_BinData(BinData_array,60);
            for(i=1:length(inputBinData_arrays))
                inputBinData_arrays{i} = alternate_binwidth_BinData(inputBinData_arrays{i},60);
            end
        end
    end
end

if(isempty(fieldnames))
    fieldnames = Prefs.fieldnames;
end

if(nargin>5)
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
plot_rows = 6;

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
    figure(fignum);
    
    ff_end =  min((ff+(plot_rows/3 -1)),length(fieldnames));
    
    i=1;
    for(f=ff:ff_end)
        
        field = fieldnames{f};
        
        ymin_line_vector = [];
        ymax_line_vector = [];
        ymin_bar_vector = [];
        ymax_bar_vector = [];
        
        % plot_location = 1 + (mod(i,plot_rows)-1)*plot_columns*BinData_array_length;

        if(i>1)
            plot_location = mod((i-1),3) + plot_columns*3;
        else
            plot_location = 1;
        end
        
        for(j=1:BinData_array_length)
            BinData = lineplot_BinData_array(j);
            
            panel_number = [(plot_location+plot_columns) (plot_location+2*plot_columns)];
            
            
            [ymin_line, ymax_line, ymin_bar, ymax_bar, barhandles(plot_location+2*plot_columns)] =  plot_attribute(inputBinData_arrays{j}, stimulus, plot_rows, plot_columns, xmin, xmax, ymin, ymax, xlabelstring, ylabelstring, field, color, panel_number);

            
            % delete within-strain stats marks
            for(rr=1:length(barhandles(plot_location+2*plot_columns).stat_symbols))
                if(barhandles(plot_location+2*plot_columns).stat_symbols(rr) > 0)
                    delete(barhandles(plot_location+2*plot_columns).stat_symbols(rr));
                    barhandles(plot_location+2*plot_columns).stat_symbols(rr) = -10;
                end
            end
            subplot(plot_rows, plot_columns, (plot_location+plot_columns));
            freq_plot_pos = get(gca, 'Position');
            
%             if(~isempty(Tracks) &&  ~isempty(strfind(field,'_freq')))
%                 mean_n_freq = round(max(BinData.n_freq));
%                 mvt = field(1:(end-5));
%                 gg = mvt_init_ethogram(Tracks(1:mean_n_freq), stimulus, plot_rows, plot_columns, ...
%                     plot_location, mvt, 'k', [xmin xmax]);
%                 ylabel('');
%             else
                subplot(plot_rows, plot_columns, plot_location);
                gg = gca;
                axis off
%            end
            set(gg,'Position',[freq_plot_pos(1), freq_plot_pos(2) + freq_plot_pos(4), freq_plot_pos(3), freq_plot_pos(4)]);
            
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
        if(i>1)
            plot_location = mod((i-1),3) + plot_columns*3;
        else
            plot_location = 1;
        end
        
        fontsize = scaled_fontsize_for_subplot(1, 1);
        for(j=1:BinData_array_length)
            BinData = lineplot_BinData_array(j);
            
            
            for(q=0:1)
                
                if(q==0) % line graph
                    panel_number = [(plot_location+plot_columns) 0];
                    plot_attribute(inputBinData_arrays{j}, stimulus, plot_rows, plot_columns, xmin, xmax, ymin_line, ymax_line, ...
                                        xlabelstring, ylabelstring, field, color, panel_number);
                    axis normal
                    hold on;
                    freq_plot_pos = get(gca, 'Position');
                    
                    if(f==ff)   % title for top line plot ... ethogram for freqs, empty for others
%                         if(~isempty(Tracks) &&  ~isempty(strfind(field,'_freq')))
%                             mean_n_freq = round(max(BinData.n_freq));
%                             mvt = field(1:(end-5));
%                             gg = mvt_init_ethogram(Tracks(1:mean_n_freq), stimulus, plot_rows, plot_columns, ...
%                                 plot_location, mvt, 'k', [xmin xmax]);
%                          	ylabel('');
%                         else
                            subplot(plot_rows, plot_columns, plot_location);
                            gg = gca;
                            axis off
%                         end
                        set(gg,'Position',[freq_plot_pos(1), freq_plot_pos(2) + freq_plot_pos(4), freq_plot_pos(3), freq_plot_pos(4)]);
                        h = text(0.5,1.2,fix_title_string(BinData.Name),'FontSize',scaled_fontsize_for_subplot(plot_rows, plot_columns),'FontName','Helvetica','HorizontalAlignment','center','units','normalized');
                        set(h,'HandleVisibility','off');
                        subplot(plot_rows, plot_columns, (plot_location+plot_columns)); % sets gca to the line plot
                    end
                else % bar graph
                    subplot(plot_rows, plot_columns, (plot_location+2*plot_columns));
                    ylim([ymin_bar, ymax_bar]);
                    axis normal
                end
                
                if(diff_flag == 1)
                    set(gca,'XColor','w');
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
                if(f<ff_end)
                    xlabel('');
                    set(gca,'XTickLabel',[]);
                    box off
                end
                
          %      if(f==ff_end)
                    if(q==0) % turn on x-axis for linegraph
                        set(gca,'XColor','k');
                    end
                    hx = get(gca, 'xlabel');
                    set(hx, 'FontSize', fontsize);
           %     end
                
            end
            plot_location = plot_location+1;
        end
        i=i+1;
    end
    
    % put symbols indicating significant differences from BinData_array(1) strain
    % on a per-bar basis
   
   
    if(isempty(regexpi(stats_flag,'no'))) % calculate stats
        [values, stddev, errors, n] = stimulus_summary_stats(BinData_array(1), stimulus, fieldnames{1});
        
        stimsummary_length = length(values(1,:));
        v=1;
        for(f=ff:ff_end)
            field = fieldnames{f};
            
            mean_matrix=zeros(stimlength, BinData_array_length, stimsummary_length) + NaN;
            stddev_matrix=mean_matrix;
            n_matrix=mean_matrix;
            
            for(i=1:BinData_array_length)
                [values, stddev, errors, n] = stimulus_summary_stats(inputBinData_arrays{i}, stimulus, field);
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
                    
                    % get p-values and correct for multiple comparisons
                    p_value_vector = multicompare_to_base_value(means, stddevs, n, strainnames);
                    
                    
                    signif_symbols = p_value_vector_to_significance_thresh(p_value_vector);

                    if(v>1)
                        plot_location = mod((v-1),3) + plot_columns*3;
                    else
                        plot_location = 1;
                    end
                    plot_location = plot_location + 2*plot_columns+1;
                    
                    for(i=2:BinData_array_length)
                        subplot(plot_rows, plot_columns, plot_location);
                        
                        x = min(get(barhandles(plot_location).errors(1,k),'xdata'));
                        x = x(1);
                        y = max(get(gca,'ylim')); y=y(1);
                        h = text(x,y, sprintf('%s',signif_symbols{i}), 'fontsize',scaled_fontsize_for_subplot(plot_rows, plot_columns), 'FontName','Helvetica','HorizontalAlignment','center' );
                        set(h,'HandleVisibility','off');
                        plot_location=plot_location+1;
                    end
                    
                end
            end
            
            clear('mean_matrix'); clear('stddev_matrix'); clear('n_matrix');
            v=v+1;
        end
    end
    fignum = fignum+1;
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
