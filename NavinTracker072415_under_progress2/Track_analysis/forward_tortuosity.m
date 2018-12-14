function tortuosity_vector = forward_tortuosity(Tracks)


tortuosity_vector = [];

fwd_state = num_state_convert('fwd');


for(t=1:length(Tracks))
    if(length(Tracks(t).SmoothX) >= 10*Tracks(t).FrameRate)
        i=1;
        start_idx = 1; end_idx = 2;
        while(i<length(Tracks(t).SmoothX))
            if(Tracks(t).State(i)==fwd_state)
                start_idx = i;
                while(Tracks(t).State(i)==fwd_state)
                    i=i+1;
                    if(i>length(Tracks(t).SmoothX))
                        break;
                    end
                end
                end_idx = i-1;
                if(end_idx - start_idx > 10*Tracks(t).FrameRate)
                    exploration_stats = track_exploration_stats(Tracks(t), Tracks(t).Time(start_idx), Tracks(t).Time(end_idx));
                    tortuosity_vector = [tortuosity_vector exploration_stats.tortuosity];
                end
            else
                i=i+1;
            end
        end
    end
end

return;
end
