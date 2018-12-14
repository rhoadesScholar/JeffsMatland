function procFrame = process_movie_frames(MovieName, background, Ring, procFrame)

%global OVERLAP_DIST;

DEBUG_FLAG = 0;

global Prefs;

half_boundbox_side = 2*sqrt(Prefs.MaxBoundingBoxArea);

edge_pixels = 0.5/Ring.PixelSize; % for finding animals wandering off the field of view; 0.5mm

NumFoundWorms = Ring.NumWorms;
DefaultLevel = Ring.DefaultThresh(1);
obj_penalty_coeff = Ring.DefaultThresh(2);

FileInfo = moviefile_info(MovieName);

if(nargin<4)
    for(i=1:FileInfo.NumFrames)
        procFrame(i).frame_number=i;
        procFrame(i).bkgnd_index=1;
    end
end

startFrame = procFrame(1).frame_number;
endFrame = procFrame(end).frame_number;

for(i=1:length(procFrame))
    procFrame(i).worm=[];
    procFrame(i).clump=[];
    procFrame(i).timestamp = i/Ring.FrameRate;
end

% used for blanking ring pixels ... sometimes the ring doesn't subtract cleanly
ring_mask = [];
aggressive_wormfind_flag=1;
if(~isempty(Ring.ring_mask))
    ring_mask = Ring.ring_mask;
    ring_mask = double(ring_mask);
else
    aggressive_wormfind_flag = 0;
end

if(isempty(Ring.RingX))
    aggressive_wormfind_flag = 0;
end

% no ring, but there is a mask ... get the mask edge so worms near it are
% ignored if they are lost
mask_edge = [];
if(aggressive_wormfind_flag == 0)
    if(~isempty(ring_mask))
        
        B = bwboundaries(ring_mask); %obtain boundary coordinates for selected objects and put into cell B
        
        boundary = B{1};
        mask_edge.X = boundary(:,2);
        mask_edge.Y = boundary(:,1);
        
        % get rid of the "outer" boundry
        
        pixel_dim = size(background);
        
        idx = find(pixel_dim(2) - mask_edge.X <=2);
        mask_edge.X(idx)=[];
        mask_edge.Y(idx)=[];
        
        idx = find(mask_edge.X<=2);
        mask_edge.X(idx)=[];
        mask_edge.Y(idx)=[];
        
        idx = find(pixel_dim(1) - mask_edge.Y <=2);
        mask_edge.X(idx)=[];
        mask_edge.Y(idx)=[];
        
        idx = find(mask_edge.Y<=2);
        mask_edge.X(idx)=[];
        mask_edge.Y(idx)=[];
        
        % find neighbor-free points and remove ... these are spurious noise
        idx = find_neighborfree_points(mask_edge.X,mask_edge.Y);
        mask_edge.X(idx)=[];
        mask_edge.Y(idx)=[];
        
        idx=[];
        
        mask_edge.ComparisonArrayX = ones([length(mask_edge.X) 1]);
        mask_edge.ComparisonArrayY = ones([length(mask_edge.Y) 1]);
        
        clear('B');
        clear('boundary');
    end
end


background = double(background);

Level = DefaultLevel;
prev_Level = Level;


mean_worm_area = Ring.meanWormSize(1);
max_worm_area = Ring.meanWormSize(1) + Ring.meanWormSize(2);


num_target_worms = NumFoundWorms;
% total_numWorms_vector = zeros(1, 60*Ring.FrameRate) + num_target_worms;
num_missing_worm_threshold = ceil(0.05*num_target_worms);
if(num_missing_worm_threshold<=1)
    num_missing_worm_threshold=1;
end
half_num_target_worms = num_target_worms/2;

aviread_to_gray; % reset static variables in the aviread_to_gray function

Mov = aviread_to_gray(MovieName, startFrame);
timerbox_coords = timestamp_coords_from_image(Mov.cdata);

big_number = FileInfo.Width*FileInfo.Height;

image_size = [FileInfo.Height FileInfo.Width];

% aggressively look for worms every ten sec
frames_ten_sec = 10*Ring.FrameRate;

level_adj_ctr=0;
global_level_adj_ctr=0;
tic
p=1;
for(Frame = startFrame:endFrame)
    
    % load frames in chunks for greater efficiency
    if(p==1 || mod(p,100)==0)
        aviread_to_gray;
        aviread_to_gray(MovieName, Frame:min((Frame+100),endFrame));
    end
    
    % subtract the background from the frame and mask out the ring
    [Movsubtract, timestamp] = background_subtracted_frame(MovieName, Frame, background, timerbox_coords);
    aviread_to_gray(MovieName, Frame, 'clear');
    if(~isempty(ring_mask))
        Movsubtract = Movsubtract.*ring_mask;
    end
    Movsubtract0 = Movsubtract;
    
    while(procFrame(p).frame_number ~= Frame)
        p=p+1;
    end
    
    
    if(~isempty(timerbox_coords))
        procFrame(p).timestamp = timestamp;
    end
    
    
    % num_target_worms as a function of Frame based on the default threshold
    % calcs? if there is no ring to keep the worms in the field
    if(aggressive_wormfind_flag == 0)
        if(isfield(Ring,'NumWorm_vector'))
            if(~isempty(Ring.NumWorm_vector))
                f = find(Ring.NumWorm_vector(:,1) ==  Frame);
                num_target_worms = Ring.NumWorm_vector(f,2);
                num_missing_worm_threshold = ceil(0.05*num_target_worms);
                if(num_missing_worm_threshold<=1)
                    num_missing_worm_threshold=1;
                end
                half_num_target_worms = num_target_worms/2;
                DefaultLevel = Ring.NumWorm_vector(f,3);
                if(p==1)
                    Level = DefaultLevel;
                    prev_Level = Level;
                end
            end
        end
    end
    
    % define expanded bounding boxes around each known worm position
    row_lim = [];
    col_lim = [];
    thresholds = Level;
    
    n=0;
    if(p>1)
        for(i=1:length(procFrame(p-1).worm))
            n = n+1;
            row_lim(n,:) = [max(1,round(procFrame(p-1).worm(i).coords(2) - half_boundbox_side)) min(FileInfo.Height, round(procFrame(p-1).worm(i).coords(2)+half_boundbox_side))];
            col_lim(n,:) = [max(1,round(procFrame(p-1).worm(i).coords(1) - half_boundbox_side)) min(FileInfo.Width,  round(procFrame(p-1).worm(i).coords(1)+half_boundbox_side))];
            thresholds(n) = procFrame(p-1).worm(i).level;
        end
        for(i=1:length(procFrame(p-1).clump))
            n = n+1;
            row_lim(n,:) = [max(1,round(procFrame(p-1).clump(i).coords(2) - half_boundbox_side)) min(FileInfo.Height, round(procFrame(p-1).clump(i).coords(2)+half_boundbox_side))];
            col_lim(n,:) = [max(1,round(procFrame(p-1).clump(i).coords(1) - half_boundbox_side)) min(FileInfo.Width,  round(procFrame(p-1).clump(i).coords(1)+half_boundbox_side))];
            thresholds(n) = procFrame(p-1).clump(i).level;
        end
        
        % fuse overlapping boxes
        stopflag=0;
        while(stopflag==0)
            stopflag = 1;
            n=1;
            while(n<=size(row_lim,1))
                rect_n = [col_lim(n,1) row_lim(n,1) (col_lim(n,2) - col_lim(n,1)) (row_lim(n,2) - row_lim(n,1))];
                
                m = n+1;
                while(m<=size(row_lim,1))
                    rect_m = [col_lim(m,1) row_lim(m,1) (col_lim(m,2) - col_lim(m,1)) (row_lim(m,2) - row_lim(m,1))];
                    
                    if(rectangle_overlap(rect_n, rect_m))
                        stopflag = 0;
                        
                        row_lim(n,:) = [min([row_lim(n,:) row_lim(m,:)]) max([row_lim(n,:) row_lim(m,:)])];
                        col_lim(n,:) = [min([col_lim(n,:) col_lim(m,:)]) max([col_lim(n,:) col_lim(m,:)])];
                        
                        % box area weighted average of thresholds
                        thresholds(n) = (rect_n(3)*rect_n(4))*thresholds(n) + (rect_m(3)*rect_m(4))*thresholds(m);
                        
                        row_lim(m,:) = [];
                        col_lim(m,:) = [];
                    else
                        m = m+1;
                    end
                end
                n = n+1;
            end
        end
    end
    
    %     if(~mod(p, 10) || p==1)
    %         row_lim = [];
    %         col_lim = [];
    %         thresholds = Level;
    %     end
    
    
    % Identify all objects in the frame
    [cc, NumWorms, numClumps, numWormsClump] = worm_bwconncomp(Movsubtract, thresholds, row_lim, col_lim, image_size);
    total_numWorms = NumWorms + numWormsClump;
    
    if(p==1)
        del_missing = 0;
        adjust_global_threshold_if_necessary();
        del_missing = 2;
    end
    
    
    % in draft mode ... will make it for real below
    [wormStats, clumpStats, NumWorms, numClumps, numWormsClump] = cc_to_wormStats_clumpStats(cc, mean_worm_area, max_worm_area);
    procFrame(p) = add_wormStats_clumpStats_to_procFrame(procFrame(p), wormStats, clumpStats, Ring, 1);
    
    unpaired_worm_idx = [];
    start_worm_array_len = length(procFrame(p).worm);
    
    % did we find enough worms for this frame?
    if(p>1)
        % find worms in frame p linked to worms and clumps in frame p-1
        unpaired_worm_idx = find_next_worm_idx();
        
        % unpaired worms might need a different local threshold to be detected
        if(~isempty(unpaired_worm_idx))
            
            
            % remove detected worms from Movsubtract to avoid repicking
            Movsubtract = set_object_pixels_value(Movsubtract, cc, 0);
            
            for(k=1:length(unpaired_worm_idx))
                i = unpaired_worm_idx(k);
                center_coords = procFrame(p-1).worm(i).coords;
                edge_flag=0;
                % if the unpaired worm is close to the edge of the field of
                % view, it may have wandered off the field of view if
                % aggressive_wormfind_flag=0; ie: no ring or border to
                % corral the animals
                if(aggressive_wormfind_flag==0)
                    if((center_coords(1) < edge_pixels) || (center_coords(2) < edge_pixels) || ...
                            ((FileInfo.Width - center_coords(1)) < edge_pixels) || ((FileInfo.Height - center_coords(2)) < edge_pixels))
                        edge_flag = 1;
                    end
                    % if there is no ring, but there is a mask, if worm is
                    % near the mask set edge_flag =1 so we don't waste time
                    % looking for it
                    if(edge_flag == 0)
                        if(~isempty(mask_edge))
                            
                            XCentroid = center_coords(1)*mask_edge.ComparisonArrayX;
                            YCentroid = center_coords(2)*mask_edge.ComparisonArrayY;
                            
                            DX = mask_edge.X - XCentroid;
                            DY = mask_edge.Y - YCentroid;
                            
                            D = DX.^2 + DY.^2;
                            
                            if((sqrt(min(D)) < edge_pixels))
                                edge_flag = 1;
                            end
                        end
                    end
                end
                if(edge_flag==0)
                    level_adj_ctr = level_adj_ctr + 1;
                    
                    x_corner = max(1,round(center_coords(1) - half_boundbox_side));
                    y_corner = max(1,round(center_coords(2) - half_boundbox_side));
                    
                    %                 local_mask = (zeros(size(Movsubtract)));
                    %                 local_mask(y_corner:min(FileInfo.Height, round(center_coords(2)+half_boundbox_side)), ...
                    %                     x_corner:min(FileInfo.Width,round(center_coords(1)+half_boundbox_side))) = 1;
                    %                 local_Movsubtract = Movsubtract.*local_mask;
                    %                 clear('local_mask');
                    %
                    %                 local_Level = find_optimal_threshold(local_Movsubtract(y_corner:min(FileInfo.Height, round(center_coords(2)+half_boundbox_side)), ...
                    %                     x_corner:min(FileInfo.Width,round(center_coords(1)+half_boundbox_side))), 1); % , Level, 1); % obj_penalty_coeff);
                    %
                    %                 local_cc = worm_bwconncomp(local_Movsubtract, local_Level);
                    
                    
                    local_Level = find_optimal_threshold(Movsubtract(y_corner:min(FileInfo.Height, round(center_coords(2)+half_boundbox_side)), ...
                        x_corner:min(FileInfo.Width,round(center_coords(1)+half_boundbox_side))), 1); % , Level, 1); % obj_penalty_coeff);
                    
                    local_cc = worm_bwconncomp(Movsubtract, local_Level, y_corner:min(FileInfo.Height, round(center_coords(2)+half_boundbox_side)), ...
                        x_corner:min(FileInfo.Width,round(center_coords(1)+half_boundbox_side)), image_size );
                    
                    
                    % pool multple objects into one; weakly detected
                    % worms may be multiple blobs
                    % if fused object is too big, use the first object
                    % and ignore the rest
                    
                    if(local_cc.NumObjects > 1)
                        temp_cc = local_cc;
                        
                        temp_cc.NumObjects = 1;
                        for(t=2:local_cc.NumObjects)
                            temp_cc.object_sizes(1) = temp_cc.object_sizes(1) + temp_cc.object_sizes(t);
                            temp_cc.PixelIdxList{1} = unique([temp_cc.PixelIdxList{1}; temp_cc.PixelIdxList{t}]);
                        end
                        temp_cc.object_sizes(2:end) = [];
                        temp_cc.PixelIdxList(2:end) = [];
                        
                        % composite object is too big, so just use the
                        % first object
                        if(temp_cc.object_sizes(1) > Prefs.MaxWormArea)
                            temp_cc = local_cc;
                            temp_cc.NumObjects = 1;
                            temp_cc.object_sizes(2:end) = [];
                            temp_cc.PixelIdxList(2:end) = [];
                        end
                        
                        local_cc = temp_cc;
                        clear('temp_cc');
                    end
                    
                    if(local_cc.NumObjects>0)
                        cc.NumObjects = cc.NumObjects  + 1;
                        cc.object_sizes(cc.NumObjects) = local_cc.object_sizes(1);
                        cc.PixelIdxList{cc.NumObjects} = local_cc.PixelIdxList{1};
                        
                        % remove the object pixels from Movsubtract to
                        % avoid re-picking
                        Movsubtract = set_object_pixels_value(Movsubtract, local_cc, 0);
                    end
                    
                    clear('local_Movsubtract');
                    
                    
                    
                end
            end % end unpaired worm loop
            
        end
    end
    
    [wormStats, clumpStats, NumWorms, numClumps, numWormsClump] = cc_to_wormStats_clumpStats(cc, mean_worm_area, max_worm_area);
    total_numWorms = NumWorms + numWormsClump;
    
    if(mod(p,frames_ten_sec)==0)
        if(aggressive_wormfind_flag==1)
            del_missing = 0;
        end
    end
    adjust_global_threshold_if_necessary();
    if(mod(p,frames_ten_sec)==0)
        del_missing = 2;
    end
    
    procFrame(p).worm = []; procFrame(p).clump = [];
    procFrame(p) = add_wormStats_clumpStats_to_procFrame(procFrame(p), wormStats, clumpStats, Ring);
    if(p>1)
        % find worms and clump in frame p linked to worms frame p-1
        [~, worms_now_in_clump_idx] = find_next_worm_idx();
        
        
        % clump to worm
        % if a clump in current frame p only has <= one worm from frame p-1
        % pointing to it, it is likely to be a bona fide worm that looks bigger
        % for some reason
        new_worm_idx = []; new_worm_parent_idx = [];
        for(c=1:length(procFrame(p).clump))
            if(isempty(procFrame(p).clump(c).parent_idx)) % de novo clump ... reclassify as worm
                new_worm_idx = [new_worm_idx c];
                new_worm_parent_idx = [new_worm_parent_idx NaN];
            else
                parent_worms = procFrame(p).clump(c).parent_idx(procFrame(p).clump(c).parent_idx<1000);
                parent_clumps = procFrame(p).clump(c).parent_idx(procFrame(p).clump(c).parent_idx>1000);
                
                % only 1 worm parent and no clump parents .. reclassify as worm
                if(length(parent_worms)==1 && isempty(parent_clumps))
                    new_worm_idx = [new_worm_idx c];
                    new_worm_parent_idx = [new_worm_parent_idx parent_worms(1)];
                end
            end
        end
        
        m=length(procFrame(p).worm);
        for(nw=1:length(new_worm_idx))
            c = new_worm_idx(nw);
            m = m+1;
            if(~isnan(new_worm_parent_idx(nw)))
                procFrame(p-1).worm(new_worm_parent_idx(nw)).next_worm_idx = m;
            end
            procFrame(p).worm(m).tracked = 0;
            procFrame(p).worm(m).level = procFrame(p).clump(c).level;
            procFrame(p).worm(m).coords = procFrame(p).clump(c).coords;
            procFrame(p).worm(m).size = procFrame(p).clump(c).size;
            procFrame(p).worm(m).image = procFrame(p).clump(c).image;
            procFrame(p).worm(m).bound_box_corner = procFrame(p).clump(c).bound_box_corner;
            procFrame(p).worm(m).next_worm_idx = [];
            procFrame(p).worm(m).ecc = procFrame(p).clump(c).ecc;
            procFrame(p).worm(m).majoraxis = procFrame(p).clump(c).majoraxis;
            procFrame(p).worm(m).ringDist = procFrame(p).clump(c).ringDist;
            procFrame(p).worm(m).body_contour = procFrame(p).clump(c).body_contour;
        end
        procFrame(p).clump(new_worm_idx) = [];
    end
    
    numObjects = NumWorms + numClumps;
    total_numWorms = NumWorms + numWormsClump;
    
    % total_numWorms_vector = [total_numWorms_vector total_numWorms];
    % num_target_worms = nanmean(total_numWorms_vector);
    
    prev_Level = Level;
    
    thresholds = [];
    for(m=1:length(procFrame(p).worm))
        thresholds = [thresholds procFrame(p).worm(m).level];
    end
    Level = nanmean(thresholds);
    procFrame(p).threshold = Level;
    
    
    
    %     num_target_worms = round(nanmean(total_numWorms_vector));
    %     num_missing_worm_threshold = ceil(0.05*num_target_worms);
    %     if(num_missing_worm_threshold<=1)
    %         num_missing_worm_threshold=2;
    %     end
    
    
    if (~mod(Frame, Prefs.PlotDataRate) || Frame==startFrame) % || procFrame(p).bkgnd_index > 1)
        calcrate = toc/Prefs.PlotDataRate;
        
        if(procFrame(p).bkgnd_index==1)
            disp([sprintf('%d/%d frames\t%d/%d worms found\tlevel = %f\t%f secs/frame\tlocal/global threshold adjusted %d/%d for %d frames\t%s', ...
                Frame, endFrame, NumWorms, round(num_target_worms), Level, calcrate, level_adj_ctr, global_level_adj_ctr, Prefs.PlotDataRate, timeString())])
        else
            disp([sprintf('%d/%d Stimframes\t%d/%d worms found\tlevel = %f\t%s',Frame, endFrame, NumWorms, round(num_target_worms), Level, timeString())])
        end
        level_adj_ctr = 0; global_level_adj_ctr=0;
        tic
    end
    
    % Display every PlotFrameRate'th frame
    if( ~mod(Frame, Prefs.PlotFrameRate) || DEBUG_FLAG==1)
        %         figure(1);
        %
        %         subplot(1,2,1);
        %         Mov = aviread_to_gray(MovieName, Frame);
        %         imshow(Mov.cdata);
        %         clear('Mov');
        %         hold on;
        %
        %         if(~isempty(Ring.RingX))
        %             plot(Ring.RingX(1:end-1),Ring.RingY(1:end-1),'r');
        %         end
        %
        %         for(pp=1:length(procFrame(p).worm))
        %             % plot(procFrame(p).worm(pp).coords(1), procFrame(p).worm(pp).coords(2),'og','markersize',procFrame(p).worm(pp).majoraxis);
        %             rectangle('position',[procFrame(p).worm(pp).bound_box_corner(1), procFrame(p).worm(pp).bound_box_corner(2), ...
        %                 size(procFrame(p).worm(pp).image,2), size(procFrame(p).worm(pp).image,1)],'EdgeColor','g');
        %             hold on;
        %         end
        %
        %         for(pp=1:length(procFrame(p).clump))
        %             text(procFrame(p).clump(pp).coords(1), procFrame(p).clump(pp).coords(2), num2str(procFrame(p).clump(pp).num_worms),'color','r');
        %             hold on;
        %         end
        %
        %         hold off;
        %
        %         subplot(1,2,2);
        %         im = ones(image_size);
        %         for(pp=1:length(procFrame(p).worm))
        %             [y_coord, x_coord] = find(procFrame(p).worm(pp).image==1);
        %
        %             x = x_coord + floor(procFrame(p).worm(pp).bound_box_corner(1));
        %             y = y_coord + floor(procFrame(p).worm(pp).bound_box_corner(2));
        %
        %             for(q=1:length(x))
        %                 im(y(q),x(q)) =  0;
        %             end
        %         end
        %
        %         for(pp=1:length(procFrame(p).clump))
        %             [y_coord, x_coord] = find(procFrame(p).clump(pp).image==1);
        %
        %             x = x_coord + floor(procFrame(p).clump(pp).bound_box_corner(1));
        %             y = y_coord + floor(procFrame(p).clump(pp).bound_box_corner(2));
        %
        %             for(q=1:length(x))
        %                 im(y(q),x(q)) =  0.5;
        %             end
        %         end
        %         imshow(im);
        %
        %         FigureName = ['Worm Tracker - Results for Frame ', num2str(Frame)];
        %         set(gcf, 'Name', FigureName);
        
        calcrate = toc; tic;
        
        if(procFrame(p).bkgnd_index==1)
            disp([sprintf('%d/%d frames\t%d/%d/%d worms found\t%d/%d/%d unpaired worms\tlevel = %f\t%f secs/frame\t%s', ...
                Frame, endFrame, NumWorms, numObjects, round(num_target_worms), ...
                start_worm_array_len,length(unpaired_worm_idx), length(procFrame(max(1,(p-1))).worm), ...
                Level, calcrate, timeString())])
        else
            disp([sprintf('%d/%d Stimframes\t%d/%d worms found\tlevel = %f\t%s',Frame, endFrame, NumWorms, round(num_target_worms), Level, timeString())])
        end
        
        
    end
    
    %     if(NumWorms>1)
    %         pause
    %     end
    
    clear('cc');
    clear('Movsubtract');
    clear('Movsubtract0');
    clear('wormStats');
    clear('clumpStats');
    
    
end % end looping through frames
aviread_to_gray;

clear('t_i'); clear('t_j'); clear('num_worms_vector');
clear('ring_mask');

procFrame = make_single(procFrame);

aviread_to_gray;

% do as embedded function to avoid memory overhead
    function [unpaired_idx, worms_mvg_to_clump_idx] = find_next_worm_idx()
        
        unpaired_idx = [];
        worms_mvg_to_clump_idx = [];
        
        % find worms in frame p linked to worms in frame p-1
        dist_matrix = zeros(length(procFrame(p-1).worm), length(procFrame(p).worm)) + 1e10;
        for(ii=1:length(procFrame(p-1).worm))
            procFrame(p-1).worm(ii).next_worm_idx = [];
            for(jj=1:length(procFrame(p).worm))
                
                distance = distance_between_worm_images_for_tracking(Prefs.MaxTrackCreateFrameDistance, 1e10, ...
                    procFrame(p-1).worm(ii).image, procFrame(p-1).worm(ii).bound_box_corner, ...
                    procFrame(p).worm(jj).image, procFrame(p).worm(jj).bound_box_corner);
                
                centroid_dist = sqrt((procFrame(p-1).worm(ii).coords(1) - procFrame(p).worm(jj).coords(1))^2 + ...
                    (procFrame(p-1).worm(ii).coords(2) - procFrame(p).worm(jj).coords(2))^2);
                
                if(distance <= 1e-4)
                    % negative give preference if worm body images overlap
                    % the baseline big_number is if two or more potential
                    % body overlaps happen ... then give preference to
                    % closest (centroid-centroid) one
                    
                    % centroid must be close enough even if the bodies in
                    % frame p and p-1 overlap
                    % if(centroid_dist <= Prefs.MaxInterFrameDistance)
                    dist_matrix(ii,jj) = -big_number + centroid_dist;
                    % end
                    
                else % non-overlapping, but close enough
                    %                     if(centroid_dist <= Prefs.MaxInterFrameDistance)
                    %                         dist_matrix(ii,jj) = min(centroid_dist, distance);
                    %                     end
                    if(distance <= Prefs.MaxTrackCreateFrameDistance)
                        dist_matrix(ii,jj) = distance;
                    end
                end
            end
        end
        
        if(size(dist_matrix,1)*size(dist_matrix,2)>0)
            [min_dist, ii, jj]  = minn(dist_matrix);
            min_dist = min_dist(1);
            ii = ii(1);
            jj = jj(1);
            while(min_dist <= Prefs.MaxTrackCreateFrameDistance)
                procFrame(p-1).worm(ii).next_worm_idx = jj;
                
                dist_matrix(ii,:) = 1e10;
                dist_matrix(:,jj) = 1e10;
                
                [min_dist, ii, jj]  = minn(dist_matrix);
                min_dist = min_dist(1);
                ii = ii(1);
                jj = jj(1);
            end
        end
        clear('dist_matrix');
        unpaired_idx = [];
        for(ii=1:length(procFrame(p-1).worm))
            if(isempty(procFrame(p-1).worm(ii).next_worm_idx))
                unpaired_idx = [unpaired_idx ii];
            end
        end
        
        % are unpaired worms now part of clumps?
        if(~isempty(unpaired_idx))
            dist_matrix = zeros(length(unpaired_idx), length(procFrame(p).clump)) + 1e10;
            for(kk=1:length(unpaired_idx))
                ii = unpaired_idx(kk);
                for(jj=1:length(procFrame(p).clump))
                    distance = distance_between_worm_images_for_tracking(Prefs.MaxTrackCreateFrameDistance, 1e10, ...
                        procFrame(p-1).worm(ii).image, procFrame(p-1).worm(ii).bound_box_corner, ...
                        procFrame(p).clump(jj).image, procFrame(p).clump(jj).bound_box_corner);
                    if(distance <= 1e-4)
                        % negative give preference if worm body images overlap
                        % the baseline big_number is if two or more potential
                        % overlaps happen ... then give preference to
                        % closest (centroid-centroid) one
                        distance = sqrt((procFrame(p-1).worm(ii).coords(1) - procFrame(p).clump(jj).coords(1))^2 + ...
                            (procFrame(p-1).worm(ii).coords(2) - procFrame(p).clump(jj).coords(2))^2);
                        dist_matrix(kk,jj) = -big_number + distance;
                        
                        %                         OVERLAP_DIST = [OVERLAP_DIST distance];
                        
                    else % or if their centroids are close enough
                        if(distance <= Prefs.MaxTrackCreateFrameDistance)
                            dist_matrix(kk,jj) = distance;
                        end
                    end
                end
            end
            if(size(dist_matrix,1)*size(dist_matrix,2)>0)
                [min_dist, kk, jj]  = minn(dist_matrix);
                min_dist = min_dist(1);
                kk = kk(1);
                jj = jj(1);
                ii = unpaired_idx(kk);
                % frame p-1 worm ii is in frame p clump jj
                while(min_dist <= Prefs.MaxTrackCreateFrameDistance)
                    procFrame(p-1).worm(ii).next_worm_idx = 1000+jj;
                    worms_mvg_to_clump_idx = [worms_mvg_to_clump_idx ii];
                    
                    procFrame(p).clump(jj).parent_idx = [procFrame(p).clump(jj).parent_idx ii];
                    
                    dist_matrix(kk,:) = 1e10;
                    dist_matrix(:,jj) = 1e10;
                    
                    [min_dist, kk, jj]  = minn(dist_matrix);
                    min_dist = min_dist(1);
                    kk = kk(1);
                    jj = jj(1);
                    ii = unpaired_idx(kk);
                end
            end
            clear('dist_matrix');
            
            unpaired_idx = [];
            for(ii=1:length(procFrame(p-1).worm))
                if(isempty(procFrame(p-1).worm(ii).next_worm_idx))
                    unpaired_idx = [unpaired_idx ii];
                end
            end
        end
        
        % find clumps in frame p linked to clumps in frame p-1
        dist_matrix = zeros(length(procFrame(p-1).clump), length(procFrame(p).clump)) + 1e10;
        for(ii=1:length(procFrame(p-1).clump))
            for(jj=1:length(procFrame(p).clump))
                
                distance = distance_between_worm_images_for_tracking(Prefs.MaxTrackCreateFrameDistance, 1e10, ...
                    procFrame(p-1).clump(ii).image, procFrame(p-1).clump(ii).bound_box_corner, ...
                    procFrame(p).clump(jj).image, procFrame(p).clump(jj).bound_box_corner);
                
                centroid_dist = sqrt((procFrame(p-1).clump(ii).coords(1) - procFrame(p).clump(jj).coords(1))^2 + ...
                    (procFrame(p-1).clump(ii).coords(2) - procFrame(p).clump(jj).coords(2))^2);
                
                if(distance <= 1e-4)
                    dist_matrix(ii,jj) = -big_number + centroid_dist;
                else
                    if(distance <= Prefs.MaxTrackCreateFrameDistance)
                        dist_matrix(ii,jj) = distance;
                    end
                end
            end
        end
        if(size(dist_matrix,1)*size(dist_matrix,2)>0)
            [min_dist, ii, jj]  = minn(dist_matrix);
            min_dist = min_dist(1);
            ii = ii(1);
            jj = jj(1);
            while(min_dist <= Prefs.MaxTrackCreateFrameDistance)
                procFrame(p).clump(jj).parent_idx = [procFrame(p).clump(jj).parent_idx (1000+ii)];
                
                dist_matrix(ii,:) = 1e10;
                dist_matrix(:,jj) = 1e10;
                
                [min_dist, ii, jj]  = minn(dist_matrix);
                min_dist = min_dist(1);
                ii = ii(1);
                jj = jj(1);
            end
        end
        clear('dist_matrix');
        
        
        % check procFrame(p-2) to see whether unpaired_idx in
        % procFrame(p-1) are part of a track and not phantom worms
        if(p>2)
            if(~isempty(unpaired_idx))
                del_idx=[];
                for(xx=1:length(unpaired_idx))
                    keepflag=0;
                    jj=1;
                    while(jj<=length(procFrame(p-2).worm))
                        if(~isempty(procFrame(p-2).worm(jj).next_worm_idx))
                            if(procFrame(p-2).worm(jj).next_worm_idx == unpaired_idx(xx))
                                keepflag=1;
                                jj = length(procFrame(p-2).worm)+10;
                            end
                        end
                        jj=jj+1;
                    end
                    if(keepflag == 0)
                        del_idx = [del_idx xx];
                    end
                end
                unpaired_idx(del_idx) = [];
            end
        end
        
        return;
    end



    function adjust_global_threshold_if_necessary()
        
        % adjust overall threshold level for detecting missing animals
        if( ( abs( num_target_worms - total_numWorms ) >= num_missing_worm_threshold )  || (total_numWorms <= half_num_target_worms) || p==1)
            
            thresh_score=[]; testLevel=[]; test_cc=[]; test_NumWorms=[]; test_numClumps=[]; test_numWormsClump=[]; total_worms_local = [];
            rr=0;
            
            % current Level
            rr = rr+1;
            testLevel(rr) = Level;
            test_cc{rr} =  cc; test_NumWorms(rr) = NumWorms; test_numClumps(rr) = numClumps; test_numWormsClump(rr) = numWormsClump;
            total_worms_local(rr) = test_NumWorms(rr)+test_numWormsClump(rr);
            thresh_score(rr) = (num_target_worms - total_worms_local(rr));
            
            
            % previous level
            rr = rr+1;
            testLevel(rr) = prev_Level;
            [test_cc{rr}, test_NumWorms(rr), test_numClumps(rr), test_numWormsClump(rr)] = worm_bwconncomp(Movsubtract0, testLevel(rr) ); % , row_lim, col_lim, image_size);
            total_worms_local(rr) = test_NumWorms(rr)+test_numWormsClump(rr);
            thresh_score(rr) = (num_target_worms - total_worms_local(rr));
            
            
            % default Level
            rr = rr+1;
            testLevel(rr) = DefaultLevel;
            [test_cc{rr}, test_NumWorms(rr), test_numClumps(rr), test_numWormsClump(rr)] = worm_bwconncomp(Movsubtract0, testLevel(rr) ); %, row_lim, col_lim, image_size);
            total_worms_local(rr) = test_NumWorms(rr)+test_numWormsClump(rr);
            thresh_score(rr) = (num_target_worms - total_worms_local(rr));
            
            [best_score, idx] = min(abs(thresh_score));
            
            
            if( (abs(best_score) >= (num_missing_worm_threshold + del_missing)) || (total_worms_local(idx) <= half_num_target_worms)  || p==1)
                % adjustment w/ ~obj_penalty
                rr = rr+1;
                testLevel(rr) = find_optimal_threshold(Movsubtract0, num_target_worms, DefaultLevel, ~obj_penalty_coeff);
                [test_cc{rr}, test_NumWorms(rr), test_numClumps(rr), test_numWormsClump(rr)] = worm_bwconncomp(Movsubtract0, testLevel(rr) ); %, row_lim, col_lim, image_size);
                total_worms_local(rr) = test_NumWorms(rr)+test_numWormsClump(rr);
                thresh_score(rr) = (num_target_worms - total_worms_local(rr));
                
                if( (abs(thresh_score(rr)) >= (num_missing_worm_threshold + del_missing)) || (total_worms_local(rr) <= half_num_target_worms)  || p==1)
                    % standard adjustment
                    rr = rr+1;
                    testLevel(rr) = find_optimal_threshold(Movsubtract0, num_target_worms, DefaultLevel, obj_penalty_coeff);
                    [test_cc{rr}, test_NumWorms(rr), test_numClumps(rr), test_numWormsClump(rr)] = worm_bwconncomp(Movsubtract0, testLevel(rr) ); %, row_lim, col_lim, image_size);
                    total_worms_local(rr) = test_NumWorms(rr)+test_numWormsClump(rr);
                    thresh_score(rr) = (num_target_worms - total_worms_local(rr));
                end
            end
            
            % pick best
            [~, idx] = min(abs(thresh_score));
            if(length(idx)>1)
                [~, max_idx] = max((testLevel(idx)));
                idx = idx(max_idx);
            end
            
            Level = testLevel(idx);
            cc = test_cc{idx};
            
            NumWorms = test_NumWorms(idx);
            numClumps = test_numClumps(idx);
            numWormsClump = test_numWormsClump(idx);
            
            numObjects = NumWorms + numClumps;
            total_numWorms = NumWorms + numWormsClump;
            
            [wormStats, clumpStats, NumWorms, numClumps, numWormsClump] = cc_to_wormStats_clumpStats(cc, mean_worm_area, max_worm_area);
            total_numWorms = NumWorms + numWormsClump;
            
            global_level_adj_ctr = global_level_adj_ctr+1;
        end
        
        return;
    end



return;
end
