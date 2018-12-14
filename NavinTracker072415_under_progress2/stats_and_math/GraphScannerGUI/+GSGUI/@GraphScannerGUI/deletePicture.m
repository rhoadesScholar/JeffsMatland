function deletePicture(obj,varargin)
%DELETEPICTURE function deletes the current picture.
    delete(get(obj.hMainFig,'currentaxes'));
    set(obj.hCurveDataTable,'data',obj.tableData);
    set(findobj('label','Add Point'),'enable','off');
    set(findobj('label','Delete Point'),'enable','off');
    set(findobj('label','Move Point'),'enable','off');
    set(findobj('label','Select Point'),'enable','off');
    set(findobj('label','Settings'),'enable','off');
    set(findobj('label','Resize...'),'enable','off');
    set(findobj('label','Curve'),'enable','off');
    set(obj.hSelectedXPoint,'string','');
    set(obj.hSelectedYPoint,'string','');
    obj.isGuiAlter = false;
    obj.curveNames = {};
    obj.xDataHistory = {};
    obj.yDataHistory = {};
    obj.xyDataValues = {};
    obj.scaleHistory = {};
    obj.coordinateHistory = {};
    set(obj.hCurveList,'string',obj.defaultCurveName{1},...
                       'value',1,'userdata',1);
    obj.xAxisLabel = '';
    obj.yAxisLabel = '';
    set(obj.hFitMenu,'enable','off');
end

