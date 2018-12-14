function summary_ethogram(BinData_array, plot_rows, plot_columns, plot_location)

if(nargin<3)
    plot_rows=1;
    plot_columns=1;
end
if(nargin<4)
    plot_location=1;
end

xmin = floor(min_struct_array(BinData_array,'time'));
xmax = ceil(max_struct_array(BinData_array,'time'));

% define image_matrix, R = delta_dir_omegaupsilon, G = speed, B = revlength

colmap = ethogram_colormap;
image_matrix=[];

for(i=1:length(BinData_array))
    for(j=1:length(BinData_array(i).time))
        image_matrix(i,j,:) = [(-BinData_array(i).delta_dir_omegaupsilon(j)) BinData_array(i).speed(j) BinData_array(i).revlength(j)];
    end
end

% scale the values to be between 0 and 1
image_matrix(:,:,1) = colormap_scaling_function(image_matrix(:,:,1), 1, 0, 0, 180);  % ecc_omegaupsilon
image_matrix(:,:,2) = colormap_scaling_function(image_matrix(:,:,2), 1, 0, 0.2, 0.05);   % speed
image_matrix(:,:,3) = colormap_scaling_function(image_matrix(:,:,3), 1, 0, 0.1, 1);      % revlength 

% multiply by frac in each state omegaUpsilon Fwd Rev
for(i=1:length(BinData_array))
    for(j=1:length(BinData_array(i).time))
        image_matrix(i,j,:) = reshape(image_matrix(i,j,:),1,3).*[BinData_array(i).frac_omegaUpsilon(j) (1-(BinData_array(i).frac_omegaUpsilon(j)+BinData_array(i).frac_Rev(j))) BinData_array(i).frac_Rev(j)];
    end
end

image(xmin:xmax, 0:length(BinData_array), image_matrix);
axis([xmin xmax 0 length(BinData_array)]);
axis xy
box('off');
axis tight

return;
end
