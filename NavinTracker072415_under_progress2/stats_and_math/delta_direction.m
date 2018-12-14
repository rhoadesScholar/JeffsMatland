function delta_theta = delta_direction(dir1, dir2)

delta_theta = dir2 - dir1;

if(dir1<0)
    if(delta_theta > 180)
        delta_theta = delta_theta - 360;
    end
end

if(dir1>0)
    if(delta_theta < -180)
        delta_theta = 360 + delta_theta;
    end
end

return;
end
