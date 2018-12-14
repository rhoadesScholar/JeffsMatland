function h = plot_sample_control_upsidedown_histograms(sample, ctrl, bincenters, sample_color, ctrl_color, ylimits, xlabel_flag,fontclass,fontsize)
% h = plot_sample_control_upsidedown_histograms(sample, ctrl, bincenters, sample_color, ctrl_color, [max_sample_yaxis max_ctrl_yaxis], xlabel_flag,fontclass,fontsize)

if(nargin<1)
    disp('h = plot_sample_control_upsidedown_histograms(sample, ctrl, bincenters, sample_color, ctrl_color, [max_sample_yaxis max_ctrl_yaxis], xlabel_flag,fontclass,fontsize)')
    return;
end

if(nargin<3)
    bincenters=[];
end

if(nargin<5)
    sample_color = [];
    ctrl_color = [];
end

if(isempty(bincenters))
    alldata = [matrix_to_vector(sample) matrix_to_vector(ctrl)];
    % bincenters = min(alldata):abs(max(alldata) - min(alldata))/10:max(alldata);
      bincenters = min(alldata):abs(max(alldata) - min(alldata))/sshist(alldata):max(alldata);
end

if(isempty(ctrl_color))
    ctrl_color = [1 1 1];
end

if(isempty(sample_color))
    sample_color = [0.5 0.5 0.5];
end

if(nargin<6)
    ylimits = [];
end

if(nargin<7)
    xlabel_flag = {'bottom',''};
end

if(nargin<8)
    fontclass = 'Helvetica';
end

if(nargin<9)
    fontsize = 14;
end

if(~isempty(ylimits))
    ylimits(2) = -ylimits(2);
    ylimits = ylimits([2 1]);
end

h.top.plot=[];
h.bottom.plot=[];

[y,x] = hist(sample,bincenters);
    edgecolor = sample_color;
    if(ischar(sample_color))
        if(sample_color=='w')
            edgecolor = 'k';
        end
    else
        if(sum(sample_color)==3)
            edgecolor = 'k';
        end
    end
h.top.plot = bar(100*y/sum(y),1,'FaceColor', sample_color,'edgecolor',edgecolor);
mean_sample = nanmean(sample);
max_sample = 100*max(y)/sum(y);
sample_y = 100*y/sum(y);

ctrl_y = []; max_ctrl=0; mean_ctrl=0;
if(~isempty(ctrl))
    [y,x] = hist(ctrl,bincenters);
    hold on
    edgecolor = ctrl_color;
    if(ischar(ctrl_color))
        if(ctrl_color=='w')
            edgecolor = 'k';
        end
    else
        if(sum(ctrl_color)==3)
            edgecolor = 'k';
        end
    end
    h.bottom.plot = bar(-100*y/sum(y),1,'FaceColor', ctrl_color,'edgecolor', edgecolor);
    mean_ctrl = nanmean(ctrl);
    max_ctrl = -100*max(y)/sum(y);
    ctrl_y = 100*y/sum(y);
end

if(isempty(ctrl))
    ctrl = zeros(size(sample));
end

% xlims = [min([min(min(get(get(h.bottom.plot,'Children'),'Xdata'))) min(min(get(get(h.top.plot,'Children'),'Xdata'))) bincenters]) max([max(max(get(get(h.bottom.plot,'Children'),'Xdata'))) max(max(get(get(h.top.plot,'Children'),'Xdata'))) bincenters])];
xlims = [0.25 length(bincenters)+0.75];
xlim(xlims);

stattext = '';

if(sum(ctrl)~=0)
%     p = ttest_compare(mean_sample, nanstd(sample), sum(~isnan(sample)), ...
%         mean_ctrl, nanstd(ctrl), sum(~isnan(ctrl)));
    
    
   [~,p] = ttest2(sample, ctrl);
   % p = (p + bootstrap_compare_means(sample, ctrl))/2;
   % p =  bootstrap_compare_means(sample, ctrl);
   
    stattext = '   ';
    if(p<0.05)
        stattext = '  *';
    end
    if(p<0.01)
        stattext = ' **';
    end
    if(p<0.001)
        stattext = '***';
    end
end

box off

if(isempty(ylimits))
    ylimits = 1.2*[max_ctrl max_sample];
end

ylim(ylimits);


% set(gca,'yticklabel',custom_round(abs(get(gca,'ytick')),0.1));
set(gca,'yticklabel',[]);
set(gca,'ytick',[]);
set(gca,'ytick',round([max_ctrl max_sample]));
if(sum(ctrl)~=0)
    set(gca,'yticklabel',round([abs(max_ctrl) max_sample]));
else
    set(gca,'yticklabel',{'',num2str(round(max_sample))});
end

original_xticks = get(gca,'xtick');
set(gca,'xtick',1:length(bincenters));
set(gca,'xticklabel',bincenters);
if(length(bincenters)>12)
    set(gca,'xtick',1:3:length(bincenters));
    set(gca,'xticklabel',bincenters(1:3:end));
end



% x-axis
xticks = get(gca,'xtick');

h.xticklabeltext = [];
h.xlabeltext = [];
xlabelpos = [];
if(strcmpi(xlabel_flag{1},'bottom'))
    xlabels = cellstr(get(gca,'xTickLabel'));
    % xlabels{end} = ['\geq',sprintf('%s',xlabels{end})];
    % xlabels{end} = ['fontsize{' fontsize-2 '}{\geq}',sprintf('%s',xlabels{end})];
    
    
    ymin = min(get(gca,'ylim'));
    for(i=1:length(xticks))
        h.xticklabeltext(i) = text(xticks(i), ymin, xlabels{i},'fontname',fontclass,'HorizontalAlignment','center','VerticalAlignment','top','fontsize',fontsize,'units','data');
    end
%     pos = get(h.xticklabeltext(end),'extent');
%     i=length(xticks);
%     h.xticklabeltext(i) = text(pos(1)+1.1*pos(3), ymin+0.03*pos(4), xlabels{end},'fontname',fontclass,'HorizontalAlignment','left','VerticalAlignment','top','fontsize',fontsize,'units','data');
   
    xlabelpos = get(h.xticklabeltext(1),'extent');
    posend = get(h.xticklabeltext(end),'extent');
    xcoord = (xlabelpos(1) + posend(1)+posend(3))/2;
    
    h.xlabeltext = text(xcoord, xlabelpos(2)+0.5*xlabelpos(4), xlabel_flag{2}, 'fontname',fontclass,'HorizontalAlignment','center','VerticalAlignment','top','fontsize',fontsize,'units','data');
end

if(strcmpi(xlabel_flag{1},'top'))
    xlabels = cellstr(get(gca,'xTickLabel'));
    
%     xlabels{end} = ['\geq',sprintf('%s',xlabels{end})];
    
    ymax = max(get(gca,'ylim')); 
    for(i=1:length(xticks))
        h.xticklabeltext(i) = text(xticks(i), ymax, xlabels{i},'fontname',fontclass,'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',fontsize,'units','data');
    end
    
    xlabelpos = get(h.xticklabeltext(1),'extent');
    posend = get(h.xticklabeltext(end),'extent');
    xcoord = (xlabelpos(1) + posend(1)+posend(3))/2;
    
    h.xlabeltext = text(xcoord, xlabelpos(2)+0.75*xlabelpos(4), xlabel_flag{2}, 'fontname',fontclass,'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',fontsize,'units','data');
end


set(gca,'xcolor','w');
set(gca,'xticklabel','');

set(get(gca,'ylabel'),'fontname',fontclass,'fontsize',fontsize);
set(gca,'fontname',fontclass,'fontsize',fontsize);

xmax = max(get(gca,'xtick'));
ymin = min(get(gca,'ylim'));
ymax = max(get(gca,'ylim'));

max_axis_val = max([abs(ymin) abs(ymax)]);

h.top.mean_text = [];
h.bottom.mean_text = [];  % max(ymax/2, max(sample_y(end-1),sample_y(end)))

max_val = max([abs(sample_y) abs(ctrl_y)]);

% h.top.mean_text = text(xlims(end), max_val, sprintf('%s%.1f',stattext,mean_sample),'fontname',fontclass,'HorizontalAlignment','right','VerticalAlignment','middle','color','k','units','data','fontsize',fontsize);
% if(sum(ctrl)~=0)          % -max(-ymin/2, max(ctrl_y(end-1),ctrl_y(end)))
%     h.bottom.mean_text = text(xlims(end), -max_val, sprintf('   %.1f',mean_ctrl),'fontname',fontclass,'HorizontalAlignment','right','VerticalAlignment','middle','color','k','units','data','fontsize',fontsize);
% end
% ylim([-max_axis_val max_axis_val]);

h.top.mean_text = text(xlims(end), mean([ymax, max(sample_y(end-1),sample_y(end))]), sprintf('%s%.1f',stattext,mean_sample),'fontname',fontclass,'HorizontalAlignment','right','VerticalAlignment','middle','color','k','units','data','fontsize',fontsize);
if(sum(ctrl)~=0)          % -max(-ymin/2, max(ctrl_y(end-1),ctrl_y(end)))
    h.bottom.mean_text = text(xlims(end), -mean([-ymin, max(ctrl_y(end-1),ctrl_y(end))]), sprintf('   %.1f',mean_ctrl),'fontname',fontclass,'HorizontalAlignment','right','VerticalAlignment','middle','color','k','units','data','fontsize',fontsize);
end

h_yL =  text(-0.075,0.5,'%','Rotation',90,'fontname',fontclass,'fontsize',fontsize,'units','normalized','HorizontalAlignment','center','VerticalAlignment','middle'); % ylabel('%');
% pos = get(h_yL,'position');
% pos(1) = pos(1)/(max(get(gca,'xlim')) - min(get(gca,'xlim')));
% pos(2) = pos(2)/(max(get(gca,'ylim')) - abs(min(get(gca,'ylim'))))/2;
% set(h_yL,'position',[pos(1) pos(2)],'units','normalized');

return;
end
