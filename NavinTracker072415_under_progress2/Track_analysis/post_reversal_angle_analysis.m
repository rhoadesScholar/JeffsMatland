function post_reversal_angle_analysis(Tracks)

direction_avging_frames = 2*Tracks(1).FrameRate;

for(i=1:length(Tracks))
    
    for(j=1:length(Tracks(i).Reorientations))
        Tracks(i).Reorientations(j) = strip_ring_Reorientations(Tracks(i).Reorientations(j));
    end
    Tracks(i).State = AssignLocomotionState(Tracks(i));
    
    for(j=1:length(Tracks(i).Reorientations))
        close all
        
        startframe_idx = max(1,Tracks(i).Reorientations(j).start-direction_avging_frames);
        endframe_idx = min(Tracks(i).Reorientations(j).end+direction_avging_frames, length(Tracks(i).Frames));
        mid_idx = round((startframe_idx+endframe_idx)/2);
        
        plot_track(Tracks(i), '', startframe_idx, endframe_idx);
        
        max_dim = max( (max(Tracks(i).SmoothX(startframe_idx:endframe_idx)) - min(Tracks(i).SmoothX(startframe_idx:endframe_idx))), ...
                       (max(Tracks(i).SmoothY(startframe_idx:endframe_idx)) - min(Tracks(i).SmoothY(startframe_idx:endframe_idx))) );
        
        
        xlim([Tracks(i).SmoothX(mid_idx)-max_dim Tracks(i).SmoothX(mid_idx)+max_dim]);
        ylim([Tracks(i).SmoothY(mid_idx)-max_dim Tracks(i).SmoothY(mid_idx)+max_dim]);
      
        
        [u(1) v(1)] = ginput(1);
        [u(2) v(2)] = ginput(1);
        [u(3) v(3)] = ginput(1);
        
        position = [u(1),v(1);u(2),v(2);u(3),v(3)];
        v1 = [position(1,1)-position(2,1), position(1,2)-position(2,2)];
        v2 = [position(3,1)-position(2,1), position(3,2)-position(2,2)];
        phi = acos(dot(v1,v2)/(norm(v1)*norm(v2)));
        Angle = (phi * (180/pi)); % radtodeg(phi)
        
        hold on;
        plot(u,v,'k');
        
        disp(num2str([i j Tracks(i).Reorientations(j).dir_before  Tracks(i).Reorientations(j).dir_after  Tracks(i).Reorientations(j).delta_dir (Tracks(i).Reorientations(j).turn_delta_dir)  (Angle)]))
        
        pause
        hold off;
    end
end


return;
end
