function comparison_fits_plot(input_fitting_struct_array, fieldnames, diff_flag, localpath, prefix, fignum_start)
% comparison_fits_plot(fitting_struct_array, fieldnames, diff_flag, localpath, prefix, fignum_start)

if(nargin<1)
    disp('usage: comparison_fits_plot(fitting_struct_array, fieldnames, diff_flag, localpath, prefix, fignum_start)');
    return;
end

global Prefs;
Prefs = define_preferences(Prefs);

fitting_struct_array_length = length(input_fitting_struct_array);

if(nargin < 2)
    fieldnames = [];
end

if(isempty(fieldnames))
    fieldnames = Prefs.fieldnames;
end

if(nargin < 3)
    diff_flag = '';
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

if(nargin < 6)
    fignum_start=1;
end

if(fignum_start == 1)
    close all;
end

disp([sprintf('comparison_fits_plot\t%s',timeString())])

temp_prefix = sprintf('page.%d',randint(1000));

plot_columns = 6; % fitting_struct_array_length;
plot_rows = 4; % length(fieldnames);

color='';
ymin=0;
ymax=0;
ylabelstring = '';

fitting_struct_array = input_fitting_struct_array;

if(strcmpi(diff_flag,'diff') || ~isempty(regexpi(diff_flag,'subtr')) || ~isempty(regexpi(diff_flag,'basel')))
    ymin=-0.001;
    ymax=0.001;
    fitting_struct_array = [];
    for(i=1:fitting_struct_array_length)
        fitting_struct_array = [ fitting_struct_array baseline_gamma_subtract_fitting_struct(input_fitting_struct_array(i)) ];
    end
end

fignum = fignum_start;

ff=1;
while(ff<=length(fieldnames))
    
    ff_end = min(ff+3, length(fieldnames));
    
    for(i=ff:ff_end)
        
        field = fieldnames{i};
        
        ymin_bar_vector = [];
        ymax_bar_vector = [];
        
        plot_location = 1 + (mod(i,4)-1)*plot_columns;
        if(mod(i,4)==0) plot_location = 1 + (4-1)*plot_columns; end
        
        for(j=1:BinData_array_length)
            
            BinData = BinData_array(j);
            
            
            % bargraphs 
            figure(fignum);
            panel_number = [0 plot_location];
            [ymin_line, ymax_line, ymin_bar, ymax_bar] = plot_attribute(BinData, stimulus, plot_rows, plot_columns, xmin, xmax, ymin, ymax, xlabelstring, ylabelstring, field, color, panel_number);
            
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
        
        % set all the y-axes to be equal and label only the leftmost y-axes
        plot_location = 1 + (mod(i,4)-1)*plot_columns; 
        if(mod(i,4)==0) plot_location = 1 + (4-1)*plot_columns; end
        fontsize = scaled_fontsize_for_subplot(1, 1);
        for(j=1:BinData_array_length)
            
            for(q=0:1)
                figure(fignum+q);
                subplot(plot_rows, plot_columns, plot_location);
                
                if(q==0) % line graph
                    panel_number = [plot_location 0];
                    plot_attribute(BinData_array(j), stimulus, plot_rows, plot_columns, xmin, xmax, ymin_line, ymax_line, xlabelstring, ylabelstring, field, color, panel_number);
                    axis normal
                else % bar graph
                    ylim([ymin_bar, ymax_bar]);
                    axis normal
                end
                
                if(strcmpi(diff_flag,'diff') || ~isempty(regexpi(diff_flag,'subtr')) || ~isempty(regexpi(diff_flag,'basel')))
                    set(gca,'XColor','w');
                end
                
                if(mod(i,4)==1)
                    h = text(0.5,1.2,fix_title_string(BinData_array(j).Name),'FontSize',scaled_fontsize_for_subplot(1, 1),'FontName','Helvetica','HorizontalAlignment','center','units','normalized');
                    set(h,'HandleVisibility','off');
                end
                
                if(j>1)
                    ylabel('');
                    set(gca,'YTickLabel',[]);
                    box off
                end
                if(j==1)
                    hy = get(gca, 'ylabel');
                    set(hy, 'FontSize', fontsize);
                end
                if(i<length(fieldnames))
                    xlabel('');
                    set(gca,'XTickLabel',[]);
                    box off
                end
                if(i==length(fieldnames))
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
    % on a per-bar basis; stimsummary_length (5) bars per stimulus
    alpha_symbol = {'+','*','**','***'};
    alpha_list = [0.05 0.01 0.001 0.0001];
    
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
                n_matrix(s,i,:) = n;
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
                
                [datavector, groupvector] = simulate_group_data_from_summary_stats(means, stddevs, n, strainnames);
                multcompare_output = anova1multicompare(datavector, groupvector, alpha_list);
                
                
                % multcompare_output.stats =
                % [strain1_index strain2_index difference alpha_list_index alpha]
                % alpha_list_index==0 for non-significant
                
                i=1;
                while(multcompare_output.stats(i,1)==1)
                    if(multcompare_output.stats(i,4)>0)
                        plot_location = (mod(f,4)-1)*plot_columns + multcompare_output.stats(i,2); 
                        if(mod(f,4)==0) plot_location = (4-1)*plot_columns + multcompare_output.stats(i,2);  end
                        subplot(plot_rows, plot_columns, plot_location);
                        v = get(gca,'children');
                        x = get(v(stimsummary_length-(k-1)),'xdata'); x=x(1);
                        y = max(get(gca,'ylim'));
                        h = text(x,y, alpha_symbol{multcompare_output.stats(i,4)}, 'fontsize',scaled_fontsize_for_subplot(4,6), 'FontName','Helvetica','HorizontalAlignment','center' );
                        set(h,'HandleVisibility','off');
                    end
                    i=i+1;
                end
                
            end
        end
        
        clear('mean_matrix'); clear('stddev_matrix'); clear('n_matrix');
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
