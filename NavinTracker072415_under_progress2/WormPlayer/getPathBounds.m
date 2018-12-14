function [ minX minY maxX maxY ] = getPathBounds(hfig)

bufferSize = 2; %number of pixels around the path

movieData = get(hfig,'userdata');

mins = min(movieData.Tracks(movieData.TrackNum).Path(:,:));
minX = mins(1);
minY = mins(2);

maxs = max(movieData.Tracks(movieData.TrackNum).Path(:,:));
maxX = maxs(1);
maxY = maxs(2);

minX = max(minX-bufferSize, 1);
minY = max(minY-bufferSize, 1);

maxX = min(maxX+bufferSize, movieData.Tracks(movieData.TrackNum).Width);
maxY = min(maxY+bufferSize, movieData.Tracks(movieData.TrackNum).Height);

movieData.PathBounds = [ minX minY maxX maxY ];

set(hfig,'userdata', movieData);

return

end