function [wormStats, clumpStats, NumWorms, numClumps, numWormsClump] = cc_to_wormStats_clumpStats(cc, mean_worm_area, max_worm_area)

global Prefs;

contact_dist = (sqrt(8)); % two pixels seperated by one pixel are maximally sqrt(8) apart

contact_dist2 = sqrt(2);

wormStats = [];
clumpStats = [];
NumWorms = 0;
numClumps = 0;
numWormsClump = 0;

STATS = custom_regionprops(cc, {'Area', 'Centroid', 'Eccentricity', 'MajorAxisLength','Image','BoundingBox'});

for(pp=1:length(STATS))
    STATS(pp).cc_index = pp;
    STATS(pp).BoundingBox = floor(STATS(pp).BoundingBox);
    STATS(pp).level = cc.level(pp);
    if(STATS(pp).Area <= Prefs.MaxWormArea)
        wormStats = [wormStats STATS(pp)];
        NumWorms = NumWorms + 1;
    else
        clumpStats = [clumpStats STATS(pp)];
        numClumps = numClumps + 1;
    end
end

m=1;
while(m<=length(clumpStats))
    % if a "clump" is actually a bona fide worm
    if((round(clumpStats(m).Area/max_worm_area) < 2 && clumpStats(m).MajorAxisLength <= Prefs.MaxWormLength) || Prefs.no_collisions_flag==1 )
        wormStats = [wormStats clumpStats(m)];
        clumpStats(m) = [];
        numClumps = numClumps - 1;
        NumWorms = NumWorms+1;
        numWormsClump = numWormsClump - 1;
    else
        numWormsClump = numWormsClump + clumpStats(m).Area/mean_worm_area;
        m=m+1;
    end
end
numWormsClump = max(0,round(numWormsClump));

% if two small worms are within one pixel of each other, fuse them since
% they are likely to be a single poorly resolved animal
ctr=1;
while(ctr==1)
    ctr = 0;
    dist_matrix = zeros(length(wormStats), length(wormStats)) + 1e10;
    for(i=1:length(wormStats))
        for(j=i+1:length(wormStats))
            
            %            [(wormStats(i).Area + wormStats(j).Area) Prefs.MaxWormArea ...
            %            rectangle_overlap([ (wormStats(i).BoundingBox(1)-contact_dist) (wormStats(i).BoundingBox(2)-contact_dist) (2*contact_dist+size(wormStats(i).Image,1)) (2*contact_dist+size(wormStats(i).Image,2)) ], ...
            %         [ wormStats(j).BoundingBox(1) wormStats(j).BoundingBox(2) size(wormStats(j).Image,1) size(wormStats(j).Image,2) ]) ...
            %            distance_between_worm_images_for_tracking(contact_dist, -10, wormStats(i).Image, wormStats(i).BoundingBox(1:2), wormStats(j).Image, wormStats(j).BoundingBox(1:2))]
            
            % distance_between_worm_images_for_tracking(contact_dist, 1e10, wormStats(i).Image, wormStats(i).BoundingBox(1:2), wormStats(j).Image, wormStats(j).BoundingBox(1:2))
            
            
            if( (wormStats(i).Area + wormStats(j).Area) <= Prefs.MaxWormArea  )
                
                % disp('here')
                
                min_dist = distance_between_worm_images_for_tracking(contact_dist, 1e10, wormStats(i).Image, wormStats(i).BoundingBox(1:2), wormStats(j).Image, wormStats(j).BoundingBox(1:2));
                
                if(min_dist <= contact_dist)
                    dist_matrix(i,j) = min_dist;
                end
            else
                if( (wormStats(i).Area + wormStats(j).Area) <= 1.5*Prefs.MaxWormArea  )
                    min_dist = distance_between_worm_images_for_tracking(contact_dist2, 1e10, wormStats(i).Image, wormStats(i).BoundingBox(1:2), wormStats(j).Image, wormStats(j).BoundingBox(1:2));
                    
                    %                     disp('or here')
                    %                     [ contact_dist2]
                    
                    if(min_dist <= contact_dist2)
                        %                         disp('over here')
                        %                         [min_dist contact_dist2]
                        dist_matrix(i,j) = min_dist;
                    end
                end
            end
        end
    end
    
    if(size(dist_matrix,1)*size(dist_matrix,2)>0)
        del_idx = [];
        [min_dist, i, j]  = minn(dist_matrix);
        min_dist = min_dist(1);
        i = i(1);
        j = j(1);
        while(min_dist <= contact_dist)
            ctr = 1;
            % merge wormStats(i) and wormStats(j) into wormStats(i);
            i_cc = wormStats(i).cc_index;
            j_cc = wormStats(j).cc_index;
            
            local_cc.level = nanmean([cc.level(i_cc) cc.level(j_cc)]);
            local_cc.Connectivity = cc.Connectivity;
            local_cc.ImageSize = cc.ImageSize;
            local_cc.NumObjects = 1;
            local_cc.object_sizes = cc.object_sizes(i_cc) + cc.object_sizes(j_cc);
            local_cc.PixelIdxList{1} = unique([cc.PixelIdxList{i_cc}; cc.PixelIdxList{j_cc}]);
            
            local_stats = custom_regionprops(local_cc, {'Area', 'Centroid', 'Eccentricity', 'MajorAxisLength','Image','BoundingBox'});
            local_stats.cc_index = wormStats(i).cc_index;
            local_stats.level = local_cc.level;
            local_stats.BoundingBox = floor(local_stats.BoundingBox);
            wormStats(i) = local_stats;
            
            dist_matrix(i,:) = 1e10;
            dist_matrix(:,j) = 1e10;
            
            del_idx = [del_idx j]; % mark wormStats(j) for purging
            NumWorms = NumWorms - 1;
            
            [min_dist, i, j]  = minn(dist_matrix);
            min_dist = min_dist(1);
            i = i(1);
            j = j(1);
            
            clear('local_cc');
            clear('local_stats');
        end
        wormStats(del_idx) = [];
    end
    clear('dist_matrix');
end

% double-check and make sure a worm is not contigious with a clump
% if it is, add it to the clump
% sometimes low threshold ghost worms appear next to clumps 
for(c=1:length(clumpStats))
    w=1;
    while(w<=length(wormStats))
        min_dist = distance_between_worm_images_for_tracking(contact_dist2, 1e10, clumpStats(c).Image, clumpStats(c).BoundingBox(1:2), wormStats(w).Image, wormStats(w).BoundingBox(1:2));
        if(min_dist <= contact_dist2) % worm(w) contigious with clump ... merge to clump(c) and delete
            i_cc = wormStats(w).cc_index;
            j_cc = clumpStats(c).cc_index;
            
            local_cc.level = nanmean([cc.level(i_cc) cc.level(j_cc)]);
            local_cc.Connectivity = cc.Connectivity;
            local_cc.ImageSize = cc.ImageSize;
            local_cc.NumObjects = 1;
            local_cc.object_sizes = cc.object_sizes(i_cc) + cc.object_sizes(j_cc);
            local_cc.PixelIdxList{1} = unique([cc.PixelIdxList{i_cc}; cc.PixelIdxList{j_cc}]);
            
            local_stats = custom_regionprops(local_cc, {'Area', 'Centroid', 'Eccentricity', 'MajorAxisLength','Image','BoundingBox'});
            local_stats.cc_index = clumpStats(c).cc_index;
            local_stats.level = local_cc.level;
            local_stats.BoundingBox = floor(local_stats.BoundingBox);
            
            clumpStats(c) = local_stats;
            wormStats(w) = [];
            NumWorms = NumWorms - 1;
            
            clear('local_cc');
            clear('local_stats');
        else
            w = w+1;
        end
    end
end

return;
end
