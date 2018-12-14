function timestamp = timestamp_from_image(image, timestamp_coords)
% timestamp = timestamp_from_image(image, [timestamp_coords])
% assumes format is hrs:min min:sec sec:msec msec msec
% 1:23:45.678 1hr, 23min, 45.678sec 

%     format is hrs:min min:sec sec:msec msec msec
%                1   2   3   4    5   6    7    8
format_vector = [3600 600 60 10 1 0.1 0.01 0.001];

global Prefs;

if(isempty(Prefs))
    timestamp_thresh = 200;
else
    timestamp_thresh =  Prefs.timestamp_thresh;
end

if(nargin<2)
    timestamp_coords = [];
end

if(isempty(timestamp_coords))
    timestamp_coords = timestamp_coords_from_image(image);
end

box_image = image(timestamp_coords(1):timestamp_coords(2), timestamp_coords(3):timestamp_coords(4));

% objects listed left to right
cc = bwconncomp(custom_im2bw(box_image, timestamp_thresh));

% filter out periods and colons
sizes = [];
for(i=1:cc.NumObjects)
    sizes = [sizes length(cc.PixelIdxList{i})];
end
period_size = min(sizes);
idx = find(sizes==period_size);
cc.PixelIdxList(idx) = [];
cc.NumObjects = length(cc.PixelIdxList);

reg_props = custom_regionprops(cc, {'Image'});

timestamp = NaN;

if(length(reg_props) == format_vector)
    timestamp_vector = [];
    for(i=1:length(reg_props))
        corr_coeffs = [];
        for(k=1:10)
            corr_coeffs = [corr_coeffs corr2( imresize(reg_props(i).Image, [14 9]), number_image_templates(k-1))];
        end
        idx = find(corr_coeffs == max(corr_coeffs));
        if(~isempty(idx))
            idx = idx(1)-1;
        else
            idx = NaN;
        end
        timestamp_vector = [timestamp_vector idx];
    end
    timestamp = sum(timestamp_vector.*format_vector);
end

return;
end

function image = number_image_templates(n)

image = [];

if(n == 0)
    image = [  0     0     0     1     1     1     0     0     0
        0     1     1     1     1     1     1     1     0
        0     1     1     0     0     0     1     1     0
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        0     1     1     0     0     0     1     1     0
        0     1     1     1     1     1     1     1     0
        0     0     0     1     1     1     0     0     0];
end

if(n==1)
    image = [   0     0     0     1     1
        0     0     1     1     1
        1     1     1     1     1
        1     1     1     1     1
        0     0     0     1     1
        0     0     0     1     1
        0     0     0     1     1
        0     0     0     1     1
        0     0     0     1     1
        0     0     0     1     1
        0     0     0     1     1
        0     0     0     1     1
        0     0     0     1     1
        0     0     0     1     1];
    image = imresize(image,[14  9]);
end

if(n==2)
    image = [ 0     0     1     1     1     1     1     0     0
        0     1     1     1     1     1     1     1     0
        1     1     1     0     0     0     1     1     1
        1     1     0     0     0     0     0     1     1
        0     0     0     0     0     0     0     1     1
        0     0     0     0     0     0     1     1     1
        0     0     0     0     0     1     1     1     0
        0     0     0     1     1     1     1     0     0
        0     0     1     1     1     0     0     0     0
        0     1     1     1     0     0     0     0     0
        0     1     1     0     0     0     0     0     0
        1     1     0     0     0     0     0     0     0
        1     1     1     1     1     1     1     1     1
        1     1     1     1     1     1     1     1     1];
end

if(n==3)
    image = [  0     0     0     1     1     1     0     0     0
        0     1     1     1     1     1     1     1     0
        0     1     1     0     0     0     1     1     0
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        0     0     0     0     0     0     1     1     0
        0     0     0     1     1     1     1     0     0
        0     0     0     1     1     1     1     1     0
        0     0     0     0     0     0     1     1     0
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        0     1     1     0     0     0     1     1     0
        0     1     1     1     1     1     1     1     0
        0     0     0     1     1     1     0     0     0];
end

if(n==4)
    image = [  0     0     0     0     1     1     1     0     0
        0     0     0     0     1     1     1     0     0
        0     0     0     1     1     1     1     0     0
        0     0     0     1     1     1     1     0     0
        0     0     1     1     0     1     1     0     0
        0     0     1     1     0     1     1     0     0
        0     1     1     0     0     1     1     0     0
        0     1     1     0     0     1     1     0     0
        1     1     0     0     0     1     1     0     0
        1     1     1     1     1     1     1     1     1
        1     1     1     1     1     1     1     1     1
        0     0     0     0     0     1     1     0     0
        0     0     0     0     0     1     1     0     0
        0     0     0     0     0     1     1     0     0];
end

if(n==5)
    image = [     0     1     1     1     1     1     1     1     0
        0     1     1     1     1     1     1     1     0
        0     1     1     0     0     0     0     0     0
        0     1     1     0     0     0     0     0     0
        1     1     0     0     0     0     0     0     0
        1     1     1     1     1     1     0     0     0
        1     1     1     1     1     1     1     1     0
        1     1     0     0     0     0     1     1     0
        0     0     0     0     0     0     0     1     1
        0     0     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        1     1     1     0     0     0     1     1     0
        0     1     1     1     1     1     1     1     0
        0     0     1     1     1     1     0     0     0];
end

if(n==6)
    image = [  0     0     0     1     1     1     0     0     0
        0     1     1     1     1     1     1     1     0
        0     1     1     0     0     0     1     1     0
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     0     0
        1     1     0     1     1     1     0     0     0
        1     1     1     1     1     1     1     1     0
        1     1     1     0     0     0     1     1     0
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        0     1     1     0     0     0     1     1     0
        0     1     1     1     1     1     1     1     0
        0     0     0     1     1     1     0     0     0];
end

if(n==7)
    image = [    1     1     1     1     1     1     1     1     1
        1     1     1     1     1     1     1     1     1
        0     0     0     0     0     0     0     1     1
        0     0     0     0     0     0     0     1     1
        0     0     0     0     0     0     1     1     0
        0     0     0     0     0     0     1     1     0
        0     0     0     0     0     1     1     0     0
        0     0     0     0     0     1     1     0     0
        0     0     0     0     1     1     0     0     0
        0     0     0     0     1     1     0     0     0
        0     0     0     0     1     1     0     0     0
        0     0     0     1     1     0     0     0     0
        0     0     0     1     1     0     0     0     0
        0     0     0     1     1     0     0     0     0];
end

if(n==8)
    image = [   0     0     0     1     1     1     0     0     0
        0     1     1     1     1     1     1     1     0
        0     1     1     0     0     0     1     1     0
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        0     1     1     0     0     0     1     1     0
        0     0     1     1     1     1     1     0     0
        0     1     1     1     1     1     1     1     0
        0     1     1     0     0     0     1     1     0
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        0     1     1     0     0     0     1     1     0
        0     1     1     1     1     1     1     1     0
        0     0     0     1     1     1     0     0     0];
end

if(n==9)
    image = [    0     0     0     1     1     1     0     0     0
        0     1     1     1     1     1     1     1     0
        0     1     1     0     0     0     1     1     0
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        0     1     1     0     0     0     1     1     1
        0     1     1     1     1     1     1     1     1
        0     0     0     1     1     1     0     1     1
        0     0     0     0     0     0     0     1     1
        1     1     0     0     0     0     0     1     1
        0     1     1     0     0     0     1     1     0
        0     1     1     1     1     1     1     1     0
        0     0     0     1     1     1     0     0     0];
end


return;
end

