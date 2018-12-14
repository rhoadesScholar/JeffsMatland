function track_drop_movie(MovieName, stimulusfile)

if(nargin<2)
    stimulusfile='';
end
stimulus = [];
if(~isempty(stimulusfile))
    stimulus = load_stimfile(stimulusfile);
    if(~isempty(stimulus))
        v=1;
        while(v<=length(stimulus(:,1)))
            if(abs(stimulus(v,1)-stimulus(v,2))<1e-4)
                stimulus(v,:)=[];
            else
                v=v+1;
            end
        end
    end
end

global Prefs;
Prefs=[];
Prefs = define_preferences(Prefs);
Prefs.swim_flag = 1;

Prefs.FreqBinSize = 1;

% for worms in drops
% Prefs.OmegaEccThresh = 0.75;
Prefs.MinOmegaDuration = Prefs.MinOmegaDuration/4;

Prefs.graph_no_stim_width = 1;
% Prefs.body_contour_flag = 0;

Prefs = CalcPixelSizeDependencies(Prefs, Prefs.DefaultPixelSize);

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

% [drop_x, drop_y, strain_names] = get_drop_centers(MovieName, PathName, FilePrefix);

FileInfo = moviefile_info(MovieName);
startFrame = 1;
endFrame = FileInfo.NumFrames;

    disp([sprintf('calculating background\t%s',timeString())])
    background = calculate_background(MovieName);
    
    ds = sprintf('%s%s.Ring.mat',PathName,FilePrefix);
    if(does_this_file_need_making(ds))
        Ring = find_square_ring_manually(background);
        save(ds, 'Ring');
    else
        Ring = find_ring(background, PathName, FilePrefix);
    end
    Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);

procFrame = [];
FileName = sprintf('%s.procFrame.mat',FilePrefix);
dummystring = sprintf('%s%s',PathName,FileName);
if(does_this_file_need_making(dummystring))
    q=1;
    for(i=startFrame:endFrame)
        procFrame(q).frame_number = i;
        procFrame(q).bkgnd_index = 1; % all frames use the same background unless otherwise specified
        q=q+1;
    end
    disp([sprintf('adjusting local object detection level\t%s',timeString())])
    [DefaultLevel, NumFoundWorms, mws, Ring] = default_worm_threshold_level(MovieName, background, procFrame, 0, Ring);
    disp([sprintf('Found %d wormdrops with a threshold = [%f %d]',NumFoundWorms,DefaultLevel(1), DefaultLevel(2))])
    ds = sprintf('%s%s.Ring.mat',PathName,FilePrefix);
    save(ds, 'Ring');
    disp([sprintf('%s saved %s\n', ds, timeString())])
    
    procFrame = process_movie_frames(MovieName, background, Ring, procFrame);
    save_procFrame(dummystring, procFrame);
    disp([sprintf('%s saved %s\n', dummystring, timeString())])
    
    clear('background');
else
    
    if(does_this_file_need_making(sprintf('%s%s.rawTracks.mat',PathName,FilePrefix)) || ...
            does_this_file_need_making(sprintf('%s%s.Tracks.mat',PathName,FilePrefix)) || ...
            does_this_file_need_making(sprintf('%s%s.linkedTracks.mat',PathName,FilePrefix)) || ...
            does_this_file_need_making(sprintf('%s%s.collapseTracks.mat',PathName,FilePrefix)) || ...
            does_this_file_need_making(sprintf('%s%s.BinData.mat',PathName,FilePrefix)) )
        
        load(dummystring);
    end
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
    analyse_rawTracks(rawTracks, stimulusfile, PathName, FilePrefix, 0);
end


BinData = alternate_binwidth_BinData(load_BinData(sprintf('%s.BinData.mat',FilePrefix)),2,2);
collapseTracks = load_Tracks(sprintf('%s.collapseTracks.mat',FilePrefix));
xmin = min(min(BinData.time), min_struct_array(collapseTracks,'Time'));
xmax = max(max(BinData.time), max_struct_array(collapseTracks,'Time'));

plot_attribute(BinData, stimulus, 5, 2, ...
        xmin, xmax, 0.75, 0.975, ...
        'time (sec)', fix_title_string('eccentricity'), 'uncorr_ecc', 'k', [1 3 5 7 9] );
plot_freq_frac(BinData, collapseTracks, stimulus, 5, 2, ...
    xmin, xmax, ...
    'time (sec)', 'liquid_omega', 'r', [2 4 6 8 10]);



return;
end

% 
% dummystring = sprintf('%s%s.dropTracks.mat',PathName, FilePrefix);
% if(file_existence(dummystring)==0)
%     ds = sprintf('%s%s.Tracks.mat',PathName, FilePrefix);
%     load(ds);
%     disp([sprintf('assigning tracks to drops\t%s',timeString())])
%     dropTracks = Tracks_to_dropTracks(Tracks, strain_names, drop_x, drop_y);
%     disp([sprintf('saving %s\t%s',dummystring,timeString())])
%     save(dummystring, 'dropTracks');
% else
%     load(dummystring);
% end
% 
% for(i=1:length(dropTracks))
%     FilePrefix = sprintf('%s.%d',dropTracks(i).Name, i);
%     localpath = sprintf('%s%s%s',PathName,dropTracks(i).Name,filesep);
%     mkdir(localpath);
%     
%     BinData = bin_and_average_all_tracks(dropTracks(i).linkedTracks);
%     
%     BodyBends.time = BinData.time;
%     BodyBends.liquid_omega_freqtime = BinData.freqtime;
%     BodyBends.mean_body_bends_per_sec = BinData.body_bends_per_sec;
%     BodyBends.liquid_omega_freq = BinData.liquid_omega_freq;
%     BodyBends = make_single(BodyBends);
%     
%     FileName = sprintf('%s.BodyBends.mat',FilePrefix);
%     dummystring = sprintf('%s%s',localpath,FileName);
%     save(dummystring,'BodyBends');
%     
%     fignum=1;
%     
%     figure(fignum);
%     plot_rows = 6; plot_columns=2;
%     plot_loc = [1 3 5 7 9; 2 4 0 0 0; 6 8 0 0 0; 10 12 0 0 0];
%     xmin = min(min(BinData.time), min_struct_array(dropTracks(1).linkedTracks,'Time'));
%     xmax = max(max(BinData.time), max_struct_array(dropTracks(1).linkedTracks,'Time'));
%     
%     % liquid_omega
%     plot_freq_frac(BinData, dropTracks(i).linkedTracks, stimulus, plot_rows, plot_columns, ...
%         xmin, xmax, ...
%         'time (sec)', 'liquid_omega', 'r', plot_loc(1,:));
%     
%     % body_bends_per_sec
%     ylabelstring = sprintf('%s\n%s','body_bends', '(/sec)');
%     local_ymin = 0;
%     ymax = 3;
%     ymax = custom_round(max(ymax, max(BinData.body_bends_per_sec)), 0.25);
%     ymax = ymax(1);
%     plot_attribute(BinData, stimulus, plot_rows, plot_columns, ...
%         xmin, xmax, local_ymin, ymax, ...
%         'time (sec)', ylabelstring, 'body_bends_per_sec', 'b', plot_loc(2,:));
%     
%     
%     orient landscape;
%     h = axes('Position',[0 0 1 1],'Visible','off');
%     set(gcf,'CurrentAxes',h);
%     text(0.5,0.95,fix_title_string(sprintf('%s%s.BodyBends',localpath,FilePrefix)),'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');
%     set(gcf,'renderer','painters');
%     
%     save_pdf(fignum, sprintf('%s%s.BodyBends.pdf',localpath, FilePrefix));
%     
%     
%     close(fignum);
%     
% end
% 
% % plot_data(BinData, dropTracks(1).linkedTracks, [], PathName, FilePrefix);
% 
% % N2_tracks = [dropTracks(1).linkedTracks(1:end) dropTracks(2).linkedTracks(1:end) dropTracks(3).linkedTracks(1:end)];
% % tdc1_tracks = [dropTracks(4).linkedTracks(1:end) dropTracks(5).linkedTracks(1:end) dropTracks(6).linkedTracks(1:end)];
% % tph1_tracks = [dropTracks(7).linkedTracks(1:end) dropTracks(8).linkedTracks(1:end) dropTracks(9).linkedTracks(1:end)];
% % dat1_tracks = [dropTracks(10).linkedTracks(1:end) dropTracks(11).linkedTracks(1:end) dropTracks(12).linkedTracks(1:end)];
% 
% % psth_plot(N2_tracks, 'path', '', 'prefix','N2',[0 stimulus(1,3)]);
% % psth_plot(tdc1_tracks, 'path', '', 'prefix','tdc1',[0 stimulus(1,3)]);
% % psth_plot(tph1_tracks, 'path', '', 'prefix','tph1',[0 stimulus(1,3)]);
% % psth_plot(dat1_tracks, 'path', '', 'prefix','dat1',[0 stimulus(1,3)]);


% return;
% end
