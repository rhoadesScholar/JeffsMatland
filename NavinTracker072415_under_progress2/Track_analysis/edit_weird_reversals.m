function Track = edit_weird_reversals(Track)
% Track = edit_weird_reversals(Track)
% identifies weird reversals
% usually associated with very slow worms that do a reversal

global Prefs;

%srev_code = num_state_convert('sRev');
%lrev_code = num_state_convert('lRev');
%omega_code = num_state_convert('omega');
fwd_code = num_state_convert('forward');
%pause_code = num_state_convert('pause');
pure_upsilon_code = num_state_convert('pure_upsilon');

fps = Track.FrameRate;
tracklen = length(Track.State);
pixelWormLength = Track.Wormlength/Track.PixelSize;

% angspeed change for forward or pure_upsilon may be a weird reversal
high_ang_not_rev = find( ( abs(Track.AngSpeed) > Prefs.RevAngSpeedThreshold ) & ...
    ( Track.State==pure_upsilon_code | Track.State==fwd_code ) );

% Track.Frames(high_ang_not_rev)

idx = [];
flip_head_tail_vector  = flip_head_tail(Track);
flip_head_tail_vector = CalcDif(flip_head_tail_vector,1);
idx = find( ( abs(flip_head_tail_vector)>0 ) & ...
    ( Track.State==pure_upsilon_code | Track.State==fwd_code ) );

% Track.Frames(idx)

high_ang_not_rev = sort(unique([high_ang_not_rev idx]));

% Track.Frames(high_ang_not_rev)

if(isempty(high_ang_not_rev))
    return;
end

i=1;
while(i<=length(high_ang_not_rev))
    j = find_end_of_contigious_stretch(high_ang_not_rev, i);
    
    if(high_ang_not_rev(j)<tracklen)
    
        peak_idx = high_ang_not_rev(i:j);
        pre_idx = max(1,(high_ang_not_rev(i)-2*fps)):max(1,(high_ang_not_rev(i)-1));
        post_idx = min(tracklen,(high_ang_not_rev(j)+1)):min(tracklen,(high_ang_not_rev(j)+2*fps));
    
        dir_before = (mean_direction(Track.Direction(pre_idx)));
        dir_after = (mean_direction(Track.Direction(post_idx)));
        delta_dir = delta_direction(dir_before, dir_after);
        
        
        % [high_ang_not_rev(j) delta_dir dir_before dir_after]
        
        rev_idx = [];
        % likely in a weird reversal
        if(abs(delta_dir) >= Prefs.RevAngSpeedThreshold)
            
            % the angspeed peak is part of the reversal
            t = peak_idx(end)+2;
            
            % find the next time the animal moves "forward" for 2 sec with Eccentricity > Prefs.ForwardEcc 
            stopflag=0;
            while(stopflag==0 && t<=tracklen)
                mean_ecc = nanmean(Track.Eccentricity(t:min(tracklen,t+2*fps)));
                
                if(mean_ecc > Prefs.ForwardEcc && nanmean(floor(Track.State(t:min(tracklen,t+2*fps))))==fwd_code)
                   stopflag=1;
                   dir_after = (mean_direction(Track.Direction(t:min(tracklen,t+2*fps))));
                end
                
                t = t + 1;
            end
            rev_idx = peak_idx(1):t-2;
            
%             % missing real frames so don't edit this track segment
%             k=1;
%             while(k<=length(rev_idx))
%                if(isempty(Track.Image{rev_idx(k)}))
%                    rev_idx = [];
%                end
%                k=k+1;
%             end
            
        end
        
        if(~isempty(rev_idx))
            % delete any Reorientations with frames in this range
            del_idx=[];
            for(k=1:length(Track.Reorientations))
                if(   (Track.Reorientations(k).start >= rev_idx(1) && Track.Reorientations(k).start <= rev_idx(end)) || ...
                      (Track.Reorientations(k).end >= rev_idx(1) && Track.Reorientations(k).end <= rev_idx(end))  )
                  del_idx = [del_idx k];
                end
            end
            Track.Reorientations(del_idx) = [];
            
            % identify post-reversal omega or upsilon 
            % start at the last frame of the event, and scoot back, find
            % peak < omega or upsilon thresh. Define peak -> fwd as the
            % event
            
            k = rev_idx(end);
            turn_idx = [];
            stopflag=0;
            while(stopflag==0)
                if( abs(Track.AngSpeed(k)) >= Prefs.AngSpeedThreshold )
                        stopflag=1;
                else
                    k = k-1;
                    if(k<rev_idx(1))
                        stopflag=1;
                    end
                end
            end
            
            if(k>rev_idx(1))
                turn_idx = k:rev_idx(end);
                if(length(turn_idx)>1)
                    rev_idx = rev_idx(1):(k-1);
                else
                    turn_idx = [];
                end
            end
            
            % if the reversal speed dips below Prefs.pauseSpeedThresh, define the
            % longest contigious stretch > Prefs.pauseSpeedThresh as the reversal
            if(~isempty(rev_idx))
                slow_idx = find(Track.Speed(rev_idx) <= Prefs.pauseSpeedThresh & Track.AngSpeed(rev_idx) < Prefs.AngSpeedThreshold);
                if(~isempty(slow_idx))
                    fast_idx = find(Track.Speed(rev_idx) > Prefs.pauseSpeedThresh | Track.AngSpeed(rev_idx) >= Prefs.AngSpeedThreshold);
                    
                    if(isempty(fast_idx))
                        rev_idx = [];
                    else
                        r = rev_idx(1)-1;
                        [start_idx, end_idx] = find_longest_contigious_stretch_in_array(fast_idx);
                        rev_idx = (r+fast_idx(start_idx)):(r+fast_idx(end_idx));
                    end
                end
            end
            
            revLen = 0;
            mean_speed = 0;
            revSpeed = 0;
            if(~isempty(rev_idx))
                revLen = track_path_length(Track, rev_idx(1), rev_idx(end))/pixelWormLength;
                mean_speed = (nanmean(Track.Speed([rev_idx turn_idx])) + nanmedian(Track.Speed([rev_idx turn_idx])))/2;
                revSpeed = (nanmean(Track.Speed(rev_idx)) + nanmedian(Track.Speed(rev_idx)) )/2; 
            end
            
            if(revLen > Prefs.SmallReversalThreshold && mean_speed > Prefs.pauseSpeedThresh && revSpeed > Prefs.pauseSpeedThresh && length(rev_idx) < 25*fps)
                
                % create reorientation structure for this event
                
                Reorientation.start = rev_idx(1);
                Reorientation.startRev = rev_idx(1);
                Reorientation.startTurn = NaN;
                Reorientation.end = max([rev_idx turn_idx]);
                Reorientation.revLen = revLen;
                Reorientation.revLenBodyBends = NaN;
                Reorientation.ecc = NaN;
                Reorientation.dir_before = dir_before;
                Reorientation.dir_after = dir_after;
                Reorientation.delta_dir = delta_direction(dir_before, dir_after);
                Reorientation.turn_delta_dir = NaN;
                Reorientation.class = '';
                Reorientation.mean_angspeed = Reorientation.delta_dir/( (Reorientation.end-Reorientation.start+1)/Prefs.FrameRate );
                Reorientation.revSpeed = revSpeed; 
                
                if(Reorientation.revLen >= Prefs.LargeReversalThreshold)
                    Reorientation.class = 'lRev';
                else
                    Reorientation.class = 'sRev';
                end
                
                if(~isempty(turn_idx))
                    Reorientation.startTurn = turn_idx(1);
                    Reorientation.ecc = min(Track.Eccentricity(turn_idx));
                    
                    % opposite direction of reversal
                    dir_pre_turn = corrected_bearing(mean_direction(Track.Direction(rev_idx)) + 180);
                    
                    dir_post_turn = dir_after;
                    
                    Reorientation.turn_delta_dir = (delta_direction(dir_pre_turn, dir_post_turn));
                    
                    if(Reorientation.ecc <= Prefs.OmegaEccThresh)
                        Reorientation.class = sprintf('%sOmega',Reorientation.class);
                    else
                        Reorientation.class = sprintf('%sUpsilon',Reorientation.class);
                    end
                else
                    Reorientation.class = sprintf('pure_%s',Reorientation.class);
                end
                
                Track.Reorientations = [Track.Reorientations, Reorientation];
                Track.Reorientations = sort_Reorientations(Track.Reorientations);
                

                % get past high_ang_not_rev > Reorientation.end
                j = find(high_ang_not_rev == Reorientation.end);
                r = Reorientation.end-1;
                while(isempty(j))
                    j = find(high_ang_not_rev == r);
                    r = r-1;
                end
                
                clear('Reorientation');
            end
        end
    end
    
    i=j+1;
end

Track.State = AssignLocomotionState(Track);
Track = worm_head_tail(Track);
[Track.body_angle, Track.head_angle, Track.tail_angle] = worm_body_angle(Track);

Track = edit_Reorientations(Track);

return;
end
