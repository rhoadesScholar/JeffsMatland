function [on_psth_Tracks, on_psth_BinData, off_psth_Tracks, off_psth_BinData] = stimulus_on_off_plots(Tracks, varargin)

global Prefs;

OPrefs = Prefs;
Prefs.FreqBinSize = Prefs.psthFreqBinSize;
Prefs.ethogram_orientation = 'vertical';


psth_pre_stim_period = Prefs.psth_pre_stim_period;
psth_post_stim_period = Prefs.psth_post_stim_period;

localpath = '';
inputprefix = prefix_from_path(pwd);

stimcode=10;

i=1;
while(i<=length(varargin))
    if(strfind(varargin{i},'before')==1)
        i=i+1;
        psth_pre_stim_period = varargin{i};
        i=i+1;
    else if(strfind(varargin{i},'after')==1)
            i=i+1;
            psth_post_stim_period = varargin{i};
            i=i+1;
        else if(strfind(varargin{i},'path')==1)
                i=i+1;
                localpath = varargin{i};
                i=i+1;
            else if(strcmp(varargin{i},'prefix')==1)
                    i=i+1;
                    inputprefix = varargin{i};
                    i=i+1;
                else if(isnumeric(varargin{i})==1)
                        stimcode = varargin{i};
                        i=i+1;
                    else
                        sprintf('Error in psth_plot: Do not recognize %s',varargin(i))
                        return
                    end
                end
            end
        end
    end
end

psth_type_string = sprintf('stim_on');
prefix = sprintf('%s.%s',inputprefix, psth_type_string);

on_psth_Tracks = make_stimulus_on_psth_Tracks(Tracks, psth_pre_stim_period, psth_post_stim_period, stimcode);
if(~isempty(localpath))
    dummystring = sprintf('%s%s%s.psth_Tracks.mat',localpath, filesep, prefix);
else
    dummystring = sprintf('%s.psth_Tracks.mat',prefix);
end
psth_Tracks = on_psth_Tracks;
save_Tracks(dummystring, psth_Tracks);
clear('psth_Tracks');

stimulus = [0, max_struct_array(on_psth_Tracks,'Time'), stimcode];
on_psth_BinData = bin_and_average_all_tracks(on_psth_Tracks, stimulus);
save_BinData(on_psth_BinData, localpath, prefix);

close all;
plot_data(on_psth_BinData, on_psth_Tracks, stimulus, localpath, prefix);
disp([sprintf('plotted %s',prefix)]);

psth_type_string = sprintf('stim_off');
prefix = sprintf('%s.%s',inputprefix, psth_type_string);

for(i=1:length(Tracks))
    Tracks(i).stimulus_vector = invert_stimulus_vector(Tracks(i).stimulus_vector, stimcode);
end

off_psth_Tracks = make_stimulus_on_psth_Tracks(Tracks, psth_pre_stim_period, psth_post_stim_period, stimcode);
if(~isempty(localpath))
    dummystring = sprintf('%s%s%s.psth_Tracks.mat',localpath, filesep, prefix);
else
    dummystring = sprintf('%s.psth_Tracks.mat',prefix);
end
psth_Tracks = off_psth_Tracks;
save_Tracks(dummystring, psth_Tracks);
clear('psth_Tracks');
clear('stimulus');

stimulus = [min_struct_array(off_psth_Tracks,'Time'), 0, stimcode];

off_psth_BinData = bin_and_average_all_tracks(off_psth_Tracks);
save_BinData(off_psth_BinData, localpath, prefix);

close all;
plot_data(off_psth_BinData, off_psth_Tracks, stimulus, localpath, prefix);
disp([sprintf('plotted %s',prefix)]);

Prefs = OPrefs;

return;
end

