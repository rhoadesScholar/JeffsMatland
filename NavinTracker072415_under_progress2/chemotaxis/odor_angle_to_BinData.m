function odor_angle_to_BinData(MovieName, plate_type, FrameRate, numWorms, track_flag)
% odor_angle_to_BinData(MovieName, plate_type, FrameRate, numWorms, track_flag)

exclusion_zone_radius = 5; % exclude points within exclusion_zone_radius mm of target zone or point

if(nargin<1)
    disp('BinData = odor_angle_to_BinData(MovieName)')
    return;
end

if(nargin<3)
    FrameRate = [];
end

if(nargin<4)
    numWorms = 0;
end
if(nargin<2)
    plate_type = 'huge';
end
if(nargin<5)
    track_flag = 1;
end

if(isempty(FrameRate))
    FrameRate=3;
end

[pathstr, FilePrefix, ext] = fileparts(MovieName);
if(~strcmp(ext,'.avi')) % not an avi file ... 
    if(isdir(MovieName)) % is a directory
        avifiles = ls(sprintf('%s%s*.avi',MovieName, filesep));
        for(i = 1:length(avifiles(:,1)))
            filenames(i,:) = sprintf('%s%s%s',MovieName,filesep,avifiles(i,:));
        end
        clear('avifiles');
        avifiles = filenames; clear('filenames');
    else  % is a list of avi files
        file_ptr = fopen(MovieName,'rt');
        dummystringCellArray = textscan(file_ptr,'%s');
        avifiles = char(dummystringCellArray{1});
        fclose(file_ptr);
    end
    disp([sprintf('Please wait ... need user input for finding worms and defining chemotaxis regions\t%s',timeString)])
    for(i = 1:length(avifiles(:,1))) % find the background, target, ctrl regions
        localfile = sscanf(avifiles(i,:),'%s');
        localfile
        odor_angle_to_BinData(localfile, plate_type, numWorms, 0);
    end
    disp([sprintf('start tracking and analysis\t%s',timeString)])
    for(i = 1:length(avifiles(:,1))) % actual tracking
        localfile = sscanf(avifiles(i,:),'%s');
        localfile
        odor_angle_to_BinData(localfile, plate_type, numWorms);
    end
    return;
end

prefix = MovieName(1:(end-4));

chemotaxis_regions_file = sprintf('%s.chemotaxis_regions.mat',prefix);
if(does_this_file_need_making(chemotaxis_regions_file))
    fileinfo = moviefile_info(MovieName);
    Mov = aviread_to_gray(MovieName,fileinfo.NumFrames);
    [target_verticies, target_point, control_verticies, control_point] = select_odor_control_regions_chemotaxis(Mov.cdata);
    clear('Mov');
    save(chemotaxis_regions_file, 'target_verticies', 'target_point', 'control_verticies', 'control_point');
    close all
    pause(2);
else
    load(chemotaxis_regions_file);
end

linkedTracks_filename = sprintf('%s.linkedTracks.mat',prefix);
if(does_this_file_need_making(linkedTracks_filename))
    chemotaxis_tracker(MovieName, plate_type, FrameRate, numWorms, track_flag);
    close all;
end
if(track_flag==0)
    return;
end
linkedTracks = load_Tracks(linkedTracks_filename);

global Prefs; Prefs=[]; 
Prefs = define_preferences(Prefs); Prefs.FrameRate = linkedTracks(1).FrameRate;
Prefs = CalcPixelSizeDependencies(Prefs, linkedTracks(1).PixelSize);

exclusion_zone_radius = exclusion_zone_radius/linkedTracks(1).PixelSize;

target_exclusion_verticies = [];
control_exclusion_verticies = [];

if(length(target_verticies)>1)
    [radius, xc,yc] = circle_from_coords(target_verticies(:,1),target_verticies(:,2));
    [x,y] = coords_from_circle_params(exclusion_zone_radius+radius, [xc,yc]);
    target_exclusion_verticies = [x' y'];
end
if(length(control_verticies)>1)
    [radius, xc,yc] = circle_from_coords(control_verticies(:,1),control_verticies(:,2));
    [x,y] = coords_from_circle_params(exclusion_zone_radius+radius, [xc,yc]);
    control_exclusion_verticies = [x' y'];
end

Mov = aviread_to_gray(MovieName,1);
close all;
figure(1);
imshow(Mov.cdata);
hold on
if(~isempty(target_exclusion_verticies))
    plot(target_exclusion_verticies(:,1), target_exclusion_verticies(:,2), 'r');
end
if(~isempty(control_exclusion_verticies))
    plot(control_exclusion_verticies(:,1), control_exclusion_verticies(:,2),'b');
end
if(~isempty(target_verticies))
    plot(target_verticies(:,1), target_verticies(:,2), '*-r');
end
if(~isempty(control_verticies))
    plot(control_verticies(:,1), control_verticies(:,2),'*-b');
end
if(~isempty(target_point))
    plot(target_point(1), target_point(2), 'or');
end
if(~isempty(control_point))
    plot(control_point(1), control_point(2), 'ob');
end
pause(2);
save_pdf(1, sprintf('%s.chemotaxis_regions.pdf',prefix));
close all
pause(2);

% % chemotaxis index vs time
% disp([sprintf('Calculating chemotaxis index timecourse\t%s',timeString)])
% load(sprintf('%s.procFrame.mat',prefix));
% [CI, frames, num_target, num_control, total_numworms] = chemotaxis_timecourse_from_procFrame(procFrame, target_verticies, control_verticies);
% figure(1);
% plot(frames/Prefs.FrameRate, CI, 'o-');
% xlabel('Time (sec)'); ylabel('chemotaxis index');
% save_pdf(1, sprintf('%s.CI.pdf',prefix));
% clear('procFrame');


disp([sprintf('Calculating attributes vs angle to target odor\t%s',timeString)])
odor_angle_target_linkedTracks = odor_source_angle_to_custom_metric(linkedTracks, target_point, target_exclusion_verticies);
save_Tracks(sprintf('%s.odor_angle_target_linkedTracks.mat',prefix),odor_angle_target_linkedTracks);

BinData_odor_angle_target = attribute_vs_custom_metric(odor_angle_target_linkedTracks, 'angle to target odor (deg)', 30);
save_BinData(BinData_odor_angle_target, '', sprintf('%s.odor_angle_target',prefix));
plot_data(BinData_odor_angle_target, [], [], '', sprintf('%s.odor_angle_target',prefix));
close all;
clear('odor_angle_target_linkedTracks');

if(~isempty(control_point))
    disp([sprintf('Calculating attributes vs angle to control odor\t%s',timeString)])
    
    odor_angle_control_linkedTracks = odor_source_angle_to_custom_metric(linkedTracks, control_point, control_exclusion_verticies);
    save_Tracks(sprintf('%s.odor_angle_control_linkedTracks.mat',prefix),odor_angle_control_linkedTracks);
    
    BinData_odor_angle_control = attribute_vs_custom_metric(odor_angle_control_linkedTracks, 'angle to control odor (deg)', 30);
    save_BinData(BinData_odor_angle_control, '', sprintf('%s.odor_angle_control',prefix));
    plot_data(BinData_odor_angle_control, [], [], '', sprintf('%s.odor_angle_control',prefix));
    close all;
    clear('odor_angle_control_linkedTracks');
end

return;
end
