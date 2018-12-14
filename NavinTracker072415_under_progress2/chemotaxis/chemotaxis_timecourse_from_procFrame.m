function [CI, frames, num_target, num_control, total_numworms] = chemotaxis_timecourse_from_procFrame(procFrame, target_region, control_region)
% [CI, frames, num_target, num_control, total_numworms] = chemotaxis_timecourse_from_procFrame(procFrame, target_region, control_region)

if(nargin<3)
   control_region = []; 
end
if(isempty(control_region))
   control_region = [0 0]; 
end

CI = [];
frames = [];
num_target = zeros(1, length(procFrame));
num_control = zeros(1, length(procFrame));
total_numworms = zeros(1, length(procFrame));
for(i=1:length(procFrame))
    frames = [frames procFrame(i).frame_number];
    
    x = []; y = [];
    for(j=1:length(procFrame(i).worm))
        x = [x procFrame(i).worm(j).coords(1)];
        y = [y procFrame(i).worm(j).coords(2)];
    end
    % find the x and y coords inside the target and control region polygons
    % with inpolygon
    target_idx = inpolygon(x,y,target_region(:,1),target_region(:,2));
    control_idx = inpolygon(x,y,control_region(:,1),control_region(:,2));
    
    if(~isempty(target_idx))
        num_target(i) = nansum(target_idx);
    end
    if(~isempty(control_idx))
        num_control(i) = nansum(control_idx);
    end
    
    x = []; y = []; clump_worms = [];
    for(j=1:length(procFrame(i).clump))
        x = [x procFrame(i).clump(j).coords(1)];
        y = [y procFrame(i).clump(j).coords(2)];
        clump_worms = [clump_worms procFrame(i).clump(j).num_worms(1)];
    end
    target_idx = inpolygon(x,y,target_region(:,1),target_region(:,2));
    control_idx = inpolygon(x,y,control_region(:,1),control_region(:,2));
    
    if(~isempty(clump_worms(find(target_idx==1))))
        num_target(i) = num_target(i) + nansum(clump_worms(find(target_idx==1)));
    end    
    if(~isempty(clump_worms(find(control_idx==1))))
        num_control(i) = num_control(i) + nansum(clump_worms(find(control_idx==1)));
    end
    
    total_numworms(i) = length(procFrame(i).worm);
    
    if(~isempty(clump_worms))
        total_numworms(i) = total_numworms(i) + nansum(clump_worms); 
    end
    
    CI = [CI (num_target(i) - num_control(i))/(total_numworms(i)) ];
end


return;
end