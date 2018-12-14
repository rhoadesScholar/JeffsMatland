function [psth_Tracks, stimlength] = make_psth_Tracks(Tracks, secs_before_stim, secs_after_stim, transition_vector, keep_original_frames)
% [psth_Tracks, stimlength] = make_psth_Tracks(Tracks, secs_before_stim, secs_after_stim, transition_vector)
% stimulus (temporal or spatial ... 1 in Tracks.stimulus_vector means the worm is being stimulated
% creates new Tracks array where time = 0 is when the stimulus is turned
% on or off, as defined by transition_vector .... time_before and time_after stim are time
% before and after the transition included in the track
% transition_vector = [a b]

global Prefs;

if(nargin<5)
    keep_original_frames = 0;
end

FrameRate = Tracks(1).FrameRate;

num_frames_before = secs_before_stim*FrameRate;
num_frames_after = secs_after_stim*FrameRate;

psth_Tracks = [];
stimlength_vector = [];
pt = 0;
i=1;
while(i<=length(Tracks))
    f=2;
    length_track_i = length(Tracks(i).Frames);
    
    breakflag=0;

     % go past the stimulus at the start of the track
        while(Tracks(i).stimulus_vector(f) == transition_vector(2) || isnan(Tracks(i).stimulus_vector(f)))
            f=f+1;
            if(f == length_track_i)
                breakflag=1;
                break;
            end
        end
    
    
    while(f<length_track_i && breakflag==0)
        
        % advance to transition point
        while(sum(Tracks(i).stimulus_vector(f-1:f) == transition_vector)< 2)
            f=f+1;
            if(f == length_track_i)
                breakflag=1;
                break;
            end
        end

        if(breakflag == 0)

            if(f>1 && f<length_track_i)
                % find  num_frames_before and after the transition
                % if the exact frame is missing, find the nearest non-missing
                % frame
                a = f-num_frames_before;
                if(a<1)
                    a=1;
                end
                while(isnan(Tracks(i).Speed(a)))
                    a=a+1;
                end

                b=f+num_frames_after;
                if(b > length_track_i)
                    b=length_track_i;
                end
                while(isnan(Tracks(i).Speed(b)))
                    b=b-1;
                end

                if(a~=f && b~=f)
                    pt=pt+1;
                    
                    % sprintf('here %d\t%d\t%d\t%d\t%d\t%d',i,a,b,f,pt,length(Tracks(pt).Time))
                    
                    dummyTrack = extract_track_segment(Tracks(i), a, b);
                    
                    
                    
                    if(~isempty(dummyTrack))
                        % sprintf('%d\t%d\t%d\t%d\t%d\t%d',i,a,b,f,pt,length(psth_Tracks(pt).Time))
                        
                        % redefine the Times and Frames for psth_Tracks(pt) such that the first
                        % frame of the transition of interest is t=time_before_stim
                        
                        z = f-a+1; % transition frame
                        
                        if(z>0 && z<=length(dummyTrack.Time))
                            new_first_frame = num_frames_before+1;
                            
                            for(j=z-1:-1:1)
                                new_first_frame = new_first_frame-1;
                            end
                            
                            dummyTrack.real_first_frame = dummyTrack.Frames(1);
                            dummyTrack.real_start_time = dummyTrack.Time(1);
                            
                            
                            if(keep_original_frames==0)
                                dummyTrack = reframe_Track(dummyTrack, new_first_frame);
                                zerotime = dummyTrack.Time(z);
                                dummyTrack.Time = dummyTrack.Time - zerotime;
                            end
                            
                            
                            
                            psth_Tracks = [psth_Tracks dummyTrack];
                        end
                        
                    end
                    
                end
            end

            sL=1;
            while(Tracks(i).stimulus_vector(f) == transition_vector(2) || isnan(Tracks(i).stimulus_vector(f))) % walk past this stimulus event
                sL=sL+1;
                f=f+1;
                
                if(f == length_track_i)
                    breakflag=1;
                    break;
                end
            end
            
            stimlength_vector = [stimlength_vector sL];  % find the average stimulus length stimlength
            
        end

    end
    i=i+1;
    
    if(length(psth_Tracks)>Prefs.max_psth_Tracks_array)
        i = length(Tracks)+10;
    end
end

stimlength = nanmedian(stimlength_vector)/FrameRate;


% only tracks that span the entire time
psth_Tracks = sort_tracks_by_length(psth_Tracks);

% minlength = Prefs.minFracLongTrack*max_struct_array(psth_Tracks,'Frames');
% i=1;
% while(i<=length(psth_Tracks))
%     if(length(psth_Tracks(i).Frames) < minlength)
%         psth_Tracks(i) = [];
%     else
%         i=i+1;
%     end
% end

psth_Tracks = make_single(psth_Tracks);

return;
end
