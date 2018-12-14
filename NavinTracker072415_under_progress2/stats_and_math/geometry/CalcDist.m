function Distance = CalcDist(x1,y1,x2,y2)
% Distance = CalcDist(x1,y1,x2,y2)

deltaX = abs(x1 - x2)';
deltaY = abs(y1 - y2)';
Distance = sqrt(deltaX.^2 + deltaY.^2);

return;

end
