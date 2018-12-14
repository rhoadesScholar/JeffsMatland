function [x,y] = Track_centroid(Track)

x = nanmean(Track.SmoothX);
y = nanmean(Track.SmoothY);

return;
end


