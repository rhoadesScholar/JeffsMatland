function inlawn_indicies = incircle(x,y, r, center)
% inlawn_indicies = incircle(x,y, r, center) returns indicies of x,y that
% are inside circle defined by r center [xc, yc]

xc = center(1);
yc = center(2);

% outer box sides
ymin = yc - r;
ymax = yc + r;
xmin = xc - r;
xmax = xc + r;

% inner box sides
sin_cos_45 = sqrt(2)/2;
ymin_inner = yc - sin_cos_45;
ymax_inner = yc + sin_cos_45;
xmin_inner = xc - sin_cos_45;
xmax_inner = xc + sin_cos_45;

r2 = r^2;
len_x = length(x);

inlawn_indicies=[];
for(i=1:len_x)
    if(x(i) <= xmax)
        if(x(i) >= xmin)
            if(y(i) <= ymax)
                if(y(i) >= ymin) % inside outer box
                    
                    % measure distance if not in inner box; if in inner
                    % box, point x,y is inside the circle
                    
                    measure_flag=1;
                    
                    if(x(i) <= xmax_inner)
                        if(x(i) >= xmin_inner)
                            if(y(i) <= ymax_inner)
                                if(y(i) >= ymin_inner) % inside inner box
                                    measure_flag=0;
                                    inlawn_indicies = [inlawn_indicies i];
                                end
                            end
                        end
                    end
                    
                    if(measure_flag==1)
                        if((x(i) - xc)^2 + (y(i) - yc)^2 <= r2)
                            inlawn_indicies = [inlawn_indicies i];
                        end
                    end
                    
                end
            end
        end
    end
end

return;
end
