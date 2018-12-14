function plot_fitting_histograms(fitting_struct, title_string)

if(nargin<2)
    title_string='';
end

plot_columns = 3*5; 
plot_rows = ceil(length(fitting_struct.data)/3 + 1);


plot_number = 0;

% rate constant histograms
xlabelstring = fix_title_string(sprintf('k (/sec)'));
color = {'b','c','m','r'};

ymax = [];
ymin = [];
handle_vector=[];
for(param_index = 1:4)
    plot_number = plot_number+1;
    
    h=plot_simulated_fit_histogram(plot_rows,plot_columns,plot_number, fitting_struct, param_index, color{param_index}, '','');
    
    handle_vector = [handle_vector h];
    
    yaxis_limits = get(h,'YLim');
    ymin = [ymin yaxis_limits(1)];
    ymax = [ymax yaxis_limits(2)];
end

ymax = max(ymax);
ymin = min(ymin);
yaxis_limits = [ymin  ymax];

handle_A = handle_vector(1);
set(handle_A,'box','off');
set(handle_A,'ylim',yaxis_limits);
posA = get(handle_A, 'position');
for(q = 2:4)
    handle_B = handle_vector(q);
    set(handle_B,'YAxisLocation','right');
    set(handle_B,'YTick',[]); % removes axis numbering
    set(handle_B,'YColor','w'); % removes axis itself by coloring it white
    set(handle_B,'YAxisLocation','left');
    set(handle_B,'YTick',[]); % removes axis numbering
    set(handle_B,'YColor','k'); %
    ylabel('');
    set(handle_B,'ylim',yaxis_limits);
    set(handle_B,'box','off');
    set(handle_B, 'position',[(posA(1)+posA(3)), posA(2), posA(3), posA(4)]);
    set(handle_A, 'position',posA);
    handle_A = handle_B;
    posA = get(handle_A, 'position');
end
box off

set(get(handle_vector(2),'XLabel'),'String',fix_title_string(['                ',xlabelstring]),'FontSize',7);


for(q = 1:4)
    h = handle_vector(q);
    
    xaxis_limits = get(h,'XLim');
    xmin = xaxis_limits(1);
    xmax = xaxis_limits(2);
    xrange = xmax - xmin;


    set(h, 'XTick', [(xmin+xrange/5) (xmax-xrange/5)], 'XTickLabel', sprintf('%0.1f|', [(xmin+xrange/5) (xmax-xrange/5)]));
    if(xrange <= 0.1)
        set(h, 'XTick', [(xmin+xrange/5) (xmax-xrange/5)], 'XTickLabel', sprintf('%0.2f|', [(xmin+xrange/5) (xmax-xrange/5)]));
    end
    if(xrange <= 0.01)
        set(h, 'XTick', [(xmin+xrange/5) (xmax-xrange/5)], 'XTickLabel', sprintf('%0.3f|', [(xmin+xrange/5) (xmax-xrange/5)]));
    end
    if(xmin>=10)
        set(h, 'XTick', [(xmin+xrange/5) (xmax-xrange/5)], 'XTickLabel', sprintf('%0.1f|', [(xmin+xrange/5) (xmax-xrange/5)]));
    end
    
    set(h,'FontSize',5);
    
    tL = get(h,'TickLength');
    set(h,'TickLength',tL*4);
    
    set(h,'Layer','top');
    

end

for(q = 1:4)
    h = handle_vector(q);
    
    xaxis_limits = get(h,'XLim');
    xmin = xaxis_limits(1);
    xmax = xaxis_limits(2);
    xrange = xmax - xmin;
    
    subplot(h);
    set(gca, 'color', 'none');
    % text((xmax - 0.4*xrange), ymax, fitting_struct.f.param{q},'FontSize',9,'color','k');
    
    dummystring = sprintf('%.6f %s\n%.6f',fitting_struct.un_norm_m_avg(q), '\pm', fitting_struct.un_norm_m_std(q));
    text((xmax - 0.5*xrange), ymax, dummystring,'FontSize',4,'color','k','HorizontalAlignment','center');
end

% blank subplot
plot_number = plot_number+1;
wormstate_code = {'A','B','C','D','E' };

% gamma distribution subplots
color = {'b','c','g','m','r'};
i=5;
for(d=1:length(fitting_struct.data))
    xlabelstring = sprintf('gamma_%s', fitting_struct.data(d).fieldname);
    
    unitstring='';
    if(regexpi(fitting_struct.data(d).fieldname,'speed'))
        unitstring = '(mm/sec)';
    end
    if(regexpi(fitting_struct.data(d).fieldname,'angle'))
        unitstring = '(degrees)';
    end
    if(regexpi(fitting_struct.data(d).fieldname,'freq'))
        unitstring = '(/min)';
    end
    
    xlabelstring = sprintf('%s %s',xlabelstring,unitstring);
    
    ymax = [];
    ymin = [];
    handle_vector=[];
    q=1;
    for(param_index = i:i+4)
        plot_number = plot_number+1;
        
        h=plot_simulated_fit_histogram(plot_rows,plot_columns,plot_number, fitting_struct, param_index, color{q}, '','');
        
        handle_vector = [handle_vector h];
        
        yaxis_limits = get(h,'YLim');
        ymin = [ymin yaxis_limits(1)];
        ymax = [ymax yaxis_limits(2)];
        q=q+1;
    end
    
    ymax = max(ymax);
    ymin = min(ymin);
    yaxis_limits = [ymin  ymax];
    
    handle_A = handle_vector(1);
    set(handle_A,'box','off');
    set(handle_A,'ylim',yaxis_limits);
    posA = get(handle_A, 'position');
    for(q = 2:5)
        handle_B = handle_vector(q);
        set(handle_B,'YAxisLocation','right');
        set(handle_B,'YTick',[]); % removes axis numbering
        set(handle_B,'YColor','w'); % removes axis itself by coloring it white
        set(handle_B,'YAxisLocation','left');
        set(handle_B,'YTick',[]); % removes axis numbering
        set(handle_B,'YColor','k'); %
        ylabel('');
        set(handle_B,'ylim',yaxis_limits);
        set(handle_B,'box','off');
        set(handle_B, 'position',[(posA(1)+posA(3)), posA(2), posA(3), posA(4)]);
        set(handle_A, 'position',posA);
        handle_A = handle_B;
        posA = get(handle_A, 'position');
    end
    box off
    
    set(get(handle_vector(3),'XLabel'),'String',fix_title_string(['',xlabelstring]),'FontSize',7)
    
    param_index=i;
    for(q = 1:5)
        h = handle_vector(q);
        
        xaxis_limits = get(h,'XLim');
        xmin = xaxis_limits(1);
        xmax = xaxis_limits(2);
        xrange = xmax - xmin;
        
        
        set(h, 'XTick', [(xmin+xrange/5) (xmax-xrange/5)], 'XTickLabel', sprintf('%0.1f|', [(xmin+xrange/5) (xmax-xrange/5)]));
        if(xrange <= 0.1)
            set(h, 'XTick', [(xmin+xrange/5) (xmax-xrange/5)], 'XTickLabel', sprintf('%0.2f|', [(xmin+xrange/5) (xmax-xrange/5)]));
        end
        if(xrange < 0.01)
            set(h, 'XTick', [(xmin+xrange/5) (xmax-xrange/5)], 'XTickLabel', sprintf('%0.3f|', [(xmin+xrange/5) (xmax-xrange/5)]));
        end
        if(xmin>=10)
            set(h, 'XTick', [(xmin+xrange/5) (xmax-xrange/5)], 'XTickLabel', sprintf('%0.1f|', [(xmin+xrange/5) (xmax-xrange/5)]));
        end
            
    
        set(h,'FontSize',5);
        
        tL = get(h,'TickLength');
        set(h,'TickLength',tL*4);
        
        set(h,'Layer','top');
        param_index=param_index+1;
    end
    
    for(q = 1:5)
        h = handle_vector(q);
        
        xaxis_limits = get(h,'XLim');
        xmin = xaxis_limits(1);
        xmax = xaxis_limits(2);
        xrange = xmax - xmin;
        
        subplot(h);
        set(gca, 'color', 'none');
        %text((xmax - 0.4*xrange), ymax, fitting_struct.f.param{i+q-1},'FontSize',9,'color','k');
    end
    
    param_index=i;
    for(q = 1:5)
        h = handle_vector(q);
        
        xaxis_limits = get(h,'XLim');
        xmin = xaxis_limits(1);
        xmax = xaxis_limits(2);
        xrange = xmax - xmin;
        
        subplot(h);
        set(gca, 'color', 'none');
        % text((xmax - 0.4*xrange), ymax, fitting_struct.f.param{q},'FontSize',9,'color','k');
        dummystring = sprintf('%.6f %s\n%.6f',fitting_struct.un_norm_m_avg(param_index), '\pm', fitting_struct.un_norm_m_std(param_index));
        text((xmax - 0.5*xrange), ymax, dummystring,'FontSize',4,'color','k','HorizontalAlignment','center');
        param_index=param_index+1;
    end
    
    
    clear('ymax');
    clear('ymin');
    clear('handle_vector');
    clear('xaxis_limits');
    clear('yaxis_limits');
    
    i=i+5;
end

p = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',p);
text(0.5,0.95,fix_title_string(title_string),'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center'); 

orient landscape;
set(gcf,'renderer','painters');
set(gcf,'PaperPositionMode','manual');
set(gcf, 'PaperPosition',[0 0 11 8.5]);
hold off;

return;
end

function h = plot_simulated_fit_histogram(plot_rows,plot_columns,plot_number,fitting_struct, param_index, color, xlabelstring,xaxis_log)

h = subplot(plot_rows,plot_columns,plot_number);

if(nargin<8)
    xaxis_log = '';
end

data_vec = fitting_struct.un_norm_simulated_fit_matrix(:,param_index);

[y,x] = hist(data_vec, 5);

y = y/(nansum(y));
binwidth = (max(x) - min(x))/length(x);

% make the plots a bit bigger
x = [(min(x)-4*binwidth) x (max(x) + 4*binwidth)];
y = [0 y 0 ];

y_mid_idx = round(length(y)/2);

local_x=x;

x_fit = fitting_struct.un_norm_m(param_index);
x_avg = fitting_struct.un_norm_m_avg(param_index);

y_fit = y(1);

if(~isnan(x_fit))
[s, fit_idx] = find_closest_value_in_array(x_fit, x);
if(~isempty(fit_idx))
    y_fit = y(fit_idx);
    while(y_fit < 1e-4)
        fit_idx = fit_idx-1;
        if(fit_idx < 1)
            break;
        else
            y_fit = y(fit_idx);
        end
    end
    while(y_fit < 1e-4)
        fit_idx = fit_idx+1;
        if(fit_idx == length(x))
            break;
        else
            y_fit = y(fit_idx);
        end
    end
end
else
    x_fit = x(1);
end

y_avg = y(y_mid_idx);
if(~isnan(x_avg)) 
[s, avg_idx] = find_closest_value_in_array(x_avg, x);
if(~isempty(fit_idx))
    y_avg = y(avg_idx);
    while(y_avg < 1e-4)
        avg_idx = avg_idx-1;
        if(avg_idx < 1)
            break;
        else
            y_avg = y(avg_idx);
        end
    end
    while(y_avg < 1e-4)
        avg_idx = avg_idx+1;
        if(avg_idx == length(x))
            break;
        else
            y_avg = y(avg_idx);
        end
    end
end
else
x_avg=x(y_mid_idx);    
end

x_fit_local = x_fit;
x_avg_local = x_avg;


if(strcmpi(xaxis_log,'log2'))
    local_x = log(x)/log(2);
    x_fit_local = log(x_fit)/log(2);
    x_avg_local = log(x_avg)/log(2);
else
    if(strcmpi(xaxis_log,'log10'))
        local_x = log(x)/log(10);
        x_fit_local = log(x_fit)/log(10);
        x_avg_local = log(x_avg)/log(10);
    else
        if(strcmpi(xaxis_log,'ln'))
            local_x = log(x);
            x_fit_local = log(x_fit);
            x_avg_local = log(x_avg);
        end
    end
end

%plot(local_x,y,'.-');
bar(local_x,y,1.1,color,'edgecolor',color);
hold on;

plot(x_fit_local, y_fit, 'x','markersize',5,'color','k');
plot(x_avg_local, y_avg, 'o','markersize',5,'color','k');

ylim([0 1.1*max(max(y), max(y_fit, y_avg))]);

xlim([min(x) max(x)]);

if(~isempty(xlabelstring))
    hx = xlabel(xlabelstring);
    fontsize = scaled_fontsize_for_subplot(plot_rows, plot_columns);
    set(gca,'FontSize',fontsize);
    set(hx,'FontSize',fontsize);
end

box off
hold off;

return;
end


