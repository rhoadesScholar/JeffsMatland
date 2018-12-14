function plot_summary_bargraphs(inputBinData, Tracks, stimulus, localpath, prefix, fignum_start)
% plot_summary_bargraphs(BinData, Tracks, stimulus, localpath, prefix, fignum_start)

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

disp([sprintf('plot summary bargraphs\t%s',timeString())])

temp_prefix = sprintf('page.%d',randint(1000));

title_string = fix_title_string(prefix);

if(Prefs.timeunits == 'sec')
    xlabelstring = 'Time (sec)';
else
    xlabelstring = 'Time (min)';
    BinData.time = BinData.time./60;
    BinData.freqtime = BinData.freqtime./60;
end

fignum = fignum_start;
hold off
figure(fignum);
plot_rows = 5; plot_columns=4;

% ethogram
panel_num = 1;
ylabelstring = sprintf('%s','Track');
if(~isempty(Tracks))
    ethogram(Tracks, plot_rows, plot_columns, panel_num, xlabelstring, ylabelstring);
end

% speed
panel_num = 2;
ylabelstring = sprintf('%s\n%s','Speed', '(mm/sec)');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'speed', [0, 0.25], ylabelstring);

% eccentricity
panel_num = 3;
ylabelstring = sprintf('%s','eccentricity'); % 0.95, 0.96
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'ecc', [0.95, 0.96], ylabelstring);

% turn omega delta_dir
panel_num = 4;
ylabelstring = sprintf('%s\n%s\n%s','upsilon/omega', 'delta direction','(deg)'); % 0.55, 0.85
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'delta_dir_omegaupsilon', [0 180], ylabelstring);

% revLength
panel_num = 5;
ylabelstring = sprintf('%s\n%s','reversal length','(bodylengths)');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'revlength', [0 1], ylabelstring);

% head angle
panel_num = 6;
ylabelstring = sprintf('%s','head angle');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'head_angle', [135, 155], ylabelstring);

% tail angle
panel_num = 7;
ylabelstring = sprintf('%s','tail angle');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'tail_angle', [140, 160], ylabelstring);

% path curvature
panel_num = 8;
ylabelstring = sprintf('%s\n%s','path curvature','(deg/mm)');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'curv', [5, 15], ylabelstring);

% freqs
ymax = 1.0;

% lRev's
panel_num = 9;
ymax = max(BinData.lRev_freq + BinData.lRev_freq_err); ymax = custom_round(ymax, 0.25,'ceil');
ylabelstring = sprintf('%s\n(/min)', 'lRev freq');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'lRev_freq', [0 ymax], ylabelstring);

% pure_lRev
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'pure lRev freq');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'pure_lRev_freq', [0 ymax], ylabelstring);

% lRevUpsilon
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'lRevUpsilon freq');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'lRevUpsilon_freq', [0 ymax], ylabelstring);

% lRevOmega
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'lRevOmega freq');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'lRevOmega_freq', [0 ymax], ylabelstring);

% sRev's
panel_num = 13;
ymax = max(BinData.sRev_freq + BinData.sRev_freq_err); ymax = custom_round(ymax, 0.25,'ceil');
ylabelstring = sprintf('%s\n(/min)', 'sRev freq');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'sRev_freq', [0 ymax], ylabelstring);

% pure_sRev
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'pure sRev freq');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'pure_sRev_freq', [0 ymax], ylabelstring);

% sRevUpsilon
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'sRevUpsilon freq');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'sRevUpsilon_freq', [0 ymax], ylabelstring);

% sRevOmega
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'sRevOmega freq');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'sRevOmega_freq', [0 ymax], ylabelstring);

% omegaUpsilon's
panel_num = 17;
ymax = max(BinData.omegaUpsilon_freq + BinData.omegaUpsilon_freq_err); ymax = custom_round(ymax, 0.25,'ceil');
ylabelstring = sprintf('%s\n(/min)', 'omegaUpsilon freq');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'omegaUpsilon_freq', [0 ymax], ylabelstring);

% pure_omegaUpsilon
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'pure omegaUpsilon freq');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'pure_omegaUpsilon_freq', [0 ymax], ylabelstring);

% pure_upsilon
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'pure upsilon freq');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'pure_upsilon_freq', [0 ymax], ylabelstring);

% omega
panel_num = panel_num+1;
ylabelstring = sprintf('%s\n(/min)', 'pure omega freq');
subplot(plot_rows, plot_columns, panel_num); stimulus_bargraphs(inputBinData, stimulus, 'pure_omega_freq', [0 ymax], ylabelstring);

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
%     prefix = sprintf('%s.summary_bargraphs',prefix);
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
    
    outfile = sprintf('%s.summary_bargraphs.pdf',outprefix);
    
    mv(tempoutfile, outfile);
    
    
    tempoutfile = sprintf('%s%s%s.%d.pdf',localpath, filesep, temp_prefix, fignum);
    rm(tempoutfile);
    
    
end

return;
end
