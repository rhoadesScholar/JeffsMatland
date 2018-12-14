function num_worms = count_worms_in_region(im)
% num_worms = count_worms_in_region(im)
% given an image im, counts number of worm objects

pixelsize = 0.0423; % 600 dpi
maxclump =  20;
min_ecc = 0.4;
MinWormArea_mm = ((2/3)*1)*((2/3)*0.1);
MaxWormArea_mm = ((4/3)*1)*((4/3)*0.1);
MinWormLength_mm = 0.5;
edge_trim_width_mm = 0;

MinWormArea = MinWormArea_mm/(pixelsize^2);
MaxWormArea = MaxWormArea_mm/(pixelsize^2);
MinWormLength = MinWormLength_mm/(pixelsize);


im = (255-double(im))./255;
im = adapthisteq(im);
im1 = im;


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


% threshold level
level = find_optimal_threshold_endpoint_chemotaxis(im, MaxWormArea, MinWormArea);

disp('getting stats for worm objects ....')

% create binary image bitmap
BW = im2bw(im, level);

% figure(100), imshow(BW); pause;

% extract info for each object in the bitmap
L = bwlabel(~BW);
clear('BW');

objects = custom_regionprops(L, {'Area','Centroid','MajorAxisLength','Eccentricity','BoundingBox'});
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


% create binary image bitmap
BW = im2bw(im, level);

% figure(101), imshow(BW); pause;

% extract info for each object in the bitmap

L = bwlabel(~BW);
% clear('BW');

disp('finding objects ....')
objects = custom_regionprops(L, {'Area','Centroid','MajorAxisLength','Eccentricity','BoundingBox'});
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
mean_worm_area = (mean(areas) + median(areas))/2;

for(i=1:length(objects))
    if(objects(i).Area<=MaxWormArea && objects(i).Area>=MinWormArea && objects(i).MajorAxisLength>=MinWormLength ...
            && intens(i) >= min_intens && intens(i) <= max_intens )
        num_worms = [num_worms max(1,(objects(i).Area/mean_worm_area))];
        worm_density = [worm_density max(1,(objects(i).Area/mean_worm_area))/(objects(i).BoundingBox(3)*objects(i).BoundingBox(4))];
    end
end
worm_density_cutoff =  1e10; % nanmedian(worm_density) + nanstd(worm_density); % max(worm_density); %

% find remaining objects that may contain clumps of worms
for(i=1:length(objects))
    if(isempty(find(obj_indices == i)))
        if(objects(i).Area > MaxWormArea && objects(i).MajorAxisLength>=MinWormLength)
            clump_size = (objects(i).Area/mean_worm_area);
            if(clump_size <= maxclump && clump_size/(objects(i).BoundingBox(3)*objects(i).BoundingBox(4)) <= worm_density_cutoff ...
                    && intens(i) <= (mean_intens + 2*std_intens) && intens(i) >= (mean_intens - 2*std_intens) )
                num_worms = [num_worms clump_size];
                obj_indices = [obj_indices i];
            else
                                num_worms = [num_worms clump_size];
                obj_indices = [obj_indices i];
%                 imshow(BW); hold on
%                     plot(objects(i).Centroid(1), objects(i).Centroid(2),'or');
%                     hold off
%                     disp(clump_size)
%                     pause
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


view_picked_worms(objects, [], num_worms, im1);
hold on
yep=1;
for(i=1:length(num_worms))
    if(num_worms(i)>10 || intens(i)<min_intens || num_worms(i)/(objects(i).BoundingBox(3)*objects(i).BoundingBox(4)) > worm_density_cutoff)
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
    
    [objects, num_worms, intens]  = box_and_create_delete_animal_objects(im, level, objects, num_worms, intens, mean_worm_area);
    
    answer = questdlg('Add/remove additional worms/objects?', 'Add/remove worms', 'Yes', 'No', 'Yes');
    
end
clear('im2');

num_worms = round(sum(num_worms));
disp([sprintf('%d worms total',num_worms)])

return;
end
