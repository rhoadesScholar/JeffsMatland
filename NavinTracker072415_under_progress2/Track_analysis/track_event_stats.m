function event_stats = track_event_stats(inputTrack, starttime, endtime)
% event_stats = track_event_stats(Track, [starttime], [endtime])
% event_stats has total number of events, their frequencies,
% and fraction of time spent in each state for the Track

if(nargin<1)
    disp('usage: event_stats = track_event_stats(Track, [starttime], [endtime])')
    disp('event_stats has total number of events, their frequencies,')
    disp('and fraction of time spent in each state for the Track')
    return
end

if(length(inputTrack)>1)
    for(i=1:length(inputTrack))
        if(nargin>2)
            event_stats(i) = track_event_stats(inputTrack(i), starttime, endtime);
        else
            event_stats(i) = track_event_stats(inputTrack(i));
        end
    end
    return;
end


if(nargin>2)
    Track = extract_tracks(inputTrack, starttime, endtime);
else
    Track = inputTrack;
end

if(isempty(Track))
    event_stats.num_pure_sRev = NaN;
    event_stats.num_sRevOmega = NaN;
    event_stats.num_sRevUpsilon = NaN;
    event_stats.num_pure_lRev = NaN;
    event_stats.num_lRevOmega = NaN;
    event_stats.num_lRevUpsilon = NaN;
    event_stats.num_pure_omega = NaN;
    event_stats.num_pure_upsilon = NaN;
    event_stats.num_sRev = NaN;
    event_stats.num_lRev = NaN;
    event_stats.num_omega = NaN;
    event_stats.num_upsilon = NaN;
    event_stats.num_rev = NaN;
    event_stats.num_pure_rev = NaN;
    event_stats.num_omegaUpsilon = NaN;
    event_stats.num_pure_omegaUpsilon = NaN;
    event_stats.sRev_freq = NaN;
    event_stats.lRev_freq = NaN;
    event_stats.omega_freq = NaN;
    event_stats.upsilon_freq = NaN;
    event_stats.rev_freq = NaN;
    event_stats.pure_rev_freq = NaN;
    event_stats.omegaUpsilon_freq = NaN;
    event_stats.pure_omegaUpsilon_freq = NaN;
    event_stats.pure_sRev_freq = NaN;
    event_stats.sRevOmega_freq = NaN;
    event_stats.sRevUpsilon_freq = NaN;
    event_stats.pure_lRev_freq = NaN;
    event_stats.lRevOmega_freq = NaN;
    event_stats.lRevUpsilon_freq = NaN;
    event_stats.pure_omega_freq = NaN;
    event_stats.pure_upsilon_freq = NaN;
    event_stats.frac_sRev = NaN;
    event_stats.frac_lRev = NaN;
    event_stats.frac_omega = NaN;
    event_stats.frac_upsilon = NaN;
    event_stats.frac_pause = NaN;
    event_stats.frac_forward = NaN;
    return;
end

state = floor(Track.State);
num_ring_frames = length(find(state==num_state_convert('ring')));
num_nonring_frames = length(inputTrack.Frames) - num_ring_frames;
delta_t = Track.Time(end)-Track.Time(1);

event_stats.num_pure_sRev = 0;
event_stats.num_sRevOmega = 0;
event_stats.num_sRevUpsilon = 0;
event_stats.num_pure_lRev = 0;
event_stats.num_lRevOmega = 0;
event_stats.num_lRevUpsilon = 0;
event_stats.num_pure_omega = 0;
event_stats.num_pure_upsilon = 0;

for(i=1:length(Track.Reorientations))
    if(strcmpi(Track.Reorientations(i).class,'pure_sRev'))
        event_stats.num_pure_sRev = event_stats.num_pure_sRev+1;
    else
        if(strcmpi(Track.Reorientations(i).class,'sRevOmega'))
            event_stats.num_sRevOmega = event_stats.num_sRevOmega+1;
        else
            if(strcmpi(Track.Reorientations(i).class,'pure_sRevUpsilon'))
                event_stats.num_sRevUpsilon = event_stats.num_sRevUpsilon+1;
            else
                if(strcmpi(Track.Reorientations(i).class,'pure_lRev'))
                    event_stats.num_pure_lRev = event_stats.num_pure_lRev+1;
                else
                    if(strcmpi(Track.Reorientations(i).class,'lRevOmega'))
                        event_stats.num_lRevOmega = event_stats.num_lRevOmega+1;
                    else
                        if(strcmpi(Track.Reorientations(i).class,'lRevUpsilon'))
                            event_stats.num_lRevUpsilon = event_stats.num_lRevUpsilon+1;
                        else
                            if(strcmpi(Track.Reorientations(i).class,'pure_omega'))
                                event_stats.num_pure_omega = event_stats.num_pure_omega+1;
                            else
                                if(strcmpi(Track.Reorientations(i).class,'pure_upsilon'))
                                    event_stats.num_pure_upsilon = event_stats.num_pure_upsilon+1;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

event_stats.num_sRev = event_stats.num_pure_sRev + event_stats.num_sRevOmega + event_stats.num_sRevUpsilon;
event_stats.num_lRev = event_stats.num_pure_lRev + event_stats.num_lRevOmega + event_stats.num_lRevUpsilon;
event_stats.num_omega = event_stats.num_pure_omega + event_stats.num_lRevOmega + event_stats.num_sRevOmega;
event_stats.num_upsilon = event_stats.num_pure_upsilon + event_stats.num_lRevUpsilon + event_stats.num_sRevUpsilon;
event_stats.num_rev = event_stats.num_sRev + event_stats.num_lRev;
event_stats.num_pure_rev = event_stats.num_pure_sRev + event_stats.num_pure_lRev;
event_stats.num_omegaUpsilon = event_stats.num_omega + event_stats.num_upsilon;
event_stats.num_pure_omegaUpsilon = event_stats.num_pure_omega + event_stats.num_pure_upsilon;


event_stats.sRev_freq = event_stats.num_sRev/delta_t;
event_stats.lRev_freq= event_stats.num_lRev/delta_t;
event_stats.omega_freq = event_stats.num_omega/delta_t;
event_stats.upsilon_freq = event_stats.num_upsilon/delta_t;
event_stats.rev_freq = event_stats.num_rev/delta_t;
event_stats.pure_rev_freq = event_stats.num_pure_rev/delta_t;
event_stats.omegaUpsilon_freq = event_stats.num_omegaUpsilon/delta_t;
event_stats.pure_omegaUpsilon_freq = event_stats.num_pure_omegaUpsilon/delta_t;

event_stats.pure_sRev_freq = event_stats.num_pure_sRev/delta_t;
event_stats.sRevOmega_freq = event_stats.num_sRevOmega/delta_t;
event_stats.sRevUpsilon_freq = event_stats.num_sRevUpsilon/delta_t;
event_stats.pure_lRev_freq = event_stats.num_pure_lRev/delta_t;
event_stats.lRevOmega_freq = event_stats.num_lRevOmega/delta_t;
event_stats.lRevUpsilon_freq = event_stats.num_lRevUpsilon/delta_t;
event_stats.pure_omega_freq = event_stats.num_pure_omega/delta_t;
event_stats.pure_upsilon_freq = event_stats.num_pure_upsilon/delta_t;

event_stats.frac_sRev = length(find(state == num_state_convert('sRev')))/num_nonring_frames;
event_stats.frac_lRev = length(find(state == num_state_convert('lRev')))/num_nonring_frames;
event_stats.frac_omega = length(find(state == num_state_convert('omega')))/num_nonring_frames;
event_stats.frac_upsilon = length(find(state == num_state_convert('upsilon')))/num_nonring_frames;
event_stats.frac_pause = length(find(Track.State == num_state_convert('pause')))/num_nonring_frames;
event_stats.frac_forward = 1 - (event_stats.frac_sRev + event_stats.frac_lRev + event_stats.frac_omega + event_stats.frac_upsilon + event_stats.frac_pause);


return;
end
