function h = plot_sample_control_line_line_histograms(sample, ctrl, bincenters, sample_color, ctrl_color, ylimits, xlabel_flag,fontclass,fontsize)
% h = plot_sample_control_line_line_histograms(sample, ctrl, bincenters, sample_color, ctrl_color, [max_sample_yaxis max_ctrl_yaxis], xlabel_flag,fontclass,fontsize)

if(nargin<1)
    disp('h = plot_sample_control_line_line_histograms(sample, ctrl, bincenters, sample_color, ctrl_color, [max_sample_yaxis max_ctrl_yaxis], xlabel_flag,fontclass,fontsize)')
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
    ctrl_color = [0 0 0];
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
if(isempty(xlabel_flag))
    xlabel_flag = {'',''};
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

ctrl_y = []; max_ctrl=0; mean_ctrl=0;
if(~isempty(ctrl))
    [y,x] = hist(ctrl,bincenters);
    hold on
    y_plot_data_ctrl = (100*y/sum(y)); y_plot_data_ctrl(y_plot_data_ctrl<0) = 0;
    h.bottom.plot = plot(1:length(bincenters), y_plot_data_ctrl, 'o-','color',ctrl_color, 'markerfacecolor',ctrl_color,'linewidth',2,'markersize',2.5);
    mean_ctrl = nanmean(ctrl);
    max_ctrl = 100*max(y)/sum(y);
    ctrl_y = 100*y/sum(y);
end

[y,x] = hist(sample,bincenters);
y_plot_data_sample = (100*y/sum(y)); y_plot_data_sample(y_plot_data_sample<0)=0;
h.top.plot = plot(1:length(bincenters), y_plot_data_sample, 'o-','color',sample_color, 'markerfacecolor',sample_color,'linewidth',2,'markersize',2.5);
mean_sample = nanmean(sample);
max_sample = 100*max(y)/sum(y);
sample_y = 100*y/sum(y);

if(isempty(ctrl))
    ctrl = zeros(size(sample));
end


% xlims = [min([min(min(get(get(h.bottom.plot,'Children'),'Xdata'))) min(min(get(get(h.top.plot,'Children'),'Xdata'))) bincenters])-0.5 max([max(max(get(get(h.bottom.plot,'Children'),'Xdata'))) max(max(get(get(h.top.plot,'Children'),'Xdata'))) bincenters])+0.5];
xlims = [1-0.5 length(bincenters)+0.5];
xlim(xlims);

stattext = '';

if(sum(ctrl)~=0)
 %       p = ranksum(sample, ctrl);
%      [~,p] = kstest2(sample, ctrl);
%        [~,p] = ttest2(sample, ctrl);
%     p = ttest_compare(mean_sample, nanstd(sample), sum(~isnan(sample)), ...
%         mean_ctrl, nanstd(ctrl), sum(~isnan(ctrl)));

    [~,p] = ttest2(sample, ctrl);
   % p = (p + bootstrap_compare_means(sample, ctrl))/2;
%  p =  bootstrap_compare_means(sample, ctrl);
    
    stattext = stat_symbol(p);
    
end

box off

if(isempty(ylimits))
    ylimits = 1.2*[0 max(max_ctrl,max_sample)];
end

ylim(ylimits);

% set(gca,'yticklabel',custom_round(abs(get(gca,'ytick')),0.1));
set(gca,'yticklabel',[]);
set(gca,'ytick',[]);
set(gca,'ytick',round(max([max_ctrl max_sample])));
set(gca,'yticklabel',round(max([abs(max_ctrl) max_sample])));


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
    xlabels{end} = ['\geq',sprintf('%s',xlabels{end})];
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
    
    h.xlabeltext = text(xcoord, xlabelpos(2)+0.5*xlabelpos(4), fix_title_string(xlabel_flag{2}), 'fontname',fontclass,'HorizontalAlignment','center','VerticalAlignment','top','fontsize',fontsize,'units','data');
end

if(strcmpi(xlabel_flag{1},'top'))
    xlabels = cellstr(get(gca,'xTickLabel'));
    xlabels{end} = ['\geq',sprintf('%s',xlabels{end})];
    
    ymax = max(get(gca,'ylim')); 
    for(i=1:length(xticks))
        h.xticklabeltext(i) = text(xticks(i), ymax, xlabels{i},'fontname',fontclass,'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',fontsize,'units','data');
    end
    
    xlabelpos = get(h.xticklabeltext(1),'extent');
    posend = get(h.xticklabeltext(end),'extent');
    xcoord = (xlabelpos(1) + posend(1)+posend(3))/2;
    
    h.xlabeltext = text(xcoord, xlabelpos(2)+0.75*xlabelpos(4), fix_title_string(xlabel_flag{2}), 'fontname',fontclass,'HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',fontsize,'units','data');
end


%set(gca,'xcolor','w');
set(gca,'xticklabel','');

set(get(gca,'ylabel'),'fontname',fontclass,'fontsize',fontsize);
set(gca,'fontname',fontclass,'fontsize',fontsize);

xmax = max(get(gca,'xtick'));
ymin = min(get(gca,'ylim'));
ymax = max(get(gca,'ylim'));

h.top.mean_text = [];
h.bottom.mean_text = [];  % max(ymax/2, max(sample_y(end-1),sample_y(end)))

text_y = mean([ymax, max(sample_y(end-1),sample_y(end))]);
h.top.mean_text = text(xlims(end), text_y, sprintf('%s%.1f\n',stattext,mean_sample),'fontname',fontclass,'HorizontalAlignment','right','VerticalAlignment','middle','color',sample_color,'units','data','fontsize',fontsize);
if(sum(ctrl)~=0)
    if(isnumeric(ctrl_color))
       if( ctrl_color(1) == ctrl_color(2) && ctrl_color(1) == ctrl_color(3)) % gray ... if its too light make it darker for text
           if(ctrl_color(1) > 0.5)
               ctrl_color = [0.5 0.5 0.5];
           end
       end
    end
    h.bottom.mean_text = text(xlims(end), text_y, sprintf('\n%s%.1f',stat_symbol,mean_ctrl),'fontname',fontclass,'HorizontalAlignment','right','VerticalAlignment','middle','color',ctrl_color,'units','data','fontsize',fontsize);
end

h_yL =  text(-0.075,0.5,'%','Rotation',90,'fontname',fontclass,'fontsize',fontsize,'units','normalized','HorizontalAlignment','center','VerticalAlignment','middle'); % ylabel('%');

return;
end
