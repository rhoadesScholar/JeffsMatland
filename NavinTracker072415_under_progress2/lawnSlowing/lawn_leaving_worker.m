function lawn_leaving_worker(MovieName, lawn_diameter, framerate, timerbox_flag)

if(nargin==1)
    lawn_diameter=6;
    framerate=1; % 1 DEBUG
    timerbox_flag=1; % 1 DEBUG
end

global Prefs;
Prefs=[];
Prefs = define_preferences(Prefs);

Prefs.lawn_diameter = lawn_diameter;
Prefs.FrameRate = framerate;
Prefs.timerbox_flag = timerbox_flag;

[PathName, FilePrefix, ext] = fileparts(MovieName);
FileInfo = moviefile_info(MovieName);
FrameNum = FileInfo.NumFrames;

startframe = 1;
endframe = FrameNum;

% DEBUG
if FrameNum < 3500
    startframe = 1;
    endframe = 1800;
else
    if FrameNum < 5300
        startframe = 1801;
        endframe = 3600;
    else
        startframe = 3601;
        endframe = 5400;
    end
end

if(~isempty(PathName))
    PathName = sprintf('%s%s',PathName,filesep);
end

lawnedge_filename = sprintf('%s%s.lawn_edge.mat',PathName, FilePrefix);
outeredge_filename = sprintf('%s%s.outer_edge.mat',PathName, FilePrefix);
linkedTracks_filename = sprintf('%s%s.linkedTracks.mat',PathName, FilePrefix);
lawnTracks_filename = sprintf('%s%s.lawnTracks.mat',PathName, FilePrefix);
working_filename = sprintf('%s%s.working',PathName, FilePrefix);

if(file_existence(working_filename))
    disp([sprintf('%s exists, someone else is working on it',working_filename)])
    return;
end

if(~does_this_file_need_making(lawnTracks_filename,Prefs.track_analysis_date) && file_existence(lawnedge_filename) && file_existence(outeredge_filename))
    disp([sprintf('%s exists, no need to remake',lawnTracks_filename)])
    return;
end

fp = fopen(working_filename,'w'); fclose(fp);

disp([sprintf('Getting background for %s',MovieName)])
background = calculate_background(MovieName,startframe,endframe);
    
if(~file_existence(outeredge_filename))
    disp([sprintf('Find outer edge ring for %s',MovieName)])
    outer_edge = find_drawn_lawn_edge(background);
    save(outeredge_filename, 'outer_edge');
else
    disp([sprintf('Load outer edge ring from %s',outeredge_filename)])
    load(outeredge_filename);
end
    
if(~file_existence(linkedTracks_filename) || ~file_existence(lawnedge_filename))
    
    
    Prefs.PixelSize = calc_pixelsize_from_lawn_edge(outer_edge, Prefs.lawn_diameter);
    
    Prefs = CalcPixelSizeDependencies(Prefs, Prefs.PixelSize);
    
    disp([sprintf('Tracking \t%s',timeString())])
    
    
    rawTracks = Tracker(PathName, FilePrefix,'','none', [startframe endframe]);
    close all;
    
    if(isempty(rawTracks))
       rm(working_filename);
       return; 
    end
    
    % re-adjust lawn-edge circle based on the tracks
    if(~file_existence(lawnedge_filename))
%         disp([sprintf('re-adjust lawn edge\t%s',timeString())])
%         lawn_edge = adjust_lawn_location(rawTracks, outer_edge);
%         
        lawn_edge = outer_edge_check(background, lawn_edge); % DEBUG
        
        
        save(lawnedge_filename, 'lawn_edge');
        
        
        % save the lawn and outer_edge as a pdf
        hidden_figure(20);
        im = background - 2*uint8(calc_pixel_occupancy(rawTracks));
        imshow(im);
        hold on;
        %     for(i=1:length(rawTracks))
        %         plot(rawTracks(i).Path(:,1)',rawTracks(i).Path(:,2)',':b','linewidth',0.1);
        %     end
        plot(outer_edge(:,2),outer_edge(:,1),'g');
        plot(lawn_edge(:,2),lawn_edge(:,1),'r');
        dummystring = fix_title_string(sprintf('%s.avi %f pixel/mm',FilePrefix, 1/Prefs.PixelSize));
        title(dummystring);
        dummystring = sprintf('%s.lawn_edge',FilePrefix);
        save_figure(20, PathName, dummystring);
    else
        disp([sprintf('load lawn edge\t%s',timeString())])
        load(lawnedge_filename);
    end
    
    close all;
    clear('rawTracks');
    clear('background');
else
    load(lawnedge_filename);
end


dummystring = sprintf('%s%s.Tracks.mat',PathName, FilePrefix);
load(dummystring);
Tracks = lawn_edge_to_stimulus_vector(Tracks, lawn_edge);
save_Tracks(dummystring, Tracks);
clear('Tracks');

load(linkedTracks_filename);
linkedTracks = lawn_edge_to_stimulus_vector(linkedTracks, lawn_edge);
save_Tracks(linkedTracks_filename, linkedTracks);

lawnTracks = linkedTracks;
save_Tracks(lawnTracks_filename, lawnTracks);

clear('linkedTracks');

Prefs.psth_pre_stim_period = 20;
Prefs.psth_post_stim_period = 20;

[on_psth_Tracks, on_psth_BinData, off_psth_Tracks, off_psth_BinData] = stimulus_on_off_plots(lawnTracks, 'path', PathName, 'prefix',FilePrefix, Prefs.LawnCode);

close all;
plot_stim_on_off_data(on_psth_BinData, on_psth_Tracks, off_psth_BinData, off_psth_Tracks, Prefs.LawnCode, PathName, FilePrefix);

clear('lawnTracks');

rm(working_filename);
return;
end
