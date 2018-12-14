function [psth_Tracks, psth_BinData] = psth_per_movie_averaging(RawTracksFiles, localpath, prefix, transition_vector)

global Prefs;

OPrefs = Prefs;
Prefs.FreqBinSize = Prefs.psthFreqBinSize;


psth_pre_stim_period = Prefs.psth_pre_stim_period;
psth_post_stim_period = Prefs.psth_post_stim_period;


psth_Tracks = [];
psth_BinData_array=[];
for i = 1:length(RawTracksFiles)
    
    localprefix = RawTracksFiles(i).name(1:length(RawTracksFiles(i).name)-14); % get prefix from prefix.rawTracks.mat
    
    psthTracks_filename = sprintf('%s%s.psth_Tracks.mat',localpath,localprefix);
    bindata_filename = sprintf('%s%s.psth.BinData.mat',localpath,localprefix);
        
    if(file_existence(psthTracks_filename)==0 || file_existence(bindata_filename)==0)
        return;
    end
    
    disp([sprintf('loading %s',psthTracks_filename)])
    t1 = load(psthTracks_filename);
    psth_Tracks = [psth_Tracks t1.psth_Tracks];
    clear('t1');
    
    t1 = load_BinData(bindata_filename);
    psth_BinData_array = [psth_BinData_array t1];
    clear('t1');
    
    clear('psthTracks_filename');
    clear('bindata_filename');
    
end

psth_Tracks = sort_tracks_by_length(psth_Tracks);

if(~isempty(localpath))
    dummystring = sprintf('%s%s%s.psth_Tracks.mat',localpath, filesep, prefix);
else
    dummystring = sprintf('%s.psth_Tracks.mat',prefix);
end
disp([sprintf('saving %s',dummystring)]);
save_Tracks(dummystring, psth_Tracks);


if(~isempty(localpath))
    dummystring = sprintf('%s%s%s.psth_BinData_array.mat',localpath, filesep, prefix);
else
    dummystring = sprintf('%s.psth_BinData_array.mat',prefix);
end
disp([sprintf('saving %s',dummystring)]);
save(dummystring, 'psth_BinData_array');



prefix = sprintf('%s.psth',prefix);

if(length(psth_BinData_array)>1 && strcmp(Prefs.averaging_type,'per-movie'))
    psth_BinData = mean_BinData_from_BinData_array(psth_BinData_array);
else
    psth_BinData = psth_BinData_array(1);
    psth_BinData.num_movies = 1;
end
save_BinData(psth_BinData, localpath, prefix);

sL=[];
for(i=1:length(psth_Tracks))
    sL = [sL length(find(psth_Tracks(i).stimulus_vector > 0))];
end
stimlength = nanmedian(sL)/psth_Tracks(1).FrameRate;

stimulus = [0, stimlength, transition_vector(2)];


if(length(psth_BinData_array)>1 && strcmp(Prefs.averaging_type,'per-movie'))
    plot_data(psth_BinData_array, psth_Tracks, stimulus, localpath, prefix);
else
    plot_data(psth_BinData, psth_Tracks, stimulus, localpath, prefix);
end

close all;
plot_summary_data(psth_BinData_array, psth_Tracks, stimulus, localpath, prefix);
close all;

Prefs = OPrefs;

return;
end

