function Tracks = odor_info_to_Tracks(inputTracks, odor_coords, odor_region_exclusion_polygon, odor_region_exclusion_polygon2)
% Tracks = odor_info_to_Tracks(inputTracks, odor_coords, odor_region_exclusion_polygon, odor_region_exclusion_polygon2)
% ignores tracks within odor_region_exclusion_polygon

global Prefs;

% agar to bottom of plate lid; for modeling odor conc
lid_height = Prefs.chemotaxis_lid_height;
D = Prefs.model_diffusion_const;

fps = inputTracks(1).FrameRate;


fwd_code = num_state_convert('fwd');
upsilon_code = num_state_convert('upsilon');
omega_code = num_state_convert('omega');

for(i=1:length(inputTracks))
    t1 = inputTracks(i);
    
    head_coords = body_position_coords(t1, 'head');
    
    for(j=1:length(t1.Frames))
        
        t1.custom_metric(j) = NaN;
        t1.odor_distance(j) = NaN;
        t1.odor_angle(j) = NaN;
        
        
        
        % t1.Q(j,:) = [0 0];
        
        %             idx = max(1,(j-2*fps)):min((j+2*fps),length(t1.Frames));
        %             idx_fwd = find(floor(t1.State(idx)) == fwd_code | t1.State(idx) == pure_upsilon_code | t1.State(idx) == pure_omega_code);
        %             idx(~idx_fwd) = [];
        %             x = t1.SmoothX(idx);
        %             y = t1.SmoothY(idx);
        %             if(length(x)>1)
        %                 [m,b] = fit_line(x,y);
        %                 [Qx,Qy] = point_on_line_d_away_from_P(m,b,t1.SmoothX(j),t1.SmoothY(j),mean_direction(t1.Direction(idx)), 10);
        %                 t1.custom_metric(j) = angle_between_three_points(odor_coords, [t1.SmoothX(j) t1.SmoothY(j)], [Qx Qy]);
        %                 t1.Q(j,:) = [Qx Qy];
        %             end
        
        
        state_code = floor(t1.State(j));
        if(state_code == fwd_code || state_code == upsilon_code || state_code == omega_code)
            idx = t1.body_contour(j).head;
        else
            idx = t1.body_contour(j).tail;
        end
        if(idx > 0)
            Qx = t1.body_contour(j).x(idx);
            Qy = t1.body_contour(j).y(idx);
        else
            idx = min(length(t1.Frames), j+1);
            Qx = t1.SmoothX(idx);
            Qy = t1.SmoothY(idx);
        end
        t1.odor_angle(j) = angle_between_three_points(odor_coords, [t1.SmoothX(j) t1.SmoothY(j)], [Qx Qy]);
        
        t1.signed_odor_angle(j) = corrected_bearing((180/pi)*( -atan2(-cosd(t1.Direction(j)), sind(t1.Direction(j))) + ...
                                                      atan2( (odor_coords(2) - t1.SmoothY(j)), (odor_coords(1) - t1.SmoothX(j)) ) ));

        
        t1.odor_distance(j) = sqrt((odor_coords(1) - head_coords(j,1))^2 + (odor_coords(2) - head_coords(j,2))^2);
        
        dz = lid_height; dx = (odor_coords(1) - head_coords(j,1)); dy = (odor_coords(2) - head_coords(j,2));
        r = sqrt(dx^2 + dy^2)*t1.PixelSize; % in mm
        t = t1.Time(j);
        t1.model_odor_conc(j) = model_odor_conc(r, t);
        
        
        % t1.Q(j,:) = [Qx Qy];
        

        
        %     % Yoshida definition
        %                     t1.custom_metric(j) = corrected_bearing((180/pi)*( -atan2(-cosd(t1.Direction(j)), sind(t1.Direction(j))) + ...
        %                                              atan2( (odor_coords(2) - t1.SmoothY(j)), (odor_coords(1) - t1.SmoothX(j)) ) ));
        
    end
    
    t1.odor_angle = RecSlidingWindow(RecSlidingWindow(RecSlidingWindow(t1.odor_angle, t1.FrameRate), t1.FrameRate), t1.FrameRate);
    t1.odor_distance = t1.odor_distance*t1.PixelSize;
    
    % gradient the worm feels
    t1.model_odor_gradient = CalcDif(t1.model_odor_conc, 1);
    
    for(j=1:length(t1.Reorientations))
        
        a = t1.Reorientations(j).start;
        b = t1.Reorientations(j).end;
        t1.Reorientations(j).dir_before = mean_direction(t1.odor_angle(max(1,(a-2*fps)):(a-1)));
        t1.Reorientations(j).dir_after = mean_direction(t1.odor_angle((b+1):min(length(t1.Frames),(b+2*fps))));
        t1.Reorientations(j).delta_dir = -delta_direction(t1.Reorientations(j).dir_before, t1.Reorientations(j).dir_after);
        
        before_idx = max(1,(a-1));
        after_idx = min(length(t1.Frames),(b+1));
        
        t1.Reorientations(j).delta_dist = t1.odor_distance(after_idx) - t1.odor_distance(before_idx);
        
        % productive if the worm gets closer to the target
        t1.Reorientations(j).productive_flag = 0;
        if(t1.Reorientations(j).delta_dist < 0)
            t1.Reorientations(j).productive_flag = 1;
        end
        
        % turn delta dir
        if(~isnan(t1.Reorientations(j).ecc))
            t1.Reorientations(j).turn_delta_dir = t1.Reorientations(j).delta_dir;
            
            % turn delta dir if coupled to a reversal
            if(~isnan(t1.Reorientations(j).revLen))
                c = t1.Reorientations(j).startTurn-1;
                revdir_before = corrected_bearing( mean_direction(t1.odor_angle(a:c)) + 180);
                t1.Reorientations(j).turn_delta_dir = -delta_direction(revdir_before, t1.Reorientations(j).dir_after);
            end
        end
    end
    
    Tracks(i) = t1;
    
    dir = Tracks(i).Direction;
        
    Tracks(i).Direction = Tracks(i).odor_angle;
    curv_sign = sign(-track_curvature(Tracks(i)));  % + for going toward target

    Tracks(i).Direction = Tracks(i).signed_odor_angle;
    Tracks(i).Curvature = curv_sign.*abs(track_curvature(Tracks(i))); 

    Tracks(i).Direction = dir;
    
    for(j=1:length(Tracks(i).Reorientations))
        % redefine odor info for any reorientation
        a = Tracks(i).Reorientations(j).start;
        b = Tracks(i).Reorientations(j).end;
        before_idx = max(1,(a-1));
        Tracks(i).odor_angle(a:b) =  Tracks(i).Reorientations(j).dir_before;
        Tracks(i).odor_distance(a:b) =  Tracks(i).odor_distance(before_idx);
        Tracks(i).signed_odor_angle(a:b) =  Tracks(i).signed_odor_angle(before_idx);
        Tracks(i).model_odor_conc(a:b) = Tracks(i).model_odor_conc(before_idx);
        Tracks(i).model_odor_gradient(a:b) = Tracks(i).model_odor_gradient(before_idx);
    end

%     for(j=1:length(Tracks(i).Reorientations))
%         % redefine odor info for any reorientation
%         a = Tracks(i).Reorientations(j).start;
%         b = Tracks(i).Reorientations(j).end;
%         before_idx = max(1,(a-1));
%         Tracks(i).odor_angle(a) =  Tracks(i).Reorientations(j).dir_before;
%         Tracks(i).odor_distance(a) =  Tracks(i).odor_distance(before_idx);
%         Tracks(i).signed_odor_angle(a) =  Tracks(i).signed_odor_angle(before_idx);
%         Tracks(i).model_odor_conc(a) = Tracks(i).model_odor_conc(before_idx);
%         Tracks(i).model_odor_gradient(a) = Tracks(i).model_odor_gradient(before_idx);
%     end


end

clear('dir');
clear('t1');

% ring_missing_code = num_state_convert('ringmiss');

if(nargin<3)
    return;
end
if(isempty(odor_region_exclusion_polygon))
    return;
end

for(i=1:length(Tracks))
    inside_flag = inpolygon(Tracks(i).SmoothX,Tracks(i).SmoothY,odor_region_exclusion_polygon(:,1),odor_region_exclusion_polygon(:,2));
    
    inside_idx = find(inside_flag==1);
    
    %     disp([i inside_idx])
    %     plot(odor_region_exclusion_polygon(:,1),odor_region_exclusion_polygon(:,2),'r');
    %     hold on;
    %     plot(odor_region_exclusion_polygon2(:,1),odor_region_exclusion_polygon2(:,2),'g');
    %     plot(Tracks(i).SmoothX,Tracks(i).SmoothY,'b');
    %     plot(odor_coords(1), odor_coords(2),'ok');
    %     axis ij
    %     hold off;
    %     pause
    
    if(~isempty(inside_idx))
        Tracks(i).odor_angle(inside_idx) = NaN;
        Tracks(i).odor_distance(inside_idx) = NaN;
        Tracks(i).stimulus_vector(inside_idx) = 10;
        Tracks(i).model_odor_conc(inside_idx) = NaN;
        Tracks(i).model_odor_gradient(inside_idx) = NaN;
        % Tracks(i).State(inside_idx) = ring_missing_code;
    end
end

if(nargin<4)
    return;
end
if(isempty(odor_region_exclusion_polygon2))
    return;
end

for(i=1:length(Tracks))
    inside_flag = inpolygon(Tracks(i).SmoothX,Tracks(i).SmoothY,odor_region_exclusion_polygon2(:,1),odor_region_exclusion_polygon2(:,2));
    inside_idx = find(inside_flag==1);
    
    
    if(~isempty(inside_idx))
        Tracks(i).odor_angle(inside_idx) = NaN;
        Tracks(i).odor_distance(inside_idx) = NaN;
        % Tracks(i).State(inside_idx) = ring_missing_code;
    end
end

return;
end
