function output_image_cell_array = interpolate_binary_images(start_image, end_image, num_intermediate_images)

output_image_cell_array = {};
for(i=1:num_intermediate_images)
    output_image_cell_array{i} = [];
end

if(isempty(start_image) || isempty(end_image))
    return;
end

s(1,:) = size(start_image);
s(2,:) = size(end_image);

start_img = imresize(start_image,round(mean(s)));
end_img = imresize(end_image,round(mean(s)));

for(i=1:num_intermediate_images)
    output_image_cell_array{i} = logical(round(((num_intermediate_images-i+1)/num_intermediate_images)*start_img + (i/num_intermediate_images)*end_img));
end

return;
end
