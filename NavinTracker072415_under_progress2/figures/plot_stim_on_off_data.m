function plot_stim_on_off_data(onBinData, onTracks, offBinData, offTracks, stimcode, localpath, prefix, fignum_start)
% plot_stim_on_off_data(BinData, Tracks, stimulus, localpath, prefix, fignum_start)

global Prefs;

onStimulus = [0, max_struct_array(onTracks,'Time'), stimcode];
offStimulus = [min_struct_array(offTracks,'Time'), 0, stimcode];

if(nargin<5)
    stimcode=10;
end

if(nargin>5)
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

if(nargin < 8)
    fignum_start=1;
end

disp([sprintf('plot on-off graphs\t%s',timeString())])

temp_prefix = sprintf('page.%d',randint(1000));

title_string = fix_title_string(prefix);


if(isempty(onBinData))
    prefix = sprintf('%s.stim_on_off',prefix);
    dummy_plot(localpath, prefix, temp_prefix);
    return;
end

if(isempty(onBinData.time))
    prefix = sprintf('%s.stim_on_off',prefix);
    dummy_plot(localpath, prefix, temp_prefix);
    return;
end


if(isempty(onBinData.freqtime))
    prefix = sprintf('%s.stim_on_off',prefix);
    dummy_plot(localpath, prefix, temp_prefix);
    return;
end

if(isempty(offBinData))
    prefix = sprintf('%s.stim_on_off',prefix);
    dummy_plot(localpath, prefix, temp_prefix);
    return;
end

if(isempty(offBinData.time))
    prefix = sprintf('%s.stim_on_off',prefix);
    dummy_plot(localpath, prefix, temp_prefix);
    return;
end

if(isempty(offBinData.freqtime))
    prefix = sprintf('%s.stim_on_off',prefix);
    dummy_plot(localpath, prefix, temp_prefix);
    return;
end

if(Prefs.timeunits == 'sec')
    xlabelstring = 'Time (sec)';
else
    xlabelstring = 'Time (min)';
    
    onBinData.time = onBinData.time./60;
    onBinData.freqtime = onBinData.freqtime./60;
    
    offBinData.time = offBinData.time./60;
    offBinData.freqtime = offBinData.freqtime./60;
end

xmin =  max( max(floor(min_struct_array(onTracks,'Time')), floor(min(onBinData.time))), max(floor(min_struct_array(offTracks,'Time')), floor(min(offBinData.time))) );
xmax = min(  min(ceil(max_struct_array(onTracks,'Time')), ceil(max(onBinData.time))), min(ceil(max_struct_array(offTracks,'Time')), ceil(max(offBinData.time))) );

xmax = min(xmax, abs(xmin));
xmin = -xmax;

ymin =  0;

% page 1
fignum = fignum_start;
hold off
hidden_figure(fignum);
plot_rows = 6; plot_columns=4;


% ethogram
ylabelstring = sprintf('%s','Track');
on_loc = [1 5];
off_loc = on_loc+1;
[h_on, y_on, ymin_on] = ethogram(onTracks, plot_rows, plot_columns, on_loc, '', ylabelstring);
[h_off, y_off, ymin_off] = ethogram(offTracks, plot_rows, plot_columns, off_loc, '', ylabelstring);
set(h_off, 'position',[(pos_on(1)+pos_on(3)+inter_plot_dist), pos_on(2), pos_on(3), pos_on(4)]);
side_by_side_subplots(h_on, h_off, [xmin xmax], [ min(0, min(ymin_on,ymin_off) ) max(y_on, y_off) ]);

% speed
ylabelstring = sprintf('%s\n%s','Speed', '(mm/sec)');
on_loc = [9 13];
stim_on_off_lineplot(fignum, onBinData, onStimulus, offBinData, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ylabelstring, ...
    xmin, xmax,  0, 0.25, ...
    'speed', 'k');

% eccentricity
ylabelstring = sprintf('%s','eccentricity');
on_loc = [17 21];
stim_on_off_lineplot(fignum, onBinData, onStimulus, offBinData, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ylabelstring, ...
    xmin, xmax, 0.95, 0.96, ...
    'ecc', 'k');


% num animals
ylabelstring = sprintf('%s\n%s','num','animals');
on_loc = 23;
stim_on_off_lineplot(fignum, onBinData, onStimulus, offBinData, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ylabelstring, ...
    xmin, xmax,  ymin, max(max(onBinData.n)+0.1*max(onBinData.n) ,  max(offBinData.n)+0.1*max(offBinData.n) ) , ...
    'n', 'k');

% Reorientations
on_loc = [3 7 11 15 19];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'reori', 'k');


orient landscape;
set(gcf,'papertype','usletter');
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
end
clear('h');

% page 2
fignum = fignum+1;
hold off
hidden_figure(fignum);
plot_rows = 5; plot_columns=4;


% Rev
on_loc = [1 5 9 13 17];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'Rev', 'b');


% pure_Rev
on_loc = [3 7 11 15 19];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'pure_Rev', 'b');

orient landscape;
set(gcf,'papertype','usletter');
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
end
clear('h');

% page 3
fignum = fignum+1;
hold off
hidden_figure(fignum);
plot_rows = 5; plot_columns=4;

% omegaUpsilon
on_loc = [1 5 9 13 17];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'omegaUpsilon', 'r');

% pure_omegaUpsilon
on_loc = [3 7 11 15 19];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'pure_omegaUpsilon', 'r');

orient landscape;
set(gcf,'papertype','usletter');
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
end
clear('h');

% page 4
fignum = fignum+1;
hold off
hidden_figure(fignum);
plot_rows = 5; plot_columns=4;


% sRev
on_loc = [1 5 9 13 17];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'sRev', 'c');

% pure_sRev
on_loc = [3 7 11 15 19];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'pure_sRev', 'c');

orient landscape;
set(gcf,'papertype','usletter');
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
end
clear('h');

% page 5
fignum = fignum+1;
hold off
hidden_figure(fignum);
plot_rows = 5; plot_columns=4;


% lRev
on_loc = [1 5 9 13 17];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'lRev', 'b');

% pure_lRev
on_loc = [3 7 11 15 19];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'pure_lRev', 'b');

orient landscape;
set(gcf,'papertype','usletter');
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
end
clear('h');



% page 6
fignum = fignum+1;
hold off
hidden_figure(fignum);
plot_rows = 5; plot_columns=4;


% omega
on_loc = [1 5 9 13 17];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'omega', 'r');

% pure_omega
on_loc = [3 7 11 15 19];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'pure_omega', 'r');

orient landscape;
set(gcf,'papertype','usletter');
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
end
clear('h');


% page 7
fignum = fignum+1;
hold off
hidden_figure(fignum);
plot_rows = 5; plot_columns=4;


% Upsilon
on_loc = [1 5 9 13 17];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'Upsilon', 'm');

% pure_Upsilon
on_loc = [3 7 11 15 19];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'pure_Upsilon', 'm');

orient landscape;
set(gcf,'papertype','usletter');
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
end
clear('h');


% page 8
fignum = fignum+1;
hold off
hidden_figure(fignum);
plot_rows = 5; plot_columns=4;


% RevOmega
on_loc = [1 5 9 13 17];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'RevOmega', 'm');

% RevOmegaUpsilon
on_loc = [3 7 11 15 19];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'RevOmegaUpsilon', 'r');

orient landscape;
set(gcf,'papertype','usletter');
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
end
clear('h');


% page 9
fignum = fignum+1;
hold off
hidden_figure(fignum);
plot_rows = 6; plot_columns=4;

% pause
on_loc = [1 5 9 13 17];
stim_on_off_freq(fignum, onBinData, onTracks, onStimulus, offBinData, offTracks, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ...
    xmin, xmax, ...
    'pause', 'k');

% reversal length
ylabelstring = sprintf('%s\n%s','rev length','(bodylengths)');
on_loc = [3 7];
stim_on_off_lineplot(fignum, onBinData, onStimulus, offBinData, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ylabelstring, ...
    xmin, xmax, 0, 1, ...
    'revlength', 'k');


% path curvature
ylabelstring = sprintf('%s\n%s','path curvature','(deg/mm)');
on_loc = [11 15];
stim_on_off_lineplot(fignum, onBinData, onStimulus, offBinData, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ylabelstring, ...
    xmin, xmax, 5, 15, ...
    'curv', 'g');


% angular speed
ylabelstring = sprintf('%s\n%s','angular speed','(deg/sec)');
on_loc = [19 23];
stim_on_off_lineplot(fignum, onBinData, onStimulus, offBinData, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ylabelstring, ...
    xmin, xmax, 0, 15, ...
    'angspeed', 'k');

orient landscape;
set(gcf,'papertype','usletter');
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
end
clear('h');

% page 10
fignum = fignum+1;
hold off
hidden_figure(fignum);
plot_rows = 6; plot_columns=4;


% body angle
ylabelstring = sprintf('%s\n%s','body angle','(degrees)');
on_loc = [1 5];
stim_on_off_lineplot(fignum, onBinData, onStimulus, offBinData, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ylabelstring, ...
    xmin, xmax, 145, 175, ...
    'body_angle', 'k');

% head angle
ylabelstring = sprintf('%s\n%s','head angle','(degrees)');
on_loc = [9 13];
stim_on_off_lineplot(fignum, onBinData, onStimulus, offBinData, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ylabelstring, ...
    xmin, xmax, 135, 155, ...
    'head_angle', 'k');

% tail angle
ylabelstring = sprintf('%s\n%s','tail angle','(degrees)');
on_loc = [17 21];
stim_on_off_lineplot(fignum, onBinData, onStimulus, offBinData, offStimulus, ...
    plot_rows, plot_columns, on_loc, ...
    '', ylabelstring, ...
    xmin, xmax, 140, 160, ...
    'tail_angle', 'k');

orient landscape;
set(gcf,'papertype','usletter');
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
end
clear('h');

prefix = sprintf('%s.stim_on_off',prefix);
pool_temp_pdfs([fignum_start fignum], localpath, prefix, temp_prefix);

return;
end
