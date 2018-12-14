function [pixelsize, arena_verticies, arena_image] = get_square_plate_pixelsize_arena_vertices_image(im1)

grid_area_sidelength_mm = 80; % 100mm square plate has 78x78mm grid area

% define the arena boundries, as well as the worm size limits in pixels
disp('Define arena corners, then double-click')

[arena_image, x_edge, y_edge] = roipoly(im1);
hold on;
plot(x_edge, y_edge, 'g', 'linewidth',2);
hold off;

arena_verticies=[];
for(i=1:4)
    arena_verticies(i,1) = x_edge(i);
    arena_verticies(i,2) = y_edge(i);
end
sidelength(1) = (x_edge(1) - x_edge(2))^2 + (y_edge(1) - y_edge(2))^2;
sidelength(2) = (x_edge(2) - x_edge(3))^2 + (y_edge(2) - y_edge(3))^2;
sidelength(3) = (x_edge(3) - x_edge(4))^2 + (y_edge(3) - y_edge(4))^2;
sidelength(4) = (x_edge(4) - x_edge(1))^2 + (y_edge(4) - y_edge(1))^2;
sidelength = mean(sqrt(sidelength));
pixelsize = grid_area_sidelength_mm/sidelength; 

% pauses to allow the GUI to catch up
close all;
pause(1);

arena_verticies = round(arena_verticies);

return;
end
