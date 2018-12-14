% stimulus (temporal or spatial ... >1 in Tracks.stimulus_vector means the worm is being stimulated
% creates new Tracks array where time = 0 is when the stimulus is turned
% on or off, as defined by transition_vector .... time_before and time_after stim are time
% before and after the transition included in the track
% transition_vector = [a b]

function psth_Tracks = make_stimulus_on_psth_Tracks(Tracks, secs_before_stim, secs_after_stim_start, stimcode)

global Prefs;

transition_vector = [0 stimcode];

num_frames_before = secs_before_stim*Tracks(1).FrameRate;
num_frames_after = secs_after_stim_start*Tracks(1).FrameRate;

psth_Tracks=[];
pt = 0;
for(i=1:length(Tracks))
    a=1; t=2; b=3;
    length_track_i = length(Tracks(i).Frames);
    breakflag=0;
    
    while(t<length_track_i && breakflag==0)
                
        % identify the transition from transition_vector(1) -> transition_vector(2) in Tracks(i).stimulus_vector
        while(sum(abs(Tracks(i).stimulus_vector(t-1:t) - transition_vector)) ~= 0)
            t=t+1;
            if(t >= length_track_i)
                breakflag=1;
                break;
            end
        end
        
        if(breakflag==0)
            a=t-1;
            while(Tracks(i).stimulus_vector(a) == Tracks(i).stimulus_vector(t-1))
                a=a-1;
                if(a<=1)
                    a=1;
                    break;
                end
            end
            if(Tracks(i).stimulus_vector(a) ~= Tracks(i).stimulus_vector(t-1))
                a=a+1;
            end
            if(t-a > num_frames_before)
                a = t-num_frames_before+1;
            end
            
            b=t+1;
            if(b>=length_track_i)
                breakflag=1;
                b=length_track_i;
            end
            
            if(breakflag==0)
                
                while(Tracks(i).stimulus_vector(b) == Tracks(i).stimulus_vector(t))
                    b=b+1;
                    if(b>=length_track_i)
                        break;
                        breakflag=1;
                        b=length_track_i;
                    end
                end
                if(Tracks(i).stimulus_vector(b) ~= Tracks(i).stimulus_vector(t))
                    b=b-1;
                end
                if(b-t > num_frames_after)
                    b = t + num_frames_after-1;
                end
                
                if(a < t-1 && b > t+1)
                    pt=pt+1;
                    
                    dummyTrack = extract_track_segment(Tracks(i), a, b);
                    
                    
                    % redefine the Times and Frames for psth_Tracks(pt) such that the first
                    % frame of the transition of interest is
                    % t=time_before_stim
                    t2=2;
                    while(sum(abs(dummyTrack.stimulus_vector(t2-1:t2) - transition_vector)) ~= 0)
                        t2=t2+1;
                    end
                    
                    new_first_frame = num_frames_before+1;
                    
                    for(j=t2-1:-1:1)
                        new_first_frame = new_first_frame-1;
                    end
                    
                    dummyTrack.real_first_frame = dummyTrack.Frames(1);
                    dummyTrack.real_start_time = dummyTrack.Time(1);
                    
                    dummyTrack = reframe_Track(dummyTrack, new_first_frame);
                    
                    % reset the Time vector in dummyTrack such that
                    % the transition frame is set to 0
                    dummyTrack.Time = dummyTrack.Time - secs_before_stim;

                    psth_Tracks = [psth_Tracks dummyTrack];
                    
                    clear('dummyTrack');
                end
                
            end
        end
        t=b+1;
    end
    
end

% only tracks that span the entire time
psth_Tracks = sort_tracks_by_length(psth_Tracks);
minlength = Prefs.minFracLongTrack*max_struct_array(psth_Tracks,'Frames');
i=1;
while(i<=length(psth_Tracks))
    if(length(psth_Tracks(i).Frames) < minlength)
        psth_Tracks(i) = [];
    else
        i=i+1;
    end
end


psth_Tracks = make_single(psth_Tracks);

return;
end
