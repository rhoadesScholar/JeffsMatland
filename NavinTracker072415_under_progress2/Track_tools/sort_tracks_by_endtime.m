function outTracks = sort_tracks_by_endtime(Tracks)

numTracks = length(Tracks);

timearray=[];

for(i=1:numTracks)
    timearray = [timearray, Tracks(i).Time(end)];
end


[s, idx] = sort(timearray);

outTracks = Tracks(idx);


clear('timearray');
clear('idx');
clear('s');

return;
end
