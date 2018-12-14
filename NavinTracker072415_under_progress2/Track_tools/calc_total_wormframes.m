function wormframes = calc_total_wormframes(tracks)
% wormframes = calc_total_wormframes(tracks)

wormframes = 0;
for(n = 1:length(tracks))
    wormframes = wormframes +  num_active_frames(tracks(n));
end

return;
end
