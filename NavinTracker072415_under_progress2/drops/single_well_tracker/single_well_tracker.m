function single_well_tracker(MovieName, numWorms)

stimulus = [];
stimulusfile='';

if(nargin<2)
    numWorms=0;
end

global Prefs;
Prefs=[];
Prefs = define_preferences(Prefs);
Prefs = define_swim_preferences(Prefs);
close all;

if(nargin == 0) % running in interactive mode... no arguments given.... ask the user for the MovieName
    [inputMovieName, PathName] = uigetfile('*.avi', 'Select AVI Movie For Analysis');
    if(isempty(inputMovieName))
        errordlg('No movie was selected for analysis');
        return;
    end
    Prefs.PlotFrameRate = Prefs.PlotFrameRateInteractive;    % 100 Display tracking on screen every PlotFrameRate frames
    Prefs.PlotDataRate = Prefs.PlotDataRateInteractive;      % 10 print data to matlab window every PlotDataRate frames
    
    MovieName = sprintf('%s%s%s',PathName,filesep,inputMovieName);
end

[PathName, FilePrefix] = fileparts(MovieName);
if(~isempty(PathName))
    PathName = sprintf('%s%s',PathName, filesep);
else
    PathName = '';
end

if(file_existence(MovieName)==0)
    disp(sprintf('Cannot find or open file %s in current directory %s\t%s',MovieName, pwd, timeString));
    return;
end

FileInfo = moviefile_info(MovieName);
startFrame = 1;
endFrame = FileInfo.NumFrames;

procFrame = [];
q=1;
for(i=startFrame:endFrame)
    procFrame(q).frame_number = i;
    procFrame(q).bkgnd_index = 1; % all frames use the same background unless otherwise specified
    q=q+1;
end
    
FileName = sprintf('%s.procFrame.mat',FilePrefix);
procFrame_filename = sprintf('%s%s',PathName,FileName);

ringfile = sprintf('%s%s.Ring.mat',PathName,FilePrefix);

if(does_this_file_need_making(ringfile))
    Ring.RingX = []; 
    Ring.RingY = [];
    Ring.ComparisonArrayX = [];
    Ring.ComparisonArrayY = [];
    Ring.Area = 0;
    Ring.Level = eps;
    Ring.PixelSize = Prefs.DefaultPixelSize;
    
    disp([sprintf('calculating background\t%s',timeString())])
    background = calculate_background(MovieName);
    
    disp('pick well perimeter points, then double-click');
    [outer_edge, radius] = outer_edge_check(background);
    close all
    Ring.PixelSize = Prefs.well_width/(radius*2);
    Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
    
    BW = poly2mask(outer_edge(:,1),outer_edge(:,2),FileInfo.Height,FileInfo.Width);
    background = background.*uint8(BW);
    
    bkgnd_filename = sprintf('%s%s.%d.%d.background.mat',PathName, FilePrefix, startFrame, endFrame);
    bkgnd = background;
    save(bkgnd_filename, 'bkgnd');
    clear('bkgnd');
    
    if(numWorms == 0)
        disp('pick worms, then press enter');
        Mov = aviread_to_gray(MovieName, round(FileInfo.NumFrames/2));
        imshow(Mov.cdata.*uint8(BW));
        [x, y] = ginput2('*g');
        numWorms = length(x);
        clear('Mov'); clear('x'); clear('y');
    end
    
    clear('BW'); clear('outer_edge');
    close all
    
    disp([sprintf('adjusting local object detection level\t%s',timeString())])
    [DefaultLevel, NumFoundWorms] = default_worm_threshold_level(MovieName, background, procFrame, numWorms);
    [DefaultLevel, NumFoundWorms, mws, Ring] = default_worm_threshold_level(MovieName, background, procFrame, NumFoundWorms, Ring);
    save(ringfile,'Ring');
    
    disp([sprintf('Found %d worms with a threshold = [%f %d]',NumFoundWorms,DefaultLevel(1), DefaultLevel(2))])
    
end

load(ringfile);
Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);


if(does_this_file_need_making(procFrame_filename))
    background = calculate_background(MovieName);
    procFrame = process_movie_frames(MovieName, background, Ring, procFrame);
    save_procFrame(procFrame_filename, procFrame);
    disp([sprintf('%s saved %s\n', procFrame_filename, timeString())])
else
    load(procFrame_filename);
end


if(~isempty(procFrame))
    rm(sprintf('%s%s.rawTracks.mat',PathName,FilePrefix));
    rm(sprintf('%s%s.Tracks.mat',PathName,FilePrefix));
    rm(sprintf('%s%s.linkedTracks.mat',PathName,FilePrefix));
    rm(sprintf('%s%s.collapseTracks.mat',PathName,FilePrefix));
    rm(sprintf('%s%s.BinData.mat',PathName,FilePrefix));
    
    disp(sprintf('assigning animals to tracks\t%s',timeString()))
    rawTracks = create_tracks(procFrame, FileInfo.Height, FileInfo.Width, Ring.PixelSize, Prefs.FrameRate, MovieName);
    
    FileName = sprintf('%s.rawTracks.mat',FilePrefix);
    dummystring = sprintf('%s%s',PathName,FileName);
    save_Tracks(dummystring, rawTracks);
    disp([sprintf('%s saved %s\n', dummystring, timeString())])
    
    clear('procFrame');
    analyse_rawTracks(rawTracks, stimulusfile, PathName, FilePrefix,0);
end

dummystring = sprintf('%s%s.collapseTracks.mat',PathName, FilePrefix);
load(dummystring);

fignum=1;
figure(fignum);


%
%
% body_bends_time = min_struct_array(collapseTracks,'Time'):1/Prefs.FrameRate:max_struct_array(collapseTracks,'Time'); % nanmean(Track_field_to_matrix(collapseTracks,'Time'));
%
% subplot(length(collapseTracks)+2,1,1);
% liquid_omega_init_freq =  nanmean(find_Track_to_matrix(collapseTracks,'mvt_init','==num_state_convert(''liquid_omega'')'))/(1/Prefs.FrameRate);
%
% liquid_omega_freqtime = (body_bends_time(1)+Prefs.FreqBinSize)/2:Prefs.FreqBinSize:body_bends_time(end);
% liquid_omega_freq = [];
% for(t=1:length(liquid_omega_freqtime)-1)
%     idx = find(body_bends_time >= liquid_omega_freqtime(t) & body_bends_time < liquid_omega_freqtime(t+1));
%     liquid_omega_freq(t) = nanmean(liquid_omega_init_freq(idx));
% end
% liquid_omega_freq(length(liquid_omega_freqtime)) = NaN;
%
% plot(liquid_omega_freqtime, liquid_omega_freq,'.-r');
% xlabel('Time (sec)');
% ylabel('omega freq (/sec)');
% xlim([body_bends_time(1) body_bends_time(end)]);
%
% subplot(length(collapseTracks)+2,1,2);
% mean_body_bends_per_sec = nanmean(Track_field_to_matrix(collapseTracks,'body_bends_per_sec'));
% plot(body_bends_time, mean_body_bends_per_sec);
% xlabel('Time (sec)');
% ylabel('mean Body bends (/sec)');
% xlim([body_bends_time(1) body_bends_time(end)]);
% ylim([0 6]);
% for(i=1:length(collapseTracks))
%     subplot(length(collapseTracks)+2,1,i+2);
%     plot(collapseTracks(i).Time, collapseTracks(i).body_bends_per_sec);
%     hold on
%     omega_init_idx = find(abs(collapseTracks(i).mvt_init-num_state_convert('liquid_omega'))<=1e-4);
%     omega_init_vector = zeros(1,length(collapseTracks(i).mvt_init)); omega_init_vector(omega_init_idx)=1;
%     plot(collapseTracks(i).Time(omega_init_idx), omega_init_vector(omega_init_idx)*(max(collapseTracks(i).body_bends_per_sec)),'*r','markersize',10);
%     title(sprintf('Track %d',i));
%     xlabel('Time (sec)');
%     ylabel('Body bends (/sec)');
%     xlim([body_bends_time(1) body_bends_time(end)]);
% end
%
% BodyBends.time = body_bends_time;
% BodyBends.liquid_omega_freqtime = liquid_omega_freqtime;
% BodyBends.mean_body_bends_per_sec = mean_body_bends_per_sec;
% BodyBends.liquid_omega_freq = liquid_omega_freq;
% BodyBends = make_single(BodyBends);
%
%


dummystring = sprintf('%s%s.BinData.mat',PathName, FilePrefix);
load(dummystring);

% BinData is in /min but for liquid omegas, per second is better
BinData.liquid_omega_freq = BinData.liquid_omega_freq/60;
BinData.liquid_omega_freq_s = BinData.liquid_omega_freq_s/60;
BinData.liquid_omega_freq_err = BinData.liquid_omega_freq_err/60;

BodyBends.time = BinData.time;

BodyBends.mean_body_bends_per_sec = BinData.body_bends_per_sec;
BodyBends.mean_body_bends_per_sec_s = BinData.body_bends_per_sec_s;
BodyBends.mean_body_bends_per_sec_err = BinData.body_bends_per_sec_err;

BodyBends.liquid_omega_freq = BinData.liquid_omega_freq;
BodyBends.liquid_omega_freq_s = BinData.liquid_omega_freq_s;
BodyBends.liquid_omega_freq_err = BinData.liquid_omega_freq_err;

BodyBends.n = BinData.n;
BodyBends = make_single(BodyBends);

plot_rows = 6; plot_columns=2;
plot_loc = [1 3 5 7 9; 2 4 0 0 0]; n_plot_loc = 11;
xmin = min(min(BinData.time), min_struct_array(collapseTracks,'Time'));
xmax = max(max(BinData.time), max_struct_array(collapseTracks,'Time'));

% liquid_omega
plot_freq_frac(BinData, collapseTracks, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, ...
    'time (sec)', 'liquid_omega', 'r', plot_loc(1,:));
subplot(plot_rows, plot_columns, 3);
ylabel(fix_title_string(sprintf('%s\n%s','liquid omega freq','(/sec)')));
ymax = 0.5;
ymax = max(ymax, ( max(BinData.liquid_omega_freq) + nanmean( BinData.liquid_omega_freq_err) ) );
ymax = ymax(1);
ymax = custom_round(ymax, 0.25,'ceil');
ylim([0 ymax]);

% body_bends_per_sec
ylabelstring = sprintf('%s\n%s','body_bends', '(/sec)');
local_ymin = 0;
ymax = 3;
ymax = max(ymax, ( max(BinData.body_bends_per_sec)+ nanmean(BinData.body_bends_per_sec_err) ) );
ymax = ymax(1);
ymax = custom_round(ymax, 0.25, 'ceil');
plot_attribute(BinData, stimulus, plot_rows, plot_columns, ...
    xmin, xmax, local_ymin, ymax, ...
    'time (sec)', ylabelstring, 'body_bends_per_sec', 'b', plot_loc(2,:));


% num animals
ylabelstring = sprintf('%s\n%s','num','animals');
ymax = max(BinData.n)+0.1*max(BinData.n);
local_ymin = 0;
errorshade_stimshade_lineplot_BinData(BinData, stimulus, plot_rows, plot_columns, n_plot_loc, ...
    [xmin xmax local_ymin ymax], ...
    'n', 'k', ...
    'time (sec)', ylabelstring);


FileName = sprintf('%s.BodyBends.mat',FilePrefix);
dummystring = sprintf('%s%s',PathName,FileName);
save(dummystring,'BodyBends');

orient landscape;
h = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',h);
text(0.5,0.95,fix_title_string(sprintf('%s%s.BodyBends',PathName,FilePrefix)),'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
set(gcf,'renderer','painters');
dummystring = sprintf('%s%s.BodyBends.pdf',PathName,FilePrefix);
save_pdf(fignum,dummystring);

% remove files not needed for single well tracking
rm(sprintf('%s%s.rawTracks.mat',PathName,FilePrefix));
rm(sprintf('%s%s.Tracks.mat',PathName,FilePrefix));
%    rm(sprintf('%s%s.linkedTracks.mat',PathName,FilePrefix));
rm(sprintf('%s%s.collapseTracks.mat',PathName,FilePrefix));
rm(sprintf('%s%s.BinData.mat',PathName,FilePrefix));
rm(sprintf('%s%s.freqs.txt',PathName,FilePrefix));
rm(sprintf('%s%s.non_freqs.txt',PathName,FilePrefix));

return;
end
