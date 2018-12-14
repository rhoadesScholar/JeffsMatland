function appended_track = append_track(track_1, track_2, join_flag)
% appended_track = append_track(track_1, track_2, join_flag)

global Prefs;

missing_code = num_state_convert('missing');

if(nargin > 2)
    if(strcmpi(join_flag,'join'))
        missing_code = num_state_convert('join');
    end
    if(strcmpi(join_flag,'interpolate'))
        missing_code = 0;
    end
    if(strcmpi(join_flag,'missing'))
        missing_code = num_state_convert('missing');
    end
end


special_fields = {'NumFrames', 'Wormlength', 'numActiveFrames', ...
    'Frames', 'Time', 'Path',  'bound_box_corner', ...
    'RingEffect', 'RingDistance', 'mvt_init', 'Reorientations', ...
    'State', 'scoredState', 'minimalState', 'Image','body_contour','original_track_indicies','Active', ...
    'Height', 'Width', 'PixelSize', 'FrameRate','curvature_vs_body_position_matrix','midbody_angle'};

if(track_2.Frames(1) > track_1.Frames(end)) % track_2 follows track_1, non overlapping
    track_i = track_1;
    track_j = track_2;
else
    if(track_1.Frames(1) > track_2.Frames(end))
        track_i = track_2;  % track_1 follows track_2, non overlapping
        track_j = track_1;
    else   
        disp(['overlapping tracks ' num2str([track_1.Frames(1) track_1.Frames(end) track_2.Frames(1) track_2.Frames(end)])])
        if(track_1.Frames(end) >= track_2.Frames(1) && track_1.Frames(end) < track_2.Frames(end))
            track_i = track_1;
            track_j = extract_track_segment(track_2, track_1.Frames(end)+1,track_2.Frames(end),'frames');
        else
            if(track_2.Frames(end) >= track_1.Frames(1) && track_2.Frames(end) < track_1.Frames(end))
                track_i = track_2;
                track_j = extract_track_segment(track_1, track_2.Frames(end)+1,track_1.Frames(end),'frames');
            else
                disp(['overlapping tracks error ' num2str([track_1.Frames(1) track_1.Frames(end) track_2.Frames(1) track_2.Frames(end)])])
                pause
            end
        end
    end
end


appended_track = track_i;

num_missing_frames = track_j.Frames(1) - track_i.Frames(track_i.NumFrames) - 1;

% if(num_missing_frames>1) % interpolate only single missing frames
%     if(strcmpi(join_flag,'interpolate'))
%         missing_code = num_state_convert('missing');
%     end
% end

% if(num_missing_frames>0)
first_missing_frame = track_i.NumFrames+1;
last_missing_frame = track_i.NumFrames + num_missing_frames;
% else
%     first_missing_frame=[];
%     last_missing_frame=[];
% end

% if(num_missing_frames>track_1.FrameRate)
%     missing_code = num_state_convert('missing');
% end

% a weirdo event for worms swimming in drops
while(num_missing_frames < 0)
    %     track_i.Name
    %     track_i.Frames(1)
    %     track_i.Frames(end)
    %
    %     track_j.Name
    %     track_j.Frames(1)
    %     track_j.Frames(end)
    
    track_i = delete_frame_from_Track(track_i, length(track_i.Frames));
    num_missing_frames = track_j.Frames(1) - track_i.Frames(track_i.NumFrames) - 1;
    first_missing_frame = track_i.NumFrames+1;
    last_missing_frame = track_i.NumFrames + num_missing_frames;
end




% insert NaN for arrays that scale w/ the frames
% frame indicies in track j arrays = old + num_missing_frames + track_i.NumFrames

trackfields = fieldnames(track_i);
for(p=1:length(special_fields))
    f=1;
    while(f<=length(trackfields))
        if(strcmp(char(trackfields{f}), char(special_fields{p}))==1)
            trackfields(f)=[];
            break;
        else
            f=f+1;
        end
    end
end

% Frames and Time
if(isfield(appended_track,'Frames')==1)
    
    appended_track.Frames(first_missing_frame:last_missing_frame) = [(track_i.Frames(track_i.NumFrames)+1):(track_j.Frames(1)-1)];
    appended_track.Frames = [appended_track.Frames, track_j.Frames];
    
    if(isfield(appended_track,'Time')==1)
        appended_track.Time = [];
        appended_track.Time = appended_track.Frames/track_1.FrameRate;
    end
end

for(f=1:length(trackfields))
    appended_track = append_field(appended_track, track_j, first_missing_frame, last_missing_frame, trackfields{f}, missing_code);
end
clear('trackfields');

% special cases

appended_track.NumFrames = track_i.NumFrames + num_missing_frames + track_j.NumFrames;


if(isfield(appended_track,'MajorAxes'))
    if(isfield(appended_track,'Wormlength'))
        appended_track.Wormlength = nanmedian(appended_track.MajorAxes)*appended_track.PixelSize;
    end
end

if(isfield(appended_track,'numActiveFrames'))
    appended_track.numActiveFrames = num_active_frames(appended_track);
end

if(isfield(appended_track,'Active'))
    appended_track.Active = appended_track.Active;
end

if(isfield(appended_track,'Path')==1)
    if(missing_code > 0)
        appended_track.Path(first_missing_frame:last_missing_frame,:) = NaN;
    else % interpolate
        appended_track.Path(first_missing_frame:last_missing_frame,1) = linear_interpolate(appended_track.Frames(first_missing_frame-1), appended_track.Path(first_missing_frame-1,1), ...
            track_j.Frames(1), track_j.Path(1,1), appended_track.Frames(first_missing_frame:last_missing_frame));
        appended_track.Path(first_missing_frame:last_missing_frame,2) = linear_interpolate(appended_track.Frames(first_missing_frame-1), appended_track.Path(first_missing_frame-1,2), ...
            track_j.Frames(1), track_j.Path(1,2), appended_track.Frames(first_missing_frame:last_missing_frame));
    end
    appended_track.Path =  cat(1,appended_track.Path,track_j.Path);
end

if(isfield(appended_track,'bound_box_corner')==1)
    if(missing_code > 0)
        appended_track.bound_box_corner(first_missing_frame:last_missing_frame,:) = NaN;
    else % interpolate
        appended_track.bound_box_corner(first_missing_frame:last_missing_frame,1) = linear_interpolate(appended_track.Frames(first_missing_frame-1), appended_track.bound_box_corner(first_missing_frame-1,1), ...
            track_j.Frames(1), track_j.bound_box_corner(1,1), appended_track.Frames(first_missing_frame:last_missing_frame));
        appended_track.bound_box_corner(first_missing_frame:last_missing_frame,2) = linear_interpolate(appended_track.Frames(first_missing_frame-1), appended_track.bound_box_corner(first_missing_frame-1,2), ...
            track_j.Frames(1), track_j.bound_box_corner(1,2), appended_track.Frames(first_missing_frame:last_missing_frame));
    end
    appended_track.bound_box_corner =  cat(1,appended_track.bound_box_corner,track_j.bound_box_corner);
end

if(isfield(appended_track,'RingDistance')==1)
    if(missing_code > 0)
        appended_track.RingDistance(first_missing_frame:last_missing_frame) = Prefs.RingDistanceCutoffPixels-1;
    else % interpolate
        appended_track.RingDistance(first_missing_frame:last_missing_frame) = linear_interpolate(appended_track.Frames(first_missing_frame-1), appended_track.RingDistance(first_missing_frame-1), ...
            track_j.Frames(1), track_j.RingDistance(1), appended_track.Frames(first_missing_frame:last_missing_frame));
    end
    appended_track.RingDistance = [appended_track.RingDistance, track_j.RingDistance];
end

% if(isfield(appended_track,'RingEffect')==1)
%     appended_track.RingEffect(first_missing_frame:last_missing_frame) = 1;
%     appended_track.RingEffect = [appended_track.RingEffect, track_j.RingEffect];
% end

if(isfield(appended_track,'mvt_init')==1)
    appended_track.mvt_init(first_missing_frame:last_missing_frame) = missing_code;
    appended_track.mvt_init = [appended_track.mvt_init, track_j.mvt_init];
end

if(isfield(appended_track,'stimulus_vector')==1)
    appended_track.stimulus_vector(first_missing_frame:floor(first_missing_frame + num_missing_frames/2)) = track_i.stimulus_vector(end);
    appended_track.stimulus_vector(floor(first_missing_frame + num_missing_frames/2):last_missing_frame) = track_j.stimulus_vector(1);
end

% state array remade below in the Reorientations section
if((isfield(appended_track,'State')==1))
    for(k=first_missing_frame:last_missing_frame)
        if(missing_code>0)
            appended_track.State(k) = missing_code;
        end
    end
    j=1;
    for(k=last_missing_frame+1:appended_track.NumFrames)
        appended_track.State(k) = track_j.State(j);
        j=j+1;
    end
end

if(isfield(appended_track,'scoredState')==1)
    
    for(k=first_missing_frame:last_missing_frame)
        appended_track.scoredState(k) = 9; % appended_track.scoredState{k} = 'missing';
    end
    j=1;
    for(k=last_missing_frame+1:appended_track.NumFrames)
        appended_track.scoredState(k) = track_j.scoredState(j);
        j=j+1;
    end
end

if(isfield(appended_track,'minimalState')==1)
    
    for(k=first_missing_frame:last_missing_frame)
        appended_track.minimalState(k) = 9; % appended_track.scoredState{k} = 'missing';
    end
    j=1;
    for(k=last_missing_frame+1:appended_track.NumFrames)
        appended_track.minimalState(k) = track_j.minimalState(j);
        j=j+1;
    end
end

% bitmap images of the worms
missing_images = [];
if(isfield(appended_track,'Image')==1)
    
    if(missing_code>0 || num_missing_frames > Prefs.FrameRate) % don't interpolate for more than 1sec of missing frames
        for(k=first_missing_frame:last_missing_frame)
            appended_track.Image{k} = [];
        end
    else
        if(last_missing_frame>=first_missing_frame)
            missing_images = interpolate_binary_images(appended_track.Image{first_missing_frame-1}, ...
                track_j.Image{1}, last_missing_frame-first_missing_frame+1);
            v=0;
            for(k=first_missing_frame:last_missing_frame)
                v=v+1;
                appended_track.Image{k} = missing_images{v};
            end
        end
    end
    j=1;
    for(k=last_missing_frame+1:appended_track.NumFrames)
        appended_track.Image{k} = track_j.Image{j};
        j=j+1;
    end
end

if(isfield(appended_track,'body_contour')==1)
    
    misses = [];
    for(k=first_missing_frame:last_missing_frame)
        appended_track.body_contour(k).x=[];
        appended_track.body_contour(k).y=[];
        appended_track.body_contour(k).midbody=0;
        appended_track.body_contour(k).head=0;
        appended_track.body_contour(k).tail=0;
        appended_track.body_contour(k).neck=0;
        appended_track.body_contour(k).lumbar=0;
        appended_track.body_contour(k).kappa = [];
        
        if(missing_code == 0)
            if(isfield(appended_track, 'Image'))
                appended_track.body_contour(k) = body_contour_from_image(appended_track.Image{k}, appended_track.bound_box_corner(k,:));
            end
            if(isempty(appended_track.body_contour(k).x))
                misses = [misses k];
            end
        end
    end   
    
    % interpolate body contour coords
    if(missing_code == 0)
        if(~isempty(misses))
            locations = {'head','neck','midbody','lumbar','tail'};
            for(gg = 1:5)
                if(appended_track.body_contour(first_missing_frame-1).(locations{gg}) > 0 && ...
                        track_j.body_contour(1).(locations{gg}) > 0)
                    start_loc_x = appended_track.body_contour(first_missing_frame-1).x(appended_track.body_contour(first_missing_frame-1).(locations{gg}));
                    start_loc_y = appended_track.body_contour(first_missing_frame-1).y(appended_track.body_contour(first_missing_frame-1).(locations{gg}));
                    
                    end_loc_x = track_j.body_contour(1).x(track_j.body_contour(1).(locations{gg}));
                    end_loc_y = track_j.body_contour(1).y(track_j.body_contour(1).(locations{gg}));
                    
                    xs = linear_interpolate(appended_track.Frames(first_missing_frame-1), start_loc_x, ...
                        track_j.Frames(1), end_loc_x, appended_track.Frames(misses));
                    ys = linear_interpolate(appended_track.Frames(first_missing_frame-1), start_loc_y, ...
                        track_j.Frames(1), end_loc_y, appended_track.Frames(misses));
                    
                    for(pp=1:length(misses))
                        appended_track.body_contour(misses(pp)).x(gg) = xs(pp);
                        appended_track.body_contour(misses(pp)).y(gg) = ys(pp);
                        appended_track.body_contour(misses(pp)).(locations{gg}) = gg;
                    end
                end
            end
        end
    end
    
    j=1;
    for(k=last_missing_frame+1:appended_track.NumFrames)
        appended_track.body_contour(k) = track_j.body_contour(j);
        j=j+1;
    end
end

if(isfield(appended_track,'curvature_vs_body_position_matrix')==1)
    
        appended_track.curvature_vs_body_position_matrix(first_missing_frame:last_missing_frame, 1:Prefs.num_contour_points) = NaN;
        appended_track.midbody_angle(first_missing_frame:last_missing_frame) = NaN;
    if(missing_code==0 && num_missing_frames <= Prefs.FrameRate && num_missing_frames>0)
        [curvature_vs_body_position_matrix, kappa_midbody] = curvature_vs_body_position(appended_track, first_missing_frame, last_missing_frame);
        appended_track.curvature_vs_body_position_matrix(first_missing_frame:last_missing_frame, 1:Prefs.num_contour_points) = curvature_vs_body_position_matrix';
        appended_track.midbody_angle(first_missing_frame:last_missing_frame) = kappa_midbody;
        clear('kappa_midbody');
        clear('curvature_vs_body_position_matrix');
    end
    appended_track.midbody_angle = [appended_track.midbody_angle, track_j.midbody_angle];
    appended_track.curvature_vs_body_position_matrix =  cat(1,appended_track.curvature_vs_body_position_matrix,track_j.curvature_vs_body_position_matrix);
end

if(missing_code==0) % recalc speed, direction, angspeed for the missing and flanking frames for interpolations
    StepSize = Prefs.StepSize*appended_track.FrameRate;
    idx = max(1,(first_missing_frame-3*Prefs.FrameRate)):min(length(appended_track.Frames),(last_missing_frame+3*Prefs.FrameRate));
    seglength = length(idx);
    if(length(idx) >= StepSize)
        Xdif = CalcDif(appended_track.SmoothX(idx), StepSize)*appended_track.FrameRate;
        Ydif = -CalcDif(appended_track.SmoothY(idx), StepSize)*appended_track.FrameRate;    % Negative sign allows "correct" direction
    else
        if(seglength > 1)
            Xdif = CalcDif(appended_track.SmoothX(idx), seglength)*appended_track.FrameRate;
            Ydif = -CalcDif(appended_track.SmoothY(idx), seglength)*appended_track.FrameRate;    % Negative sign allows "correct" direction
        else
            Xdif = 0;
            Ydif = 0;
        end
    end
    Ydif(Ydif == 0) = eps;       % Avoid division by zero in direction calculation
    
%     if(isfield(appended_track, 'Speed')) % recalculate Direction & Speeds for interpolated frames
%         appended_track.Speed(idx) = sqrt(Xdif.^2 + Ydif.^2)*appended_track.PixelSize;
%     end
    
    if(isfield(appended_track, 'Direction'))
        appended_track.Direction(idx) = atan(Xdif./Ydif)*360/(2*pi);	    % In degrees, 0 = Up ("North")
        NegYdifIndexes = find(Ydif < 0);
        Index1 = find(appended_track.Direction(idx(NegYdifIndexes)) <= 0);
        Index2 = find(appended_track.Direction(idx(NegYdifIndexes)) > 0);
        appended_track.Direction(idx(NegYdifIndexes(Index1))) = appended_track.Direction(idx(NegYdifIndexes(Index1))) + 180;
        appended_track.Direction(idx(NegYdifIndexes(Index2))) = appended_track.Direction(idx(NegYdifIndexes(Index2))) - 180;
        
        if(isfield(appended_track, 'AngSpeed'))
            if(seglength >= StepSize)
                appended_track.AngSpeed(idx) = CalcAngleDif(appended_track.Direction(idx), StepSize)*appended_track.FrameRate;
            else
                if(seglength > 1)
                    appended_track.AngSpeed(idx) = CalcAngleDif(appended_track.Direction(idx), seglength)*appended_track.FrameRate;
                else
                    appended_track.AngSpeed(idx) = 0;
                end
            end
        end
    end
end

if(isfield(appended_track,'Reorientations')==1)
    
    for(k=1:length(track_j.Reorientations))
        track_j.Reorientations(k).startRev = track_j.Reorientations(k).startRev + last_missing_frame;
        track_j.Reorientations(k).startTurn = track_j.Reorientations(k).startTurn + last_missing_frame;
        track_j.Reorientations(k).end = track_j.Reorientations(k).end + last_missing_frame;
        track_j.Reorientations(k).start = track_j.Reorientations(k).start + last_missing_frame;
    end
    appended_track.Reorientations = [appended_track.Reorientations track_j.Reorientations];
    
    if(missing_code==0) % interpolate
        appended_track.Reorientations = strip_ring_Reorientations(appended_track.Reorientations);
        appended_track = edit_Reorientations(appended_track); % also remakes appended_track.State
        appended_track = ring_effects(appended_track);
        appended_track.mvt_init = mvt_init_vector(appended_track);
    end
end

if(isfield(appended_track,'original_track_indicies')==1)
    appended_track.original_track_indicies = unique([track_i.original_track_indicies track_j.original_track_indicies]);
end

return;
end

function appended_track = append_field(appended_track, track_j, first_missing_frame, last_missing_frame, field, missing_code)

if(isfield(appended_track,field)==1)
    if(isnumeric(appended_track.(field)))
        if(isvector(appended_track.(field)) || isvector(track_j.(field)))
            if(missing_code > 0)
                appended_track.(field)(first_missing_frame:last_missing_frame) = NaN;
            else
                appended_track.(field)(first_missing_frame:last_missing_frame) = linear_interpolate(appended_track.Frames(first_missing_frame-1), appended_track.(field)(first_missing_frame-1), ...
                    track_j.Frames(1), track_j.(field)(1), appended_track.Frames(first_missing_frame:last_missing_frame));
                
                %                 if(~isempty(appended_track.(field)(first_missing_frame:last_missing_frame)) && strcmp(field,'Eccentricity'))
                %                     field
                %                 disp([appended_track.Frames(first_missing_frame-1) appended_track.(field)(first_missing_frame-1)])
                %                 disp([track_j.Frames(1) track_j.(field)(1)])
                %                 appended_track.Frames(first_missing_frame:last_missing_frame)
                %                 appended_track.(field)(first_missing_frame:last_missing_frame)
                %                 pause
                %                 end
                
            end
            appended_track.(field) =  [appended_track.(field) track_j.(field)];
        end
    end
end

return;
end
