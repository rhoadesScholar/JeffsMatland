function PathBounds = splitGetPathBounds(Tracks, TrackNum)

bufferSize = 2; %number of pixels around the path

mins = min(Tracks(TrackNum).Path(:,:));
minX = mins(1);
minY = mins(2);

maxs = max(Tracks(TrackNum).Path(:,:));
maxX = maxs(1);
maxY = maxs(2);

minX = max(minX-bufferSize, 1);
minY = max(minY-bufferSize, 1);

maxX = min(maxX+bufferSize, Tracks(TrackNum).Width);
maxY = min(maxY+bufferSize, Tracks(TrackNum).Height);

PathBounds = [ minX minY maxX maxY ];

return

end