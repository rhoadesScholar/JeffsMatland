function [hTxt, xtick, xticklabel] = xaxis_log_ticks(h, log_label_spacing)
% [hTxt, xtick, xticklabel] = xaxis_log_ticks(h, [log_label_spacing])

if(nargin<1)
    disp('usage: [hTxt, xtick, xticklabel] = xaxis_log_ticks(h, [log_label_spacing])');
    return;
end

if(nargin<2)
    log_label_spacing = 1;
end

set(h,'xscale','log');

xlims = get(h,'xlim');
xlim_min = xlims(1);
xlim_max = xlims(2);

xtick = [];
t=xlim_min;
i=1;
newt = xlim_min;
xticklabel{i} = sprintf('10^{%d}',log10(newt));
while(t<xlim_max) % min(10, xlim_max))
    currt = t;
    newt = 10*newt;
    while(t<newt)
        xtick = [xtick t];
        t=t+currt;
        i=i+1;
        xticklabel{i} = '';
    end
    xticklabel{i} = sprintf('10^{%d}',log10(newt));
    if(mod(log10(newt),log_label_spacing)~=0)
        xticklabel{i} = '';
    end
end
if(xlim_max > xtick(end))
    xtick = [xtick xlim_max];
else
    if(max(xtick)>xlim_max)
        xticklabel(end)=[];
        idx = find(xtick > xlim_max);
        xtick(idx) = [];
        xticklabel(idx) = [];
    end
end
    
set(h,'xminortick','on','layer','top');
set(h,'xtick',xtick);

xtick_handle = get(h, 'XTick');
y_handle = get(h, 'YLim');
set(h,'xticklabel',[]); % turn off X-axis ticklabels
hTxt = text(xtick_handle, y_handle(ones(size(xtick_handle))), xticklabel, ...   %# create text at same locations
    'Interpreter','tex', ...                   %# specify tex interpreter
    'VerticalAlignment','top', ...             %# v-align to be underneath
    'HorizontalAlignment','center', ...        %# h-aligh to be centered
    'fontname',get(h,'fontname'),'fontsize',get(h,'fontsize') );

return;
end

