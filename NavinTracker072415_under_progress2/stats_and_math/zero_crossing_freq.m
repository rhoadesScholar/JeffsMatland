function freq = zero_crossing_freq(value_vector, windowsize)
% freq = zero_crossing_freq(value_vector, windowsize)

if(nargin<2)
    windowsize = 10;
end

freq = [];

start_idx=1;
while(start_idx<=length(value_vector))

    local_winsize = windowsize;
    end_idx = start_idx+windowsize-1;
    if(end_idx>length(value_vector))
        end_idx = length(value_vector);
        local_winsize = end_idx-start_idx+1;
    end
   
    
    num_zero_crossings = length(zero_crossing(value_vector(start_idx:end_idx), [], 0, 'none'));
        
    freq = [freq num_zero_crossings/local_winsize];
        
    start_idx = start_idx + windowsize;
end

return;
end
