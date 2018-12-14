function new_image = set_object_pixels_value(current_image, cc, value)

if(nargin<3)
    value = 0;
end

new_image = current_image;

idx=[];
for(i=1:cc.NumObjects)
    idx = [idx; cc.PixelIdxList{i}];
end

new_image(idx) = value;

clear('idx');

return;
end
