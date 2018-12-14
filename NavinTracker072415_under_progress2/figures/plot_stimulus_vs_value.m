function [f, ymin, ymax, xmin, xmax, hh] = plot_stimulus_vs_value(BinData_array, stimulus, stimulus_field, field, color)
% [f, ymin, ymax, xmin, xmax, hh] = plot_stimulus_vs_value(BinData_array, stimulus, stimulus_field, field, color)

define_led_prefs();
global POWERMETER_AREA;

f=[];
hh=[];

if(nargin<5)
    color = {'b','r'};
end


diff_flag=0;

if(strcmpi(stimulus_field,'power'))
    xlabelstring = 'stimulus power (mW)';
else
    if(strcmpi(stimulus_field,'time'))
        xlabelstring = 'stimulus time (sec)';
    else
        if(strcmpi(stimulus_field,'duration'))
            xlabelstring = 'stimulus duration (sec)';
        else
            if(strcmpi(stimulus_field,'pulsewidth'))
                xlabelstring = 'pulse width (msec)';
            else
                if(strcmpi(stimulus_field,'frequency'))
                    xlabelstring = 'pulse frequency (Hz)';
                end
            end
        end
    end
end

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

xlabelstring = fix_title_string(xlabelstring);
ylabelstring = fix_title_string(ylabelstring);

if(diff_flag==1)
    ylabelstring = ['\Delta ' ylabelstring];
end

all_y = [];

for(b=1:length(BinData_array))
    power_density = [];
    y = [];
    y_err = [];
    
    BinData = BinData_array(b);
    if(diff_flag==1)
        BinData = baseline_subtract_BinData(BinData, [0 stimulus(1,1)]);
    end
    for(i=1:length(stimulus(:,1)))
        t1 = stimulus(i,1);
        t2 = stimulus(i,2);

        if(stimulus(i,4)>0)
            if(strcmpi(stimulus_field,'power'))
                power_density = [power_density stimulus(i,4)];
            else
                if(strcmpi(stimulus_field,'time'))
                    power_density = [power_density (t2+t1)/2];
                else
                    if(strcmpi(stimulus_field,'duration'))
                        power_density = [power_density (t2-t1)];
                    else
                        
                        if(strcmpi(stimulus_field,'frequency'))
                            if(stimulus(i,5) == 0) % not flashing
                                frq = 1000;
                            else
                                frq = 1/stimulus(i,5);
                            end
                            power_density = [power_density frq];
                        else
                            if(strcmpi(stimulus_field,'pulsewidth'))
                                pw = 1000*stimulus(i,6);
                                if(pw == 0)
                                    pw = 1000;
                                end
                                power_density = [power_density pw];
                            end
                        end
                    end
                end
            end
            
            
            [val, stddev, err, n] = segment_statistics(BinData, field, 'mean', t1, t2);
            y = [y val];
            y_err = [y_err err];
        end
        
        
    end
    
    [val, stddev, err, n] = segment_statistics(BinData, field, 'mean', 0, stimulus(1,1));
    power_density = [0 power_density];
    y = [val y];
    y_err = [err y_err];
    
    all_y = [all_y y];
    
    power_density = power_density; % /POWERMETER_AREA;
    eL = errorline(power_density,y, y_err,'o');
    set(eL,'color',color{b});
    hold on;
end

% if(diff_flag==1)
%     all_y = abs(all_y);
% end

y0=[];
for(b=1:length(BinData_array))
    BinData = BinData_array(b);
    if(diff_flag==1)
        BinData = baseline_subtract_BinData(BinData, [0 stimulus(1,1)]);
    end
    [val, stddev, err, n] = segment_statistics(BinData, field, 'mean', 0, stimulus(1,1));
    y0 = [y0 val];
end
y0 = nanmean(y0);




set(gca, 'color', 'none');

hy = ylabel(ylabelstring);
hx = xlabel(xlabelstring);

% fontsize = scaled_fontsize_for_subplot(plot_rows, plot_columns);
% set(gca,'FontSize',fontsize);
% set(hy,'FontSize',fontsize);
% set(hx,'FontSize',fontsize);


% hold on;
% p = power_density;
% eq_string = sprintf('y(p) = dy*(p^n/(EC50^n + p^n)) + %f; n=1; EC50=%f; dy=%f',y0,nanmedian(power_density),max(y)-y0);
% f = ezfit(p, y, eq_string);
% % showfit(f,'fitcolor',color);
% EC50 = f.m(1);
% dy = f.m(2);
% n = f.m(3);
% 
% x = sort(p);
% yfit = dy*(x.^n./(EC50^n + x.^n)) + y0;
% 
% if(sum(isnan(yfit))>0 || sum(isnan(f.m))>0 || sum(isnan(f.m_error))>0 )
%     yfit(1:length(x)) = nanmean(y);
%     f.m(1) = NaN; f.m(2) = nanmean(y)-min(y); f.m(3) = NaN;
%     f.m_error(1) = NaN; f.m_error(2) = eps; f.m_error(3) = NaN;
% end
% if(f.m_error(1)>f.m(1) || f.m_error(2)>f.m(2) || f.m_error(3)>f.m(3))
%     yfit(1:length(x)) = nanmean(y);
%     f.m(1) = NaN; f.m(2) = nanmean(y)-min(y); f.m(3) = NaN;
%     f.m_error(1) = NaN; f.m_error(2) = eps; f.m_error(3) = NaN;
% end
% 
% if(~isempty(regexpi(field,'frac')) || ~isempty(regexpi(field,'freq')))
%     if(f.m(1) < 0)
%         f.m(1) = 0;
%     end
%     if(f.m(2) < 0)
%         f.m(2) = 0;
%     end
% end
% 
% if(f.m(1) > 2*max(p))
%     f.m(1) = 2*max(p);
% end
% if(f.m(2) > 2*max(y))
%     f.m(2) = 2*max(y);
% end
% 
% if(f.m_error(1) > 2*max(p))
%     f.m_error(1) = 2*max(p);
% end
% if(f.m_error(2) > 2*max(y))
%     f.m_error(2) = 2*max(y);
% end
% 
% hh = plot(x,yfit, 'color',color);
% box off
% hold off

% ymin = double(max(0, custom_round(min(all_y),0.05,'floor')));
% ymax = double(custom_round(max(all_y),0.05,'ceil'));
% ylim([ymin ymax]);

xlimits = get(gca,'xlim');
xmin = xlimits(1);
xmax = xlimits(2);

box off;

hold off;

return;

end

