function curveListFcn(obj,varargin)
%CURVELISTFCN displays user defined curve which has been picked from the
%dropdown-menu. 
    curveInd = get(obj.hCurveList,'value');
    set(obj.hCurveList,'userdata',curveInd)
    handle = findobj('tag','plotting');
    if ~isempty(handle) && ~isempty(obj.scaleHistory) && ~isempty(obj.coordinateHistory)
        obj.xyScaleMatrix = obj.scaleHistory{curveInd};
        obj.xyCoordinatesMatrix = obj.coordinateHistory{curveInd};
        set(handle,...
            'xdata',obj.xDataHistory{curveInd},...
            'ydata',obj.yDataHistory{curveInd});
        set(obj.hCurveDataTable,'data',obj.xyDataValues{curveInd});
        drawnow
    end
end

