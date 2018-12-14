function setPoint(scObj,varargin)
%SETPOINT1 function captures origin, xlim and ylim points from the picture.
    set(scObj.hCoordinateFigure,'visible','off');
    [x y] = GSGUI.GraphScannerGUI.extractpts(get(scObj.mainObj.hMainFig,'currentaxes'));
    handle = get(gcbo,'tag');
    hAxesData = get(scObj.hAxesDataTable,'data');
    switch handle
        case 'point1'
            hAxesData(1,3:4) = [x(1) y(1)]; % accept only the first point
        case 'point2'
            hAxesData(2,3:4) = [x(1) y(1)];
        case 'point3'
            hAxesData(3,3:4) = [x(1) y(1)];
    end
    set(scObj.hAxesDataTable,'data',hAxesData);
    set(scObj.hCoordinateFigure,'visible','on');
end

