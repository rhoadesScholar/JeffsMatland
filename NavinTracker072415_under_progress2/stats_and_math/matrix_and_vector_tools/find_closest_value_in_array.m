function [val, idx] = find_closest_value_in_array(x, array)
% [val, idx] = find_closest_value_in_array(x, array)
% return value val and index idx of the closest element in array to x

if(nargin<1)
   disp('[val, idx] = find_closest_value_in_array(x, array)');
   return
end

val = [];
idx = [];

[~,idx] = min(abs(array - x));

if(isempty(idx))
    return;
end

idx = idx(1);
val = array(idx);

return;
end
