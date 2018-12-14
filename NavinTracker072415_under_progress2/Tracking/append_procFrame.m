function procFrame = append_procFrame(procFrameA, procFrameB)
% procFrame = append_procFrame(procFrameA, procFrameB)
% appends procFrameB to the end of procFrameA
% next_worm_idx assigned to the last frame of procFrameA

global Prefs;

procFrame = [procFrameA procFrameB];

if(length(procFrameA)==0)
    return;
end

big_number = (2^14)^2;

p = length(procFrameA) + 1; % index for first frame of procFrameB

unpaired_idx = [];

% find worms in frame p linked to worms in frame p-1
dist_matrix = zeros(length(procFrame(p-1).worm), length(procFrame(p).worm)) + 1e10;
for(ii=1:length(procFrame(p-1).worm))
    for(jj=1:length(procFrame(p).worm))
        
        distance = distance_between_worm_images_for_tracking(Prefs.MaxTrackCreateFrameDistance, 1e10, ...
            procFrame(p-1).worm(ii).image, procFrame(p-1).worm(ii).bound_box_corner, ...
            procFrame(p).worm(jj).image, procFrame(p).worm(jj).bound_box_corner);
        
        if(distance <= 1e-4)
            % negative give preference if worm body images overlap
            % the baseline big_number  is if two or more potential
            % body overlaps happen ... then give preference to
            % closest (centroid-centroid) one
            distance = sqrt((procFrame(p-1).worm(ii).coords(1) - procFrame(p).worm(jj).coords(1))^2 + ...
                (procFrame(p-1).worm(ii).coords(2) - procFrame(p).worm(jj).coords(2))^2);
            dist_matrix(ii,jj) = -big_number + distance;
        else % or if their centroids are close enough
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
                % the baseline big_number (2048^2) is if two or more potential
                % overlaps happen ... then give preference to
                % closest (centroid-centroid) one
                distance = sqrt((procFrame(p-1).worm(ii).coords(1) - procFrame(p).clump(jj).coords(1))^2 + ...
                    (procFrame(p-1).worm(ii).coords(2) - procFrame(p).clump(jj).coords(2))^2);
                dist_matrix(kk,jj) = -big_number + distance;
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
        while(min_dist <= Prefs.MaxTrackCreateFrameDistance)
            procFrame(p-1).worm(ii).next_worm_idx = 1000+jj;
            
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

return;
end
