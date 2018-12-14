function xx = x_values_logscale_curvefit_display(xlims)
% xx = x_values_logscale_curvefit_display(xlims)

if(nargin<1)
    disp('usage: xx = x_values_logscale_curvefit_display(xlims)');
    return;
end

xlim_min = xlims(1);
xlim_max = xlims(2);

xx = [];
t=xlim_min;
i=1;
newt = xlim_min;
while(t<xlim_max)
    currt = 0.1*t;
    newt = 10*newt;
    while(t<newt)
        xx = [xx t];
        t=t+currt;
        i=i+1;
    end
end
xx = [xx xlim_max];

return;
end

