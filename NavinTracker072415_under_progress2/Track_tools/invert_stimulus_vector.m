function outvector = invert_stimulus_vector(stim_vector, stimcode)

if(nargin<2)
    stimcode = 1;
end

outvector = [];
for(i=1:length(stim_vector))
    if(stim_vector(i)==stimcode);
        outvector(i) = 0;
    else
        if(stim_vector(i)==0)
            outvector(i) = stimcode;
        else
            outvector(i) = stim_vector(i);
        end
    end
    
end

return;
end
