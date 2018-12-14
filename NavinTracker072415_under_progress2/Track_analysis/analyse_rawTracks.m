function analyse_rawTracks(rawTracks, stimulusfile, localpath, FilePrefix, plotflag)
% analyse_rawTracks(rawTracks, stimulusfile, localpath, FilePrefix)

global Prefs;

if(nargin<5)
    plotflag=0;
end

OPrefs = Prefs;

FileName = sprintf('%s.Tracks.mat',FilePrefix);
trackfilename = sprintf('%s%s',localpath,FileName);

FileName = sprintf('%s.linkedTracks.mat',FilePrefix);
linkedfilename = sprintf('%s%s',localpath,FileName);

FileName = sprintf('%s.collapseTracks.mat',FilePrefix);
collapsefilename = sprintf('%s%s',localpath,FileName);

FileName = sprintf('%s.BinData.mat',FilePrefix);
bindatafilename = sprintf('%s%s',localpath,FileName);

FileName = sprintf('%s.rawTracks.mat',FilePrefix);
rawtracksfilename = sprintf('%s%s',localpath,FileName);

stimulus=[];
if(~isempty(stimulusfile))
    dummystring = sprintf('%s.psth_Tracks.mat',FilePrefix);
    dummystring = sprintf('%s%s',localpath,dummystring);
    if(does_this_file_need_making(dummystring,Prefs.track_analysis_date)==1)
        rm(bindatafilename);
        rm(collapsefilename);
    end
    
    if(isnumeric(stimulusfile)) % stimulusfile input is actually a stimulus array
        stimulus = stimulusfile;
    else
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
end


BinData = [];

% trackfilename
% does_this_file_need_making(trackfilename,Prefs.track_analysis_date)
% collapsefilename
% does_this_file_need_making(collapsefilename,Prefs.track_analysis_date)
% linkedfilename
% does_this_file_need_making(linkedfilename,Prefs.track_analysis_date)
% bindatafilename
% does_this_file_need_making(bindatafilename,Prefs.track_analysis_date)

% analyse if Tracks, linked, collapse files does not exist, or is too old, or if rawTracks is new
if(does_this_file_need_making(trackfilename,Prefs.track_analysis_date)==1 || ...
        does_this_file_need_making(collapsefilename,Prefs.track_analysis_date)==1 || ...
        does_this_file_need_making(linkedfilename,Prefs.track_analysis_date)==1 || ...
        does_this_file_need_making(bindatafilename,Prefs.track_analysis_date)==1 )
    
    if(isempty(rawTracks))
        disp([sprintf('loading %s %s\n', rawtracksfilename, timeString())])
        load(rawtracksfilename);
    end
    
    Prefs.FrameRate = rawTracks(1).FrameRate;
    Prefs = CalcPixelSizeDependencies(Prefs, rawTracks(1).PixelSize);
    
    
    NumTracks = length(rawTracks);
    if(does_this_file_need_making(trackfilename,Prefs.track_analysis_date)==1)
        tic;
        num_frames=0;
        for TN = 1:NumTracks
            num_frames = num_frames + length(rawTracks(TN).Frames);
            if(~mod(TN, 50) || TN==1)
                calcrate = toc/num_frames;
                disp([sprintf('Analyzing track segment %d/%d\t%f secs/wormframe\t%s',TN,NumTracks,calcrate,timeString())]);
                tic; num_frames=0;
            end
            
            Tracks(TN) = AnalyseTrack(rawTracks(TN));
        end
        
        clear('rawTracks');
        
        Tracks = attach_stimulus_vector_to_tracks(Tracks, stimulus);
        Tracks = sort_tracks_by_starttime(Tracks); % sort the tracks in the file by starting time
        
        FileName = sprintf('%s.Tracks.mat',FilePrefix);
        dummystring = sprintf('%s%s',localpath,FileName);
        disp([sprintf('saving %s %s\n', dummystring, timeString())])
        save_Tracks(dummystring, Tracks);
        disp([sprintf('%s saved %s\n', dummystring, timeString())])
    else
        disp([sprintf('loading %s %s\n', trackfilename, timeString())])
        Tracks = load_Tracks(trackfilename);
    end
    
    FileName = sprintf('%s.linkedTracks.mat',FilePrefix);
    dummystring = sprintf('%s%s',localpath,FileName);
    if(~file_existence(dummystring))
        linkedTracks = link_tracks(Tracks);
        clear('Tracks');
        
        % linkage w/o regard for direction
        linkedTracks = link_tracks(linkedTracks, 1, 0, 1, 'interpolate');
        
        % if only 1 worm, link w/o regard for distance
        if(round(nanmean(num_worms_per_frame(linkedTracks)))<=2)
            FileName = sprintf('%s.linkedTracks.mat',FilePrefix);
            dummystring = sprintf('%s%s',localpath,FileName);
            save_Tracks(dummystring, linkedTracks);
            
            linkedTracks = aggresive_track_linkage(linkedTracks);
            
            FileName = sprintf('%s.forced.linkedTracks.mat',FilePrefix);
            dummystring = sprintf('%s%s',localpath,FileName);
            save_Tracks(dummystring, linkedTracks);
        else
            
            FileName = sprintf('%s.linkedTracks.mat',FilePrefix);
            dummystring = sprintf('%s%s',localpath,FileName);
            
            disp([sprintf('saving %s %s\n', dummystring, timeString())])
            save_Tracks(dummystring, linkedTracks);
            disp([sprintf('%s saved %s\n', dummystring, timeString())])
        end
    else
        clear('Tracks');
        linkedTracks = load_Tracks(dummystring);
    end
    
    
    FileName = sprintf('%s.collapseTracks.mat',FilePrefix);
    dummystring = sprintf('%s%s',localpath,FileName);
    if(~file_existence(dummystring))
        collapseTracks = collapse_tracks(linkedTracks); % linkedTracks
        clear('linkedTracks');
        collapseTracks = shrink_collapseTracks(collapseTracks);
        
        FileName = sprintf('%s.collapseTracks.mat',FilePrefix);
        dummystring = sprintf('%s%s',localpath,FileName);
        
        disp([sprintf('saving %s\t%s', dummystring,timeString())])
        save_Tracks(dummystring,collapseTracks);
        disp([sprintf('%s saved\t%s', dummystring,timeString())])
    else
        clear('linkedTracks');
        collapseTracks = load_Tracks(dummystring);
    end
    
    disp([sprintf('binning and averaging\t%s', timeString())])
    if(Prefs.aggressive_wormfind_flag == 0)
        BinData = [];
        return;
    else
        BinData = bin_and_average_all_tracks(collapseTracks, stimulus); % bin the data
    end
    save_BinData(BinData, localpath, FilePrefix);
    disp([sprintf('binning and averaging finished ... \t%s', timeString())])
    
end


if(isempty(BinData))
    BinData = load_BinData(bindatafilename);
end

if(~isempty(BinData))
    
    
    if(~isempty(localpath))
        outprefix = sprintf('%s%s',localpath,FilePrefix);
    else
        outprefix = prefix;
    end
    outfile = sprintf('%s.pdf',outprefix);
    
    if(~does_this_file_need_making(outfile))
        plotflag = 0;
    end
    
    if(plotflag==1)
        disp([sprintf('plotting data and ethograms\t%s', timeString())]);
        close all;
        try 
            plot_data(BinData, collapseTracks, stimulus, localpath, FilePrefix);
        catch
            load (collapsefilename);
            plot_data(BinData, collapseTracks, stimulus, localpath, FilePrefix);
        end
        
        if(~isempty(stimulus))
            
            [psth_Tracks, psth_BinData] = psth_plot(collapseTracks, 'path', localpath, 'prefix',FilePrefix,[0 stimulus(1,3)]);
            
            %             % only makes sense if we have more than one stimulus
            %             stim_ctr=0;
            %             for(s=1:length(stimulus(:,1)))
            %                 if(stimulus(s,3)>0)
            %                     stim_ctr=stim_ctr+1;
            %                 end
            %             end
            %             if(stim_ctr > 1)
            %                 [psth_Tracks, psth_BinData] = psth_plot(collapseTracks, 'path', localpath, 'prefix',FilePrefix,[0 stimulus(1,3)]);
            %             end
            
        end
    end
end

Prefs = OPrefs;

close all;

return;
end

