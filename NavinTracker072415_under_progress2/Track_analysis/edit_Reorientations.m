function outTrack = edit_Reorientations(Track)

global Prefs;

fwd_state_code = num_state_convert('fwd_state');
fwd_code = num_state_convert('fwd');
pauseplus_code = num_state_convert('pause')+0.1;
pure_Upsilon_code = num_state_convert('pure_Upsilon');

critical_angle = 180-Prefs.MinDeltaHeadingUpsilon;

MaxUpsilonOmegaDurationFrames = Prefs.MaxUpsilonOmegaDuration*Track.FrameRate;

i=1;
while(i<=length(Track.Frames))
    if(~isnan(Track.body_angle(i)))
        if(Track.body_angle(i) <= critical_angle && Track.Eccentricity(i)<=Prefs.UpsilonEccThresh) % a potential turn
            if(floor(Track.State(i)) <= fwd_state_code) % currently classified as fwd
                
                % find end j of the new turn
                j=i+1;
                if(j>=length(Track.Frames))
                    j=length(Track.Frames);
                end
                while(floor(Track.State(j)) <= fwd_state_code && Track.body_angle(j) <= critical_angle && Track.Eccentricity(j)<=Prefs.UpsilonEccThresh)
                    j=j+1;
                    if(j>=length(Track.Frames))
                        j=length(Track.Frames);
                        break;
                    end
                end
                
                a=i-1; p=0;
                while(p<=2*Prefs.FrameRate)
                    if(a>=1)
                        if(are_these_equal(floor(Track.State(a)), fwd_code))
                            a=a-1;
                        else
                            break;
                        end
                    end
                    if(a <= 1)
                        a=1;
                        break;
                    end
                    
                    p=p+1;
                end
                
                b=j+1; p=0;
                while(p<=2*Prefs.FrameRate)
                    if(b<=length(Track.State))
                        if(are_these_equal(floor(Track.State(b)), fwd_code))
                            b=b+1;
                        else
                            break;
                        end
                    end
                    
                    if(b >= length(Track.State))
                        b=length(Track.State);
                        break;
                    end
                    
                    p=p+1;
                end
                
                dir_before = mean_direction(Track.Direction(a:i-1));
                dir_after = mean_direction(Track.Direction(j+1:b));
                delta_dir = delta_direction(dir_before, dir_after);
                
                % disp([num2str(i),' ', num2str(j),' ', num2str(a),' ', num2str(dir_before),' ', num2str(b),' ', num2str(dir_after),' ', num2str(delta_dir)])
                
                if(abs(delta_dir) >= Prefs.MinDeltaHeadingUpsilon)
                    if(j-i < MaxUpsilonOmegaDurationFrames)
                        k=length(Track.Reorientations)+1;
                        
                        Track.Reorientations(k).start = i;
                        Track.Reorientations(k).startTurn = i;
                        Track.Reorientations(k).end = j;
                        Track.Reorientations(k).class = 'pure_Upsilon';
                        Track.Reorientations(k).startRev = NaN;
                        Track.Reorientations(k).revLen = NaN;
                        Track.Reorientations(k).revLenBodyBends = NaN;
                        Track.Reorientations(k).revSpeed = NaN;
                        Track.Reorientations(k).ecc = min(Track.Eccentricity(i:j));
                        Track.Reorientations(k).dir_before = dir_before;
                        Track.Reorientations(k).dir_after = dir_after;
                        Track.Reorientations(k).delta_dir = delta_dir;
                        Track.Reorientations(k).turn_delta_dir = Track.Reorientations(k).delta_dir;
                        Track.Reorientations(k).mean_angspeed =  Track.Reorientations(k).delta_dir/( (Track.Reorientations(k).end-Track.Reorientations(k).start+1)/Prefs.FrameRate );
                        
%                         start_reori=[];
%                         for(w=1:length(Track.Reorientations))
%                             start_reori = [start_reori, Track.Reorientations(w).start];
%                         end
%                         [s, idx] = sort(start_reori);
%                         Track.Reorientations = Track.Reorientations(idx);
%                         clear('s'); clear('idx'); clear('start_reori');
                        
                        Track.Reorientations = sort_Reorientations(Track.Reorientations);
                        
                        Track.State(i:j) = pure_Upsilon_code;
                    end
                end
                
                i=j;
            end
        end
    end
    i=i+1;
end


if(~isempty(Track.Reorientations))
    dummyReori = Track.Reorientations;
    i=2;
    while(i<=length(dummyReori))
        % fuse two turns/omegas seperated by a second or less
        if(dummyReori(i).start - dummyReori(i-1).end <= Prefs.FrameRate+1)
            gap_idx = dummyReori(i-1).end+1:dummyReori(i).start-1;
            if(nansum(Track.State(gap_idx)) <= pauseplus_code*length(gap_idx)) % gap seperated by a pause or fwd so OK to fuse
                
                % fuse two turns seperated by a second or less
                if(strcmp(dummyReori(i).class,'pure_Upsilon') && strcmp(dummyReori(i-1).class,'pure_Upsilon'))
                    
                    
                    dummyReori(i-1).start = dummyReori(i-1).start;
                    dummyReori(i-1).startTurn = dummyReori(i-1).start;
                    dummyReori(i-1).end = dummyReori(i).end;
                    dummyReori(i-1).class = 'pure_Upsilon';
                    dummyReori(i-1).startRev = NaN;
                    dummyReori(i-1).revLen = NaN;
                    dummyReori(i-1).revLenBodyBends = NaN;
                    dummyReori(i-1).revSpeed = NaN;
                    dummyReori(i-1).ecc = min(dummyReori(i-1).ecc, dummyReori(i).ecc);
                    dummyReori(i-1).dir_before = dummyReori(i-1).dir_before;
                    dummyReori(i-1).dir_after = dummyReori(i).dir_after;
                    dummyReori(i-1).delta_dir = delta_direction(dummyReori(i-1).dir_before, dummyReori(i-1).dir_after);
                    dummyReori(i-1).turn_delta_dir = dummyReori(i-1).delta_dir;
                    dummyReori(i-1).mean_angspeed =  dummyReori(i-1).delta_dir/( (dummyReori(i-1).end-dummyReori(i-1).start+1)/Prefs.FrameRate );
                    
                    dummyReori(i) = [];
                else
                    % fuse two omegas seperated by a second or less
                    if(strcmp(dummyReori(i).class,'pure_omega') && strcmp(dummyReori(i-1).class,'pure_omega'))
                        
                        dummyReori(i-1).start = dummyReori(i-1).start;
                        dummyReori(i-1).startTurn = dummyReori(i-1).start;
                        dummyReori(i-1).end = dummyReori(i).end;
                        dummyReori(i-1).class = 'pure_omega';
                        dummyReori(i-1).startRev = NaN;
                        dummyReori(i-1).revLen = NaN;
                        dummyReori(i-1).revLenBodyBends = NaN;
                        dummyReori(i-1).revSpeed = NaN;
                        dummyReori(i-1).ecc = min(dummyReori(i-1).ecc, dummyReori(i).ecc);
                        dummyReori(i-1).dir_before = dummyReori(i-1).dir_before;
                        dummyReori(i-1).dir_after = dummyReori(i).dir_after;
                        dummyReori(i-1).delta_dir = delta_direction(dummyReori(i-1).dir_before, dummyReori(i-1).dir_after);
                        dummyReori(i-1).turn_delta_dir = dummyReori(i-1).delta_dir;
                        dummyReori(i-1).mean_angspeed =  dummyReori(i-1).delta_dir/( (dummyReori(i-1).end-dummyReori(i-1).start+1)/Prefs.FrameRate );
                        
                        dummyReori(i) = [];
                    else
                        
                        % fuse pure_omega/pure_Upsilon seperated by a second or less
                        if( (   (strcmp(dummyReori(i).class,'pure_omega') && strcmp(dummyReori(i-1).class,'pure_Upsilon')) || ...
                                (strcmp(dummyReori(i).class,'pure_Upsilon') && strcmp(dummyReori(i-1).class,'pure_omega')) ) )
                            
                            dummyReori(i-1).start = dummyReori(i-1).start;
                            dummyReori(i-1).startTurn = dummyReori(i-1).start;
                            dummyReori(i-1).end = dummyReori(i).end;
                            dummyReori(i-1).class = 'pure_omega';
                            dummyReori(i-1).startRev = NaN;
                            dummyReori(i-1).revLen = NaN;
                            dummyReori(i-1).revLenBodyBends = NaN;
                            dummyReori(i-1).revSpeed = NaN;
                            dummyReori(i-1).ecc = min(dummyReori(i-1).ecc, dummyReori(i).ecc);
                            dummyReori(i-1).dir_before = dummyReori(i-1).dir_before;
                            dummyReori(i-1).dir_after = dummyReori(i).dir_after;
                            dummyReori(i-1).delta_dir = delta_direction(dummyReori(i-1).dir_before, dummyReori(i-1).dir_after);
                            dummyReori(i-1).turn_delta_dir = dummyReori(i-1).delta_dir;
                            dummyReori(i-1).mean_angspeed =  dummyReori(i-1).delta_dir/( (dummyReori(i-1).end-dummyReori(i-1).start+1)/Prefs.FrameRate );
                            
                            dummyReori(i) = [];
                        else
                            i=i+1;
                        end
                    end
                end
            else
                i=i+1;
            end
        else
            i=i+1;
        end
    end
    Track.Reorientations = dummyReori;
end

% get rid of pauses disguised as Reorientations
% if speed is below the pause threshold both before and after the
% reorientation, this is probably a paused animal ... jitter is giving the
% angular speed changes
edited_flag=1;
while(edited_flag==1)
    edited_flag=0;
    i=1;
    while(i<=length(Track.Reorientations))
        
        del_flag=0;
        a = Track.Reorientations(i).start - (Track.FrameRate+1);
        if(a<=0)
            a=1;
        end
        while(Track.State(a) > fwd_state_code && a < Track.Reorientations(i).start-1)
            a=a+1;
        end
        
        if(a < Track.Reorientations(i).start)
            pre_reori_speed = max(Track.Speed(a:Track.Reorientations(i).start-1));
            
            % disp([Track.Frames(a) pre_reori_speed])
            
            b = Track.Reorientations(i).end + (Track.FrameRate+1);
            if(b > length(Track.Frames))
                b = length(Track.Frames);
            end
            while(Track.State(b) > fwd_state_code && b > Track.Reorientations(i).end+1)
                b=b-1;
            end
            if(b > Track.Reorientations(i).end)
                post_reori_speed = max(Track.Speed(Track.Reorientations(i).end+1:b));
                
                % disp([0 Track.Frames(b) post_reori_speed])
                
                if(pre_reori_speed <= Prefs.pauseSpeedThresh && post_reori_speed <= Prefs.pauseSpeedThresh )
                    del_flag=1;
                    edited_flag=1;
                end
            end
        end
        
        
        if(~isnan(Track.Reorientations(i).revLen))
            if(Track.Reorientations(i).revLen < Prefs.SmallReversalThreshold || ...
               Track.Reorientations(i).revSpeed <= Prefs.pauseSpeedThresh)
                    del_flag=1;
            end
        end
        
        if(del_flag==1)
            Track.Reorientations(i)=[];
        else
            i=i+1;
        end
    end
    
    if(isempty(Track.Reorientations))
        Track.Reorientations=[];
    end
    Track.State = AssignLocomotionState(Track);
end

% fuse Rev reorientation to turn reorientations if the rev ends within Prefs.RevOmegaMaxGap seconds of the turn start
RevOmegaFrameGap = Prefs.RevOmegaMaxGap*Track.FrameRate;

edited_flag=1;
while(edited_flag==1)
    edited_flag=0;
    i=1;
    while(i<length(Track.Reorientations))
        fused_flag=0;
        if(~isempty(regexpi(Track.Reorientations(i).class,'Rev')))
            if(strcmp(Track.Reorientations(i+1).class,'pure_Upsilon') || strcmp(Track.Reorientations(i+1).class,'pure_omega'))
                if(Track.Reorientations(i+1).start - Track.Reorientations(i).end <= RevOmegaFrameGap)
                    % fuse i+1 to i and delete i+1
                    fused_flag=1;
                    edited_flag=1;
                    
                    % i is a pure reversal, so fuse simply
                    if(isnan(Track.Reorientations(i).startTurn))
                        if(strcmp(Track.Reorientations(i+1).class,'pure_omega'))
                            Track.Reorientations(i).class = sprintf('%sOmega',Track.Reorientations(i).class(6:end));
                        else
                            Track.Reorientations(i).class = sprintf('%sUpsilon',Track.Reorientations(i).class(6:end));
                        end
                        Track.Reorientations(i).startTurn = Track.Reorientations(i+1).startTurn;
                        Track.Reorientations(i).ecc = Track.Reorientations(i+1).ecc;
                    else % i is a composite event ... extend the turn segment ... upgrade the class designation if need be
                        Track.Reorientations(i).ecc = min(Track.Reorientations(i).ecc, Track.Reorientations(i+1).ecc);
                        if(strcmp(Track.Reorientations(i+1).class,'pure_omega'))
                            Track.Reorientations(i).class = sprintf('%sOmega',Track.Reorientations(i).class(1:4));
                        end
                    end
                    
                    revdir_before = corrected_bearing(mean_direction(Track.Direction(Track.Reorientations(i).start:(Track.Reorientations(i).startTurn-1))) + 180); % opposite direction of reversal
                    Track.Reorientations(i).turn_delta_dir = delta_direction(revdir_before, Track.Reorientations(i+1).dir_after);
                    
                    Track.Reorientations(i).end = Track.Reorientations(i+1).end;
                    Track.Reorientations(i).dir_after = Track.Reorientations(i+1).dir_after;
                    Track.Reorientations(i).delta_dir = delta_direction(Track.Reorientations(i).dir_before, Track.Reorientations(i).dir_after);
                    Track.Reorientations(i).mean_angspeed =  Track.Reorientations(i).delta_dir/( (Track.Reorientations(i).end-Track.Reorientations(i).start+1)/Track.FrameRate );
                    
                    
                    Track.Reorientations(i+1)=[];
                end
            end
        end
        if(fused_flag==0)
            i=i+1;
        end
    end
    
    if(isempty(Track.Reorientations))
        Track.Reorientations=[];
    end
    Track.State = AssignLocomotionState(Track);
end


% revupsilon w/ turn_delta_dir >= RevOmegaUpsilonDeltaHeadingThresh re-classified as omega
del_idx=[];
for(i=1:length(Track.Reorientations))
    if(~isempty(regexpi(Track.Reorientations(i).class,'Rev'))) % Rev
        if(~isnan(Track.Reorientations(i).startTurn)) % coupled to a turn
            if(abs(Track.Reorientations(i).turn_delta_dir) >=  Prefs.RevOmegaUpsilonDeltaHeadingThresh) % upgrade to omega
                Track.Reorientations(i).class = sprintf('%sOmega',Track.Reorientations(i).class(1:4));
            end
        else % pure reversal of some sort ... is it really a pause in disguise?
            if(Track.Reorientations(i).revSpeed <= Prefs.pauseSpeedThresh)
                del_idx = [del_idx i];
            end
        end
    end
end
Track.Reorientations(del_idx) = [];

Track.State = AssignLocomotionState(Track);
Track = worm_head_tail(Track);
[Track.body_angle, Track.head_angle, Track.tail_angle] = worm_body_angle(Track);

outTrack = Track;

return;
end

