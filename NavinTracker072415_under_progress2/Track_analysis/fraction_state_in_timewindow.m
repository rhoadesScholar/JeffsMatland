function [frac, std, sem, n_total] = fraction_state_in_timewindow(BinData, mvt_types, timewindow)
% [frac, std, sem, n_total] = fraction_state_in_timewindow(inputBinData, mvt_types, timewindow)
% uses tracks in a forward state for 1sec prior to timewindow(1)

if(isempty(BinData))
    frac = zeros(1, length(mvt_types)) + NaN;
    std = frac;
    sem = frac;
    n_total = frac;
    return;
end

if(nargin < 2)
    disp('usage: [frac, std, sem, n_total] = fraction_state_in_timewindow(BinData, mvt_types, timewindow)')
    return;
end

if(nargin < 3)
    timewindow = [BinData.time(1) BinData.time(end)];
end

frac=[]; std=[];  sem=[]; n_total=[]; 

for(i=1:length(mvt_types))
    attrib = sprintf('frac_%s',mvt_types{i});
    [f, d, e, n] = segment_statistics(BinData, attrib, 'magnitude_weighted_mean', timewindow(1), timewindow(2));
    frac = [frac f];
    std = [std d];
    sem = [sem e];
    n_total = [n_total n];
end

return;
end
