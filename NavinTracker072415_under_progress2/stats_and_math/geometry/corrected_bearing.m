function theta = corrected_bearing(theta)

if(length(theta)>1)
    idx = find(theta>180);
    theta(idx) = theta(idx) - 360;
    idx = find(theta<-180);
    theta(idx) = theta(idx) + 360;
    return;
end

if(theta > 180)
    theta =  theta - 360;
end
if(theta < -180)
    theta =  360 + theta;
end

return;
end
