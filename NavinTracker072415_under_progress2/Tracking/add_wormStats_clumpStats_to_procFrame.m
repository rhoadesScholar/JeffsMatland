function procFrame = add_wormStats_clumpStats_to_procFrame(procFrame, wormStats, clumpStats, Ring, draft_flag)
% procFrame = add_wormStats_clumpStats_to_procFrame(procFrame, wormStats, clumpStats, Ring, draft_flag)
% if draft_flag = 0 calculate everything into worm and clump arrays (default)
% if draft_flag = 1 ignore a bunch of fields (used for process_movie_frames)

if(nargin<5)
    draft_flag = 0;
end

m=length(procFrame.worm);

for(ws=1:length(wormStats))
    
    if(wormStats(ws).BoundingBox(3)>1 && wormStats(ws).BoundingBox(4)>1) % filter out 1D worms
        
        m = m+1;
        
        procFrame.worm(m).tracked = 0;
        
        procFrame.worm(m).level = wormStats(ws).level;
        procFrame.worm(m).coords = wormStats(ws).Centroid;
        procFrame.worm(m).size = wormStats(ws).Area;
        procFrame.worm(m).image = wormStats(ws).Image;
        procFrame.worm(m).bound_box_corner = floor([wormStats(ws).BoundingBox(1) wormStats(ws).BoundingBox(2)]);
        procFrame.worm(m).next_worm_idx = [];
        
        procFrame.worm(m).ecc = wormStats(ws).Eccentricity;
        procFrame.worm(m).majoraxis = wormStats(ws).MajorAxisLength;
        
        
        if(draft_flag == 0)
            procFrame.worm(m).ringDist = calc_WormRingDistances(procFrame.frame_number, Ring, procFrame.worm(m).coords);
            procFrame.worm(m).body_contour = body_contour_from_image(wormStats(ws).Image, procFrame.worm(m).bound_box_corner);
        else
            procFrame.worm(m).ringDist = NaN;
            procFrame.worm(m).body_contour = body_contour_from_image([], procFrame.worm(m).bound_box_corner);
        end
        
    end
    
end

m=length(procFrame.clump);
for(ws=1:length(clumpStats))
    
    if(clumpStats(ws).BoundingBox(3)>1 && clumpStats(ws).BoundingBox(4)>1) % filter out 1D clumps
        
        m = m+1;
        
        procFrame.clump(m).level = clumpStats(ws).level;
        procFrame.clump(m).coords = clumpStats(ws).Centroid;
        procFrame.clump(m).bound_box_corner = [clumpStats(ws).BoundingBox(1) clumpStats(ws).BoundingBox(2)];
        procFrame.clump(m).num_worms = round(clumpStats(ws).Area/Ring.meanWormSize(1));
        procFrame.clump(m).image = clumpStats(ws).Image;
        procFrame.clump(m).size = clumpStats(ws).Area;
        procFrame.clump(m).parent_idx = [];
        
        procFrame.clump(m).ecc = clumpStats(ws).Eccentricity;
        procFrame.clump(m).majoraxis = clumpStats(ws).MajorAxisLength;
        
        
        if(draft_flag == 0)
            procFrame.clump(m).ringDist = calc_WormRingDistances(procFrame.frame_number, Ring, procFrame.clump(m).coords);
            procFrame.clump(m).body_contour = body_contour_from_image(clumpStats(ws).Image, procFrame.clump(m).bound_box_corner);
        else
            procFrame.clump(m).ringDist = NaN;
            procFrame.clump(m).body_contour = body_contour_from_image([], procFrame.clump(m).bound_box_corner);
        end
        
    end
    
end

return;
end
