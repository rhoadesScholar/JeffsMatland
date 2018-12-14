function [outer_edge, radius, xc, yc] = find_round_plate_edge(bkgnd, dummy_argument2)

b2 = imfill(imtophat(bkgnd, strel('disk',12)));

b2 = imfill(imtophat(b2, strel('disk',12)));
b2 = imfill(imtophat(b2, strel('disk',12)));
b2 = imfill(imtophat(b2, strel('disk',12)));


b3 = ~im2bw(b2, graythresh(b2));

cc = bwconncomp_sorted(b3,'descend');


b4 = zeros(cc.ImageSize(1),cc.ImageSize(2));
b4(cc.PixelIdxList{1}) = 1;

[y,x] = find(b4==1);
xc = mean(x);
yc = mean(y);
d = sqrt((x-xc).^2 + (y-yc).^2);
[p,r] = hist(d,100);
[~,max_idx] = max(p);
radius = r(max_idx); 


% b5 = edge(b4);
% [x, y] = find(b5==1);
% [radius, xc,yc] = circle_from_coords(x, y);


[outer_edge(:,1), outer_edge(:,2) ] = coords_from_circle_params(radius, [xc,yc]);
if(nargin<2)
    [outer_edge, radius, xc, yc] = outer_edge_check(bkgnd, outer_edge);
end

clear('b2');
clear('b3');
clear('b4');
clear('b5');

return;
end

