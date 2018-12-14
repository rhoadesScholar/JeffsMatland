function [stim, non_stim] = get_stimulus_revlengths(Tracks, attribute)
% not yet done!!

stim = [];
non_stim = [];


if(attribute == 'Reversals')
for(i=1:length(Tracks))
    if(~isempty(Tracks(i).Reversals))
    for(j=1:length(Tracks(i).Reversals(:,1)))
            
        idx = find(Tracks(i).Frames == Tracks(i).Reversals(j,1));
        
            if(Tracks(i).stimulus_vector(idx)==1)
                stim = [stim Tracks(i).Reversals(j,3)];
            else
                non_stim = [non_stim Tracks(i).Reversals(j,3)];
            end
        
    end
    end
end
end

return;
end
