function [Tracks, early_tracks] = tracks_of_interest_for_chemotaxis(inputTracks, maxtime)
% [Tracks, early_tracks] = tracks_of_interest_for_chemotaxis(inputTracks, maxtime)
% maxtime is latest track start time in min (Default 30min)

if(nargin < 2)
    maxtime = 30;
end

% find tracks that enter the odor (stimulus_vector == 10)
% truncate 

t = 1; early_tracks = []; Tracks = [];
for(i=1:length(inputTracks))
    if(inputTracks(i).Time(1) <= maxtime*60)
        early_tracks = [early_tracks inputTracks(i)];
    end
    if(inputTracks(i).stimulus_vector(1) == 0)
        idx = find(inputTracks(i).stimulus_vector > 0);
        if(~isempty(idx)) % entered odor
            tr = extract_track_segment(inputTracks(i), 1, min(idx(1)+inputTracks(i).FrameRate, length(inputTracks(i).Frames)));
            
            if(length(tr.Frames) >= 10*tr.FrameRate)
                if(tr.Time(1) <= 30*60)
                    Tracks = [Tracks tr];
                    t = t+1;
                end
            end
            
        end
    end
end

Tracks = sort_tracks_by_startframe(Tracks);

return;
end
