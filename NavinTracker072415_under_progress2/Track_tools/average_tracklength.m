function [tracklength, lengths] = average_tracklength(tracks)
% [tracklength, lengths] = average_tracklength(tracks)

lengths = [];
tracklength = 0;

if(nargin<1)
    disp('[tracklength, lengths] = average_tracklength(tracks)')
    return
end

if(isempty(tracks))
    return;
end

for(i=1:length(tracks))
	lengths = [lengths tracks(i).numActiveFrames];
end

tracklength = round((nanmedian(lengths) + nanmean(lengths))/2);

return;
end
