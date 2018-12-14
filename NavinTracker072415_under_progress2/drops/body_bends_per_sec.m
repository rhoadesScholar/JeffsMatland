function Track = body_bends_per_sec(Track)

global Prefs;


for(i=1:length(Track.Reorientations))
    Track.Reorientations(i).revLenBodyBends = NaN;
    startrev_idx = Track.Reorientations(i).start;
    endrev_idx = Track.Reorientations(i).startTurn-1;
    if(isnan(endrev_idx))
        endrev_idx = Track.Reorientations(i).end;
    end
    if(~isnan(Track.Reorientations(i).revLen))
        midbody_angle = Track.midbody_angle(startrev_idx:endrev_idx);
        if(Track.FrameRate>3)
            midbody_angle = smooth(midbody_angle);
        end
        Track.Reorientations(i).revLenBodyBends = length(zero_crossing(midbody_angle,[],0,'none'));
        if(Track.Reorientations(i).revLenBodyBends==0) % short reversal < 1 bodybend assigned as 0.5
            Track.Reorientations(i).revLenBodyBends = 0.5;
        end
    end
end

if(Prefs.swim_flag == 0)
    return;
end
    
if(Prefs.swim_flag == 1) % liquid omega for animals thrashing in liquid
    Track.mvt_init = zeros(1,length(Track.mvt_init));
    % omega while ecc <= Prefs.OmegaEccThresh
    state_idx = find(Track.Eccentricity <= Prefs.OmegaEccThresh);
    state_vector = zeros(1,length(Track.Frames))+1;
    Track.State = state_vector;
    state_vector(state_idx) = num_state_convert('liquid_omega');
    MinOmegaDurationFrames = Prefs.MinOmegaDuration*Prefs.FrameRate;
    transition_vector = [0 diff(state_vector)];
    for(i=1:length(Track.Frames))
        if(transition_vector(i)~=0)
            j=i+1;
            while(j<length(Track.Frames) && transition_vector(j)==0)
                j=j+1;
            end
            if(j-i < MinOmegaDurationFrames)
                transition_vector(i)=0;
                transition_vector(j)=0;
            else
                Track.State(i:j) = num_state_convert('liquid_omega');
            end
        end
    end
    transition_idx = find(transition_vector>0);
    Track.mvt_init(transition_idx) = num_state_convert('liquid_omega');
end

kappa_midbody = Track.midbody_angle;

windowsize = round(Prefs.BodyBendWindowLength*Prefs.FrameRate); % window for bodybend count

kappa_midbody(find(Track.State~=num_state_convert('fwd'))) = NaN;

% multiply by 2 since each full cycle has two body bends - one to deflect,
% one to return
[Track.body_bends_per_sec, Track.max_bend_angle] = characteristic_freq_sliding_window(kappa_midbody, windowsize);
Track.body_bends_per_sec = 2*Prefs.FrameRate*Track.body_bends_per_sec;

not_fwd_idx = find(Track.State~=num_state_convert('fwd'));
Track.body_bends_per_sec(not_fwd_idx) = NaN;
Track.max_bend_angle(not_fwd_idx) = NaN;

pause_idx = find(abs(Track.State-num_state_convert('pause'))<=1e-4);
Track.body_bends_per_sec(pause_idx)=0;

Track.body_bends_per_sec(Track.body_bends_per_sec > Prefs.FrameRate/2) = Prefs.FrameRate/2;

% subplot(2,2,[3 4])
% plot(Track.Time,bend_metric);
% hold on;
% %plot(peak(:,1), peak(:,2),'.r');
% plot(time_body_bend, peak(pos_idx,2),'.r');
% hold off
% subplot(2,2,[1 2])
% single_Track_ethogram(Track);
% subplot(2,2,[3 4])
% plot(Track.Time,Track.body_bends_per_sec);
% disp([(length(peak(:,2))/2)/(Track.Time(idx(end))-Track.Time(idx(1))) num_pos/(Track.Time(idx(end))-Track.Time(idx(1))) Tracks_fft(Track,'Eccentricity')])

return;
end
