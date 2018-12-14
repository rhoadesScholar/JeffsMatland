function plot_data(inputBinData, Tracks, stimulus, localpath, prefix, fignum_start)
% plot_data(BinData, Tracks, stimulus, localpath, prefix, fignum_start)

global Prefs;

if(nargin<2)
    Tracks=[];
    stimulus=[];
    localpath='';
    prefix='';
    fignum_start=1;
end

inputBinData = extract_BinData_array(inputBinData);
BinData = mean_BinData_from_BinData_array(inputBinData);

if(nargin>3)
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

disp([sprintf('plot graphs\t%s',timeString())])

temp_prefix = sprintf('page.%d',randint(1000));

title_string = fix_title_string(prefix);

if(isempty(BinData))
    dummy_plot(localpath, prefix, temp_prefix);
    return;
end

if(isempty(BinData.time))
    dummy_plot(localpath, prefix, temp_prefix);
    return;
end

if(Prefs.timeunits == 'sec')
    xlabelstring = 'Time (sec)';
else
    xlabelstring = 'Time (min)';
    BinData.time = BinData.time./60;
    BinData.freqtime = BinData.freqtime./60;
end

if(isfield(BinData,'xlabel'))
    xlabelstring = BinData.xlabel;
end

tmin = floor(min_struct_array(BinData,'time')); 
if(~isempty(Tracks))
    Tracks = sort_tracks_by_length(Tracks);
    tmin = max(floor(min_struct_array(Tracks,'Time')), tmin);
    mvt_init_ethogram(Tracks, stimulus, 'initialize');
end
xmin = min(0,tmin);

xmax = ceil(max_struct_array(BinData,'time'));
if(~isempty(Tracks))
    xmax = min(ceil(max_struct_array(Tracks,'Time')), xmax);
end

%if(~isempty(Tracks))
ymin =  0;
%else % if this function is called w/ empty Tracks, BinData almost certainly is a difference
%    ymin = [];
%end

% page 1
fignum = fignum_start;
hidden_figure(fignum);
plot_rows = 6; plot_columns=2;

if(~isempty(stimulus))
    % ethogram
    if(strcmp(Prefs.ethogram_orientation,'horizontal'))
        plot_loc = [1 2 0 0 0; 3 5 0 0 0; 7 9 0 0 0; 4 6 8 10 12];
        n_plot_loc = 11;
    else
        plot_loc = [1 3 0 0 0; 5 7 0 0 0; 9 11 0 0 0; 2 4 6 8 10];
        n_plot_loc = 12;
    end
    if(~isempty(Tracks))
        ylabelstring = sprintf('%s','Track');
        if(strcmp(Prefs.ethogram_orientation,'horizontal'))
            ethogram(Tracks, plot_rows, plot_columns, plot_loc(1,:), xlabelstring, ylabelstring);
        else
            ethogram(Tracks, plot_rows, plot_columns, plot_loc(1,:), '', ylabelstring);
        end
    end
else % probably staring
    plot_rows = 5; plot_columns=2;
    plot_loc = [0 0 0 0 0; 1 3 0 0 0; 5 7 0 0 0; 2 4 6 8 10];
    n_plot_loc = 9;
end


% speed
ylabelstring = sprintf('%s\n%s','Speed', '(mm/sec)');
ymax = 0.25;
local_ymin = 0;
if(isempty(ymin))
    local_ymin = min(BinData.speed)-max(BinData.speed_err);
    ymax = max(BinData.speed)+max(BinData.speed_err);
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end
plot_attribute(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, local_ymin, ymax, ...
    xlabelstring, ylabelstring, 'speed', 'k', plot_loc(2,:));

% eccentricity
ylabelstring = sprintf('%s','eccentricity');
ymax = 0.96;
local_ymin = 0.95;
if(isempty(ymin))
    local_ymin = min(BinData.ecc)-max(BinData.ecc_err);
    ymax = max(BinData.ecc)+max(BinData.ecc_err);
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end
plot_attribute(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, local_ymin, ymax, ...
    xlabelstring, ylabelstring, 'ecc', 'k', plot_loc(3,:));

% num animals
ylabelstring = sprintf('%s\n%s','num','animals');
ymax = max(BinData.n)+0.1*max(BinData.n);
local_ymin = 0;
errorshade_stimshade_lineplot_BinData(inputBinData, stimulus, plot_rows, plot_columns, n_plot_loc, ...
    [xmin xmax local_ymin ymax], ...
    'n', 'k', ...
    xlabelstring, ylabelstring);
hold on;
ymax = max(BinData.n)+0.1*max(BinData.n);
local_ymin = 0;
errorshade_stimshade_lineplot_BinData(inputBinData, [], plot_rows, plot_columns, n_plot_loc, ...
    [xmin xmax local_ymin ymax], ...
    'n_freq', [0.5 0.5 0.5], ...
    xlabelstring, ylabelstring);
hold off;

% reorientations
plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'nonUpsilon_reori', 'k', plot_loc(4,:));

page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix);

% page 2
fignum=fignum+1;
hidden_figure(fignum);
plot_rows = 5; plot_columns=2;
plot_loc = [1 3 5 7 9; 2 4 6 8 10];
ylim_vec = [];

% Rev
ylim_vec = plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'Rev', 'b', plot_loc(1,:));

% pure_Rev
plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pure_Rev', 'b', plot_loc(2,:), ylim_vec);

page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix);


% page 3
fignum=fignum+1;
hidden_figure(fignum);
plot_rows = 5; plot_columns=2;
plot_loc = [1 3 5 7 9; 2 4 6 8 10];
ylim_vec=[];

% omegaUpsilon
ylim_vec = plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'omegaUpsilon', 'r', plot_loc(1,:));

% pure_omegaUpsilon
plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pure_omegaUpsilon', 'r', plot_loc(2,:),ylim_vec);

page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix);


% page 4
fignum=fignum+1;
hidden_figure(fignum);
plot_rows = 5; plot_columns=2;
plot_loc = [1 3 5 7 9; 2 4 6 8 10];
ylim_vec=[];

% sRev
ylim_vec = plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'sRev', 'c', plot_loc(1,:));

% pure_sRev
plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pure_sRev', 'c', plot_loc(2,:), ylim_vec);

page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix);


% page 5
fignum=fignum+1;
hidden_figure(fignum);
plot_rows = 5; plot_columns=2;
plot_loc = [1 3 5 7 9; 2 4 6 8 10];
ylim_vec =[];

% lRev
ylim_vec = plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'lRev', 'b', plot_loc(1,:));

% pure_lRev
plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pure_lRev', 'b', plot_loc(2,:), ylim_vec);

page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix);


% page 6
fignum=fignum+1;
hidden_figure(fignum);
plot_rows = 5; plot_columns=2;
plot_loc = [1 3 5 7 9; 2 4 6 8 10];
ylim_vec=[];

% omega
ylim_vec = plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'omega', 'r', plot_loc(1,:));

% pure_omega
plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pure_omega', 'r', plot_loc(2,:), ylim_vec);

page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix);


% page 7
fignum=fignum+1;
hidden_figure(fignum);
plot_rows = 5; plot_columns=2;
plot_loc = [1 3 5 7 9; 2 4 6 8 10];
ylim_vec=[];

% upsilon
ylim_vec = plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'upsilon', 'm', plot_loc(1,:));

% pure_upsilon
plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pure_upsilon', 'm', plot_loc(2,:), ylim_vec);


page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix);


% page 8
fignum=fignum+1;
hidden_figure(fignum);
plot_rows = 5; plot_columns=2;
plot_loc = [1 3 5 7 9; 2 4 6 8 10];
ylim_vec = [];

% RevOmegaUpsilon
ylim_vec = plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'RevOmegaUpsilon', 'r', plot_loc(1,:));

% RevOmega
plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'RevOmega', 'r', plot_loc(2,:), ylim_vec);

page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix);

% page 9
fignum=fignum+1;
hidden_figure(fignum);
plot_rows = 5; plot_columns=2;
plot_loc = [1 3 5 7 9; 2 4 6 8 10];
ylim_vec = [];

% lRevOmega
% lRevUpsilon

if(max(BinData.lRevOmega_freq) > max(BinData.lRevUpsilon_freq))
    ylim_vec = plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'lRevOmega', 'b', plot_loc(1,:));
    plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'lRevUpsilon', 'b', plot_loc(2,:), ylim_vec);
else
    ylim_vec = plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'lRevUpsilon', 'b', plot_loc(2,:));
    plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'lRevOmega', 'b', plot_loc(1,:), ylim_vec);
end

page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix);


% page 10
fignum=fignum+1;
hidden_figure(fignum);
plot_rows = 5; plot_columns=2;
plot_loc = [1 3 5 7 9; 2 4 6 8 10];
ylim_vec = [];

% sRevOmega
% sRevUpsilon

if(max(BinData.sRevOmega_freq) > max(BinData.sRevUpsilon_freq))
    ylim_vec = plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'sRevOmega', 'c', plot_loc(1,:));
    plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'sRevUpsilon', 'c', plot_loc(2,:), ylim_vec);
else
    ylim_vec = plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'sRevUpsilon', 'c', plot_loc(2,:));
    plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'sRevOmega', 'c', plot_loc(1,:), ylim_vec);
end

page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix);


% page 11
fignum=fignum+1;
hidden_figure(fignum);
plot_rows = 6; plot_columns=2;
plot_loc = [1 3 5 7 9; 2 4 0 0 0; 6 8 0 0 0; 10 12 0 0 0];

% pause
plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pause', 'k', plot_loc(1,:));


% reversal length
%if(~isfield(BinData,'revlength_bodybends'))
    ylabelstring = sprintf('%s\n%s','reversal length','(bodylengths)');
    ymax = 1;
    local_ymin = 0;
    plot_attribute(inputBinData, stimulus, plot_rows, plot_columns, ...
        xmin, xmax, local_ymin, ymax, ...
        xlabelstring, ylabelstring, 'revlength', 'b', plot_loc(2,:));
% else
%     ylabelstring = sprintf('%s\n%s','reversal length','(bodybends)');
%     ymax = 5;
%     local_ymin = 0;
%     plot_attribute(BinData, stimulus, plot_rows, plot_columns, ...
%         xmin, xmax, local_ymin, ymax, ...
%         xlabelstring, ylabelstring, 'revlength_bodybends', 'b', plot_loc(2,:));
% end

% path curvature
ylabelstring = sprintf('%s\n%s','path curvature','(deg/mm)');
ymax = 15;
local_ymin = 5;
if(isempty(ymin))
    local_ymin = min(BinData.curv)-max(BinData.curv_err);
    ymax = max(BinData.curv)+max(BinData.curv_err);
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end
plot_attribute(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, local_ymin, ymax, ...
    xlabelstring, ylabelstring, 'curv', 'g', plot_loc(3,:));

% ecc_omegaupsilon
if(~isfield(BinData,'delta_dir_omegaupsilon'))
    ylabelstring = sprintf('%s\n%s','eccentricity','omega/upsilon');
    ymax = 0.85;
    local_ymin = 0.55;
    plot_attribute(inputBinData, stimulus, plot_rows, plot_columns, ...
        xmin, xmax, local_ymin, ymax, ...
        xlabelstring, ylabelstring, 'ecc_omegaupsilon', 'r', plot_loc(4,:));
else
    ylabelstring = sprintf('%s\n%s\n%s','delta direction','omega/upsilon','(deg)');
    ymax = 180;
    local_ymin = 0;
    plot_attribute(inputBinData, stimulus, plot_rows, plot_columns, ...
        xmin, xmax, local_ymin, ymax, ...
        xlabelstring, ylabelstring, 'delta_dir_omegaupsilon', 'r', plot_loc(4,:));
end

% % angspeed
% ylabelstring = sprintf('%s\n%s','angular speed','(deg/sec)');
% ymax = 15;
% local_ymin = 0;
% if(isempty(ymin))
%     local_ymin = min(BinData.angspeed)-max(BinData.angspeed_err);
%     ymax = max(BinData.angspeed)+max(BinData.angspeed_err);
%     del = 10^round(log10((ymax-local_ymin)/5));
%     local_ymin = custom_round(local_ymin, del);
%     ymax = custom_round(ymax, del);
% end
% plot_attribute(BinData, stimulus, plot_rows, plot_columns, ...
%                 xmin, xmax, local_ymin, ymax, ...
%                 xlabelstring, ylabelstring, 'angspeed', 'k', plot_loc(4,:));

page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix);

% page 12
fignum=fignum+1;
hidden_figure(fignum);
plot_rows = 6; plot_columns=2;
plot_loc = [1 3; 5 7; 9 11; 2 4; 6 8];

% body angle
ylabelstring = sprintf('%s\n%s','body angle','(degrees)');
ymax = 175;
local_ymin = 145;
if(isempty(ymin))
    local_ymin = min(BinData.body_angle)-max(BinData.body_angle_err);
    ymax = max(BinData.body_angle)+max(BinData.body_angle_err);
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end
plot_attribute(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, local_ymin, ymax, ...
    xlabelstring, ylabelstring, 'body_angle', 'k', plot_loc(1,:));

% head angle
ylabelstring = sprintf('%s\n%s','head angle','(degrees)');
ymax = 155;
local_ymin = 135;
if(isempty(ymin))
    local_ymin = min(BinData.head_angle)-max(BinData.head_angle_err);
    ymax = max(BinData.head_angle)+max(BinData.head_angle_err);
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end
plot_attribute(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, local_ymin, ymax, ...
    xlabelstring, ylabelstring, 'head_angle', 'k', plot_loc(2,:));

% tail angle
ylabelstring = sprintf('%s\n%s','tail angle','(degrees)');
ymax = 160;
local_ymin = 140;
if(isempty(ymin))
    local_ymin = min(BinData.tail_angle)-max(BinData.tail_angle_err);
    ymax = max(BinData.tail_angle)+max(BinData.tail_angle_err);
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end
plot_attribute(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, local_ymin, ymax, ...
    xlabelstring, ylabelstring, 'tail_angle', 'k', plot_loc(3,:));


% revSpeed
ylabelstring = sprintf('%s\n%s','revSpeed', '(mm/sec)');
ymax = 0.25;
local_ymin = 0;
if(isempty(ymin))
    local_ymin = min(BinData.revSpeed)-max(BinData.revSpeed_err);
    ymax = max(BinData.revSpeed)+max(BinData.revSpeed_err);
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end
plot_attribute(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, local_ymin, ymax, ...
    xlabelstring, ylabelstring, 'revSpeed', 'b', plot_loc(4,:));

% post-reversal reorientation angle
ylabelstring = sprintf('%s\n%s\n%s','post-reversal','reorientation','(deg)');
ymax = 180;
local_ymin = 0;
plot_attribute(inputBinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, local_ymin, ymax, ...
    xlabelstring, ylabelstring, 'delta_dir_rev', 'b', plot_loc(5,:));


page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix);



% page 13
if(Prefs.swim_flag == 1)
    fignum=fignum+1;
    hidden_figure(fignum);
    plot_rows = 6; plot_columns=2;
    plot_loc = [1 3 5 7 9; 2 4 0 0 0; 6 8 0 0 0; 10 12 0 0 0];
    
    % liquid_omega
    plot_freq_frac(inputBinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'liquid_omega', 'r', plot_loc(1,:));
    
    % body_bends_per_sec
    ylabelstring = sprintf('%s\n%s','body_bends', '(/sec)');
    local_ymin = 0;
    ymax = 3;
    ymax = custom_round(max(ymax, max(BinData.body_bends_per_sec)), 0.25);
    ymax = ymax(1);
    plot_attribute(inputBinData, stimulus, plot_rows, plot_columns, ...
        xmin, xmax, local_ymin, ymax, ...
        xlabelstring, ylabelstring, 'body_bends_per_sec', 'b', plot_loc(2,:));
    
    page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix);
end



if(~isempty(prefix))
    pool_temp_pdfs([fignum_start fignum], localpath, prefix, temp_prefix);
end


mvt_init_ethogram(Tracks, stimulus, 'clear');




return;
end


function page_end_stuff(gcf, fignum, title_string, prefix, tempdir, temp_prefix)

orient landscape;
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
title_string = fix_title_string(title_string);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');


disp([sprintf('page %d done ... saving\t%s',fignum, timeString())]);
if(~isempty(prefix))
    filename = sprintf('%s%s.%s', tempdir, temp_prefix, num2str(fignum));
    save_pdf(gcf, filename, 1);
    
    disp([sprintf('page %d saved\t%s',fignum, timeString())]);
    close(fignum);
else
    show_figure(fignum);
end
clear('h');

return;
end
