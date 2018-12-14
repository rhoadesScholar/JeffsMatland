function [CI, chemotaxis_frame, worms_per_region, total_worms] = chemotaxis(picture_filename, plate_type)

global Prefs;
Prefs = define_preferences(Prefs);


if(nargin<2)
    plate_type = 'round';
end

if(nargin == 0) % running in interactive mode... no arguments given.... ask the user for the MovieName
    cd(pwd);
    
    [picture_filename, pathname] = uigetfile(...
        {'*.tif;*.tiff;*.png;*.jpeg;*.jpg', 'image Files (*.tif;*.tiff;*.png;*.jpeg;*.jpg)'; '*.*',  'All Files (*.*)' }, ...
        'Select scanned image file for analysis');
    
    if(isempty(picture_filename))
        errordlg('No image file was selected for analysis');
        return;
    end
    
    picture_filename = sprintf('%s%s%s',pathname,picture_filename);
end


% some default values
arena_verticies = [];
maxclump =  10;
min_ecc = 0.4;
MinWormArea_mm = ((2/3)*1)*((2/3)*0.1);
MaxWormArea_mm = ((4/3)*1)*((4/3)*0.1);
MinWormLength_mm = 0.5;
grid_width_mm = 0.5;
default_threshold = 0.55;
pixelsize = 0.0423; % 600 dpi
edge_trim_width_mm = 2;
blank_level = 1;
grid = [];
grid_steps=6;
round_plate_working_radius_mm = 38; % 37.5;
target_zone_distance_mm = 20;


if(isempty(regexpi(plate_type,'square')))
    edge_trim_width_mm = 0;
end


CI = 0;
total_worms = 0;

close all

if(iscell(picture_filename))
   dd =  picture_filename;
   clear('picture_filename');
   picture_filename = dd{1};
   platename = dd{2};
   clear('dd');
end

% could automatically split image into four pieces and skip the crop step

plate_location_rec = [0 0 1 1];
if(ischar(picture_filename))
    im_in = imread(picture_filename);
    
    questdlg('Identify the plate or region of interest, then double-click','Find plate','OK','OK');
    [im_in, plate_location_rec] = imcrop(im_in);
    imshow(im_in);
    im = im_in;
     platename = inputdlg('Plate name?'); 
        platename = platename{1};
else
    im =  picture_filename;
    im_in = im;
end
       
        
        if(~isempty(regexpi(plate_type,'round')))
            [outer_edge, radius, xc, yc] = find_round_plate_edge(im,'dont_check');
            
            [outer_edge(:,1), outer_edge(:,2) ] = coords_from_circle_params(round_plate_working_radius_mm/pixelsize, [xc,yc]);
            % [outer_edge, radius, xc, yc] = outer_edge_check(im_in, outer_edge, round_plate_working_radius_mm/pixelsize);
            
            BW = uint8(poly2mask(outer_edge(:,1),outer_edge(:,2),size(im_in,1),size(im_in,2)));
            im = im_in.*BW;
        else
            if(~isempty(regexpi(plate_type,'square')))
            questdlg('Identify the region of interest, then double-click','OK','OK');
            h_im = imshow(im_in);
            e = impoly(gca);
            wait(e);
            BW = createMask(e,h_im);
            im = im_in.*uint8(BW);
            end
        end
    

im = (255-double(im))./255;

%im = trim_empty_regions(im);

% define the arena boundries, as well as the worm size limits in pixels
% can include choice of different functions for different plate types

if(~isempty(regexpi(plate_type,'square')))
    answer(1)='N';
    while(answer(1)=='N')
        [pixelsize, arena_verticies, arena_image] = get_square_plate_pixelsize_arena_vertices_image(im);
        [grid, gridlines_x, gridlines_y] = generate_grid_from_corners(arena_verticies, grid_steps);
        
        hold on;
        plot(gridlines_x, gridlines_y, '.b','markersize',1);
        plot(grid(:,1), grid(:,2), 'or');
        
        answer = questdlg('Grid OK?', ...
            'Define grid' , ...
            'Yes','No','Yes');
        close all;
        pause(1);   % pause to allow the GUI to catch up
    end
    min_y = round(min(arena_verticies(:,2))); max_y = round(max(arena_verticies(:,2)));
    min_x = round(min(arena_verticies(:,1))); max_x = round(max(arena_verticies(:,1)));
    
    % trim to get only the arena
    im = im( min_y:max_y, min_x:max_x );
end



MinWormArea = MinWormArea_mm/(pixelsize^2);
MaxWormArea = MaxWormArea_mm/(pixelsize^2);
MinWormLength = MinWormLength_mm/(pixelsize);


im = adapthisteq(im); % imadjust(im); % im - mean(mean(im))/2; adapthisteq(im);
im1=im;



% fill in the gridlines of square plates with pixels of the average
% background intensity; this may allow us to detect some worms on the line
% edges
if(~isempty(regexpi(plate_type,'square')))
    % shift grid to fit the cropped arena image
    
    grid(:,1) = grid(:,1)-min_x+1;
    grid(:,2) = grid(:,2)-min_y+1;
    
    gridlines_y = gridlines_y - min_y+1;
    gridlines_x = gridlines_x - min_x+1;
    
    disp('found grid ....')
end

% trim edge_trim_width_mm mm around the edges ... often shadows, outer edge of arena, lid, etc cause weird effects
% might need something more complex for circular plates
[r,c] = size(im);
minus_mm_y_start = max(1,round(edge_trim_width_mm/pixelsize));
minus_mm_y_end = r - minus_mm_y_start;
minus_mm_x_start = max(1,round(edge_trim_width_mm/pixelsize));
minus_mm_x_end = c - minus_mm_x_start;
working_arena_image = zeros(size(im));
working_arena_image(minus_mm_y_start:minus_mm_y_end,minus_mm_x_start:minus_mm_x_end)=1;
im = im.*working_arena_image;

disp('looking for worms ...')

% threshold level
level = find_optimal_threshold_endpoint_chemotaxis(im, MaxWormArea, MinWormArea);

disp('getting stats for worm objects ....')

% create binary image bitmap
BW = im2bw(im, level);

% figure(100), imshow(BW); pause;

% extract info for each object in the bitmap
L = bwlabel(~BW);
clear('BW');

objects = regionprops(L, {'Area','Centroid','MajorAxisLength','Eccentricity','BoundingBox'});
clear('L');

% remove objects that are clearly not worms
maxclump_area = maxclump*MaxWormArea;
maxclump_area_4 = 4*maxclump_area;
i=1;
while(i<=length(objects))
    if(objects(i).Area < MinWormArea || objects(i).Eccentricity < min_ecc || objects(i).Eccentricity > 0.99 || ...
            objects(i).Area > maxclump_area || objects(i).BoundingBox(3)*objects(i).BoundingBox(4) > maxclump_area_4)
        objects(i) = [];
    else
        i=i+1;
    end
end

% get mean intensity per object ... used for getting rid of splotches
intens=[];
for(i=1:length(objects))
    intens = [intens mean_object_intensity(objects(i), im, level)];
end

% find objects that have the dimensions and intensities of a standard worm
worm_intens=[];
for(i=1:length(objects))
    if(objects(i).Area<=MaxWormArea && objects(i).Area>=MinWormArea && objects(i).MajorAxisLength>=MinWormLength)
        worm_intens = [worm_intens intens(i)];
    end
end
min_intens = min(worm_intens);
max_intens = max(worm_intens);
mean_intens = (nanmean(worm_intens) + nanmedian(worm_intens))/2;
std_intens = nanstd(worm_intens);

% blank the grid and re-find objects
if(~isempty(regexpi(plate_type,'square')))
    grid_width = round((grid_width_mm/2)/(pixelsize));
    blank_level = 1; % median(matrix_to_vector(im));
    for(i=1:length(gridlines_y))
        y = round(gridlines_y(i));
        x = round(gridlines_x(i));
        im(y, x) = blank_level;
        
        for(q=-grid_width:1:grid_width)
            if(x+q <= max_x && x+q >= min_x)
                im(y,x+q)=blank_level;
            end
            if(y+q <= max_y && y+q >= min_y)
                im(y+q,x)=blank_level;
            end
            if(x+q <= max_x && x+q >= min_x && y+q <= max_y && y+q >= min_y)
                im(y+q,x+q)=blank_level;
            end
        end
    end
end

% create binary image bitmap
BW = im2bw(im, level);

% figure(101), imshow(BW); pause;

% extract info for each object in the bitmap

L = bwlabel(~BW);
clear('BW');

disp('finding objects ....')
objects = regionprops(L, {'Area','Centroid','MajorAxisLength','Eccentricity','BoundingBox'});
clear('L');

disp('removing non-worm objects ....')

% remove objects that are clearly not worms
maxclump_area = maxclump*MaxWormArea;
maxclump_area_4 = 4*maxclump_area;
i=1;
while(i<=length(objects))
    if(objects(i).Area < MinWormArea || objects(i).Eccentricity < min_ecc || objects(i).Eccentricity > 0.99 || ...
            objects(i).Area > maxclump_area || objects(i).BoundingBox(3)*objects(i).BoundingBox(4) > maxclump_area_4)
        objects(i) = [];
    else
        i=i+1;
    end
end

intens=[];
for(i=1:length(objects))
    intens = [intens mean_object_intensity(objects(i), im, level)];
end


% figure
% view_picked_worms(objects, [], [], im1);
% pause


% find objects that have the dimensions of a standard worm

areas=[];
obj_indices=[];
num_worms=[];
worm_density=[];
for(i=1:length(objects))
    if(objects(i).Area<=MaxWormArea && objects(i).Area>=MinWormArea && objects(i).MajorAxisLength>=MinWormLength ...
            && intens(i) >= min_intens && intens(i) <= max_intens )
        areas = [areas objects(i).Area];
        obj_indices=[obj_indices i];
    end
end
mean_worm_area = mean(areas) + std(areas); % (mean(areas) + median(areas))/2;
% hist(areas,sshist(areas));
% [mean_worm_area mean(areas)  median(areas)]
% pause


for(i=1:length(objects))
    if(objects(i).Area<=MaxWormArea && objects(i).Area>=MinWormArea && objects(i).MajorAxisLength>=MinWormLength ...
            && intens(i) >= min_intens && intens(i) <= max_intens )
        num_worms = [num_worms max(1,(objects(i).Area/mean_worm_area))];
        worm_density = [worm_density max(1,(objects(i).Area/mean_worm_area))/(objects(i).BoundingBox(3)*objects(i).BoundingBox(4))];
    end
end
worm_density_cutoff =  nanmedian(worm_density) + nanstd(worm_density); % max(worm_density); %

% find remaining objects that may contain clumps of worms
for(i=1:length(objects))
    if(isempty(find(obj_indices == i)))
        if(objects(i).Area > MaxWormArea && objects(i).MajorAxisLength>=MinWormLength)
            clump_size = (objects(i).Area/mean_worm_area);
            if(clump_size <= maxclump && clump_size/(objects(i).BoundingBox(3)*objects(i).BoundingBox(4)) <= worm_density_cutoff ...
                    ... % && intens(i) >= min_intens && intens(i) <= max_intens )
                    && intens(i) <= (mean_intens + std_intens) && intens(i) >= (mean_intens - std_intens) )
                num_worms = [num_worms clump_size];
                obj_indices = [obj_indices i];
            end
        end
    end
end

[p,idx] = sort(obj_indices);
obj_indices = obj_indices(idx);
num_worms = num_worms(idx);

% remove objects not assigned as worm(s)
i=1;
del_idx=[];
while(i<=length(objects))
    if(isempty(find(obj_indices == i)))
        del_idx = [del_idx i];
    end
    i=i+1;
end
objects(del_idx) = [];
intens(del_idx) = [];
clear('obj_indices');


view_picked_worms(objects, [], num_worms, im_in);
hold on
yep=1;
for(i=1:length(num_worms))
    if(num_worms(i)>4 || num_worms(i)<0.5 || num_worms(i)/(objects(i).BoundingBox(3)*objects(i).BoundingBox(4)) > worm_density_cutoff)
        if(yep==1)
            disp(['You may want to double-check the green objects in particular!'])
            yep=0;
        end
        rectangle('Position',objects(i).BoundingBox,'EdgeColor','g');
    end
end

% manually add worms
% pick centroid of region, assume box size of average box dimensions, count
% worms via area, else one

answer = questdlg('Add/remove additional worms?', 'Add/remove worms', 'Yes', 'No', 'Yes');
yep=1;
while(answer(1)=='Y')
    if(yep==1)
        disp('Box animal(s) of interest to add ...');
        disp('Box square(s) of interest to delete ...');
        yep=0;
    end
    
    [objects, num_worms, intens]  = box_and_create_delete_animal_objects(im_in, level, objects, num_worms, intens, mean_worm_area);
    close all;
    view_picked_worms(objects, [], num_worms, im_in);
    hold on
    for(i=1:length(num_worms))
        if(num_worms(i)>4 || num_worms(i)<0.5 || intens(i)<min_intens || num_worms(i)/(objects(i).BoundingBox(3)*objects(i).BoundingBox(4)) > worm_density_cutoff)
            rectangle('Position',objects(i).BoundingBox,'EdgeColor','g');
        end
    end
    
    areas=[];
    for(i=1:length(objects))
        if(objects(i).Area<=MaxWormArea && objects(i).Area>=MinWormArea && objects(i).MajorAxisLength>=MinWormLength ...
                && intens(i) >= min_intens && intens(i) <= max_intens )
            areas = [areas objects(i).Area];
        end
    end
    mean_worm_area = mean(areas) + std(areas); % (mean(areas) + median(areas))/2;
    
    
    answer = questdlg('Add/remove additional worms/objects?', 'Add/remove worms', 'Yes', 'No', 'Yes');
    
end
clear('im2');
close all

total_worms = round(sum(num_worms));

if(isempty(regexpi(plate_type,'square')))
    % identfy odor1 and odor2 points
    odor1 = zeros(1,3);
    odor2 = odor1;
    
    imshow(im_in);
    questdlg(sprintf('Select odor1.\nHit return.'), 'Odor source identification', 'OK', 'OK');
    [odor1(1), odor1(2)] = ginput2('ob');
    hold on
    plot(odor1(1), odor1(2), 'ob');
    
    a = questdlg(sprintf('Select odor2 or control.\nHit return.'), 'Odor source identification', 'OK', 'no second spot', 'OK');
    if(a(1)=='O')
        [odor2(1), odor2(2)] = ginput2('or');
        
        hold on
        plot(odor1(1), odor1(2), 'ob');
        plot(odor2(1), odor2(2), 'or');
        
        [x,y] = coords_from_circle_params(target_zone_distance_mm/pixelsize, [odor1(1) odor1(2)] );
        plot(x,y,'b');
        [x,y] = coords_from_circle_params(target_zone_distance_mm/pixelsize, [odor2(1) odor2(2)] );
        plot(x,y,'r');
    end
end

% figure
% imshow(im1);
% hold on;
% plot(grid(:,1), grid(:,2), 'or');

chemotaxis_frame.name = platename;
if(ischar(picture_filename))
    chemotaxis_frame.filename = picture_filename;
else
    chemotaxis_frame.filename = platename;
end
chemotaxis_frame.plate_location_rec = plate_location_rec;
chemotaxis_frame.mean_worm_area = mean_worm_area;
chemotaxis_frame.objects = [];

if(~isempty(regexpi(plate_type,'square')))
    chemotaxis_frame.grid = grid; % grid coords
    chemotaxis_frame.worms_in_grid = zeros(grid_steps,grid_steps); % each element = #worms in that grid box; 4,3 = 4th row, 3rd column
end

del_idx=[];
for(i=1:length(objects))
    chemotaxis_frame.objects(i).coords = objects(i).Centroid;
    chemotaxis_frame.objects(i).mean_intensity = intens(i);
    chemotaxis_frame.objects(i).worm_area = objects(i).Area;
    chemotaxis_frame.objects(i).BoundingBox = objects(i).BoundingBox;
    chemotaxis_frame.objects(i).num_worms = max(1,num_worms(i));
    
    if(~isempty(regexpi(plate_type,'square')))
        chemotaxis_frame.objects(i).grid_coords = find_grid_box_coords(chemotaxis_frame.grid, grid_steps, chemotaxis_frame.objects(i).coords);
        
        if(~isempty(chemotaxis_frame.objects(i).grid_coords))
            chemotaxis_frame.worms_in_grid(chemotaxis_frame.objects(i).grid_coords(2),chemotaxis_frame.objects(i).grid_coords(1)) = ...
                chemotaxis_frame.worms_in_grid(chemotaxis_frame.objects(i).grid_coords(2),chemotaxis_frame.objects(i).grid_coords(1)) + ...
                chemotaxis_frame.objects(i).num_worms;
        else
            del_idx = [del_idx i];
        end
    else
        chemotaxis_frame.objects(i).r1 = sqrt((chemotaxis_frame.objects(i).coords(1) - odor1(1))^2 + (chemotaxis_frame.objects(i).coords(2) - odor1(2))^2);
        chemotaxis_frame.objects(i).r2 = sqrt((chemotaxis_frame.objects(i).coords(1) - odor2(1))^2 + (chemotaxis_frame.objects(i).coords(2) - odor2(2))^2);
        
        if(chemotaxis_frame.objects(i).r1 <= target_zone_distance_mm/pixelsize)
            odor1(3) = odor1(3)+chemotaxis_frame.objects(i).num_worms;
        end
        if(chemotaxis_frame.objects(i).r2 <= target_zone_distance_mm/pixelsize)
            odor2(3) = odor2(3)+chemotaxis_frame.objects(i).num_worms;
        end
        
    end
    
end
chemotaxis_frame.objects(del_idx)=[];

    close all;
    
        h=view_picked_worms(objects, [], num_worms, im_in);

    worms_per_region = [];
    if(~isempty(regexpi(plate_type,'square')))
        [CI, num_in_left, num_in_right, num_neutral] = square_plate_chemotaxis_index(chemotaxis_frame.worms_in_grid);
        ts = sprintf('CI = %f\n left = %d   right = %d   neutral = %d',CI, num_in_left, num_in_right, num_neutral);
        worms_per_region = [num_in_left num_in_right num_neutral];
        disp(ts)
    else
        hold on;
        plot(odor1(1), odor1(2), 'ob');
        plot(odor2(1), odor2(2), 'or');
        
        [x,y] = coords_from_circle_params(target_zone_distance_mm/pixelsize, [odor1(1) odor1(2)] );
        plot(x,y,'b');
        [x,y] = coords_from_circle_params(target_zone_distance_mm/pixelsize, [odor2(1) odor2(2)] );
        plot(x,y,'r');
        
        CI = (odor1(3) - odor2(3))/length(chemotaxis_frame.objects);
        ts = sprintf('choice_odor1 = %f\n odor1 = %d   odor2 = %d   neutral = %d',CI, round(odor1(3)), round(odor2(3)), round(total_worms-(odor1(3) + odor2(3))));
        worms_per_region = [round(odor1(3)), round(odor2(3)), round(total_worms-(odor1(3) + odor2(3)))];
        disp(ts);
    end
    
    title(fix_title_string(sprintf('%s\n%s',platename, ts)));
    orient landscape
    save_pdf(h,platename);
    
  


% disp([sprintf('pick sections for counting worms')])
% 
% worms_per_region = [];
% answer = questdlg('Pick regions for counting worms?', 'Worm counting', 'Yes', 'No', 'Yes');
% if(answer(1) == 'Y')
%     answer(1) = 'N';
%     
%     centroids=[];
%     for(i=1:length(objects))
%         centroids = [centroids; objects(i).Centroid];
%     end
% else
%     answer(1) = 'Y';
% end
% 
% while(answer(1) == 'N')
%     
%     [BW, x_frame, y_frame] = roipoly(im1);
%     clear('BW');
%     
%     in_section_idx = inpolygon(centroids(:,1), centroids(:,2), x_frame, y_frame);
%     num_worms_section = sum(num_worms(in_section_idx));
%     
%     worms_per_region = [worms_per_region num_worms_section];
%     
%     disp([sprintf('%d worms in this region',num_worms_section)])
%     
%     answer = questdlg('Counting completed?', 'Worm counting', 'Yes', 'No', 'Yes');
%     
% end
% 
% close all;
% view_picked_worms(objects, [], num_worms, im1);

return;
end
