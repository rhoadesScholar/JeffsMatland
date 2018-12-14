function [peaks, valleys]=peakfind(vec, thresh, peaksearchingmode)
%PEAKFIND find the peaks and valleys of a time series using threshold
%tracking
%
%    [PEAKS,VALLEYS] = PEAKFIND(VEC,THRESH,PEAKSEARCHMODESTART) 
%
%    input:
%    VEC is a vector time series
%    THRESH is an absolute threshold criterion (scalar)
%
%    output:
%    PEAKS and VALLEYS are Nx2 matrices. 
%    PEAKS(:,1) is a column vector of peak indices
%    PEAKS(:,2) is a column vector of peak values
%    contains indices in V, and column 2 the found values.
%
%    VALLEYS is the same structure for valleys
%
%    if peaksearchmodestart=1 then first search for a peak as we
%    scan from left to right
%    else if peaksearchmodestart ~= 1 otherwise first search for a valley
%    
%    by default, search for a peak first (say, if initial signal deflection 
%    is positive)
%
%    hints:
%    size(PEAKS,1) gives number of peaks
%    size(PEAKS,1) and size(VALLEYS,1) differ by at most 1
%    peaks and valleys always alternate    
%
%    ssk2133@columbia.edu
%
if nargin < 3
  peaksearchingmode=1;
end

if nargin < 2
    thresh=15;
end

peaks = [];
valleys = [];
max_tracker_val = -Inf;
min_tracker_val = Inf;
max_tracker_index = NaN;
min_tracker_index = NaN;

for i=1:length(vec)
    
  vi=vec(i);
  
  %update max_tracker_val if needed
  if vi > max_tracker_val
      max_tracker_val=vi;
      max_tracker_index=i; 
  end

  %update min_tracker_val if needed
  if vi < min_tracker_val
      min_tracker_val=vi;
      min_tracker_index=i;
  end
  
  if peaksearchingmode==1
      if vi < max_tracker_val-thresh
          peaks=[peaks ; max_tracker_index max_tracker_val]; %add entry to peaks
          min_tracker_index=i;  %move up min tracker to current time
          min_tracker_val=vi;
          peaksearchingmode=0;  %switch to valley searching
      end  
  else
      if vi > min_tracker_val+thresh
          valleys=[valleys ; min_tracker_index min_tracker_val];  %add entry to valleys
          max_tracker_index=i;  %move up max tracker to current time
          max_tracker_val=vi;
          peaksearchingmode=1;  %switch to peak searching
      end
  end
  
  
end
