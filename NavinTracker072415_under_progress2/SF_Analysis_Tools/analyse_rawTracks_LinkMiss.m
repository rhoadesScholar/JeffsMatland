function [Tracks, linkedTracks] = analyse_rawTracks_LinkMiss(rawTracks, stimulusfile, localpath, FilePrefix)

global Prefs;

FileName = sprintf('%s.Tracks.mat',FilePrefix); 
dummystring = sprintf('%s%s',localpath,FileName);

% analyse if Tracks file does not exist, or is too old, or if rawTracks is new
if(does_this_file_need_making(dummystring)==1 || ~isempty(rawTracks))

    if(isempty(rawTracks))
        FileName = sprintf('%s.rawTracks.mat',FilePrefix);
        dummystring = sprintf('%s%s',localpath,FileName);
        load(dummystring);
    end
    
    NumTracks = length(rawTracks);
    for TN = 1:NumTracks
        if(~mod(TN, 200) || TN==1)
            disp([sprintf('Analyzing track segment %d/%d\t%s',TN,NumTracks,timeString())])
        end

        Tracks(TN) = AnalyseTrack(rawTracks(TN));
    end

    stimulus=[];
    if(isnumeric(stimulusfile)) % stimulusfile input is actually a stimulus array
        stimulus = stimulusfile;
    else
        if(~isempty(stimulusfile))
            stimulus = load(stimulusfile);
        end
    end
    Tracks = attach_stimulus_vector_to_tracks(Tracks, stimulus);
    Tracks = sort_tracks_by_starttime(Tracks); % sort the tracks in the file by starting time

    Tracks = make_single(Tracks);
    FileName = sprintf('%s.Tracks.mat',FilePrefix);
    dummystring = sprintf('%s%s',localpath,FileName);
    save(dummystring, 'Tracks');
    disp([sprintf('%s saved %s\n', dummystring, timeString())])
    
    %linkedTracks = link_tracks(Tracks);
    linkedTracks = [];

    FileName = sprintf('%s.linkedTracks.mat',FilePrefix);
    dummystring = sprintf('%s%s',localpath,FileName);
    save(dummystring, 'linkedTracks');
    disp([sprintf('%s saved %s\n', dummystring, timeString())])

    
    %FileName = sprintf('%s.collapseTracks.mat',FilePrefix); 
    %dummystring = sprintf('%s%s',localpath,FileName);
    %collapseTracks = collapse_tracks(Tracks);
    %disp([sprintf('saving %s\t%s', dummystring,timeString())])
    %save(dummystring,'collapseTracks');
    %disp([sprintf('binning and averaging\t%s', timeString())])
    %BinData = [];
    %BinData = bin_and_average_all_tracks(collapseTracks, BinData); % bin the data
    %save_BinData(BinData, localpath, FilePrefix);
    %disp([sprintf('binning and averaging finished ... \t%s', timeString())])
%    plot_save_data(BinData, collapseTracks, stimulus, localpath, FilePrefix);

end

return;
end

