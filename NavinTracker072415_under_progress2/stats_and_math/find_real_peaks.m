function idx = find_real_peaks(y)
% idx = find_real_peaks(y)


y2 = smooth(smooth(y)); % smooth the data
y2p_smooth = smooth(smooth([0 diff(y2)'])); % smooth the derivative


peak_idx = zero_crossing(y2p_smooth); % find zeros for the derivative; ie:peaks
thresh = (nanmean(y2) + nanmedian(y2))/2; 
thresh_std = nanstd(y2);
above_thresh_idx = find(y2>(thresh + thresh_std) | y2<(thresh - thresh_std)) ; % peaks are only those values above the mean

idx = intersect(peak_idx, above_thresh_idx);

return;
end
