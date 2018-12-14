function [dist, xy] = ldist(xyP, xyL) %gets closest point on line (array xyL) to point xyP and distance between

if any(isnan(xyP)) || isempty(xyP) || any(any(isnan(xyL))) || isempty(xyL)
    dist = double(NaN);
    xy = double([NaN NaN]);
%     x = single(xy(1));
%     y = single(xy(2));
else
    segMat = squareform(pdist([xyL; xyP]));
    [row, ~] = find(segMat == min(segMat(1:end-1,end)));
    segIndex = min(row);
    g = segIndex - 1;
    if g < 1
        g = 1; 
    end
    e = segIndex + 1;
    if e > length(xyL)
        e = segIndex;
    end
    xyL = xyL(g:e,:);
    for i = 1:(e-g)
        %line segment defined by ax + by + c = 0
        %a = (y1 – y2)
        %b = (x2 – x1)
        %c = (x1y2 – x2y1)
        a = xyL(i,2) - xyL(i+1,2);
        b = xyL(i+1,1) - xyL(i,1);
        c = xyL(i,1)*xyL(i+1,2) - xyL(i+1,1)*xyL(i,2);
        dists(i) = abs(a*xyP(1) + b*xyP(2) + c) / sqrt(a^2 + b^2);
        xys(i,1) = (b*(b*xyP(1) - a*xyP(2)) - a*c) / (a^2 + b^2);
        xys(i,2) = (a*(-b*xyP(1) + a*xyP(2)) - b*c) / (a^2 + b^2);
    end

    dist = dists(dists == min(dists));
    dist = min(dist);
    xy = xys(dists == min(dists), :);
%     x = xy(1);
%     y = xy(2);
end
return
end