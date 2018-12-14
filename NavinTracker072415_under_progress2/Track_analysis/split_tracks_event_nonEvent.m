function [eventTracks, eventBinData, nonEventTracks, nonEventBinData] = split_tracks_event_nonEvent(Tracks, t0, tf, stimulus)
% [eventTracks, nonEventTracks] = split_tracks_event_nonEvent(Tracks, t0, deltaT, event)

global Prefs;
Prefs = define_preferences(Prefs);


if(nargin<4)
    stimulus=[];
end

OPrefs = Prefs;
Prefs.FreqBinSize = Prefs.psthFreqBinSize;
Prefs.ethogram_orientation = 'vertical';
    
psth_pre_stim_period = Prefs.psth_pre_stim_period;
psth_post_stim_period = Prefs.psth_post_stim_period;

omega_idx = []; upsilon_idx =[];
sRev_code = num_state_convert('sRev');
lRev_code = num_state_convert('lRev');
omega_code  = num_state_convert('omega');
upsilon_code = num_state_convert('upsilon');

eventTracks = [];
nonEventTracks = [];
for(i=1:length(Tracks))
    idx = find((Tracks(i).Time >= t0) & (Tracks(i).Time <= tf));
    local_mvt_init = Tracks(i).State(idx);
    srev_idx = find(floor(local_mvt_init) == sRev_code);
    lrev_idx = find(floor(local_mvt_init) == lRev_code);
    omega_idx = find(floor(local_mvt_init) == omega_code);
    upsilon_idx = find(floor(local_mvt_init) == upsilon_code);
    
    if(isempty(srev_idx) && isempty(lrev_idx) && isempty(omega_idx) && isempty(upsilon_idx))
        nonEventTracks = [nonEventTracks Tracks(i)];
    else
        eventTracks = [eventTracks Tracks(i)];
    end
end

eventBinData = bin_and_average_all_tracks(eventTracks, stimulus);
nonEventBinData = bin_and_average_all_tracks(nonEventTracks, stimulus);

close all
plot_data(eventBinData, eventTracks, stimulus, '', 'N2_revomegaupsilon_10sec');
close all
plot_data(nonEventBinData, nonEventTracks, stimulus, '', 'N2_no_revomegaupsilon_10sec');

open N2_revomegaupsilon_10sec.pdf
open N2_no_revomegaupsilon_10sec.pdf

Prefs = OPrefs;

return;
end
