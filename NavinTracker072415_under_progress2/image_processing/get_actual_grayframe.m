function [actual_grayframe, slice] = get_actual_grayframe(target_frame)

actual_grayframe = ceil(target_frame/3);
slice = mod(target_frame, 3);
if(slice == 0)
    slice = 3;
end

return;
end
 