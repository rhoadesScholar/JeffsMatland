function [frac, std, sem, n_total] = fraction_events_initiated_in_timewindow(inputTracks, event_type, timewindow)
% [frac, std, sem, n_total] = fraction_events_initiated_in_timewindow(inputTracks, event_type, timewindow)
% uses tracks in a forward state for 1sec prior to timewindow(1)

if(isempty(inputTracks))
    frac = NaN;
    std = NaN;
    sem = NaN;
    n_total = NaN;
    return;
end

srev_code = num_state_convert('srev');
lrev_code = num_state_convert('lrev');
omega_code = num_state_convert('omega');
upsilon_code = num_state_convert('upsilon');
fwd_code = num_state_convert('fwd');

if(nargin < 3)
    disp('usage: [frac, std, sem, n_total] = fraction_events_initiated_in_timewindow(inputTracks, event_type, timewindow)')
    return;
end

event_type = lower(event_type);

if(~strcmp(event_type,'response'))
    mvt_code = num_state_convert(event_type);
end


Tracks = extract_track_segment(inputTracks, timewindow(1)-2, timewindow(end), 'time');

starttime = min_struct_array(Tracks,'Time');
endtime = max_struct_array(Tracks,'Time');

% mostly paused ... maybe dead or injured so edit out
pause_code = num_state_convert('pause');
for(i=1:length(Tracks))
    Tracks(i).numActiveFrames = num_active_frames(Tracks(i));
end

% del_idx=[];
% for(i=1:length(Tracks))
%     if(length(find(abs(Tracks(i).State - pause_code)<1e-4)) >  0.8*Tracks(i).numActiveFrames)
%         del_idx = [del_idx i];
%     end
%     if(Tracks(i).Time(1) > starttime || Tracks(i).Time(end) < endtime)
%         del_idx = [del_idx i];
%     end
%     
%     if(Tracks(i).numActiveFrames < (endtime-starttime)*Tracks(i).FrameRate )
%         del_idx = [del_idx i];
%     end
%     
% end
% del_idx = unique(del_idx);
% Tracks(del_idx) = [];

n_total = 0;
frac = 0;
for(i=1:length(Tracks))
        n_total = n_total+1;
        
        idx = [];
        if(strcmp(event_type,'lrev') || strcmp(event_type,'srev') || strcmp(event_type,'omega') || strcmp(event_type,'upsilon'))
            idx = find(floor(Tracks(i).mvt_init) == mvt_code);
        else
            if(strcmp(event_type,'response'))
                % idx = find(floor(Tracks(i).mvt_init) > fwd_code);
                idx = find(floor(Tracks(i).mvt_init) == srev_code | floor(Tracks(i).mvt_init) == lrev_code | floor(Tracks(i).mvt_init) == omega_code);
            else
                if(strcmp(event_type,'rev'))
                    idx = find(floor(Tracks(i).mvt_init) == srev_code | floor(Tracks(i).mvt_init) == lrev_code);
                else
                    idx = find(abs((Tracks(i).mvt_init) - mvt_code) < 1e-4);
                end
            end
        end
        
        if(~isempty(idx))
            frac = frac+1;
        else
%             i
%             Tracks(i).Time
%             floor(Tracks(i).State)
%             floor(Tracks(i).mvt_init)
%             pause
        end
end
frac = frac/n_total;

std = sqrt(frac*(1-frac));
sem = std/sqrt(n_total);

return;
end
