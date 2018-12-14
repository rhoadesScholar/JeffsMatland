function outTracks = sort_tracks_by_endFrame(Tracks)


numTracks = length(Tracks);

timearray=[];

for(i=1:numTracks)
    timearray = [timearray, Tracks(i).Frames(end)];
end


[s, idx] = sort(timearray);

outTracks = Tracks(idx);


clear('timearray');
clear('idx');

return;
end
