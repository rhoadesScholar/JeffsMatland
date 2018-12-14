function single_well_tracker_master(directoryListFilename, varargin)
% single_well_tracker_master(directoryListFilename, [''numworms'']'])


rehash path; % refreshes the m-files

global Prefs;
Prefs = [];
Prefs = define_preferences(Prefs);
Prefs = define_swim_preferences(Prefs);


if(nargin==0)
    disp(['Usage: single_well_tracker_master(directoryListFilename, [''numworms'']'])
    return
end

target_numworms = 0;
i=1;
while(i<=length(varargin))
    
    if(strcmpi(varargin{i},'numworms')==1)
        i=i+1;
        target_numworms = varargin{i};
        i=i+1;
        sprintf('Error in single_well_tracker_master: Do not recognize %s',char(varargin{i}))
        return
    end
end

file_ptr = fopen(directoryListFilename,'rt');

if(file_ptr == -1) % directoryListFilename is not an actual file, but is a directory
    
    file_ptr = fopen('temp','w');
    fprintf(file_ptr,'%s\n',directoryListFilename);
    fclose(file_ptr);
    
    file_ptr = fopen('temp','rt');
    dummystringCellArray = textscan(file_ptr,'%s');
    fclose(file_ptr);
    delete('temp');
else % is a file
    
    [pathstr, FilePrefix, ext] = fileparts(directoryListFilename);
    
    if(strcmp(ext,'.avi')==1) % is a single avi file
        fclose(file_ptr);
        
        if(~isempty(pathstr))
            fps = sprintf('%s%s%s',pathstr,filesep,FilePrefix);
        else
            fps = FilePrefix;
        end
        
        single_well_tracker(directoryListFilename, target_numworms);
        
        return;
    else % is a bona fide directory list file
        dummystringCellArray = textscan(file_ptr,'%s');
        fclose(file_ptr);
    end
end

directoryList = char(dummystringCellArray{1});


% make background and find rings for all the movies
disp(['Automatically calculating background for all the movies in the directory'])
global_background = [];
for i = 1:length(directoryList(:,1))
    directoryList(i,:) = filesep_convert(directoryList(i,:));
    PathName = deblank(directoryList(i,:));
    
    if(strcmp(PathName,'')==0)
        localpath = PathName;
        if(localpath(end)~=filesep)
            localpath = sprintf('%s%s',PathName, filesep);
        end
    else
        localpath = '';
    end
    dummystring = sprintf('%s%s*.avi',PathName,filesep);
    movieList = dir(dummystring);
    
    for j=1:length(movieList)
        [pathstr, FilePrefix, ext] = fileparts(movieList(j).name);
        
        MovieName = sprintf('%s%s%s.avi',PathName, filesep, FilePrefix);
        FileInfo = moviefile_info(MovieName);
        startFrame = 1;
        endFrame = FileInfo.NumFrames;
        
        if(isempty(global_background))
            global_background = zeros(FileInfo.Height,FileInfo.Width,'uint8');
        else
            if(size(global_background)~=[FileInfo.Height,FileInfo.Width])
               error(sprintf('%s dimensions %d x %d are not the same dimensions as the other movies %d x %d',MovieName,FileInfo.Height,FileInfo.Width, size(global_background,1), size(global_background,2)))
            end
        end
        background = calculate_background(MovieName);
        global_background = global_background + background;
        clear('background');
    end
    
    global_background = global_background/j;
end
globalRing.RingX = []; 
globalRing.RingY = [];
globalRing.ComparisonArrayX = [];
globalRing.ComparisonArrayY = [];
globalRing.Area = 0;
globalRing.Level = eps;
globalRing.PixelSize = Prefs.DefaultPixelSize;

disp('pick well perimeter points, then double-click');
[outer_edge, radius] = outer_edge_check(global_background);
clear('outer_edge');
close all
globalRing.PixelSize = Prefs.well_width/(radius*2);
Prefs = CalcPixelSizeDependencies(Prefs, globalRing.PixelSize);

BW = uint8(poly2mask(outer_edge(:,1),outer_edge(:,2),FileInfo.Height,FileInfo.Width));
clear('global_background');

numWorms = sscanf(char(inputdlg('Average number of worms per well?')),'%d');
            
for i = 1:length(directoryList(:,1))
    directoryList(i,:) = filesep_convert(directoryList(i,:));
    PathName = deblank(directoryList(i,:));
    
    if(strcmp(PathName,'')==0)
        localpath = PathName;
        if(localpath(end)~=filesep)
            localpath = sprintf('%s%s',PathName, filesep);
        end
    else
        localpath = '';
    end
    dummystring = sprintf('%s%s*.avi',PathName,filesep);
    movieList = dir(dummystring);
    
    for j=1:length(movieList)
        [pathstr, FilePrefix, ext] = fileparts(movieList(j).name);
        
        MovieName = sprintf('%s%s%s.avi',PathName, filesep, FilePrefix);
        FileInfo = moviefile_info(MovieName);
        startFrame = 1;
        endFrame = FileInfo.NumFrames;

        disp([sprintf('%s%s%s.avi\t%s',PathName, filesep, FilePrefix, timeString())])
        
        ringfile = sprintf('%s%s%s.Ring.mat',PathName, filesep, FilePrefix);
        if(does_this_file_need_making(ringfile))
            Ring = globalRing;
            
            disp([sprintf('calculating background\t%s',timeString())])
            background = calculate_background(MovieName);
            background = background.*BW;
            
            bkgnd_filename = sprintf('%s%s%s.%d.%d.background.mat',PathName, filesep, FilePrefix, startFrame, endFrame);
            bkgnd = background;
            save(bkgnd_filename, 'bkgnd');
            clear('bkgnd');
            
            close all
            
            procFrame = [];
            q=1;
            for(i=startFrame:endFrame)
                procFrame(q).frame_number = i;
                procFrame(q).bkgnd_index = 1; % all frames use the same background unless otherwise specified
                q=q+1;
            end
            disp([sprintf('adjusting object detection level\t%s',timeString())])
            [DefaultLevel, NumFoundWorms] = default_worm_threshold_level(MovieName, background, procFrame, numWorms);
            [DefaultLevel, NumFoundWorms, mws, Ring] = default_worm_threshold_level(MovieName, background, procFrame, NumFoundWorms, Ring);
            disp([sprintf('Found %d worms with a threshold = [%f %d]',NumFoundWorms,DefaultLevel(1),DefaultLevel(2))])
            save(ringfile,'Ring');
            
            clear('procFrame');
            clear('Ring');
            clear('background');
        end
    end
end

clear('BW');

disp([sprintf('Tracking and processing movies\t%s',timeString)])
for i = 1:length(directoryList(:,1))
    
    % convert file paths automatically to the correct directory seperator
    directoryList(i,:) = filesep_convert(directoryList(i,:));
    
    PathName = deblank(directoryList(i,:));
    
    if(strcmp(PathName,'')==0)
        localpath = PathName;
        if(localpath(end)~=filesep)
            localpath = sprintf('%s%s',PathName, filesep);
        end
    else
        localpath = '';
    end
    
    dummystring = sprintf('%s%s*.avi',PathName,filesep);
    movieList = dir(dummystring);
    
    % Track all the movies
    for j=1:length(movieList)
        
        [pathstr, FilePrefix, ext] = fileparts(movieList(j).name);
        [pathstr, prf, ext] = fileparts(FilePrefix);
        
        working_file = sprintf('%s%s.working',localpath, FilePrefix);
        
        if(file_existence(working_file) == 0 && ...
                ( does_this_file_need_making(sprintf('%s%s.BodyBends.mat',localpath, FilePrefix), Prefs.trackerbirthday) == 1 ) )
            
            disp([sprintf('processing %s%s.avi',localpath, FilePrefix)])
            
            % remove any processed files for this movie, in case they exist
            disp(sprintf('Removing old processed files for %s%s.avi\t%s',localpath,FilePrefix, timeString()))
            dummystring = sprintf('%s%s.BodyBends.mat',localpath,FilePrefix);
            rm(dummystring);
            dummystring = sprintf('%s%s.linkedTracks.mat',localpath,FilePrefix);
            rm(dummystring);
            dummystring = sprintf('%s%s*.txt',localpath,FilePrefix);
            rm(dummystring);
            dummystring = sprintf('%s%s*.pdf',localpath,FilePrefix);
            rm(dummystring);
            
            fp = fopen(working_file,'w'); fclose(fp);
            
            mov_file = sprintf('%s%s.avi',localpath, FilePrefix);
            
            command = sprintf('single_well_tracker(''%s'')',mov_file);
            launch_matlab_command(command);
            
            rm(working_file);
        else
            if(file_existence(working_file) == 1)
                disp([sprintf('%s%s.avi is being worked on',localpath, FilePrefix)])
            end
        end
    end
end

return;
end
