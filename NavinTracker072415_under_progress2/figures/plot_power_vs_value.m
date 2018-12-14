function [f, ymin, ymax, xmin, xmax, hh] = plot_power_vs_value(BinData_array, stimulus, field, color, stattype)
% [f, ymin, ymax, xmin, xmax, hh] = plot_power_vs_value(BinData_array, stimulus, field, color)

define_led_prefs();
global POWERMETER_AREA;

if(nargin<4)
    color = '';
end

if(nargin<5)
    stattype = 'mean';
end

if(isempty(color))
    color = stimulus_colormap(stimulus(1,3));
end

diff_flag=0;

xlabelstring = 'mW';

units = '';
if(regexpi(field,'speed'))
    units = '(mm/sec)';
end
if(regexpi(field,'freq'))
    units = '(/min)';
end
if(regexpi(field,'angle'))
    units = '(degrees)';
end
ylabelstring = sprintf('%s\n%s',field,units);

if(diff_flag==1)
    ylabelstring = sprintf('%s %s','\Delta',ylabelstring);
end

xlabelstring = fix_title_string(xlabelstring);
ylabelstring = fix_title_string(ylabelstring);

power_density = [];
y = [];
y_err = [];

for(b=1:length(BinData_array))
    BinData = BinData_array(b);
    if(diff_flag==1)
        BinData = baseline_subtract_BinData(BinData, [0 stimulus(1,1)]);
    end
    for(i=1:length(stimulus(:,1)))
        t1 = stimulus(i,1);
        t2 = stimulus(i,2);
        if(stimulus(i,4)>0)
            power_density = [power_density stimulus(i,4)];
            [val, stddev, err, n] = segment_statistics(BinData, field, stattype, t1, t2);
            y = [y val];
            y_err = [y_err err];
        end
    end
    
    [val, stddev, err, n] = segment_statistics(BinData, field, stattype, 0, stimulus(1,1));
    power_density = [0 power_density];
    y = [val y];
    y_err = [err y_err];
end

y0=[];
for(b=1:length(BinData_array))
    BinData = BinData_array(b);
    if(diff_flag==1)
        BinData = baseline_subtract_BinData(BinData, [0 stimulus(1,1)]);
    end
    [val, stddev, err, n] = segment_statistics(BinData, field, stattype, 0, stimulus(1,1));
    y0 = [y0 val];
end
y0 = nanmean(y0);

power_density = power_density; % /POWERMETER_AREA;

if(diff_flag==1)
    y = abs(y);
end

eL = errorline(power_density,y, y_err,'.','color',color);
set(eL,'color',color);
hold on;
plot(power_density,y,'o','color',color,'markersize',10,'markerfacecolor',color);

set(gca, 'color', 'none');

hy = ylabel(ylabelstring);
hx = xlabel(xlabelstring);

% fontsize = scaled_fontsize_for_subplot(plot_rows, plot_columns);
% set(gca,'FontSize',fontsize);
% set(hy,'FontSize',fontsize);
% set(hx,'FontSize',fontsize);


hold on;
p = power_density;

% increasing
if(y(end) > y(1))
    eq_string = sprintf('y(p) = dy*(p^n/(EC50^n + p^n)) + %f; n=1; EC50=%f; dy=%f',y0,nanmedian(power_density),max(y)-y0);
else % decreasing
    eq_string = sprintf('y(p) = dy*(p^n/(EC50^n + p^n)) + %f; n=1; EC50=%f; dy=%f',y0,nanmedian(power_density),max(y)-min(y));
end

f = ezfit(p, y, eq_string);
% showfit(f,'fitcolor',color);
EC50 = f.m(1);
dy = f.m(2);
n = f.m(3);

x = sort(p);
yfit = dy*(x.^n./(EC50^n + x.^n)) + y0;

if(sum(isnan(yfit))>0 || sum(isnan(f.m))>0 || sum(isnan(f.m_error))>0 )
    yfit(1:length(x)) = nanmean(y);
    f.m(1) = NaN; f.m(2) = nanmean(y)-min(y); f.m(3) = NaN;
    f.m_error(1) = NaN; f.m_error(2) = eps; f.m_error(3) = NaN;
end
if(f.m_error(1)>f.m(1) || f.m_error(2)>f.m(2) || f.m_error(3)>f.m(3))
    yfit(1:length(x)) = nanmean(y);
    f.m(1) = NaN; f.m(2) = nanmean(y)-min(y); f.m(3) = NaN;
    f.m_error(1) = NaN; f.m_error(2) = eps; f.m_error(3) = NaN;
end

if(~isempty(regexpi(field,'frac')) || ~isempty(regexpi(field,'freq')))
    if(f.m(1) < 0)
        f.m(1) = 0;
    end
    if(f.m(2) < 0)
        f.m(2) = 0;
    end
end

if(f.m(1) > 2*max(p))
    f.m(1) = 2*max(p);
end
if(f.m(2) > 2*max(y))
    f.m(2) = 2*max(y);
end

if(f.m_error(1) > 2*max(p))
    f.m_error(1) = 2*max(p);
end
if(f.m_error(2) > 2*max(y))
    f.m_error(2) = 2*max(y);
end

xfit_data = linspace(min(x),max(x),100);
if(~isnan(sum(f.m)))
    yfit_data = dy*(xfit_data.^n./(EC50^n + xfit_data.^n)) + y0;
    hh = plot(xfit_data,yfit_data, 'color',color,'linewidth',2);
else
    % yfit_data = spline(x,y,xfit_data);
    % [m,b] = fit_line(x,y); yfit_data = m*xfit_data + b; 
    % yfit_data = zeros(1,length(xfit_data))+nanmean(y); % 
    yfit_data = smooth(x,y); xfit_data=x;
    hh = plot(xfit_data,yfit_data, 'color',color,'linewidth',2);
end

box off
hold off

ymin = double(max(0, custom_round(min(y),0.05,'floor')));
ymax = double(custom_round(max(y),0.05,'ceil'));
ylim([ymin ymax]);
xlimits = get(gca,'xlim');
xmin = xlimits(1);
xmax = xlimits(2);

return;

end

