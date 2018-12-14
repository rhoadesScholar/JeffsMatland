function [values,errs] = extract_stimulus_ON_avg(BinData, attribute, stattype, stimulus)

values=[];
errs=[];



for(i=1:length(stimulus))
    % stimulus i
    t1 = stimulus(i,1);
    t2 = stimulus(i,2);
    [val, stddev, err, n] = segment_statistics(BinData, attribute, stattype, t1, t2);
    
    values(i) = val;
    errs(i) = err;
    
end

return;
end

