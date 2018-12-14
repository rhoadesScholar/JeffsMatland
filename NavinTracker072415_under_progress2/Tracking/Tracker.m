function rawTracks = Tracker(PathName, FilePrefix, stimulusfile, Ringtype, varargin)
% rawTracks = Tracker(PathName, FilePrefix, stimulusfile, Ringtype, varargin) or standalone program

global Prefs;
Prefs = define_preferences(Prefs);

aviread_to_gray;

FileInfo = [];
Ring = [];

if(nargin<3)
    stimulusfile='';
end

if(nargin<4)
    Ringtype = 'square';
else
    if(isempty(Ringtype))
        Ringtype = 'square';
    end
end

startFrame = [];
endFrame = [];
target_numworms = 0;
    
i=1;
if(nargin > 4)
    if(isnumeric(varargin{i}))
        startFrame = varargin{1}(1);
        endFrame = varargin{1}(2);
        i=i+1;
    else if(strcmpi(varargin{i},'numworms')==1)
            i=i+1;
            target_numworms = varargin{i};
            i=i+1;
        else if(strcmpi(varargin{i},'framerate')==1)
                i=i+1;
                Prefs.FrameRate = varargin{i};
                Prefs = CalcPixelSizeDependencies(Prefs, Prefs.DefaultPixelSize);
                i=i+1;
            end
        end
    end
end

OPrefs = Prefs;
% Prefs.Ringtype = lower(Ringtype);

rawTracks = [];

% Get AVI movie for analysis
% --------------------------

if(nargin == 0) % running in interactive mode... no arguments given.... ask the user for the MovieName
    cd(pwd);
    [FileName, PathName] = uigetfile('*.avi', 'Select AVI Movie For Analysis');
    if FileName == 0
        errordlg('No movie was selected for analysis');
        Prefs = OPrefs;
        return;
    end
    
    [pathstr, FilePrefix, ext] = fileparts(FileName);
    
    localpath = sprintf('%s%s',PathName, filesep);
    
    Prefs.PlotFrameRate = Prefs.PlotFrameRateInteractive;    % 100 Display tracking on screen every PlotFrameRate frames
    Prefs.PlotDataRate = Prefs.PlotDataRateInteractive;      % 10 print data to matlab window every PlotDataRate frames
    
else  % probably running from a script
    
    Prefs.PlotFrameRate = Prefs.PlotFrameRateBatch;
    Prefs.PlotDataRate = Prefs.PlotDataRateBatch;
    
    if(nargin==1) % is likely an avi file
        
        FileName = PathName;
        [PathName, FilePrefix, ext] = fileparts(FileName);
        if(strcmp(ext,'.avi')==0) % not an avi file
            sprintf('%s is not an .avi file.\nBailing out...',FileName)
            Prefs = OPrefs;
            return;
        end
        FileName = sprintf('%s.avi',FilePrefix);
    else
        FileName = sprintf('%s.avi', FilePrefix);
    end
    
    if(strcmp(PathName,'')==0)
        localpath = PathName;
        if(localpath(end)~=filesep)
            localpath = sprintf('%s%s',PathName, filesep);
        end
    else
        localpath = '';
    end
    
    
    testfile = sprintf('%s%s',localpath,FileName);
    fp = fopen(testfile,'r');
    if(fp==-1)
        sprintf('Cannot open %s',testfile)
        Prefs = OPrefs;
        return;
    end
    fclose(fp);
    % does the tracks file exist?
    
    
    rawtracksfilename = sprintf('%s%s.rawTracks.mat',localpath, FilePrefix);
    
    if(file_existence(rawtracksfilename))
        disp([sprintf('rawTracks file %s exists....',rawtracksfilename)])
        
        if(does_this_file_need_making(rawtracksfilename,Prefs.trackerbirthday)==0)
            disp([sprintf('processing....\t%s',timeString())])
            
            rawTracks = [];
            analyse_rawTracks(rawTracks, stimulusfile, localpath, FilePrefix);
            
            if(nargout>0)
                load(rawtracksfilename);
            end
            
            Prefs = OPrefs;
            return;
        else
            disp(sprintf('... but is old ... re-analyse'))
            rm(rawtracksfilename);
        end
    end
end

% remove any processed files for this movie, in case they exist
disp(sprintf('Removing old processed files for %s%s.avi\t%s',localpath,FilePrefix, timeString()))
dummystring = sprintf('%s%s*Tracks.mat',localpath,FilePrefix);
rm(dummystring);
dummystring = sprintf('%s%s*BinData.mat',localpath,FilePrefix);
rm(dummystring);
dummystring = sprintf('%s%s*.txt',localpath,FilePrefix);
rm(dummystring);
dummystring = sprintf('%s%s*.pdf',localpath,FilePrefix);
rm(dummystring);

RealMovieName = sprintf('%s%s',localpath, FileName);

disp(sprintf('Found %s ... ',RealMovieName))

procFrame_file = sprintf('%s%s.procFrame.mat',localpath, FilePrefix);
if(does_this_file_need_making(procFrame_file))
    
    MovieName = RealMovieName;
    
    % read info about the movie
    FileInfo = moviefile_info(MovieName);
    
    if(isempty(startFrame))
        startFrame = 1;
        endFrame = FileInfo.NumFrames;
    end
    
    if(endFrame > FileInfo.NumFrames)
        endFrame = FileInfo.NumFrames;
    end
    
    
    NumFrames = endFrame-startFrame+1;
    
    disp(sprintf('Now defining the global background and boundry\t%s',timeString()))
    global_background = calculate_background(MovieName);
    Ring = find_ring(global_background,localpath, FilePrefix);
    
    if(isempty(Ring.ring_mask))
        Prefs.aggressive_wormfind_flag = 0;
    end
    
    if(~isempty(Ring.NumWorms) && target_numworms==0)
        target_numworms = Ring.NumWorms;
    end
    
    if(isfield(Ring,'arena_name'))
        if(length(Ring.arena_name)>1)
            if(target_numworms==0)
                target_numworms = 30*length(Ring.arena_name);
            end
        end
    end
        
    procFrame = [];
    if(Prefs.NumCPU<=1 ||  NumFrames < 2*Prefs.TrackProcessChunkSize) % just do it in one process
        procFrame = master_process_movie_frames(MovieName, localpath, FilePrefix, Ring, stimulusfile, startFrame, endFrame, target_numworms);
        dummystring = sprintf('%s%s.%d_%d.procFrame.mat',localpath, FilePrefix, startFrame, endFrame);
        mv(dummystring, procFrame_file);
        clear('dummystring');
    else % fork_process_movie_frames to process chunks in parallel
        
        if(isempty(Ring.NumWorms) || isempty(Ring.DefaultThresh) || isempty(Ring.meanWormSize))
            [~, ~, ~, Ring] = default_worm_threshold_level(MovieName, calculate_background(MovieName), procFrame, target_numworms, Ring);
            save(sprintf('%s%s.Ring.mat',localpath, FilePrefix), 'Ring');
        end
        
        
        
        frameStep = round(NumFrames/(Prefs.NumCPU));
        
%         startFrame_vector = startFrame:frameStep:(endFrame-frameStep);
%         frameEnd_vector = (startFrame+frameStep-1):frameStep:endFrame;
%         if(endFrame - frameEnd_vector(end) <= 1.5*frameStep)
%             frameEnd_vector(end+1) = endFrame;
%         end
%         if(length(frameEnd_vector)>length(startFrame_vector))
%             startFrame_vector = [startFrame_vector frameEnd_vector(end-1)+1];
%         end

        startFrame_vector = [];
        frameEnd_vector = [];
        f=startFrame;
        while(f<endFrame)
            startFrame_vector = [startFrame_vector f];
            frameEnd_vector = [frameEnd_vector startFrame_vector(end)+frameStep-1];
            f = f + frameStep;
        end
        if(frameEnd_vector  > endFrame)
            frameEnd_vector = endFrame;
        end
        frameEnd_vector(end) = endFrame;
        if(frameEnd_vector(end) - startFrame_vector(end) + 1 < frameStep/2)
            startFrame_vector(end) = [];
            frameEnd_vector(end) = [];
            frameEnd_vector(end) = endFrame;
        end
            
        for(kk=1:length(startFrame_vector))
            dummystring = sprintf('%s%s.%d_%d.procFrame.mat',localpath, FilePrefix, startFrame_vector(kk), frameEnd_vector(kk));
            if(file_existence(dummystring)==0)
                fork_process_movie_frames(MovieName, localpath, FilePrefix, stimulusfile, startFrame_vector(kk), frameEnd_vector(kk), target_numworms);
                pause(10);    
            end
        end
        % wait for all to finish
        done_flag=0;
        cycle = 0;
        while(done_flag==0)
            cycle = cycle + 1;
            done_flag = 1;
            kk=1;
            num_finished = 0;
            not_done = [];
            for(kk=1:length(startFrame_vector))
                dummystring = sprintf('%s%s.%d_%d.procFrame.mat',localpath, FilePrefix, startFrame_vector(kk), frameEnd_vector(kk));
                if(file_existence(dummystring)==0)
                    done_flag = 0;
                    not_done = [not_done kk];
                else
                    num_finished = num_finished + 1;
                end
            end
            pause(10);
            if(mod(cycle,10)==0)
                disp([sprintf('%d/%d child processes finished\t%s',num_finished, length(startFrame_vector), timeString)])
                if(length(not_done) == 1)
                    disp([sprintf('\tWaiting for %d to %d \t%s',  startFrame_vector(not_done(1)), frameEnd_vector(not_done(1)), timeString)])
                end
            end
        end
        % pool procFrame segments into single procFrame file
        disp([sprintf('pooling procFrame segments into single procFrame file\t%s',timeString)])

        dummy_procFrame = [];
        for(kk=1:length(startFrame_vector))
            pause(30);
            try
                load(sprintf('%s%s.%d_%d.procFrame.mat',localpath, FilePrefix, startFrame_vector(kk), frameEnd_vector(kk)));
            catch
                pause(240);
                load(sprintf('%s%s.%d_%d.procFrame.mat',localpath, FilePrefix, startFrame_vector(kk), frameEnd_vector(kk)));
            end
            if(isfield(procFrame(1),'scalars'))%decompress procFrames if necessary
                procFrame = compress_decompress_procFrame(procFrame);
            end
            dummy_procFrame = append_procFrame(dummy_procFrame, procFrame);
            clear('procFrame');
        end
        procFrame = dummy_procFrame;
        clear('dummy_procFrame');
        disp([sprintf('saving final procFrame to %s\t%s',procFrame_file, timeString)])
        save_procFrame(procFrame_file,procFrame);
        
        % remove segment procFrame files
        for(kk=1:length(startFrame_vector))
            rm(sprintf('%s%s.%d_%d.procFrame.mat',localpath, FilePrefix, startFrame_vector(kk), frameEnd_vector(kk)));
        end
    end
    
        
    % save the background and ring as a pdf
    hidden_figure(15);
    imshow(global_background);
    hold on;
    plot(Ring.RingX, Ring.RingY,'.g','markersize',2);
    if(isfield(Ring,'arena_name'))
        for(t=1:length(Ring.arena_name))
            text(Ring.arena_center(t,1), Ring.arena_center(t,2), fix_title_string(Ring.arena_name{t}), 'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center','color','g');
        end
    end
    dummystring = fix_title_string(sprintf('%s.avi ring area = %f level = %f %dx%d pixels %f pixel/mm',FilePrefix, Ring.Area, Ring.Level, FileInfo.Height, FileInfo.Width, 1/Ring.PixelSize));
    title(dummystring);
    dummystring = sprintf('%s%s.bkgnd.ring.pdf',localpath, FilePrefix);
    if(isempty(Ring.ComparisonArrayX))
        dummystring = sprintf('%s%s.bkgnd.no_ring.pdf',localpath, FilePrefix);
    end
    save_pdf(15, dummystring);
    close(15);
    pause(1); % let the GUI catch up
    clear('global_background');
    
    
    % this movie has multiple arenas, so create a procFrame file for each
    % then, re-run this function for each procFrame file
    % then return
    if(isfield(Ring,'arena_name'))
        multi_arena_split_procFrame(procFrame, Ring, stimulusfile, localpath, FilePrefix);
        return;
    end
    
else
    disp([sprintf('loading procFrame file %s .... %s\n',procFrame_file,timeString())])
    procFrame = load_procFrame(procFrame_file);
end

if(isempty(Ring))
    ringfile = sprintf('%s%s.Ring.mat',localpath, FilePrefix);
    load(ringfile);
    if(isfield(Ring,'arena_name'))
        multi_arena_split_procFrame(procFrame, Ring, stimulusfile, localpath, FilePrefix);
        
        % clear any child m-files in temp
        rm(sprintf('%schild_command_script_%d*.m', tempdir,Prefs.PID));
        
        return;
    end
end

    if(isempty(Ring.ring_mask))
        Prefs.aggressive_wormfind_flag = 0;
    end
    
disp(sprintf('assigning animals to tracks\t%s',timeString()))

% additional info
if(isempty(FileInfo))
    FileInfo = moviefile_info(RealMovieName);
end
rawTracks = create_tracks(procFrame, FileInfo.Height, FileInfo.Width, Ring.PixelSize, Prefs.FrameRate, fullpath_from_filename(RealMovieName));
clear('localname');
clear('dummystring');


% Save rawTracks
if(nargin == 0)  % interactive
    FileName = sprintf('%s.rawTracks.mat',FilePrefix);
    [FileName,localpath] = uiputfile(FileName, 'Save Track Data');
    if FileName ~= 0
        save_Tracks([localpath, FileName], rawTracks);
    end
else % command-line or batch
    FileName = sprintf('%s.rawTracks.mat',FilePrefix);
    dummystring = sprintf('%s%s',localpath,FileName);
    save_Tracks(dummystring, rawTracks);
    disp([sprintf('%s saved %s\n', dummystring, timeString())])
end

% analyse and save analysed Tracks
analyse_rawTracks(rawTracks, stimulusfile, localpath, FilePrefix);
if(nargout==0)
    clear('rawTracks')
end

% remove copy of movie from tempdir
aviread_to_gray('rm_temp');

% clear any child m-files in temp
rm(sprintf('%schild_command_script_%d*.m', tempdir,Prefs.PID));

Prefs = OPrefs;

return;
end
