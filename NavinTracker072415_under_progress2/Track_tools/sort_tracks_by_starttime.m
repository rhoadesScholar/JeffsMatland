function outTracks = sort_tracks_by_starttime(Tracks)

numTracks = length(Tracks);

timearray=[];

%if(isfield(Tracks(1),'Time'))
%    for(i=1:numTracks)
%        timearray = [timearray, Tracks(i).Time(1)];
%    end
%else
    for(i=1:numTracks)
        timearray = [timearray, Tracks(i).Frames(1)];
    end
%end

[s, idx] = sort(timearray);

outTracks = Tracks(idx);


clear('timearray');
clear('idx');
clear('s');

return;
end
