function outTracks = sort_tracks_by_startframe(Tracks)

numTracks = length(Tracks);

timearray=[];

for(i=1:numTracks)
    timearray = [timearray, Tracks(i).Frames(1)];
end


[s, idx] = sort(timearray);

outTracks = Tracks(idx);


clear('timearray');
clear('idx');
clear('s');

return;
end
