function plot_summary_data(inputBinData, Tracks, stimulus, localpath, prefix, fignum_start)
% plot_summary_data(BinData, Tracks, stimulus, localpath, prefix, fignum_start)

global Prefs;

BinData = mean_BinData_from_BinData_array(inputBinData);


if(nargin>=4)
    if(~isempty(localpath) || ~isempty(prefix))
        if(isempty(localpath))
            localpath=pwd;
        end
        localpath = sprintf('%s%s',localpath,filesep);
    end
else
    localpath='';
    prefix='';
end

if(nargin < 6)
    fignum_start=1;
end

disp([sprintf('plot summary_linegraphs\t%s',timeString())])

temp_prefix = sprintf('page.%d',randint(1000));

title_string = fix_title_string(prefix);

if(Prefs.timeunits == 'sec')
    xlabelstring = 'Time (sec)';
else
    xlabelstring = 'Time (min)';
    BinData.time = BinData.time./60;
    BinData.freqtime = BinData.freqtime./60;
end

tmin = min(floor(min_struct_array(Tracks,'Time')), floor(min(BinData.time)));
xmin = min(0,tmin);
xmax = max(ceil(max_struct_array(Tracks,'Time')), ceil(max(BinData.time)));

fignum = fignum_start;
hold off
figure(fignum);
plot_rows = 5; plot_columns=4;


% ethogram
panel_num = 1;
ylabelstring = sprintf('%s','Track');
ethogram(Tracks, plot_rows, plot_columns, panel_num, xlabelstring, ylabelstring);

% speed
panel_num = 2;
ylabelstring = sprintf('%s\n%s','Speed', '(mm/sec)');
plot_linegraph(inputBinData, [], plot_rows, plot_columns, ...
    xmin, xmax, 0, 0.25, ...
    xlabelstring, ylabelstring, 'revSpeed', 'b', panel_num);
hold on;
plot_linegraph(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, 0, 0.25, ...
    xlabelstring, ylabelstring, 'speed', 'k', panel_num);
hold off;

% eccentricity
panel_num = 3;
ylabelstring = sprintf('%s','eccentricity'); % 0.95, 0.96
h = plot_linegraph(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, 0.95, 0.96, ...
    xlabelstring, ylabelstring, 'ecc', 'k', panel_num);

% turn omega delta direction
panel_num = 4;
ylabelstring = sprintf('%s\n%s\n%s','upsilon/omega', 'delta direction','(deg)'); % 0.55, 0.85
h = plot_linegraph(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, 0, 180, ...
    xlabelstring, ylabelstring, 'delta_dir_omegaupsilon', 'r', panel_num);

% revLength
panel_num = 5;
ylabelstring = sprintf('%s\n%s','reversal length','(bodylengths)');
plot_linegraph(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, 0, 1, ...
    xlabelstring, ylabelstring, 'revlength', 'b', panel_num);

% head angle
panel_num = 6;
ylabelstring = sprintf('%s','head angle');
plot_linegraph(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, 135, 155, ...
    xlabelstring, ylabelstring, 'head_angle', 'k', panel_num);

% tail angle
panel_num = 7;
ylabelstring = sprintf('%s','tail angle');
plot_linegraph(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, 140, 160, ...
    xlabelstring, ylabelstring, 'tail_angle', 'k', panel_num);

% path curvature
panel_num = 8;
ylabelstring = sprintf('%s\n%s','path curvature','(deg/mm)');
plot_linegraph(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, 5, 15, ...
    xlabelstring, ylabelstring, 'curv', 'g', panel_num);


% freqs
ymax = 1.0;

% lRev's
panel_num = 9;
ymax = max(BinData.lRev_freq + BinData.lRev_freq_err); ymax = custom_round(ymax, 0.25,'ceil');
ylabelstring = sprintf('%s\n(/min)', 'lRev freq');
errorshade_stimshade_lineplot_BinData(inputBinData, stimulus, plot_rows, plot_columns, panel_num, ...
    [xmin xmax 0 ymax], ...
    'lRev_freq', 'b', ...
    xlabelstring, ylabelstring);

% pure_lRev
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'pure lRev freq');
errorshade_stimshade_lineplot_BinData(inputBinData, stimulus, plot_rows, plot_columns, panel_num, ...
    [xmin xmax 0 ymax], ...
    'pure_lRev_freq', 'b', ...
    xlabelstring, ylabelstring);

% lRevUpsilon
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'lRevUpsilon freq');
errorshade_stimshade_lineplot_BinData(inputBinData, stimulus, plot_rows, plot_columns, panel_num, ...
    [xmin xmax 0 ymax], ...
    'lRevUpsilon_freq', 'b', ...
    xlabelstring, ylabelstring);

% lRevOmega
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'lRevOmega freq');
errorshade_stimshade_lineplot_BinData(inputBinData, stimulus, plot_rows, plot_columns, panel_num, ...
    [xmin xmax 0 ymax], ...
    'lRevOmega_freq', 'b', ...
    xlabelstring, ylabelstring);

% sRev's
panel_num = 13;
ymax = max(BinData.sRev_freq + BinData.sRev_freq_err); ymax = custom_round(ymax, 0.25,'ceil');
ylabelstring = sprintf('%s\n(/min)', 'sRev freq');
errorshade_stimshade_lineplot_BinData(inputBinData, stimulus, plot_rows, plot_columns, panel_num, ...
    [xmin xmax 0 ymax], ...
    'sRev_freq', 'c', ...
    xlabelstring, ylabelstring);

% pure_sRev
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'pure sRev freq');
errorshade_stimshade_lineplot_BinData(inputBinData, stimulus, plot_rows, plot_columns, panel_num, ...
    [xmin xmax 0 ymax], ...
    'pure_sRev_freq', 'c', ...
    xlabelstring, ylabelstring);

% sRevUpsilon
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'sRevUpsilon freq');
errorshade_stimshade_lineplot_BinData(inputBinData, stimulus, plot_rows, plot_columns, panel_num, ...
    [xmin xmax 0 ymax], ...
    'sRevUpsilon_freq', 'c', ...
    xlabelstring, ylabelstring);

% sRevOmega
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'sRevOmega freq');
errorshade_stimshade_lineplot_BinData(inputBinData, stimulus, plot_rows, plot_columns, panel_num, ...
    [xmin xmax 0 ymax], ...
    'sRevOmega_freq', 'c', ...
    xlabelstring, ylabelstring);


% omegaUpsilon's
panel_num = 17;
ymax = max(BinData.omegaUpsilon_freq + BinData.omegaUpsilon_freq_err); ymax = custom_round(ymax, 0.25,'ceil');
ylabelstring = sprintf('%s\n(/min)', 'omegaUpsilon freq');
errorshade_stimshade_lineplot_BinData(inputBinData, stimulus, plot_rows, plot_columns, panel_num, ...
    [xmin xmax 0 ymax], ...
    'omegaUpsilon_freq', 'r', ...
    xlabelstring, ylabelstring);

% pure_omegaUpsilon
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'pure omegaUpsilon freq');
errorshade_stimshade_lineplot_BinData(inputBinData, stimulus, plot_rows, plot_columns, panel_num, ...
    [xmin xmax 0 ymax], ...
    'pure_omegaUpsilon_freq', 'r', ...
    xlabelstring, ylabelstring);
% pure_upsilon
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'pure upsilon freq');
errorshade_stimshade_lineplot_BinData(inputBinData, stimulus, plot_rows, plot_columns, panel_num, ...
    [xmin xmax 0 ymax], ...
    'pure_upsilon_freq', 'm', ...
    xlabelstring, ylabelstring);

% omega
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'pure omega freq');
errorshade_stimshade_lineplot_BinData(inputBinData, stimulus, plot_rows, plot_columns, panel_num, ...
    [xmin xmax 0 ymax], ...
    'pure_omega_freq', 'r', ...
    xlabelstring, ylabelstring);


% panel_num = 15;
% ylabelstring = sprintf('%s\n%s','num','animals');
% ymax = max(BinData.n)+0.1*max(BinData.n);
% local_ymin = 0;
% errorshade_stimshade_lineplot_BinData(BinData, stimulus, plot_rows, plot_columns, n_plot_loc, ...
%     [xmin xmax local_ymin ymax], ...
%     'n', 'k', ...
%     xlabelstring, ylabelstring);
% hold on;
% ymax = max(BinData.n)+0.1*max(BinData.n);
% local_ymin = 0;
% errorshade_stimshade_lineplot_BinData(BinData, [], plot_rows, plot_columns, n_plot_loc, ...
%     [xmin xmax local_ymin ymax], ...
%     'n_freq', [0.5 0.5 0.5], ...
%     xlabelstring, ylabelstring);
% hold off;

orient landscape;
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');

if(~isempty(prefix))
    save_figure(gcf, localpath, temp_prefix, num2str(fignum),1);
end
clear('h');


% if(~isempty(prefix))
%     prefix = sprintf('%s.summary_linegraphs',prefix);
%     pool_temp_pdfs(fignum, localpath, prefix, temp_prefix);
% end

if(~isempty(localpath))
    
    outprefix = sprintf('%s%s',localpath,prefix);
    
    command = sprintf('pdftk');
    
    
    if(~isempty(localpath))
        if(localpath(1)~='\' && localpath(1)~='/' && localpath(2)~=':')
            command = sprintf('%s %s%s%s%s%s.%d.pdf',command, pwd, filesep, localpath, filesep, temp_prefix, fignum);
        else
            command = sprintf('%s %s%s%s.%d.pdf',command, localpath, filesep, temp_prefix, fignum);
        end
    else
        command = sprintf('%s %s.%d.pdf',command, temp_prefix, fignum);
    end
    
    tempoutfile = sprintf('%s%s.%d.fig',localpath, temp_prefix, fignum);
    rm(tempoutfile);
    
    
    tempoutfile = sprintf('%s.pdf',tempname);
    command = sprintf('%s cat output %s',command, tempoutfile);
    run_command(command);
    
    outfile = sprintf('%s.summary_linegraphs.pdf',outprefix);
    
    mv(tempoutfile, outfile);
    
    tempoutfile = sprintf('%s%s%s.%d.pdf',localpath, filesep, temp_prefix, fignum);
    rm(tempoutfile);
end

% probably staring?
if(isempty(stimulus))
    if(xmax-xmin > 30*60)
        stimulus = 'staring';
    end
end

if(~isempty(stimulus))
    plot_summary_bargraphs(inputBinData, Tracks, stimulus, localpath, prefix, fignum_start+1);
end

return;
end
