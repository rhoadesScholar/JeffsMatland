function [x,y,place] = checkDistance(x_1,y_1,pts,mode,xi)
%CHECKDISTANCE function checks the approriate distance for the closest
%point and places the point on the right place.
    switch mode
        case 'add'
            if length(x_1) == 1
                x = [x_1;pts(1)];
                y = [y_1;pts(2)];
                place = 1;
            else 
                dist1 = (x_1-pts(1)).^2+(y_1-pts(2)).^2;
                dist2 = (x_1(2:end)-x_1(1:end-1)).^2+(y_1(2:end)-y_1(1:end-1)).^2;
                [val1,x1] = min(dist1);
                if isequal(x1,1) 
                    if dist2(1) < dist1(2)
                        x = [pts(1);x_1];
                        y = [pts(2);y_1];
                        place = x1;
                    else
                        x = [x_1(1);pts(1);x_1(2:end)];
                        y = [y_1(1);pts(2);y_1(2:end)];
                        place = x1+1;
                    end
                elseif x1 == length(x_1)
                    if dist2(end) < dist1(end-1)
                        x = [x_1;pts(1)];
                        y = [y_1;pts(2)];
                        place = x1+1;
                    else
                        x = [x_1(1:end-1);pts(1);x_1(end)];
                        y = [y_1(1:end-1);pts(2);y_1(end)];
                        place = x1;
                    end
                else
                    if x1 ~= 1 && x1 ~= length(x_1)
                        a = [x_1(x1),y_1(x1)] - pts;
                        b = [x_1(x1-1),y_1(x1-1)] - pts;
                        c = [x_1(x1+1),y_1(x1+1)] - pts;
                        if dist1(x1-1) < dist2(x1-1) &&...
                            acosd(sum(a.*c)./(norm(a)*norm(c))) <...
                            acosd(sum(a.*b)./(norm(a)*norm(b)))
                            x = [x_1(1:x1-1);pts(1);x_1(x1:end)];
                            y = [y_1(1:x1-1);pts(2);y_1(x1:end)];
                            place = x1;
                        elseif dist1(x1+1) < dist2(x1) &&...
                            acosd(sum(a.*b)./(norm(a)*norm(b))) <...
                            acosd(sum(a.*c)./(norm(a)*norm(c)))
                            x = [x_1(1:x1);pts(1);x_1(x1+1:end)];
                            y = [y_1(1:x1);pts(2);y_1(x1+1:end)]; 
                            place = x1+1;
                        else
                            if dist1(x1-1) < dist1(x1+1)
                                x = [x_1(1:x1-1);pts(1);x_1(x1:end)];
                                y = [y_1(1:x1-1);pts(2);y_1(x1:end)];
                                place = x1;
                            else
                                x = [x_1(1:x1);pts(1);x_1(x1+1:end)];
                                y = [y_1(1:x1);pts(2);y_1(x1+1:end)];
                                place = x1+1;
                            end
                        end
                    end
                end
            end
        case 'delete'
            dist1 = (x_1-pts(1)).^2+(y_1-pts(2)).^2;
            [val1,x1] = min(dist1);
            place = [x_1(x1),y_1(x1)];
            x_1(x1) = [];
            y_1(x1) = [];
            x = x_1;
            y = y_1;
        case 'select'
            dist1 = (x_1-pts(1)).^2+(y_1-pts(2)).^2;
            [val1,x1] = min(dist1);
            place = [x_1(x1),y_1(x1),x1];
            x = x_1;
            y = y_1;
        case 'move'
            if numel(x_1) == 1 && numel(y_1) == 1
                x = pts(1);
                y = pts(2);
                place = 1;
            elseif numel(x_1) == 2 && numel(y_1) == 2
                x_1(xi) = [];
                y_1(xi) = [];
                x = [x_1;pts(1)];
                y = [y_1;pts(2)];
                place = 2;
            elseif numel(x_1) > 2 && numel(y_1) > 2
                x_1(xi) = [];
                y_1(xi) = [];
                dist1 = (x_1-pts(1)).^2+(y_1-pts(2)).^2;
                dist2 = (x_1(2:end)-x_1(1:end-1)).^2+(y_1(2:end)-y_1(1:end-1)).^2;
                [val1,x1] = min(dist1);
                if x1 == 1
                    if dist2(1) < dist1(2)
                        x = [pts(1);x_1];
                        y = [pts(2);y_1];
                        place = x1;
                    else
                        x = [x_1(1);pts(1);x_1(2:end)];
                        y = [y_1(1);pts(2);y_1(2:end)];
                        place = x1+1;
                    end
                elseif x1 == length(x_1)
                    if dist2(end) < dist1(end-1)
                        x = [x_1;pts(1)];
                        y = [y_1;pts(2)];
                        place = x1+1;
                    else
                        x = [x_1(1:end-1);pts(1);x_1(end)];
                        y = [y_1(1:end-1);pts(2);y_1(end)];
                        place = x1;
                    end
                else
                    if x1 ~= 1 && x1 ~= length(x_1)
                        a = [x_1(x1),y_1(x1)] - pts;
                        b = [x_1(x1-1),y_1(x1-1)] - pts;
                        c = [x_1(x1+1),y_1(x1+1)] - pts;
                        if dist1(x1-1) < dist2(x1-1) &&...
                            acosd(sum(a.*c)./(norm(a)*norm(c))) <...
                            acosd(sum(a.*b)./(norm(a)*norm(b)))
                            x = [x_1(1:x1-1);pts(1);x_1(x1:end)];
                            y = [y_1(1:x1-1);pts(2);y_1(x1:end)];
                            place = x1; 
                        elseif dist1(x1+1) < dist2(x1) &&...
                            acosd(sum(a.*b)./(norm(a)*norm(b))) <...
                            acosd(sum(a.*c)./(norm(a)*norm(c)))
                            x = [x_1(1:x1);pts(1);x_1(x1+1:end)];
                            y = [y_1(1:x1);pts(2);y_1(x1+1:end)];
                            place = x1+1;
                        else
                            if dist1(x1-1) < dist1(x1+1)
                                x = [x_1(1:x1-1);pts(1);x_1(x1:end)];
                                y = [y_1(1:x1-1);pts(2);y_1(x1:end)];
                                place = x1;
                            else
                                x = [x_1(1:x1);pts(1);x_1(x1+1:end)];
                                y = [y_1(1:x1);pts(2);y_1(x1+1:end)];
                                place = x1+1;
                            end
                        end
                    end
                end
            end
    end
end


