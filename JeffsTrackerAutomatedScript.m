function JeffsTrackerAutomatedScript(directoryListFilename, varargin)
% JeffsTrackerAutomatedScript(directoryListFilename, [stimulusFile.txt], ['dont_track'], ['trackonly'], ['replot'], ['reanalyze'] )

rehash path; % refreshes the m-files

curr_dir = pwd;

global Prefs;
Prefs = [];

Prefs = define_preferences(Prefs);
aviread_to_gray;

if(nargin==0)
    disp(['Usage: JeffsTrackerAutomatedScript(argument1, [stimulusFile], other_arguments)'])
    disp(['stimulusFile is optional'])
    disp(['argument1 can be:'])
    disp(['     a movie filename,'])
    disp(['     a directory of movies,'])
    disp(['     a cell array of movie filenames,'])
    disp(['     a cell array of directory filenames,'])
    disp(['     or a text file listing directories of movies'])
    disp(['If you have a second movie my_scale_movie.avi with a object of known length, include ''scale'',''my_scale_movie.avi'' in the argument '])
    disp(['If you have drawn a circle on the plate using a holepunch template as a scale marker, include ''holepunch'' '])
    disp(['If your framerate is NOT 3, include ''framerate'',''my_framerate'' in the argument '])
    disp(['If number of worms <20 or >30, then you might include ''numworms'',#worms in the argument (optional)'])
    disp(['If you have a copper ring, AND your animals are on food, include ''food'' in the argument (optional)'])
    disp(['If you believe collisions between worms is unlikely, include ''no_collisions'' in the argument (optional)'])
    return
end

stimulusIntervalFile = '';
trackonly_flag = 0;
trackmasterflag = 0;
retrack_flag = 0;
reanalyze_flag = 0;
target_numworms = 0;
dont_track_flag = 0;
pixelsize_MovieName = '';

i=1;
while(i<=length(varargin))
    
    
    if(isempty(findstr(char(varargin{i}),'.stim'))==0) % .stim file is a stimulus interval file
        stimulusIntervalFile = varargin{i};
        i=i+1;
    else if(isempty(findstr(char(varargin{i}),'.txt'))==0) % .txt file is a stimulus interval file
            stimulusIntervalFile = varargin{i};
            [stimfilepathstr, stimfileprefix] = fileparts(stimulusIntervalFile);
            if(~isempty(stimfilepathstr))
                stimulusIntervalFile = sprintf('%s%s%s.txt',stimfilepathstr,filesep,stimfileprefix);
            else
                stimulusIntervalFile = sprintf('%s.txt',stimfileprefix);
            end
            i=i+1;
        else if(strfind(lower(varargin{i}),lower('Bin'))==1)
                i=i+1;
                Prefs.BinSize = varargin{i};
                Prefs.FreqBinSize = Prefs.BinSize;
                Prefs.SpeedEccBinSize = Prefs.BinSize;
                i=i+1;
            else if(strfind(lower(varargin{i}),lower('FreqBin'))==1)
                    i=i+1;
                    Prefs.FreqBinSize = varargin{i};
                    i=i+1;
                else if(~isempty(strfind(lower(varargin{i}),lower('cpu'))==1))
                        i=i+1;
                        Prefs.NumCPU = varargin{i};
                        i=i+1;
                    else if(~isempty(strfind(lower(varargin{i}),lower('worm'))==1) || ~isempty(strfind(lower(varargin{i}),lower('animal'))==1))
                            i=i+1;
                            target_numworms = varargin{i};
                            i=i+1;
                        else if(strcmpi(varargin{i},'square')==1)
                                Prefs.Ringtype = lower(varargin{i});
                                i=i+1;
                            else if(strcmpi(varargin{i},'food')==1)
                                    Prefs.Ringtype = 'square.food';
                                    i=i+1;
                                else if(strcmpi(varargin{i},'no_collisions')==1)
                                        Prefs.no_collisions_flag=1;
                                        i=i+1;
                                    else if(strcmpi(varargin{i},'holepunch')==1)
                                            Prefs.Ringtype = lower(varargin{i});
                                            i=i+1;
                                        else if(strcmpi(varargin{i},'timerbox')==1)
                                                Prefs.timerbox_flag = 1;
                                                i=i+1;
                                            else if(strcmpi(varargin{i},'none')==1)
                                                    Prefs.Ringtype = 'noRingHereThanks';
                                                    i=i+1;
                                                else if(strfind(lower(varargin{i}),lower('SpeedEccBin'))==1)
                                                        i=i+1;
                                                        Prefs.SpeedEccBinSize = varargin{i};
                                                        i=i+1;
                                                    else if((~isempty(strfind(lower(varargin{i}),'scale')) || ~isempty(strfind(lower(varargin{i}),'calib'))) && file_existence((varargin{i}))==0)
                                                            i=i+1;
                                                            pixelsize_MovieName = varargin{i};
                                                            i=i+1;
                                                        else if(strfind(lower(varargin{i}),'trackonly')==1)
                                                                trackonly_flag = 1;
                                                                i=i+1;
                                                            else if(~isempty(strfind(lower(varargin{i}),'dont')) && ~isempty(strfind(lower(varargin{i}),'track')))
                                                                    dont_track_flag = 1;
                                                                    i=i+1;
                                                                else if(strcmpi(varargin{i},'trackmaster')==1)
                                                                        trackmasterflag=1;
                                                                        i=i+1;
                                                                    else if(strncmpi(varargin{i},'retr',4) == 1 )
                                                                            retrack_flag=1;
                                                                            i=i+1;
                                                                        else if(strncmpi(varargin{i},'rean',4) == 1)
                                                                                reanalyze_flag=1;
                                                                                i=i+1;
                                                                            else if(strncmpi(varargin{i},'anal',4) == 1)
                                                                                    reanalyze_flag=1;
                                                                                    i=i+1;
                                                                                else if(~isempty(regexpi(varargin{i},'plot')))
                                                                                        reanalyze_flag=2;
                                                                                        i=i+1;
                                                                                    else if(strfind(lower(varargin{i}),'framerate')==1)
                                                                                            i=i+1;
                                                                                            Prefs.FrameRate = varargin{i};
                                                                                            Prefs = CalcPixelSizeDependencies(Prefs, Prefs.DefaultPixelSize);
                                                                                            i=i+1;
                                                                                        else if(strfind(lower(varargin{i}),'quick') == 1)
                                                                                                quick=1;
                                                                                                i=i+1;
                                                                                            else
                                                                                                sprintf('Error in JeffsTrackerAutomatedScript: Do not recognize %s',char(varargin{i}))
                                                                                                return
                                                                                            end
                                                                                        end
                                                                                    end
                                                                                end
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

scaleRing = [];
if(~isempty(pixelsize_MovieName))
    scaleRing = get_pixelsize_from_arbitrary_object(pixelsize_MovieName);
    % scaleRing = find_ring(pixelsize_MovieName);
    Prefs.DefaultPixelSize = scaleRing.PixelSize;
    Prefs.PixelSize = scaleRing.PixelSize;
    Prefs = CalcPixelSizeDependencies(Prefs, Prefs.DefaultPixelSize);
end

if(length(target_numworms)==1)
    if(target_numworms > 0)
        Prefs.DefaultNumWormRange = [max(1,target_numworms) target_numworms+2];
        target_numworms = 0;
    end
else
    Prefs.DefaultNumWormRange = [min(target_numworms) max(target_numworms)];
    target_numworms = 0;
end

quick = exist('quick', 'var');

% if argument is '.', process the movies in the current directory,
% but give the average files prefix as the name of the directory
if(ischar(directoryListFilename))
    
    if(directoryListFilename=='.')
        directoryListFilename = current_directory;
        
        if(~isempty(stimulusIntervalFile))
            stimulusIntervalFile = fullpath_from_filename(stimulusIntervalFile);
        end
        if(~isempty(pixelsize_MovieName))
            pixelsize_MovieName = fullpath_from_filename(pixelsize_MovieName);
        end
        
        cd ../;
    end
end



if(iscell(directoryListFilename))
    for(i=1:length(directoryListFilename))
        ds = sprintf('JeffsTrackerAutomatedScript(''%s'', ''dont_track''',directoryListFilename{i});
        for(v=1:length(varargin))
            if(ischar(varargin{v}))
                ds = sprintf('%s,''%s''',ds,varargin{v});
            else
                ds = sprintf('%s,%d',ds,varargin{v});
            end
        end
        ds = sprintf('%s);',ds);
        eval(ds);
    end
    for(i=1:length(directoryListFilename))
        ds = 'JeffsTrackerAutomatedScript(directoryListFilename{i}';
        for(v=1:length(varargin))
            if(ischar(varargin{v}))
                ds = sprintf('%s,''%s''',ds,varargin{v});
            else
                ds = sprintf('%s,%d',ds,varargin{v});
            end
        end
        ds = sprintf('%s);',ds);
        eval(ds);
    end
    return;
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
    
    [PathName, FilePrefix, ext] = fileparts(directoryListFilename);
    
    if(strcmp(ext,'.avi')==1) % is a single avi file
        fclose(file_ptr);
        
        if(~isempty(PathName))
            fps = sprintf('%s%s%s',PathName,filesep,FilePrefix);
        else
            fps = FilePrefix;
        end
        
        if(retrack_flag == 1)
            rmstr = sprintf('%s.*.mat',fps);
            rm(rmstr);
        end
        if(reanalyze_flag == 1)
            rmstr = sprintf('%s.Tracks.mat',fps);
            rm(rmstr);
            rmstr = sprintf('%s.linkedTracks.mat',fps);
            rm(rmstr);
            rmstr = sprintf('%s.collapseTracks.mat',fps);
            rm(rmstr);
            rmstr = sprintf('%s.BinData.mat',fps);
            rm(rmstr);
        end
        if(reanalyze_flag == 2)
            rmstr = sprintf('%s.BinData.mat',fps);
            rm(rmstr);
        end
        
        if(isempty(PathName))
            PathName = pwd;
        end
        
        background = calculate_background(sprintf('%s%s%s.avi',PathName, filesep, FilePrefix));
        
        ringfile = sprintf('%s%s%s.Ring.mat',PathName, filesep, FilePrefix);
        if(isempty(scaleRing))
            Ring = find_ring(background,sprintf('%s%s',PathName,filesep), FilePrefix, 1, quick);%%%
        else
            if(strcmp(Prefs.Ringtype(1:6),'square'))
                Ring = find_ring(background,sprintf('%s%s',PathName,filesep), FilePrefix, 1, quick);%%%
            else
                Ring = scaleRing;
            end
            Ring.PixelSize = scaleRing.PixelSize;
            save(ringfile, 'Ring');
        end
        
        
        
        if(isempty(Ring.DefaultThresh))
            [~, ~, ~, Ring] = default_worm_threshold_level(sprintf('%s%s%s.avi',PathName, filesep, FilePrefix), background, [], target_numworms, Ring, 1);
            save(ringfile,'Ring');
        end
        
        if(dont_track_flag==1)
            cd(curr_dir);
            return;
        end
        
        
        command = sprintf('Tracker(''%s'',''%s'',''%s'','''',''numworms'',%d, ''framerate'', %d)', PathName, FilePrefix, stimulusIntervalFile, target_numworms, Prefs.FrameRate);
        eval(command);
        
        %         dummystring = 'SingleFileJeffsTrackerAutomatedScript(directoryListFilename';
        %         for(v=1:length(varargin))
        %             dummystring = sprintf('%s,''%s''',dummystring,varargin{v});
        %         end
        %         dummystring = sprintf('%s)',dummystring);
        %         eval(dummystring);
        
        cd(curr_dir);
        return;
    else % is a bona fide directory list file
        dummystringCellArray = textscan(file_ptr,'%s');
        fclose(file_ptr);
    end
end

directoryList = char(dummystringCellArray{1});

animal_find_dud_idx = [];

disp(['Automatically calculating background and rings for all the movies in the directory'])
disp(['Some might need manual intervention later, so please do not leave yet!'])

% parallel processing for ring and animal finding
if(Prefs.NumCPU > 3)
    prefsfile = sprintf('%s%sPrefs.%d.mat',tempdir,filesep,Prefs.PID);
    save(prefsfile, 'Prefs');
    num_cpus = Prefs.NumCPU;
    doneflag=0;
    while(doneflag == 0)
        doneflag = 1;
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
                ringfile = sprintf('%s%s%s.Ring.mat',PathName, filesep, FilePrefix);
                working_file = sprintf('%s%s%s.Ring.working',PathName, filesep, FilePrefix);
                
                if(does_this_file_need_making(ringfile))
                    doneflag = 0;
                    
                    if(file_existence(working_file) == 0)
                        fp = fopen(working_file,'w'); fclose(fp);
                        disp([sprintf('%s%s%s.avi\t%s',PathName, filesep, FilePrefix, timeString())])
                        moviefile = sprintf('%s%s%s.avi',PathName, filesep, FilePrefix);
                        
                        command = sprintf('cd %s; global Prefs; Prefs = []; load %s;', pwd, prefsfile);
                        command = sprintf('%s scaleRing = find_ring(''%s'');', command, pixelsize_MovieName);
                        command = sprintf('%s calc_background_ring_worm_count(''%s'', ''%s'', scaleRing, %i);', command, PathName, moviefile, quick);
                        
                        if(num_cpus>1)
                            launch_matlab_command(command,1);
                            num_cpus = num_cpus - 1;
                        else
                            calc_background_ring_worm_count(PathName, moviefile, scaleRing);
                        end
                    end
                else
                    % working file exists and the ringfile exists ...
                    % so, the ringfile was just made
                    if(file_existence(working_file)==1 && does_this_file_need_making(ringfile) == 0)
                        num_cpus = num_cpus+1;
                        %                         load(ringfile);
                        %                         if(Ring.NumWorms < Prefs.DefaultNumWormRange(1) || Ring.NumWorms > Prefs.DefaultNumWormRange(2))
                        %                             animal_find_dud_idx = [animal_find_dud_idx; i j];
                        %                         end
                        clear('Ring');
                        rm(working_file);
                    end
                end
            end
        end
        pause(2);
    end
end

% make background and find rings for all the movies
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
    
    % disp([sprintf('%s:',PathName)])
    
    for j=1:length(movieList)
        [pathstr, FilePrefix, ext] = fileparts(movieList(j).name);
        
        ringfile = sprintf('%s%s%s.Ring.mat',PathName, filesep, FilePrefix);
        if(does_this_file_need_making(ringfile))
            rm(ringfile);
            background = calculate_background(sprintf('%s%s%s.avi',PathName, filesep, FilePrefix));
            % first pass, no manual intervention
            
            if(isempty(scaleRing))
                Ring = find_ring(background,sprintf('%s%s',PathName,filesep), FilePrefix, 0, quick);%%%
            else
                if(strcmp(Prefs.Ringtype(1:6),'square'))
                    Ring = find_ring(background,sprintf('%s%s',PathName,filesep), FilePrefix, 1, quick);%%%
                else
                    Ring = scaleRing;
                end
                Ring.PixelSize = scaleRing.PixelSize;
                save(ringfile, 'Ring');
            end
            
            % successfully found ring, so calc default threshold for finding animals
            if(~does_this_file_need_making(ringfile))
                %if(target_numworms == 0)
                if(isempty(Ring.DefaultThresh))
                    [DefaultLevel, NumFoundWorms, mws, Ring] = default_worm_threshold_level(sprintf('%s%s%s.avi',PathName, filesep, FilePrefix), background, [], target_numworms, Ring, 0);
                    save(ringfile, 'Ring');
                    
                    if(NumFoundWorms < Prefs.DefaultNumWormRange(1) || NumFoundWorms > Prefs.DefaultNumWormRange(2))
                        animal_find_dud_idx = [animal_find_dud_idx; i j];
                    end
                end
                %end
            end
            clear('Ring');
            clear('background');
        end
    end
end

% now allow manual intervention for those files that failed
disp(['Manually pick rings, if needed'])

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
        background = calculate_background(sprintf('%s%s%s.avi',PathName, filesep, FilePrefix));
        
        ringfile = sprintf('%s%s%s.Ring.mat',PathName, filesep, FilePrefix);
        if(does_this_file_need_making(ringfile))
            rm(ringfile);
            % manual intervention now permitted for finding ring
            Ring = find_ring(background,sprintf('%s%s',PathName,filesep), FilePrefix, 1, quick);%%%
            
            % find default thresholds and number of worms this file now that we have the manual ring  ...
            %if(target_numworms == 0)
            [DefaultLevel, NumFoundWorms, mws, Ring] = default_worm_threshold_level(sprintf('%s%s%s.avi',PathName, filesep, FilePrefix), background, [], target_numworms, Ring, 0);
            save(ringfile,'Ring');
            
            if(NumFoundWorms < Prefs.DefaultNumWormRange(1) || NumFoundWorms > Prefs.DefaultNumWormRange(2))
                animal_find_dud_idx = [animal_find_dud_idx; i j];
            end
            %end
            
            clear('Ring');
        end
        clear('background');
    end
end

for k=1:size(animal_find_dud_idx,1)
    
    i = animal_find_dud_idx(k,1);
    j = animal_find_dud_idx(k,2);
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
    
    disp([sprintf('%s:',PathName)])
    
    [pathstr, FilePrefix, ext] = fileparts(movieList(j).name);
    
    background = calculate_background(sprintf('%s%s%s.avi',PathName, filesep, FilePrefix));
    
    Ring = find_ring(background,sprintf('%s%s',PathName,filesep), FilePrefix, 1, quick);%%%
    
    disp(sprintf('%d %d %d %s%s%s.avi',i,j,Ring.NumWorms, PathName, filesep, FilePrefix))
    
    [DefaultLevel, NumFoundWorms, mws, Ring] = default_worm_threshold_level(sprintf('%s%s%s.avi',PathName, filesep, FilePrefix), background, [], target_numworms, Ring, 1);
    ringfile = sprintf('%s%s%s.Ring.mat',PathName, filesep, FilePrefix);
    save(ringfile,'Ring');
    
    clear('Ring');
    clear('background');
end

if(dont_track_flag==1)
    cd(curr_dir);
    return;
end

for i = 1:length(directoryList(:,1))
    
    actually_processed_flag=0;
    
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
    
    if(retrack_flag == 1)
        rmstr = sprintf('%s%s*procFrame.mat',PathName,filesep);
        rm(rmstr);
        rmstr = sprintf('%s%s*Tracks.mat',PathName,filesep);
        rm(rmstr);
    end
    if(reanalyze_flag == 1)
        rmstr = sprintf('%s%s*.Tracks.mat',PathName,filesep);
        rm(rmstr);
        rmstr = sprintf('%s%s*.BinData.mat',PathName,filesep);
        rm(rmstr);
        rmstr = sprintf('%s%s*.linkedTracks.mat',PathName,filesep);
        rm(rmstr);
        rmstr = sprintf('%s%s*.collapseTracks.mat',PathName,filesep);
        rm(rmstr);
        rmstr = sprintf('%s%s*.psth*',PathName,filesep);
        rm(rmstr);
    end
    if(reanalyze_flag == 2)
        rmstr = sprintf('%s%s*.BinData.mat',PathName,filesep);
        rm(rmstr);
        rmstr = sprintf('%s%s*.psth.BinData.mat',PathName,filesep);
        rm(rmstr);
    end
    
    % Track all the movies
    elapsed_time=[];
    et_index=0;
    for j=1:length(movieList)
        
        [pathstr, FilePrefix, ext] = fileparts(movieList(j).name);
        [pathstr, prf, ext] = fileparts(FilePrefix);
        
        %         if(strcmp(PathName,'')==0)
        %             localpath = PathName;
        %             if(localpath(end)~=filesep)
        %                 localpath = sprintf('%s%s',PathName, filesep);
        %             end
        %         else
        %             localpath = '';
        %         end
        
        working_file = sprintf('%s%s.working',localpath, FilePrefix);
        
        if(file_existence(working_file) == 0 && ...
                ( does_this_file_need_making(sprintf('%s%s.procFrame.mat',localpath, FilePrefix), Prefs.trackerbirthday) == 1 || ...
                does_this_file_need_making(sprintf('%s%s.rawTracks.mat',localpath, FilePrefix), Prefs.trackerbirthday) == 1 || ...
                does_this_file_need_making(sprintf('%s%s.Tracks.mat',localpath, FilePrefix), Prefs.track_analysis_date) == 1 || ...
                does_this_file_need_making(sprintf('%s%s.linkedTracks.mat',localpath, FilePrefix), Prefs.track_analysis_date) == 1 || ...
                does_this_file_need_making(sprintf('%s%s.collapseTracks.mat',localpath, FilePrefix), Prefs.track_analysis_date) == 1 ) )
            
            disp([sprintf('processing %s%s.avi',localpath, FilePrefix)])
            actually_processed_flag=1;
            tic
            
            % remove any processed files for this movie, in case they exist
            disp(sprintf('Removing old processed files for %s%s.avi\t%s',localpath,FilePrefix, timeString()))
            dummystring = sprintf('%s%s.Tracks.mat',localpath,FilePrefix);
            rm(dummystring);
            dummystring = sprintf('%s%s.linkedTracks.mat',localpath,FilePrefix);
            rm(dummystring);
            dummystring = sprintf('%s%s.collapseTracks.mat',localpath,FilePrefix);
            rm(dummystring);
            dummystring = sprintf('%s%s.BinData.mat',localpath,FilePrefix);
            rm(dummystring);
            dummystring = sprintf('%s%s*.txt',localpath,FilePrefix);
            rm(dummystring);
            dummystring = sprintf('%s%s*.pdf',localpath,FilePrefix);
            rm(dummystring);
            dummystring = sprintf('%s%s.psth_Tracks.mat',localpath,FilePrefix);
            rm(dummystring);
            dummystring = sprintf('%s%s.psth.BinData.mat',localpath,FilePrefix);
            rm(dummystring);
            
            
            if(does_this_file_need_making(sprintf('%s%s.rawTracks.mat',localpath, FilePrefix), Prefs.trackerbirthday) == 1)
                dummystring = sprintf('%s%s.rawTracks.mat',localpath,FilePrefix);
                rm(dummystring);
            end
            
            if(does_this_file_need_making(sprintf('%s%s.procFrame.mat',localpath, FilePrefix), Prefs.trackerbirthday) == 1)
                dummystring = sprintf('%s%s.rawTracks.mat',localpath,FilePrefix);
                rm(dummystring);
                dummystring = sprintf('%s%s.procFrame.mat',localpath,FilePrefix);
                rm(dummystring);
            end
            
            % remove the averaged files since they will need to be remade
            %             dummystring = sprintf('%s%s*',localpath,prefix_from_path(PathName));
            %             rm(dummystring);
            
            fp = fopen(working_file,'w'); fclose(fp);
            command = sprintf('Tracker(''%s'',''%s'',''%s'','''',''numworms'',%d, ''framerate'', %d)', localpath, FilePrefix, stimulusIntervalFile, target_numworms, Prefs.FrameRate);
            launch_matlab_command(command);
            rm(working_file);
            
            
            et_index = et_index + 1;
            elapsed_time(et_index) = toc;
        else
            if(file_existence(working_file) == 1)
                disp([sprintf('%s%s.avi is being worked on',localpath, FilePrefix)])
            else if(does_this_file_need_making(sprintf('%s%s.rawTracks.mat',localpath, FilePrefix), Prefs.trackerbirthday) == 0)
                    disp([sprintf('%s%s.avi has been processed',localpath, FilePrefix)])
                end
            end
        end
        
        if(file_existence(sprintf('%s%sstop.txt',pwd,filesep)))
            disp([sprintf('stop due to %s%sstop.txt',pwd,filesep)])
            cd(curr_dir);
            return;
        end
        
    end
    % Analyse all the Tracks, combine the independent experiments in this
    % directory
    
    mean_time_per_run=150;
    if(~isempty(elapsed_time))
        mean_time_per_run = mean(elapsed_time);
    end
    
    analyse_flag=0;%analyse_flag=1;
    j=1;
    while(j<=length(movieList))
        
        if(file_existence(sprintf('%s%sstop.txt',pwd,filesep)))
            disp([sprintf('stop due to %s%sstop.txt',pwd,filesep)])
            cd(curr_dir);
            return;
        end
        
        [pathstr, FilePrefix, ext] = fileparts(movieList(j).name);
        [pathstr, prf, ext] = fileparts(FilePrefix);
        testfile = sprintf('%s%s%s.BinData.mat',PathName,filesep, FilePrefix);
        working_file = sprintf('%s%s%s.working',PathName,filesep, FilePrefix);
        if(file_existence(testfile)==0)  % this BinData file does not exist ... someone else is working on it, so let that process do the averaging
            analyse_flag=0;
            if(trackmasterflag==1)  % but this process is a master, so wait for the jobs to finish
                j=0;
%                 analyse_flag=1;
                stopflag=0;
                tic;
                while(stopflag==0)
                    et = toc;
                    disp([sprintf('Will wait %f sec for %s%s.avi to finish\t%s',2*mean_time_per_run-et, localpath, FilePrefix,timeString())])
                    if(et > 2*mean_time_per_run)
                        disp([sprintf('something wrong with processing %s%s.avi ... this computer will retry it\t%s',localpath, FilePrefix,timeString())])
                        rm(working_file);
                        command = sprintf('Tracker(''%s'',''%s'',''%s'', '''',''numworms'',%d, ''framerate'', %d)', PathName, FilePrefix, stimulusIntervalFile,target_numworms, Prefs.FrameRate);
                        disp([sprintf('processing %s%s.avi',localpath, FilePrefix)])
                        launch_matlab_command(command);
                        actually_processed_flag=1;
                        stopflag=1;
                    end
                    if(file_existence(testfile)==1)
                        stopflag=1;
                    else
                        pause(10);
                    end
                end
            else
                if(file_existence(working_file))
                    disp([sprintf('%s exists ... another CPU should complete and average this directory',working_file)])
                else
                    disp([sprintf('Neither %s nor %s exists ... consider re-running JeffsTrackerAutomatedScript for directory %s',testfile, working_file, localpath)])
                end
            end
        end
        j=j+1;
    end
    
    
    if(file_existence(sprintf('%s%sstop.txt',pwd,filesep)))
        disp([sprintf('stop due to %s%sstop.txt',pwd,filesep)])
        cd(curr_dir);
        return;
    end
    
    if(analyse_flag==1)
        if(trackonly_flag==0)
            % if the averaged files don't exist, make them
            if( does_this_file_need_making(sprintf('%s%s.avg.collapseTracks.mat',localpath, prefix_from_path(PathName)), Prefs.trackerbirthday) == 1 || ...
                    does_this_file_need_making(sprintf('%s%s.avg.BinData.mat',localpath, prefix_from_path(PathName)), Prefs.trackerbirthday) == 1  || ...
                    does_this_file_need_making(sprintf('%s%s.avg.BinData_array.mat',localpath, prefix_from_path(PathName)), Prefs.trackerbirthday) == 1  || ...
                    does_this_file_need_making(sprintf('%s%s.avg.freqs.txt',localpath, prefix_from_path(PathName)), Prefs.trackerbirthday) == 1  || ...
                    does_this_file_need_making(sprintf('%s%s.avg.non_freqs.txt',localpath, prefix_from_path(PathName)), Prefs.trackerbirthday) == 1  || ...
                    does_this_file_need_making(sprintf('%s%s.avg.pdf',localpath, prefix_from_path(PathName)), Prefs.trackerbirthday) == 1 )
                
                actually_processed_flag=1;
            end
            
            if(~isempty(stimulusIntervalFile))
                if( does_this_file_need_making(sprintf('%s%s.avg.psth.BinData.mat',localpath, prefix_from_path(PathName)), Prefs.trackerbirthday) == 1 || ...
                        does_this_file_need_making(sprintf('%s%s.avg.psth.pdf',localpath, prefix_from_path(PathName)), Prefs.trackerbirthday) == 1  || ...
                        does_this_file_need_making(sprintf('%s%s.avg.psth_Tracks.mat',localpath, prefix_from_path(PathName)), Prefs.trackerbirthday) == 1  )
                    actually_processed_flag=1;
                end
            end
            
            if(actually_processed_flag==1 || reanalyze_flag>0) % reanalyse and average only if movies were actually processed
                AnalysisMaster(PathName, 'stimulusIntervalFile',stimulusIntervalFile);
            end
        end
    end
    
end

% remove copy of movie from tempdir
aviread_to_gray('rm_temp');

clear('Prefs');

cd(curr_dir);
return;
end
