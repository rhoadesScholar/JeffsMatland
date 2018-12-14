function need_to_analyse_flag = process_RawTracksFiles(RawTracksFiles, stimulusfile, localpath, FilePrefix)

global Prefs;

need_to_analyse_flag=0;

if(strcmp(localpath, '')==1)
    prefix = FilePrefix;
else
    prefix = sprintf('%s.avg',prefix_from_path(localpath));
end
global_collapseTracks_file = sprintf('%s%s.collapseTracks.mat',localpath,prefix);
global_BinData_array_file = sprintf('%s%s.BinData_array.mat',localpath,prefix);
if(does_this_file_need_making(global_collapseTracks_file,Prefs.track_analysis_date))
    need_to_analyse_flag=1;
end
if(does_this_file_need_making(global_BinData_array_file,Prefs.track_analysis_date))
    need_to_analyse_flag=1;
end

% a movie needs to be analysed
for i = 1:length(RawTracksFiles)
    prefix = RawTracksFiles(i).name(1:length(RawTracksFiles(i).name)-14); % get prefix from prefix.rawTracks.mat
    
    collapseTracks_filename = sprintf('%s%s.collapseTracks.mat',localpath,prefix);
    if(does_this_file_need_making(collapseTracks_filename,Prefs.track_analysis_date))
        need_to_analyse_flag=1;
    end
    if(file_age(collapseTracks_filename) > file_age(global_collapseTracks_file))
        rm(global_collapseTracks_file);
        need_to_analyse_flag=1;
    end
    
    bindata_filename = sprintf('%s%s.BinData.mat',localpath,prefix);
    if(does_this_file_need_making(bindata_filename,Prefs.track_analysis_date))
        need_to_analyse_flag=1;
    end
    if(file_age(bindata_filename) > file_age(global_BinData_array_file))
        rm(global_BinData_array_file);
        need_to_analyse_flag=1;
    end
    
    if(~isempty(stimulusfile))
        psth_Tracks_filename  = sprintf('%s%s.psth_Tracks.mat',localpath,prefix);
        if(does_this_file_need_making(psth_Tracks_filename,Prefs.track_analysis_date))
            need_to_analyse_flag=1;
        end
        
        psth_BinData_filename  = sprintf('%s%s.psth.BinData.mat',localpath,prefix);
        if(does_this_file_need_making(psth_BinData_filename,Prefs.track_analysis_date))
            need_to_analyse_flag=1;
        end
    end
    
end

% movies are analysed, but the joined files need to be made
if(strcmp(localpath, '')==1)
    prefix = FilePrefix;
else
    prefix = sprintf('%s.avg',prefix_from_path(localpath));
end


if(need_to_analyse_flag==1)
    
    for i = 1:length(RawTracksFiles)
        prefix = RawTracksFiles(i).name(1:length(RawTracksFiles(i).name)-14); % get prefix from prefix.rawTracks.mat
        analyse_rawTracks([], stimulusfile, localpath, prefix, 0);
    end
    
    
    BinData_array = [];
    for i = 1:length(RawTracksFiles)
        bindata_filename = sprintf('%s%s.BinData.mat',localpath,RawTracksFiles(i).name(1:length(RawTracksFiles(i).name)-14));
        disp([sprintf('loading %s\t%s', bindata_filename,timeString())])
        t1 = load_BinData(bindata_filename);
        t1.num_movies = 1;
        BinData_array = [BinData_array t1];
        clear('t1');
        clear('bindata_filename');
    end
    BinData_array = extract_BinData_array(BinData_array);
%     mintime = floor(min_struct_array(BinData_array,'time'));
%     maxtime = ceil(max_struct_array(BinData_array,'time'));
    if(strcmp(localpath, '')==1)
        prefix = FilePrefix;
    else
        prefix = sprintf('%s.avg',prefix_from_path(localpath));
    end
    dummystring = sprintf('%s%s.BinData_array.mat',localpath,prefix);
    disp([sprintf('saving %s\t%s', dummystring,timeString())])
    save(dummystring,'BinData_array');
    clear('dummystring');
    clear('BinData_array');
    
    collapseTracks = [];
    for i = 1:length(RawTracksFiles)
        prefix = RawTracksFiles(i).name(1:length(RawTracksFiles(i).name)-14); % get prefix from prefix.rawTracks.mat
        collapseTracks_filename = sprintf('%s%s.collapseTracks.mat',localpath,prefix);
        disp([sprintf('loading %s\t%s', collapseTracks_filename,timeString())])
        t1 = load_Tracks(collapseTracks_filename);
        j=1;
        while(j<=length(t1))
            collapseTracks  = [collapseTracks t1(j)];
            t1(j) = [];
        end
        clear('collapseTracks_filename');
        clear('t1');
    end
    collapseTracks = sort_tracks_by_length(collapseTracks);
    % collapseTracks = extract_track_segment(collapseTracks,mintime,maxtime,'time');
    if(strcmp(localpath, '')==1)
        prefix = FilePrefix;
    else
        prefix = sprintf('%s.avg',prefix_from_path(localpath));
    end
    dummystring = sprintf('%s%s.collapseTracks.mat',localpath,prefix);
    disp([sprintf('saving %s\t%s', dummystring,timeString())])
    save_Tracks(dummystring,collapseTracks);
    clear('dummystring');
    clear('collapseTracks');
    
    psth_Tracks = [];
    if(~isempty(stimulusfile))
        for i = 1:length(RawTracksFiles)
            psth_Tracks_filename  = sprintf('%s%s.psth_Tracks.mat',localpath,RawTracksFiles(i).name(1:length(RawTracksFiles(i).name)-14));
            if(file_existence(psth_Tracks_filename))
                disp([sprintf('loading %s\t%s', psth_Tracks_filename,timeString())])
                t1 = load_Tracks(psth_Tracks_filename);
                j=1;
                while(j<=length(t1))
                    psth_Tracks  = [psth_Tracks t1(j)];
                    t1(j) = [];
                end
                clear('t1');
            end
            clear('psth_Tracks_filename');
        end
        if(~isempty(psth_Tracks))
            dummystring = sprintf('%s%s.psth_Tracks.mat',localpath,prefix);
            disp([sprintf('saving %s\t%s', dummystring,timeString())])
            save_Tracks(dummystring, psth_Tracks);
            clear('dummystring');
            clear('psth_Tracks');
        end
    end
        
end

return;
end
