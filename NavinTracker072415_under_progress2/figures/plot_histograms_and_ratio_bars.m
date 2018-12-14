function plot_histograms_and_ratio_bars(filename, value_label, value_units, bincenters, expt_color)
% data in filename with the following format
% strainA_ctrl n n n n n n n n
% strainA_expt m m m m m m m m m m m m 
% strainB_ctrl n n n n n n n n
% strainB_expt m m m m m m m m m m m m 

if(nargin<3)
    value_label = '';
    value_units = '';
end
if(nargin<5)
    expt_color = 'r';
end

if(nargin<4)
    bincenters = [];% [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15];
end

fontsize=10;

ctrl_color = [0.5 0.5 0.5];
bar_color = [0.5 0.5 0.5];
ylims = [0 1.5];

x_axisflag= 'bottom';
    
datastruct = importdata(filename);
i = 1;
for(j=1:2:size(datastruct.data,1)-1)
   strainnames{i} = datastruct.rowheaders{j}(1:end-5);
   i=i+1;
end


strain = [];


xlabeltext = sprintf('%s\n(%s)',value_label, value_units);

fignum = 1; num_rows = 3; num_cols = 3;
row_idx = 1; subplotnum = 1;
ratio_vector = []; ratio_err = []; ratio_p = [];
for(i=1:length(strainnames))
    
    strain(i).name = strainnames{i};
    strain(i).ctrl.data = datastruct.data(row_idx, :);
    
    strain(i).ctrl.mean = nanmean(strain(i).ctrl.data);
    strain(i).ctrl.std = nanstd(strain(i).ctrl.data);
    strain(i).ctrl.n = sum(~isnan(strain(i).ctrl.data));
    strain(i).ctrl.err = strain(i).ctrl.std/sqrt(strain(i).ctrl.n);
    
    row_idx = row_idx+1;
    strain(i).expt.data = datastruct.data(row_idx, :);
    
    strain(i).expt.mean = nanmean(strain(i).expt.data);
    strain(i).expt.std = nanstd(strain(i).expt.data);
    strain(i).expt.n = sum(~isnan(strain(i).expt.data));
    strain(i).expt.err = strain(i).expt.std/sqrt(strain(i).expt.n);
    
    row_idx = row_idx+1;
    
    strain(i).ratio = strain(i).expt.mean/strain(i).ctrl.mean;
    strain(i).ratio_err = strain(i).ratio*sqrt( (strain(i).ctrl.err/strain(i).ctrl.mean)^2 + (strain(i).expt.err/strain(i).expt.mean)^2);
    
    strain(i).p =  ttest_compare(strain(i).ctrl.mean, strain(i).ctrl.std, strain(i).ctrl.n, ...
        strain(i).expt.mean, strain(i).expt.std, strain(i).expt.n);
    
    ratio_vector = [ratio_vector strain(i).ratio];
    ratio_err = [ratio_err strain(i).ratio_err];
    ratio_p = [ratio_p strain(i).p];
       
    figure(fignum);
    subplot(num_rows, num_cols, subplotnum); subplotnum=subplotnum+1;
    h=plot_sample_control_line_line_histograms(strain(i).expt.data, strain(i).ctrl.data, ...
        bincenters, expt_color, ctrl_color,[],{x_axisflag, xlabeltext},'Helvetica',fontsize);
    % ht = title(fix_title_string(strainnames{i}));
    text(0.5, 1, fix_title_string(strainnames{i}),'HorizontalAlignment','center','VerticalAlignment','top','units','normalized');

    if(subplotnum > num_rows*num_cols)
        subplotnum = 1;
        set(gcf,'color','w');
        fignum = fignum+1;
    end
        
end
set(gcf,'color','w');
orient landscape


[~, ~, adjusted_p]=fdr_bh(ratio_p);

fignum = fignum+1;
figure(fignum);
% bars
for(i=1:length(strain))
    bar(i, ratio_vector(i), 1,'facecolor', bar_color  );
    hold on;
    
    errorline(i,ratio_vector(i),ratio_err(i),'.k','linewidth',1);
    hold on;
    text(i, ratio_vector(i)+1.5*ratio_err(i),  stat_symbol(adjusted_p(i)),'FontName','Helvetica','FontSize',fontsize,'HorizontalAlignment','center','VerticalAlignment','middle','units','data','color','k');
    hold on;
end
ylabeltext = sprintf('%s\n%s (control)',underline(sprintf('%s (expt)',value_label),fontsize),value_label);
ylabel(ylabeltext);
set(get(gca,'ylabel'),'FontName','Helvetica','FontSize',fontsize);
                   
xlim([0.25 length(strainnames)+0.75]);
set(gca,'xtick',1:length(strainnames));
set(gca,'xticklabel',[]);
dy=0.075;
for(k=1:length(strainnames))
    text(k, 0-dy, fix_title_string(strainnames{k}), 'horizontalalign','right','verticalalign','middle','FontName','Helvetica','FontSize',fontsize,'rotation',45);
end
set_axes_fontstuff(gca,'FontName','Helvetica','FontSize',fontsize);
box off;
axis square;
hold off;

set(gcf,'color','w');
