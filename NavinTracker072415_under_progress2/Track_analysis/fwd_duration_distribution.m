function distrib = state_duration_distribution(Track,state)
% distrib = state_duration_distribution(Track,state)
% distrib is vector with durations of state state (in seconds)

state_code = num_state_convert(state);

distrib = [];

if(length(Track)>1)
    for(i=1:length(Track))
        distrib = [distrib state_duration_distribution(Track(i),state)];
    end
    return;
end

i=1;
while(i<=length(Track.State))
    if(abs(Track.State(i)-state_code)<=1e-4)
        p=0;
        while(abs(Track.State(i)-state_code)<=1e-4 && i<=length(Track.State))
            p=p+1;
            i=i+1;
            if(i>length(Track.State))
                break;
            end
        end
        if(p>0)
            distrib = [distrib p];
        end
    else
        i=i+1;
    end
end

distrib = distrib/Track.FrameRate;

return;
end
