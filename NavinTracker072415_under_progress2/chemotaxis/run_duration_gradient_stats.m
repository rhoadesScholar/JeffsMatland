function [up_gradient, down_gradient, orthogonal_gradient] = run_duration_gradient_stats(Tracks)
% returns the distributions of forward run times (pure_Upsilon counts as
% fwd for this for up-gradient, down-gradient, and orthogonal to the
% gradient
% up_gradient odor-angle = 0-60; orthogonal_gradient odor angle = 60-120;
% down_gradient = 120-180 deg

up_gradient = []; down_gradient = []; orthogonal_gradient = [];
for(i=1:length(Tracks))
    % remove pure_upsilons from the reorientations
    idx = [];
    for(j=1:length(Tracks(i).Reorientations))
        if(strcmpi(Tracks(i).Reorientations(j).class,'pure_upsilon'))
            idx = [idx j];
        end
    end
    Tracks(i).Reorientations(idx) = [];
    
    mean_dir = []; durations = [];
    if(~isempty(Tracks(i).Reorientations))
        a = 1; start_idx = 1;
        if(Tracks(i).Reorientations(1).start == 1) % starts w/ a Reori
            a = Tracks(i).Reorientations(1).end + 1;
            start_idx = 2;
        end
        for(j=start_idx:length(Tracks(i).Reorientations))
            b = Tracks(i).Reorientations(j).start - 1;     
            mean_dir = [mean_dir mean_direction(Tracks(i).odor_angle(a:b))];
            durations = [durations length(Tracks(i).odor_angle(a:b))];
            a = Tracks(i).Reorientations(j).end + 1;
        end
        if(Tracks(i).Reorientations(end).end < length(Tracks(i).Frames))
            b = length(Tracks(i).Frames);
            mean_dir = [mean_dir mean_direction(Tracks(i).odor_angle(a:b))];
            durations = [durations length(Tracks(i).odor_angle(a:b))];
        end
    else % entire track is a single run
        mean_dir = mean_direction(Tracks(i).odor_angle);
        durations = length(Tracks(i).odor_angle);
    end
    
    up_idx = find(mean_dir < 60);
    ortho_idx = find(mean_dir > 60 & mean_dir < 120);
    down_idx = find(mean_dir > 120);
    
    up_gradient = [up_gradient durations(up_idx)]; 
    down_gradient = [down_gradient durations(down_idx)]; 
    orthogonal_gradient = [orthogonal_gradient durations(ortho_idx)];
end

up_gradient = up_gradient./Tracks(1).FrameRate;
down_gradient = down_gradient./Tracks(1).FrameRate;
orthogonal_gradient = orthogonal_gradient./Tracks(1).FrameRate;

return;
end 
