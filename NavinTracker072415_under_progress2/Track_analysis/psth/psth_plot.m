function [psth_Tracks, psth_BinData] = psth_plot(Tracks, varargin)

global Prefs;

OPrefs = Prefs;
Prefs.FreqBinSize = Prefs.psthFreqBinSize;

Prefs.ethogram_orientation = 'vertical';
    
psth_pre_stim_period = Prefs.psth_pre_stim_period;
psth_post_stim_period = Prefs.psth_post_stim_period;

transition_vector = [0 1];

localpath = '';
prefix = prefix_from_path(pwd);


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
                    prefix = varargin{i};
                    i=i+1;
                else if(isnumeric(varargin{i})==1)
                        transition_vector = varargin{i};
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


[psth_Tracks, stimlength] = make_psth_Tracks(Tracks, psth_pre_stim_period, psth_post_stim_period, transition_vector);

if(~isempty(localpath))
    dummystring = sprintf('%s%s%s.psth_Tracks.mat',localpath, filesep, prefix);
else
    dummystring = sprintf('%s.psth_Tracks.mat',prefix);
end
disp([sprintf('saving %s',dummystring)]);
save_Tracks(dummystring, psth_Tracks);

stimulus = [0, stimlength, transition_vector(2)];

psth_BinData = bin_and_average_all_tracks(psth_Tracks, stimulus);

prefix = sprintf('%s.psth',prefix);

save_BinData(psth_BinData, localpath, prefix);

close all;
plot_data(psth_BinData, psth_Tracks, stimulus, localpath, prefix);
close all;
plot_summary_data(psth_BinData, psth_Tracks, stimulus, localpath, prefix);

Prefs = OPrefs;

return;
end

