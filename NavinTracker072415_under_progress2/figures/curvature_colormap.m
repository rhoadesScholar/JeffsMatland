function val = curvature_colormap(curv)

persistent cmap;
persistent indicies

if(nargin<1)
    cmap=[];
    indicies=[];
    return;
end

lim=45;

if(isnan(curv))
    val = [0 0 0];
    return;
end

if(isempty(cmap))
    cmap =  blue_red_colormap(-lim, lim);  % colormap('jet');
    indicies = linspace(-lim, lim, size(cmap,1));
end


if(curv < -lim)
    val = cmap(1,:);
    return
end
if(curv > lim)
    val = cmap(end,:);
    return
end
[~,idx] = find_closest_value_in_array(curv,indicies);

val = cmap(idx,:);

return;
end
