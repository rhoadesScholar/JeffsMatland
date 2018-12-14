function grid_coords = find_grid_box_coords(grid, grid_step, coords)

grid_coords = [];

grid_x = 1;
grid_y = 1;
i=1;
while(i<=length(grid(:,1))-1-grid_step)
    if(mod(i,(grid_step+1))~=0)
        uL = i;
        uR = i+1;
        lL = i+7;
        lR = i+8;
        
        box_vertex_idx = [uL uR lR lL uL];
        
        
        
        if(inpolygon(coords(1), coords(2), grid(box_vertex_idx,1), grid(box_vertex_idx,2)));
            grid_coords = [grid_x grid_y];
            
%             disp([i inpolygon(coords(1), coords(2), grid(box_vertex_idx,1), grid(box_vertex_idx,2))])
%             pause
            
            return;
        end
        grid_x = grid_x + 1;
    else
        grid_x = 1;
        grid_y = grid_y + 1;
    end
    i=i+1;
end

% disp([i inpolygon(coords(1), coords(2), grid(box_vertex_idx,1), grid(box_vertex_idx,2))])
% pause

return;
end
