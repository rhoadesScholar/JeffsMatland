function headingError = getHeadingError(xyI, xyA)% returns degree error of (A)ctual heading from (I)deal heading towards closest intersection;
    % xyA= [xi, yi; x(i-1), y(i-1)]

    if size(xyA, 1) == 1
        headingError = 0;
        return
    end
%     if isempty(xyI)
%         disp('Load background file');
%         uiopen
%         xyI = findBorderManually (bkgnd, edge)
%     end
    if size(xyI, 1) > 1%checks to see if xyI is lawn edge array or intersection point
        [~, xyI] = ldist(xyA(1,:), xyI);
    end

    pathI = defineLineMB([xyA(1,:); xyI]);
    pathA = defineLineMB([xyA(1,:); xyA(2,:)]);

    line3 = getPerpLineMB(pathI, xyI);
    xy3 = findIntersectMB(pathA, line3);
    
    lengthI = getDist([xyA(1,:); xyI]);
    lengthAto3 = getDist([xyA(1,:); xy3]);    
% unecessary %     length3 = getDist(xyI, xy3);
    headingError = rad2deg(acos(lengthI/lengthAto3));
    %FIND DIRECTION OF ACTUAL PATH (towards or away from lawn) and adjust
    %heading error if necessary
    if lengthAto3 > getDist([xyA(2,:); xy3])
        headingError = 180 - headingError;
    end
    headingError = real(headingError);
    return

end

function dist = getDist(xys)
    dist = sqrt((xys(2,1) - xys(1,1))^2 + (xys(2,2) - xys(1,2))^2);
end

function coef = getPerpLineMB(line, xyI)
    m = 1/-line(1);
    b = xyI(2) - m*xyI(1);
    coef = [m b];
end

function xy = findIntersectMB(line1, line2)
    x = (line1(2) - line2(2)) / (line2(1) - line1(1));
    y = [x 1]*line1';
    xy = [x y];
end

function coef = defineLineMB(xys)%coef = [m b]
%line segment defined by y = mx + b
        %m = (y2 - y1)/(x2 – x1)
        %b = y1 - (m*x1)     
        m = (xys(2,2) - xys(1,2))/(xys(2,1) - xys(1,1));
        b = xys(1,2) + m*xys(1,1);
        coef = [m b];
end

function coef = defineLineABC(xys)%coef = [a b c]
%line segment defined by ax + by + c = 0
        %a = (y1 – y2)
        %b = (x2 – x1)
        %c = (x1y2 – x2y1)
        a = xys(1,2) - xys(2,2);
        b = xys(2,1) - xys(1,1);
        c = xys(1,1)*xys(2,2) - xys(2,1)*xys(1,2);
        coef = [a b c];
end