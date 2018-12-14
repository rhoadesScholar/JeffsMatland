function outTracks = sort_tracks_by_length(Tracks, realframes_flag)

if(nargin<2)
    realframes_flag = 0;
end

numTracks = length(Tracks);

timearray=[];

% sort by "middleness"
if(ischar(realframes_flag))
    mid = (min_struct_array(Tracks,'Time') + max_struct_array(Tracks,'Time') )/2.0;
    for(i=1:numTracks)
        timearray = [timearray, middleness(Tracks(i).Time, mid)]; % Tracks(i).numActiveFrames]; % middleness(Tracks(i).Time, mid)];  % [timearray, Tracks(i).NumFrames];
    end
else
    
    % sort by tracklength
    
    if(realframes_flag==1)
        for(i=1:numTracks)
            timearray = [timearray, -length(Tracks(i).Frames)];
        end
    else
        if(isfield(Tracks,'numActiveFrames'))
            for(i=1:numTracks)
                timearray = [timearray, -Tracks(i).numActiveFrames];
            end
        else
            for(i=1:numTracks)
                timearray = [timearray, -length(Tracks(i).Frames)];
            end
        end
    end
end

[s, idx] = sort(timearray);
outTracks = Tracks(idx);

% maxFrames = outTracks(1).NumFrames;

% maxFrames = 0;
% for(i=1:length(outTracks))
%     if(outTracks(i).NumFrames > maxFrames)
%         maxFrames = outTracks(i).NumFrames;
%     end
% end

% minNumFrames = Prefs.minFracLongTrack*maxFrames;

% swap short tracks w/ longer ones
% NumLongTracks = 0;
% for(i=1:length(outTracks))
%     if(outTracks(i).numActiveFrames <  minNumFrames)
%         j=i+1;
%         if(j<=length(outTracks))
%             while(outTracks(j).numActiveFrames <  minNumFrames)
%                 j=j+1;
%                 if(j>length(outTracks))
%                     break;
%                 end
%             end
%             if(j<=length(outTracks))
%                 if(outTracks(j).numActiveFrames >=  minNumFrames)
%                     t1 = outTracks(i);
%                     outTracks(i) = outTracks(j);
%                     outTracks(j) = t1;
%                 end
%             end
%         end
%     end
% end

%     minNumFrames
%     for(i=1:length(outTracks))
%         outTracks(i).numActiveFrames
%     end

clear('timearray');
clear('idx');

return;
end

function n = middleness(x, mid)

% how close to the middle of the assaytime is this track?

n = (mid - (max(x) + min(x) )/2.0)^2;

return;
end
