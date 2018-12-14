function [values,errs] = extract_stimulus_preON_avg(BinData, attribute, stattype, stimulus)

values=[];
errs=[];

pre_stim_period=50;

for(i=1:length(stimulus))
    % stimulus i
    t1 = stimulus(i,1) - pre_stim_period;
    t2 = stimulus(i,1);
     [values, stddev, errs, n]  = segment_statistics(BinData, attribute, stattype, t1, t2);
    
end

return;
end



