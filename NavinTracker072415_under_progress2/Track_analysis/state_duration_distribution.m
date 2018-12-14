function [distrib, t_start, t_end] = state_duration_distribution(Track,state)
% [distrib, t_start, t_end] = state_duration_distribution(Track,state)
% distrib is vector with durations of state state (in seconds)
% t_start(i) and t_end(i) are the start and end times for the segment whose
% duration is  distrib(i)

distrib = []; t_start = []; t_end = [];

if(length(Track)>1)
    for(i=1:length(Track))
        [d, t1 ,t2] = state_duration_distribution(Track(i),state);
        distrib = [distrib d];
        t_start = [t_start t1];
        t_end = [t_end t2];
    end
    return;
end

state_code = num_state_convert(state);

if(length(state_code)>1)
    Track.State = floor(Track.State);
end

for(k=1:length(state_code))
    
i=1;
while(i<=length(Track.State))
    if(abs(Track.State(i)-state_code(k))<=1e-4)
        p=0; t_start = [t_start i];
        while(abs(Track.State(i)-state_code(k))<=1e-4 && i<=length(Track.State))
            p=p+1;
            i=i+1;
            if(i>length(Track.State))
                break;
            end
        end
        if(p>0)
            distrib = [distrib p];
            t_end = [t_end i];
        end
    else
        i=i+1;
    end
end

end

distrib = distrib/Track.FrameRate;
t_start = t_start/Track.FrameRate;
t_end = t_end/Track.FrameRate;

return;
end
