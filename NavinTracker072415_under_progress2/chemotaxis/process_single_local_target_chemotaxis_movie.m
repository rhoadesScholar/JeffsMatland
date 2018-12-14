function process_single_local_target_chemotaxis_movie(MovieName, pixelsize_MovieName, framerate)
% process_single_local_target_chemotaxis_movie(MovieName, ctrl_MovieName, framerate)
% pixelsize_MovieName has object for calibrating pixelsize (default = MovieName)
% square plate grids are 13x13mm
% framerate = 3 (default)

if(nargin==0)
    disp('usage: process_single_local_target_chemotaxis_movie(MovieName, pixelsize_MovieName, framerate)')
    return; 
end

global Prefs;
Prefs = define_preferences(Prefs);

% since we are localized to a small section, worms will go in and out of
% view ... don't waste time looking for worms that are simply not there!
Prefs.aggressive_wormfind_flag = 0; 

if(nargin<2)
    pixelsize_MovieName = MovieName;
end

if(nargin<3)
    framerate=3;
end
Prefs.FrameRate = framerate;

[PathName, FilePrefix] = fileparts(MovieName);
if(~isempty(PathName))
    PathName = sprintf('%s%s',PathName, filesep);
else
    PathName = '';
end
ringfile = sprintf('%s%s.Ring.mat',PathName,FilePrefix);
Ring = get_pixelsize_from_arbitrary_object(pixelsize_MovieName);
Ring.FrameRate = Prefs.FrameRate;
save(ringfile, 'Ring');

Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);


prefix = MovieName(1:(end-4));

chemotaxis_regions_file = sprintf('%s.chemotaxis_regions.mat',prefix);
if(does_this_file_need_making(chemotaxis_regions_file))
    Mov = aviread_to_gray(MovieName,1);
    [target_verticies, target_point] = select_odor_control_regions_chemotaxis(Mov.cdata);
    clear('Mov');
    save(chemotaxis_regions_file, 'target_point');
    close all
    pause(2);
else
    load(chemotaxis_regions_file);
end

linkedTracks_filename = sprintf('%s.linkedTracks.mat',prefix);
if(does_this_file_need_making(linkedTracks_filename))
    Tracker(MovieName);
    close all;
end

linkedTracks = load_Tracks(linkedTracks_filename);


disp([sprintf('Calculating attributes vs angle to target odor\t%s',timeString)])
odor_angle_target_linkedTracks = odor_source_angle_to_custom_metric(linkedTracks, target_point);
save_Tracks(sprintf('%s.odor_angle_target_linkedTracks.mat',prefix),odor_angle_target_linkedTracks);
BinData_odor_angle_target = attribute_vs_custom_metric(odor_angle_target_linkedTracks, 'angle to target odor (deg)', 30);
save_BinData(BinData_odor_angle_target, '', sprintf('%s.odor_angle_target',prefix));
plot_data(BinData_odor_angle_target, [], [], '', sprintf('%s.odor_angle_target',prefix));
close all;
clear('odor_angle_target_linkedTracks');
clear('BinData_odor_angle_target');

disp([sprintf('Calculating attributes vs distance to target odor\t%s',timeString)])
odor_distance_target_linkedTracks = odor_source_distance_to_custom_metric(linkedTracks, target_point);
save_Tracks(sprintf('%s.odor_distance_target_linkedTracks.mat',prefix),odor_distance_target_linkedTracks);
BinData_odor_distance_target = attribute_vs_custom_metric(odor_distance_target_linkedTracks, 'distance to target odor (mm)', 5);
save_BinData(BinData_odor_distance_target, '', sprintf('%s.odor_distance_target',prefix));
plot_data(BinData_odor_distance_target, [], [], '', sprintf('%s.odor_distance_target',prefix));
close all;
clear('odor_distance_target_linkedTracks');
clear('BinData_odor_distance_target');

return;
end