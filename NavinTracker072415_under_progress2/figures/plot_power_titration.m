% grid subplot
% violet	blue 	green 	ambergreen 	amber
% type A
% type B
% type C
%
% fit to hill eqn ... get EC50 and max
%     bargraphs EC50 and max
% violet	blue 	green 	ambergreen 	amber

% strainlist = {'N2','tag168_arch','tag168_archT','tag168_optoArch','tag168_arch_unfused','tph1_chop2star','tph1_ChVhTail','tph1_chop2TC'};

function plot_power_titration(strainlist, attribute, colorlist)

if(nargin<2)
    attribute = [];
end

if(isempty(attribute))
    attribute = 'frac_pause';
end

if(nargin<3)
    colorlist = [];
end

if(isempty(colorlist))
    colorlist = {'blue','doublegreen','doubleamber'};
end

cmap = [stimulus_colormap(1); stimulus_colormap(2); stimulus_colormap(3)];

fignum=0;

fignum = fignum+1; figure(fignum);
f = one_titration_per_subplot(strainlist, colorlist, attribute);
 
fignum = fignum+1; figure(fignum);
overlay_titrations(strainlist, colorlist, attribute);

% fignum = fignum+1; figure(fignum);
% compare_titrations({'N2','tag168_arch','tag168_archT','tag168_optoArch','tag168_arch_unfused','tph1_chop2star'}, {'k','y','m','r','g','c'}, 'blue', attribute,1);
% compare_titrations({'N2','tag168_arch','tag168_archT','tag168_optoArch','tag168_arch_unfused','tph1_chop2star'}, {'k','y','m','r','g','c'}, 'doublegreen', attribute,3);
% compare_titrations({'N2','tag168_arch','tag168_archT','tag168_optoArch','tag168_arch_unfused','tph1_chop2star'}, {'k','y','m','r','g','c'}, 'doubleamber', attribute,5);


fignum = fignum+1; figure(fignum);
ymin_matrix=[];
ymax_matrix=[];
fileprefix = '';
for(i=1:length(strainlist))
    
    fileprefix = sprintf('%s%s.',fileprefix,strainlist{i});
    
    EC50 = [];
    EC50_err = [];
    dy = [];
    dy_err = [];
    EC50_dy = [];
    EC50_dy_err = [];
    for(j=1:length(colorlist))
        EC50  = [ EC50 f{i,j}.m(1) ];
        EC50_err  = [ EC50_err f{i,j}.m_error(1) ];
        
        dy  = [ dy f{i,j}.m(2) ];
        dy_err  = [ dy_err f{i,j}.m_error(2) ];
        
        EC50_dy  = [ EC50_dy f{i,j}.m(2)/f{i,j}.m(1) ];
        EC50_dy_err  = [ EC50_dy_err (f{i,j}.m(2)/f{i,j}.m(1))*sqrt( (f{i,j}.m_error(1)/f{i,j}.m(1))^2 + (f{i,j}.m_error(2)/f{i,j}.m(2))^2) ];
    end
    
    subplot(3, length(strainlist), (i-1)+1);
    barweb(EC50, EC50_err, 1, [], '', '', 'EC50', cmap, []); % length(strainlist), length(colorlist)
    text(0.5,1.1,fix_title_string(strainlist{i}),'FontSize',scaled_fontsize_for_subplot(1,1),'FontName','Helvetica','HorizontalAlignment','center','units','normalized');
    ymin_matrix(1,i) = min(EC50 - EC50_err);
    ymax_matrix(1,i) = max(EC50 + EC50_err);
    
    subplot(3, length(strainlist), (i-1)+length(strainlist)+1);
    barweb(dy, dy_err, 1, [], '', '', 'dy', cmap, []);
    ymin_matrix(2,i) = min(dy - dy_err);
    ymax_matrix(2,i) = max(dy + dy_err);
    
    subplot(3, length(strainlist), (i-1)+2*length(strainlist)+1);
    barweb(EC50_dy, EC50_dy_err, 1, [], '', '', 'EC50_dy', cmap, []);
    ymin_matrix(3,i) = min(EC50_dy - EC50_dy_err);
    ymax_matrix(3,i) = max(EC50_dy + EC50_dy_err);
    
end
ymin_matrix = matrix_replace(ymin_matrix,'<',0,0);

k=1;
for(j=1:3)
    ymin = min(ymin_matrix(j,:));
    ymax = max(ymax_matrix(j,:));
    for(i=1:length(strainlist))
        subplot(3, length(strainlist), k);
        ylim([0 ymax]);
        k=k+1;
    end
end


fileprefix = sprintf('%s%s',fileprefix,'power_titrations');
temp_prefix = sprintf('page.%d',randint(1000));
for(i=1:fignum)
    figure(i);
    orient landscape;
    set(gcf,'renderer','painters');
    set(gcf,'color','w');
    filename = sprintf('%s%s%s.%s.pdf', tempdir,filesep,temp_prefix, num2str(i));
    save_pdf(gcf, filename, 1);
end
pool_temp_pdfs(1:fignum, '', fileprefix, temp_prefix);

return
end

function f = one_titration_per_subplot(strainlist, colorlist, attribute)

ymin_vec = [];
ymax_vec = [];
k=1;
for(i=1:length(strainlist))
    for(j=1:length(colorlist))
        stimulus = load_stimfile(sprintf('power_titrate.%s.txt',colorlist{j}));
        
        fn=sprintf('%s%s%s%s%s_%s.BinData.mat',strainlist{i},filesep,colorlist{j},filesep,strainlist{i},colorlist{j});
        if(~file_existence(fn))
           fn=sprintf('%s%s%s%s%s_%s.avg.BinData.mat',strainlist{i},filesep,colorlist{j},filesep,strainlist{i},colorlist{j}); 
        end
        BinData = load_BinData(fn);
        
        %BinData = load_BinData_arrays(sprintf('%s%s%s%s%s_%s.BinData_array.mat',strainlist{i},filesep,colorlist{j},filesep,strainlist{i},colorlist{j}));
        subplot(length(strainlist), length(colorlist), k);
        if(~isempty(BinData.Name))
        [f{i,j}, ymin, ymax] = plot_power_vs_value(BinData, stimulus, attribute);
        hold on;
        ymin_vec = [ymin_vec ymin];
        ymax_vec = [ymax_vec ymax];
        else
            f{i,j}.m=[NaN NaN NaN  ]; f{i,j}.m_error=[NaN NaN NaN  ];
        end
        
        k=k+1;
    end
end

ymin = min(ymin_vec); ymin=ymin(1);
ymax = max(ymax_vec); ymax=ymax(1);
k=1;
for(i=1:length(strainlist))
    for(j=1:length(colorlist))
        subplot(length(strainlist), length(colorlist), k);
        ylim([ymin ymax]);
        xmax = max(get(gca, 'xlim'));
        m = f{i,j}.m; m_error = f{i,j}.m_error;
        fit_text = sprintf('EC50 = %.3f +/- %.3f\ndy = %.3f +/- %.3f\nn = %.3f +/- %.3f',m(1),m_error(1),m(2),m_error(2),m(3),m_error(3));
        text(0.025*xmax, ymax, fit_text, 'fontsize',scaled_fontsize_for_subplot(length(strainlist), length(colorlist)));
        k=k+1;
        if(j==length(colorlist)) % length(strainlist), length(colorlist)
            text(1.25,0.5,fix_title_string(strainlist{i}),'FontSize',scaled_fontsize_for_subplot(1,1),'FontName','Helvetica','HorizontalAlignment','center','units','normalized');
        end
    end
end

return;
end

function overlay_titrations(strainlist, colorlist, attribute)

ymin_v = [];
ymax_v = [];
xmin_v = [];
xmax_v = [];
k=1;
for(i=1:length(strainlist))
    subplot(ceil(length(strainlist)/3), 3, k);
    for(j=1:length(colorlist))
        stimulus = load_stimfile(sprintf('power_titrate.%s.txt',colorlist{j}));
        
        
        
                fn=sprintf('%s%s%s%s%s_%s.BinData.mat',strainlist{i},filesep,colorlist{j},filesep,strainlist{i},colorlist{j});
        if(~file_existence(fn))
           fn=sprintf('%s%s%s%s%s_%s.avg.BinData.mat',strainlist{i},filesep,colorlist{j},filesep,strainlist{i},colorlist{j}); 
        end
        BinData = load_BinData(fn);
        
        %BinData = load_BinData_arrays(sprintf('%s%s%s%s%s_%s.BinData_array.mat',strainlist{i},filesep,colorlist{j},filesep,strainlist{i},colorlist{j}));
        [ff, ymin, ymax, xmin, xmax] = plot_power_vs_value(BinData, stimulus, attribute);
        ymin_v = [ymin_v ymin];
        ymax_v = [ymax_v ymax];
        xmin_v = [xmin_v xmin];
        xmax_v = [xmax_v xmax];
        hold on;
    end % ceil(length(strainlist)/3), 3
    text(0.5,1.05,fix_title_string(strainlist{i}),'FontSize',scaled_fontsize_for_subplot(1,1),'FontName','Helvetica','HorizontalAlignment','center','units','normalized');
    hold off;
    k=k+1;
end
ymin = min(ymin_v);
ymax = max(ymax_v);
xmin = min(xmin_v);
xmax = max(xmax_v);
k=1;
for(i=1:length(strainlist))
    subplot(ceil(length(strainlist)/3), 3, k);
    axis([xmin xmax ymin ymax]);
    k=k+1;
end

return;
end

function compare_titrations(strainlist, plotcolors, colorlist, attribute, plot_loc)

subplot(3,2,plot_loc);

ymin_v = [];
ymax_v = [];
xmin_v = [];
xmax_v = [];


for(i=1:length(strainlist))
    stimulus = load_stimfile(sprintf('power_titrate.%s.txt',colorlist));
    
    
        fn=sprintf('%s%s%s%s%s_%s.BinData.mat',strainlist{i},filesep,colorlist{j},filesep,strainlist{i},colorlist{j});
        if(~file_existence(fn))
           fn=sprintf('%s%s%s%s%s_%s.avg.BinData.mat',strainlist{i},filesep,colorlist{j},filesep,strainlist{i},colorlist{j}); 
        end
        BinData = load_BinData(fn);    
    
    [ff, ymin, ymax, xmin, xmax] = plot_power_vs_value(BinData, stimulus, attribute, plotcolors{i});
    ymin_v = [ymin_v ymin];
    ymax_v = [ymax_v ymax];
    xmin_v = [xmin_v xmin];
    xmax_v = [xmax_v xmax];
    legend_txt{i} = fix_title_string(strainlist{i});
    hold on;
end

ymin = min(ymin_v);
ymax = max(ymax_v);
xmin = min(xmin_v);
xmax = max(xmax_v);
axis([xmin xmax ymin ymax]);
text(0.5,1.05,fix_title_string(colorlist),'FontSize',scaled_fontsize_for_subplot(1,1),'FontName','Helvetica','HorizontalAlignment','center','units','normalized');
hold off;

subplot_legend(legend_txt, plotcolors, 3, 2, plot_loc+1);

return;
end
