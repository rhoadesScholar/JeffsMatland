function chemotaxis_tracker_emily(MovieName, plate_type, FrameRate, track_flag)
% chemotaxis_tracker(MovieName, plate_type, FrameRate, track_flag)

if(nargin<1)
    disp('usage: chemotaxis_tracker(MovieName, plate_type, FrameRate, track_flag)')
    disp('FrameRate=3 by default')
    disp('MovieName can be ''blah.avi'' or {''blah.avi'',''pixelsize_scale_movie.avi''}')
    disp('plate_type can be ''square'', ''round'', ''other'', ''huge'', or ''ring'' if there is a copper ring }')
    return
end

close all;

if(nargin<4)
    track_flag = 1;
end

if(nargin<3)
    FrameRate = [];
end
if(isempty(FrameRate))
    FrameRate = 3;
end

if(nargin<2)
    plate_type = 'round'; % 'square'; 'huge'; 'round'
end

grid_steps=6;
huge_pixel_size = 0.050073; % from Steve Flavell's define_preferences.m

stimulus = [];
stimulusfile='';

numWorms=0; % code for automated counting of animals


global Prefs;
Prefs=[];
Prefs = define_preferences(Prefs);
Prefs.FrameRate = FrameRate;
Prefs = CalcPixelSizeDependencies(Prefs, Prefs.DefaultPixelSize);
Prefs.use_global_background_flag = 1; % use global background during tracking NP 4/15/15

% ... don't waste time looking for worms that are simply not there!
Prefs.aggressive_wormfind_flag = 0;

% timer box
% Prefs.timerbox_flag = 1; %'1' if there is time stamp, '0' if there is none.


% first file is the actual movie, second is the movie for getting the
% pixelsize
pixelsize_MovieName = '';
if(iscell(MovieName))
    x =  MovieName;
    clear('MovieName');
    if(length(x)>1)
        pixelsize_MovieName = x{2};
    end
    MovieName = x{1};
    clear('x');
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

background = calculate_background(MovieName);

FileName = sprintf('%s.procFrame.mat',FilePrefix);
procFrame_filename = sprintf('%s%s',PathName,FileName);

ringfile = sprintf('%s%s.Ring.mat',PathName,FilePrefix);
prefix = MovieName(1:(end-4));

if(does_this_file_need_making(ringfile))
    Ring.RingX = [];
    Ring.RingY = [];
    Ring.ComparisonArrayX = [];
    Ring.ComparisonArrayY = [];
    Ring.Area = 0;
    Ring.ring_mask = [];
    Ring.Level = eps;
    Ring.PixelSize = Prefs.DefaultPixelSize;
    Ring.FrameRate = Prefs.FrameRate; % default framerate
    Ring.NumWorms = [];
    Ring.DefaultThresh = [];
    Ring.meanWormSize = [];
    
    outer_edge =[0 0; 0 FileInfo.Width; FileInfo.Height FileInfo.Width; FileInfo.Height 0; 0 0];
    
    if(~isempty(pixelsize_MovieName))
        if(~isempty(regexpi(plate_type,'square')))
            [pixelsize, arena_verticies] = get_square_plate_pixelsize_arena_vertices_image(calculate_background(pixelsize_MovieName));
        else
            Ring = get_pixelsize_from_arbitrary_object(pixelsize_MovieName);
        end
        Ring.FrameRate = Prefs.FrameRate;
    else
        % square plate
        if(~isempty(regexpi(plate_type,'square')))
            answer(1)='N';
            while(answer(1)=='N')
                [pixelsize, arena_verticies] = get_square_plate_pixelsize_arena_vertices_image(background);
                [grid, gridlines_x, gridlines_y] = generate_grid_from_corners(arena_verticies, grid_steps);
                
                close all
                imshow(background);
                hold on;
                plot(gridlines_x, gridlines_y, '.b','markersize',1);
                plot(grid(:,1), grid(:,2), 'or');
                
                answer = questdlg('Grid OK?', ...
                    'Define grid' , ...
                    'Yes','No','Yes');
                close all;
                pause(1);   % pause to allow the GUI to catch up
            end
            close all;
            Ring.PixelSize = pixelsize;
            outer_edge = arena_verticies;
            Ring.ring_mask = uint8(poly2mask(outer_edge(:,1),outer_edge(:,2),FileInfo.Height,FileInfo.Width));
            
        end
        
        % round plate
        if(~isempty(regexpi(plate_type,'round')))
            [outer_edge, radius] = find_round_plate_edge(background);
            close all
            Ring.PixelSize = Prefs.circular_chemotaxis_plate_diameter/(radius*2);
            Ring.ring_mask = uint8(poly2mask(outer_edge(:,1),outer_edge(:,2),FileInfo.Height,FileInfo.Width));
        end
        
        if(~isempty(regexpi(plate_type,'other')))
            Ring = get_pixelsize_from_arbitrary_object(pixelsize_MovieName);
        end
        
        % huge plate -- use Steve's pixelsize
        % create dummy outer_edge
        if(~isempty(regexpi(plate_type,'huge')))
            Ring.PixelSize = huge_pixel_size;
        end
        
        if(~isempty(regexpi(plate_type,'ring')))
            scaleRing = get_pixelsize_from_arbitrary_object(pixelsize_MovieName);
            Ring = find_ring(background,PathName, FilePrefix, 1);
            Ring.PixelSize = scaleRing.PixelSize;
            save(ringfile, 'Ring');
        end
    end
    
    clear('outer_edge');
    Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
    
    % find the worms and set the default threshold
    [DefaultLevel, NumFoundWorms, mws, Ring] = default_worm_threshold_level(MovieName, background, procFrame, numWorms, Ring);
    disp([sprintf('Found %d worms with a threshold = [%f %d]',Ring.NumWorms, Ring.DefaultThresh(1), Ring.DefaultThresh(2))])
    
    save(ringfile, 'Ring');
end


chemotaxis_regions_file = sprintf('%s.chemotaxis_regions.mat',prefix);
if(does_this_file_need_making(chemotaxis_regions_file))
    fileinfo = moviefile_info(MovieName);
    
    [target_verticies, target_point, control_verticies, control_point] = select_odor_control_regions_chemotaxis(background);
    clear('Mov');
    save(chemotaxis_regions_file, 'target_verticies', 'target_point', 'control_verticies', 'control_point');
    close all
    pause(2);
else
    load(chemotaxis_regions_file);
end

if(track_flag == 0)
    close all;
    return;
end

linkedTracks_filename = sprintf('%s.linkedTracks.mat',prefix);

if(does_this_file_need_making(linkedTracks_filename))
    Tracker(MovieName);
    close all;
end
linkedTracks = load_Tracks(linkedTracks_filename);


% disp([sprintf('Calculating attributes vs angle and distance to target odor\t%s',timeString)])
% target_odor_linkedTracks = odor_info_to_Tracks(linkedTracks, target_point, target_verticies, control_verticies);
% save_Tracks(sprintf('%s.target_odor_linkedTracks.mat',prefix),target_odor_linkedTracks);

% target_odor_linkedTracks = values_to_track_custom_metric(target_odor_linkedTracks, 'odor_angle');
% BinData_odor_angle_target = attribute_vs_custom_metric(target_odor_linkedTracks, 'angle to target odor (deg)', 30);
% save_BinData(BinData_odor_angle_target, '', sprintf('%s.odor_angle_target',prefix));
% plot_data(BinData_odor_angle_target, [], [], '', sprintf('%s.odor_angle_target',prefix));
% close all;
% clear('BinData_odor_angle_target');

disp([sprintf('Calculating attributes vs angle and distance to target odor\t%s',timeString)])
target_odor_linkedTracks = odor_info_to_Tracks(linkedTracks, target_point, target_verticies, control_verticies);
save_Tracks(sprintf('%s.target_odor_linkedTracks.mat',prefix),target_odor_linkedTracks);

target_odor_linkedTracks = values_to_track_custom_metric(target_odor_linkedTracks, 'SmoothX');
BinData_odor_distance_target = attribute_vs_custom_metric(target_odor_linkedTracks, 'X coordinate (pixel)', 100);
save_BinData(BinData_odor_distance_target, '', sprintf('%s.xdistance_target',prefix));

plot_data(BinData_odor_distance_target, [], [], '', sprintf('%s.odor_xdistance_target',prefix));
close all;
clear('BinData_odor_distance_target');

% figure(1);
% chemotaxis_event_triggered_plots(target_odor_linkedTracks, 'lRevOmega');
% save_pdf(1, sprintf('%s.lRevOmega.trigger',prefix)); 
% close all;
% 
% figure(1);
% chemotaxis_event_triggered_plots(target_odor_linkedTracks, 'pure_upsilon');
% save_pdf(1, sprintf('%s.pure_upsilon.trigger',prefix)); 
% close all;


return;
end
