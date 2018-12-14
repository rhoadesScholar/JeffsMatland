function plot_fit_parameter_covariance(start_fignum, fitting_struct, title_string)

% 4x5
%     g1  g2  g3  g4  g5
% k1
% k2
% k3
% k4
 
% 4x5
%     g1  g2  g3  g4  g5
% g1  x   +   +   +   +
% g2  x   x   +   +   +
% g3  x   x   x   +   +
% g4  x   x   x   x   +
 
% 3x4
%     k1  k2  k3  k4
% k1  x   +   +   +
% k2  x   x   +   +
% k3  x   x   x   +


% page 1 


% page 2 


% page 3 

if(nargin<3)
   fieldname='speed';
end

if(nargin<4)
   title_string='';
end

title_string = sprintf('%s %s',title_string, fieldname);

plot_columns = 3; 
plot_rows = ceil(length(fitting_struct.data)/plot_columns + 1);

xmax = ceil(max(fitting_struct.t));
xmin = floor(min(fitting_struct.t));

subplot(plot_rows,plot_columns,1);
if(~isempty(fitting_struct.A))
    plot(fitting_struct.t, fitting_struct.A, 'b','linewidth',2);
    hold on
    plot(fitting_struct.t, fitting_struct.B, 'c','linewidth',2);
    plot(fitting_struct.t, fitting_struct.C, 'g','linewidth',2);
    plot(fitting_struct.t, fitting_struct.D, 'm','linewidth',2);
    plot(fitting_struct.t, fitting_struct.E, 'r','linewidth',2);
    
    xlim([xmin xmax]);
    
    sh = stimulusShade(stimulus, 0,1,[0.7 0.7 0.7]); uistack(sh(end:-1:1),'bottom');
    box off
    dummystring = sprintf('%.3f\n%.3f\n%.3f\n%.3f',fitting_struct.k(1), fitting_struct.k(2), fitting_struct.k(3), fitting_struct.k(4));
    text(fitting_struct.t(round(0.05*length(fitting_struct.t))),0.5, dummystring,'FontSize',10);
end

for(d=1:length(fitting_struct.data))
    hh=subplot(plot_rows,plot_columns,d+1);
    
    if(fitting_struct.data(d).inst_freq_code == 2) % is freq
        t = fitting_struct.t_freq;
    else
        t = fitting_struct.t;
    end
        
    % curve fit confidence intervals
    if(~isempty(fitting_struct.data(d).un_norm_avg_y_fit) && ~isempty(fitting_struct.data(d).un_norm_y_fit_std))
        xpoints=[t,fliplr(t)];
        upper = fitting_struct.data(d).un_norm_avg_y_fit + fitting_struct.data(d).un_norm_y_fit_std;
        lower = fitting_struct.data(d).un_norm_avg_y_fit - fitting_struct.data(d).un_norm_y_fit_std;
        ypoints=[upper, fliplr(lower)];
        fillhandle=fill(xpoints,ypoints,[0.5 0.5 0.5]);
        set(fillhandle,'EdgeColor','none');
        hold on
    end

    plot(t, fitting_struct.data(d).un_norm_y_fit,'r','linewidth',3);
    if(~isempty(fitting_struct.data(d).un_norm_avg_y_fit))
        hold on;
        plot(t, fitting_struct.data(d).un_norm_avg_y_fit,'--b','linewidth',3);
    end
    
    hold on;
    errorline(t, fitting_struct.data(d).un_norm_y, fitting_struct.data(d).un_norm_y_err,'.k');
    
    range = (max(fitting_struct.data(d).un_norm_y) + max(fitting_struct.data(d).un_norm_y_err)) - (min(fitting_struct.data(d).un_norm_y) - max(fitting_struct.data(d).un_norm_y_err));
    
    ymin = min(fitting_struct.data(d).un_norm_y) - max(fitting_struct.data(d).un_norm_y_err) - 0.1*range;
    ymax = max(fitting_struct.data(d).un_norm_y) + max(fitting_struct.data(d).un_norm_y_err) + 0.1*range;
    
    ymin=1e10;
    ymax=-1e10;
    if(strcmp(fitting_struct.data(d).fieldname,'speed'))
        ymin = 0;
        ymax = 0.25;
    end
    if(strcmp(fitting_struct.data(d).fieldname,'ecc'))
        ymin = 0.940;
        ymax = 0.965;
    end
    if(strcmp(fitting_struct.data(d).fieldname,'head_angle'))
        ymin = 135;
        ymax = 150;
    end
    if(strcmp(fitting_struct.data(d).fieldname,'tail_angle'))
        ymin = 140;
        ymax = 155;
    end
    
    ymin = min(ymin, (min(fitting_struct.data(d).un_norm_y) - max(fitting_struct.data(d).un_norm_y_err) - 0.1*range));
    ymax = max(ymax, (max(fitting_struct.data(d).un_norm_y) + max(fitting_struct.data(d).un_norm_y_err) + 0.1*range));

    
    if(fitting_struct.data(d).inst_freq_code == 2) % is freq
        ymin = 0;
        
        if(ymax > 0.5 && ymax < 1)
            ymax = 1;
        else
            ymax = custom_round(ymax,0.5);
        end
        if(ymax <= ymin)
            ymax = 0.5;
        end
    end
    ylim([ymin ymax]);
    
    xlim([xmin xmax]);
    
    box off
    
    sh = stimulusShade(stimulus, ymin,ymax); 
    uistack(sh(end:-1:1),'bottom');
    
    ylabel(fix_title_string(fitting_struct.data(d).fieldname));
    dummystring = '';
    
%     dummystring = sprintf('%s%.3f   %.3f   %.3f   %.3f',dummystring, ...
%         fitting_struct.data(d).k0(1), fitting_struct.data(d).k0(2), fitting_struct.data(d).k0(3),fitting_struct.data(d).k0(4));
%     
%     dummystring = sprintf('%s%.3f   %.3f   %.3f   %.3f   %.3f', dummystring, ...
%         fitting_struct.data(d).un_norm_gamma0(1), fitting_struct.data(d).un_norm_gamma0(2), fitting_struct.data(d).un_norm_gamma0(3), ...
%         fitting_struct.data(d).un_norm_gamma0(4), fitting_struct.data(d).un_norm_gamma0(5));
    
    dummystring = sprintf('%s\n%.3f   %.3f   %.3f   %.3f',dummystring, ...
        fitting_struct.data(d).k(1), fitting_struct.data(d).k(2), fitting_struct.data(d).k(3),fitting_struct.data(d).k(4));
    
    dummystring = sprintf('%s\n%.3f   %.3f   %.3f   %.3f   %.3f', dummystring, ...
        fitting_struct.data(d).un_norm_gamma(1), fitting_struct.data(d).un_norm_gamma(2), fitting_struct.data(d).un_norm_gamma(3), ...
        fitting_struct.data(d).un_norm_gamma(4), fitting_struct.data(d).un_norm_gamma(5));
    
    %dummystring = sprintf('%s\n%d %f',dummystring, fitting_struct.data(d).model_index, fitting_struct.data(d).aic);
    
    xloc = double(t(round(0.04*length(t))));
    yloc = double(ymin + 1.05*(ymax-ymin)); 
    text(xloc , yloc, dummystring,'FontSize',9);
    
    hold off;
end

p = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',p);
text(0.5,0.97,fix_title_string(title_string),'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center'); 

orient landscape;
set(gcf,'renderer','painters');
set(gcf,'PaperPositionMode','manual');
set(gcf, 'PaperPosition',[0 0 11 8.5]);
hold off;
    
return;
end

