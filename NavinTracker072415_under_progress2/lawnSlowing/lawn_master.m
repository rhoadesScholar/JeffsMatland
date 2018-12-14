function lawn_master(dirname)

lawn_diameter = 6; % in mm
framerate=1; % 1 DEBUG
timerbox_flag=1; % 1 DEBUG

global Prefs;
Prefs = [];
Prefs = define_preferences(Prefs);

Prefs.lawn_diameter = lawn_diameter;
Prefs.FrameRate = framerate;
Prefs.timerbox_flag = timerbox_flag;

PathName = deblank(dirname);
if(PathName(end)~=filesep)
    PathName = sprintf('%s%s',PathName, filesep);
end

dummystring = sprintf('%s*.avi',PathName);
movieList = dir(dummystring);

fresh_edge=[];
for(j=1:length(movieList))
    MovieName = sprintf('%s%s',PathName, movieList(j).name);
    [pn, FilePrefix, ext] = fileparts(MovieName);
    outeredge_filename = sprintf('%s%s.outer_edge.mat',PathName, FilePrefix);
    
    FileInfo = moviefile_info(MovieName);
    FrameNum = FileInfo.NumFrames;
    
    startframe = 1;
    endframe = FrameNum;
    
%     DEBUG
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
    
    fresh_edge(j)=0;
    if(~file_existence(outeredge_filename))
        disp([sprintf('Find background for %s',MovieName)])
        background = calculate_background(MovieName,startframe,endframe);
        disp([sprintf('Find lawn ring and estimated lawn edge for %s',MovieName)])
        outer_edge = find_drawn_lawn_edge(background);
        fresh_edge(j)=1;
        if(~isempty(outer_edge))
            save(outeredge_filename, 'outer_edge');
        end
        
        clear('background');
        clear('outer_edge');
    end
    
    close all;

end

disp([sprintf('Double-check lawn rings\t%s',timeString())])
for(j=1:length(movieList))
    if(fresh_edge(j)==1)
        MovieName = sprintf('%s%s',PathName, movieList(j).name);
        [pn, FilePrefix, ext] = fileparts(MovieName);
        outeredge_filename = sprintf('%s%s.outer_edge.mat',PathName, FilePrefix);
        
        
        disp([sprintf('Check lawn ring for %s',MovieName)])
        
        FileInfo = moviefile_info(MovieName);
        FrameNum = FileInfo.NumFrames;
        
        startframe=1;
        endframe=FrameNum;
%         DEBUG
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
        
        if(file_existence(outeredge_filename))
            load(outeredge_filename);
        else
            outer_edge=[];
        end
        
        background = calculate_background(MovieName,startframe,endframe);
        outer_edge = outer_edge_check(background, outer_edge);
        
        save(outeredge_filename, 'outer_edge');
        
        close all;
        clear('background');
        clear('outer_edge');
    end
end

for(j=1:length(movieList))
    
    [pathstr, FilePrefix, ext] = fileparts(movieList(j).name);
    
    workingfile = sprintf('%s%s.working',PathName,FilePrefix);
    linkedTracks_filename = sprintf('%s%s.linkedTracks.mat',PathName, FilePrefix);
    lawnTracks_filename = sprintf('%s%s.lawnTracks.mat',PathName, FilePrefix);
    if(~file_existence(workingfile) && (~file_existence(linkedTracks_filename) || ~file_existence(lawnTracks_filename)))
        disp([sprintf('Processing %s\t%s',movieList(j).name, timeString())])
        
        % cp stuff for this movie to temp
        tempPathName = sprintf('%s%s%s',tempdir, FilePrefix,filesep);
        mkdir(tempPathName);
        cmd = sprintf('cp(''%s%s*'', ''%s'')',PathName, FilePrefix, tempPathName);
        eval(cmd);
        
        % run the command on a child process
        dummystring = sprintf('%s%s',tempPathName, movieList(j).name);
        command = sprintf('lawn_leaving_worker(''%s'',%f, %d, %d)', dummystring, Prefs.lawn_diameter, Prefs.FrameRate, Prefs.timerbox_flag);
        fp = fopen(workingfile,'w'); fclose(fp);
        launch_matlab_command(command);
        
        % cp stuff back from temp
        cmd = sprintf('cp(''%s*'', ''%s'')',tempPathName, PathName);
        eval(cmd);
        
        % purge tempdir
        rmdir(tempPathName,'s');
        
        rm(workingfile);
    else
        if(file_existence(workingfile))
            disp([sprintf('%s is being worked on by another process\t%s',movieList(j).name, timeString())])
        else
            disp([sprintf('%s is already processed\t%s',movieList(j).name, timeString())])
        end
    end
end

% combine data from different movies here

localpath = dirname;
if(localpath(end) == filesep)
    localpath = localpath(1:(end-1));
end
prefix = prefix_from_path(localpath);
master_linkedtracks_file = sprintf('%s%s%s.linkedTracks.mat',localpath, filesep,prefix);

if(does_this_file_need_making(master_linkedtracks_file))
    
    working_file = sprintf('%s%s%s.working',localpath, filesep,prefix);
    
    if(~file_existence(working_file))
        
        fp = fopen(working_file,'w'); fclose(fp);
        
        all_linkedTracks = [];
        for(j=1:length(movieList))
            [pathstr, FilePrefix, ext] = fileparts(movieList(j).name);
            
            dummystring = sprintf('%s%s.linkedTracks.mat',PathName, FilePrefix);
            load(dummystring);
            all_linkedTracks = [all_linkedTracks linkedTracks];
            clear('linkedTracks');
        end
        linkedTracks = sort_tracks_by_length(all_linkedTracks);
        clear('all_linkedTracks');
        save(master_linkedtracks_file,'linkedTracks');
        
        Prefs.psth_pre_stim_period = 20;
        Prefs.psth_post_stim_period = 20;
        
        [on_psth_Tracks, on_psth_BinData, off_psth_Tracks, off_psth_BinData] = stimulus_on_off_plots(linkedTracks, 'path', localpath, 'prefix',prefix, Prefs.LawnCode);
        
        close all;
        plot_stim_on_off_data(on_psth_BinData, on_psth_Tracks, off_psth_BinData, off_psth_Tracks, Prefs.LawnCode, localpath, prefix);
        
        rm(working_file);
    else
        disp([sprintf('another process is making on %s ... %s',master_linkedtracks_file,timeString)])
    end
else
    disp([sprintf('%s already exists ... %s',master_linkedtracks_file,timeString)])
end

return;
end
