function overlay_plot(BinData_array, Track_array_struct, colors, stimulus, localpath, prefix, fignum_start)
% overlay_plot(BinData_array, Track_array_struct, colors, stimulus, localpath, prefix, fignum_start)


if(nargin<1)
    disp('usage: overlay_plot(BinData_array, Track_array_struct, colors, stimulus, localpath, prefix, fignum_start)');
    return;
end

global Prefs;
Prefs = define_preferences(Prefs);

BinData_array_length = length(BinData_array);

for(i=1:BinData_array_length)
    strain_names{i} = BinData_array(i).Name;
end

if(nargin < 2)
    Track_array_struct = [];
end

if(nargin < 3)
    colors = [];
end

if(nargin < 4)
    stimulus = [];
end

if(isempty(colors))    
    for(i=1:BinData_array_length)
       colors{i} = [rand rand rand]; 
    end
end

if(nargin>4)
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

if(nargin < 7)
    fignum_start=1;
end

if(fignum_start == 1)
    close all;
end
    
disp([sprintf('overlay_plot\t%s',timeString())])

temp_prefix = sprintf('page.%d',randint(1000));

title_string = fix_title_string(prefix);

if(Prefs.timeunits == 'sec')
    xlabelstring = 'Time (sec)';
else
    xlabelstring = 'Time (min)';
    for(bb=1:length(BinData_array))
        BinData_array(bb).time = BinData_array(bb).time./60;
        BinData_array(bb).freqtime = BinData_array(bb).freqtime./60;
    end
end

if(~isempty(Track_array_struct))
    minlength = length(Track_array_struct(1).Tracks);
    for(i=1:length(Track_array_struct))
        Track_array_struct(i).Tracks = sort_tracks_by_length(Track_array_struct(i).Tracks);
        if(length(Track_array_struct(i).Tracks) < minlength)
            minlength = length(Track_array_struct(i).Tracks);
        end
    end
    for(i=1:length(Track_array_struct))
        if(length(Track_array_struct(i).Tracks) > minlength)
            Track_array_struct(i).Tracks = Track_array_struct(i).Tracks(1:minlength);
        end
    end
    
    tmin = min(floor(min_struct_array(Track_array_struct(1).Tracks,'Time')), floor(min_struct_array(BinData_array,'time')));
else
    tmin = floor(min_struct_array(BinData_array,'time'));
end
xmin = min(0,tmin);

if(~isempty(Track_array_struct))
    xmax = max(ceil(max_struct_array(Track_array_struct(1).Tracks,'Time')), ceil(max_struct_array(BinData_array,'time')));
else
    xmax = ceil(max_struct_array(BinData_array,'time'));
end

if(~isempty(Track_array_struct))
    ymin =  0;
else % if this function is called w/ empty Track_array_struct, BinData almost certainly is a difference 
    ymin = [];
end


    
% page 1
fignum = fignum_start;
figure(fignum);
plot_rows = 5; plot_columns=2;
plot_loc = [1 0 0; 3 0 0; 2 4 6; 7 0 0];
n_plot_loc = 5;
subplot_legend(strain_names, colors, plot_rows, plot_columns, plot_loc(4,:));
    
% speed
ylabelstring = sprintf('%s\n%s','Speed', '(mm/sec)');
ymax = 0.25;
local_ymin = 0;
if(isempty(ymin))
    local_ymin = min(local_ymin, min_struct_array(BinData_array,'speed')-max_struct_array(BinData_array,'speed_err')); local_ymin=local_ymin(1);
    ymax = max_struct_array(BinData_array,'speed')+max_struct_array(BinData_array,'speed_err');
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end
plot_attribute_BinData_array(fignum, BinData_array, stimulus, plot_rows, plot_columns, ...
                xmin, xmax, local_ymin, ymax, ...
                xlabelstring, ylabelstring, 'speed', colors, plot_loc(1,:));


% eccentricity     
ylabelstring = sprintf('%s','eccentricity');
ymax = 0.96;
local_ymin = 0.95;
if(isempty(ymin))
    local_ymin = min_struct_array(BinData_array,'ecc')-max_struct_array(BinData_array,'ecc_err');
    ymax = max_struct_array(BinData_array,'ecc')+max_struct_array(BinData_array,'ecc_err');
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end
plot_attribute_BinData_array(fignum, BinData_array, stimulus, plot_rows, plot_columns, ...
                xmin, xmax, local_ymin, ymax, ...
                xlabelstring, ylabelstring, 'ecc', colors, plot_loc(2,:));            
            
% num animals
ylabelstring = sprintf('%s\n%s','num','animals');
ymax = max_struct_array(BinData_array,'n')+0.1*max_struct_array(BinData_array,'n');
local_ymin = 0;
errorshade_stimshade_lineplot_BinData_array(BinData_array, stimulus, plot_rows, plot_columns, n_plot_loc, ...
    [xmin xmax local_ymin ymax], 'n', colors, xlabelstring, ylabelstring);
                
% reorientations             
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'reori', colors, plot_loc(3,:))



orient landscape;
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center'); 
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
else
    show_figure(fignum);
end
clear('h');



% page 2
fignum=fignum+1;
figure(fignum);
plot_rows = 7; plot_columns=2;
plot_loc = [1 3 5; 2 4 6; 7 9 11; 8 10 12; 13 0 0];
subplot_legend(strain_names, colors, plot_rows, plot_columns, plot_loc(5,:));




% Rev             
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'Rev', colors, plot_loc(1,:))

% omegaUpsilon 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'omegaUpsilon', colors, plot_loc(2,:))

% pure_Rev             
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pure_Rev', colors, plot_loc(3,:))

% pure_omegaUpsilon 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pure_omegaUpsilon', colors, plot_loc(4,:))


orient landscape;
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
else
    show_figure(fignum);
end
clear('h');

% page 3
fignum=fignum+1;
figure(fignum);
plot_rows = 7; plot_columns=2;
plot_loc = [1 3 5; 2 4 6; 7 9 11; 8 10 12; 13 0 0];
subplot_legend(strain_names, colors, plot_rows, plot_columns, plot_loc(5,:));
                               
% sRev 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'sRev', colors, plot_loc(1,:))

% lRev 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'lRev', colors, plot_loc(2,:))

% pure_sRev 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pure_sRev', colors, plot_loc(3,:))

% pure_lRev 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pure_lRev', colors, plot_loc(4,:))


orient landscape;
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
else
    show_figure(fignum);
end
clear('h');

% page 4
fignum=fignum+1;
figure(fignum);
plot_rows = 7; plot_columns=2;
plot_loc = [1 3 5; 2 4 6; 7 9 11; 8 10 12; 13 0 0];
subplot_legend(strain_names, colors, plot_rows, plot_columns, plot_loc(5,:));

% upsilon 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'upsilon', colors, plot_loc(1,:))

% omega 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'omega', colors, plot_loc(2,:))

% pure_upsilon 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pure_upsilon', colors, plot_loc(3,:))

% pure_omega 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pure_omega', colors, plot_loc(4,:))

orient landscape;
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
else
    show_figure(fignum);
end
clear('h');

% page 5
fignum=fignum+1;
figure(fignum);
plot_rows = 5; plot_columns=2;
plot_loc = [1 3 5; 2 4 6; 7 0 0];
subplot_legend(strain_names, colors, plot_rows, plot_columns, plot_loc(3,:));

% RevOmega 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'RevOmega', colors, plot_loc(1,:))

% RevomegaUpsilon 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'RevOmegaUpsilon', colors, plot_loc(2,:))

orient landscape;
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
else
    show_figure(fignum);
end
clear('h');

% page 6
fignum=fignum+1;
figure(fignum);
plot_rows = 7; plot_columns=2;
plot_loc = [1 3 5; 2 4 6; 7 9 11; 8 10 12; 13 0 0];
subplot_legend(strain_names, colors, plot_rows, plot_columns, plot_loc(5,:));

% lRevOmega 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'lRevOmega', colors, plot_loc(1,:))

% lRevUpsilon
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'lRevUpsilon', colors, plot_loc(2,:))

% sRevOmega 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'sRevOmega', colors, plot_loc(3,:))

% sRevUpsilon 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'sRevUpsilon', colors, plot_loc(4,:))

orient landscape;
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
else
    show_figure(fignum);
end
clear('h');


% page 7
fignum=fignum+1;
figure(fignum);
plot_rows = 5; plot_columns=2;
plot_loc = [1 3 5; 2 0 0 ; 4 0 0 ; 6 0 0; 7 0 0 ];

subplot_legend(strain_names, colors, plot_rows, plot_columns, plot_loc(5,:));

% pause 
plot_freq_frac_BinData_array(fignum, BinData_array, Track_array_struct, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, 'pause', colors, plot_loc(1,:))

% reversal length
ylabelstring = sprintf('%s\n%s','reversal length','(bodylengths)');
ymax = 1;
local_ymin = 0;
if(isempty(ymin))
    local_ymin = min_struct_array(BinData_array,'revlength')-max_struct_array(BinData_array,'revlength_err');
    ymax = max_struct_array(BinData_array,'revlength')+max_struct_array(BinData_array,'revlength_err');
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end                            
plot_attribute_BinData_array(fignum, BinData_array, stimulus, plot_rows, plot_columns, ...
                xmin, xmax, local_ymin, ymax, ...
                xlabelstring, ylabelstring, 'revlength', colors, plot_loc(2,:));            
 
            
% path curvature
ylabelstring = sprintf('%s\n%s','path curvature','(deg/mm)');
ymax = 15;
local_ymin = 5;
if(isempty(ymin))
    local_ymin = min_struct_array(BinData_array,'curv')-max_struct_array(BinData_array,'curv_err');
    ymax = max_struct_array(BinData_array,'curv')+max_struct_array(BinData_array,'curv_err');
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end  
plot_attribute_BinData_array(fignum, BinData_array, stimulus, plot_rows, plot_columns, ...
                xmin, xmax, local_ymin, ymax, ...
                xlabelstring, ylabelstring, 'curv', colors, plot_loc(3,:));            
                        
% ecc_omegaupsilon
if(~isfield(BinData_array,'delta_dir_omegaupsilon'))
    ylabelstring = sprintf('%s\n%s','eccentricity','omega/upsilon');
    ymax = 0.85;
    local_ymin = 0.55;
    plot_attribute_BinData_array(fignum, BinData_array, stimulus, plot_rows, plot_columns, ...
        xmin, xmax, local_ymin, ymax, ...
        xlabelstring, ylabelstring, 'ecc_omegaupsilon', colors, plot_loc(4,:));
else
    ylabelstring = sprintf('%s\n%s\n%s','delta direction','omega/upsilon','(deg)');
    ymax = 180;
    local_ymin = 0;
    plot_attribute_BinData_array(fignum, BinData_array, stimulus, plot_rows, plot_columns, ...
        xmin, xmax, local_ymin, ymax, ...
        xlabelstring, ylabelstring, 'delta_dir_omegaupsilon', colors, plot_loc(4,:));
end

            

% % angspeed
% ylabelstring = sprintf('%s\n%s','angular speed','(deg/sec)');
% ymax = 15;
% local_ymin = 0;
% if(isempty(ymin))
%     local_ymin = min_struct_array(BinData_array,'angspeed')-max_struct_array(BinData_array,'angspeed_err');
%     ymax = max_struct_array(BinData_array,'angspeed')+max_struct_array(BinData_array,'angspeed_err');
%     del = 10^round(log10((ymax-local_ymin)/5));
%     local_ymin = custom_round(local_ymin, del);
%     ymax = custom_round(ymax, del);
% end      
% plot_attribute_BinData_array(fignum, BinData_array, stimulus, plot_rows, plot_columns, ...
%                 xmin, xmax, local_ymin, ymax, ...
%                 xlabelstring, ylabelstring, 'angspeed', colors, plot_loc(4,:));            
             
orient landscape;
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
else
    show_figure(fignum);
end
clear('h');
             

% page 8
fignum=fignum+1;
figure(fignum);
plot_rows = 5; plot_columns=2;
plot_loc = [1; 3; 5; 2];
subplot_legend(strain_names, colors, plot_rows, plot_columns, 7);
                                                         
% body angle
ylabelstring = sprintf('%s\n%s','body angle','(degrees)');
ymax = 175;
local_ymin = 145;
if(isempty(ymin))
    local_ymin = min_struct_array(BinData_array,'body_angle')-max_struct_array(BinData_array,'body_angle_err');
    ymax = max_struct_array(BinData_array,'body_angle')+max_struct_array(BinData_array,'body_angle_err');
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end              
plot_attribute_BinData_array(fignum, BinData_array, stimulus, plot_rows, plot_columns, ...
                xmin, xmax, local_ymin, ymax, ...
                xlabelstring, ylabelstring, 'body_angle', colors, plot_loc(1,:));            
            
% head angle
ylabelstring = sprintf('%s\n%s','head angle','(degrees)');
ymax = 155;
local_ymin = 135;
if(isempty(ymin))
    local_ymin = min_struct_array(BinData_array,'head_angle')-max_struct_array(BinData_array,'head_angle_err');
    ymax = max_struct_array(BinData_array,'head_angle')+max_struct_array(BinData_array,'head_angle_err');
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end     
plot_attribute_BinData_array(fignum, BinData_array, stimulus, plot_rows, plot_columns, ...
                xmin, xmax, local_ymin, ymax, ...
                xlabelstring, ylabelstring, 'head_angle', colors, plot_loc(2,:));            
          
% tail angle
ylabelstring = sprintf('%s\n%s','tail angle','(degrees)');
ymax = 160;
local_ymin = 140;
if(isempty(ymin))
    local_ymin = min_struct_array(BinData_array,'tail_angle')-max_struct_array(BinData_array,'tail_angle_err');
    ymax = max_struct_array(BinData_array,'tail_angle')+max_struct_array(BinData_array,'tail_angle_err');
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end
plot_attribute_BinData_array(fignum, BinData_array, stimulus, plot_rows, plot_columns, ...
                xmin, xmax, local_ymin, ymax, ...
                xlabelstring, ylabelstring, 'tail_angle', colors, plot_loc(3,:));            
           
% revSpeed            
ylabelstring = sprintf('%s\n%s','revSpeed', '(mm/sec)');
ymax = 0.25;
local_ymin = 0;
if(isempty(ymin))
    local_ymin = min_struct_array(BinData_array,'revSpeed')-max_struct_array(BinData_array,'revSpeed_err');
    ymax = max_struct_array(BinData_array,'revSpeed')+max_struct_array(BinData_array,'revSpeed_err');
    del = 10^round(log10((ymax-local_ymin)/5));
    local_ymin = custom_round(local_ymin, del);
    ymax = custom_round(ymax, del);
end
plot_attribute_BinData_array(fignum, BinData_array, stimulus, plot_rows, plot_columns, ...
                xmin, xmax, local_ymin, ymax, ...
                xlabelstring, ylabelstring, 'revSpeed', colors, plot_loc(4,:));
            
                     
orient landscape;
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
if(~isempty(prefix))
    save_figure(gcf, tempdir, temp_prefix, num2str(fignum),1);
    close(fignum);
else
    show_figure(fignum);
end
clear('h');

if(~isempty(prefix))
    pool_temp_pdfs([fignum_start fignum], localpath, prefix, temp_prefix);
end

return;
end