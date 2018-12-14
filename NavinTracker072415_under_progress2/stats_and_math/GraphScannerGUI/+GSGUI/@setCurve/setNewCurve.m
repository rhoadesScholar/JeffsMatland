function scObj = setNewCurve(scObj,varargin)
%SETNEWCURVE function for defining initial point(s) from the picture.
    data = scObj.mainObj.xyCoordinatesMatrix;
    if all(data(:) == 0)
        warndlg('All coordinates values are zeros','Warning!!');
        return
    end
    if ~isempty(findobj('tag','plotting')) &&...
        numel(get(findobj('tag','plotting'),'xdata')) > 0
        set(findobj('tag','plotting'),'xdata',[],'ydata',[]);
        drawnow   
    end
    set(scObj.mainObj.hSelectedXPoint,'string','0');
    set(scObj.mainObj.hSelectedYPoint,'string','0');
    set(findobj('label','Add Point','-and',...
        'tag','on'),...
        'callback',@(varargin)addNewPoint(scObj,varargin),...
        'enable','on');
    set(findobj('label','Delete Point','-and',...
        'tag','on'),...
        'callback',@(varargin)deletePoint(scObj,varargin),...
        'enable','on');
    set(findobj('label','Move Point','-and',...
        'tag','on'),...
        'callback',@(varargin)movePoint(scObj,varargin),...
        'enable','on');
    set(findobj('label','Select Point','-and',...
        'tag','on'),...
        'callback',@(varargin)selectPoint(scObj,varargin),...
        'enable','on');        
    set(findobj(scObj.mainObj.hConMenu,'tag','UIcmadd'),...
        'callback',@(varargin)addNewPoint(scObj,varargin),...
        'enable','on');
    set(findobj(scObj.mainObj.hConMenu,'tag','UIcmdelete'),...
        'callback',@(varargin)deletePoint(scObj,varargin),...
        'enable','on');
    set(findobj(scObj.mainObj.hConMenu,'tag','UIcmmove'),...
        'callback',@(varargin)movePoint(scObj,varargin),...
        'enable','on');
    set(findobj(scObj.mainObj.hConMenu,'tag','UIcmselect'),...
        'callback',@(varargin)selectPoint(scObj,varargin),'enable','on');
    set(scObj.mainObj.hCurveDataTable,...
        'cellselectioncallback',@(varargin)cellSelection(scObj,varargin))                            
    set(scObj.mainObj.hCurveDataTable,'visible','on')
    set(scObj.mainObj.hCurveDataTable,'data',scObj.mainObj.tableData)
    [x,y] = GSGUI.GraphScannerGUI.extractpts(get(scObj.mainObj.hMainFig,'currentaxes'));
    if ~isempty(scObj.mainObj.xDataHistory)
        scObj.mainObj.curveNames{end + 1} = scObj.mainObj.defaultCurveName{1};
        set(scObj.mainObj.hCurveList,'string',scObj.mainObj.curveNames)
        set(scObj.mainObj.hCurveList,'value',numel(scObj.mainObj.curveNames))
        set(scObj.mainObj.hCurveList,'userdata',numel(scObj.mainObj.curveNames))
    end
    if isempty(scObj.mainObj.curveNames)
        scObj.mainObj.curveNames{end + 1} = scObj.mainObj.defaultCurveName{1};
        set(scObj.mainObj.hCurveList,'string',scObj.mainObj.curveNames)
        set(scObj.mainObj.hCurveList,'value',numel(scObj.mainObj.curveNames))
        set(scObj.mainObj.hCurveList,'userdata',numel(scObj.mainObj.curveNames))
    end
    scObj.mainObj.xDataHistory{end + 1} = x;
    scObj.mainObj.yDataHistory{end + 1} = y;
    xyScaleMatrix = scObj.mainObj.xyScaleMatrix;
    [xOut,yOut] = GSGUI.GraphScannerGUI.outOfRange(data,x,y);
    if (xOut && xyScaleMatrix(1) == 2) || (yOut && xyScaleMatrix(2) == 2)
        if ~isempty(scObj.mainObj.curveNames)
            scObj.mainObj.curveNames(end) = [];
            set(scObj.mainObj.hCurveList,'string',scObj.mainObj.curveNames)
            set(scObj.mainObj.hCurveList,'value',numel(scObj.mainObj.curveNames))
            set(scObj.mainObj.hCurveList,'userdata',numel(scObj.mainObj.curveNames))
        end
        return
    end
    newCoordinates = GSGUI.GraphScannerGUI.calculation(x,y,data,xyScaleMatrix);
    scObj.mainObj.xyDataValues{end + 1} = newCoordinates;
    if ~isempty(scObj.mainObj.coordinateHistory) &&...
       numel(scObj.mainObj.coordinateHistory) < numel(scObj.mainObj.curveNames) 
        scObj.mainObj.scaleHistory{end + 1} = scObj.mainObj.xyScaleMatrix;
        scObj.mainObj.coordinateHistory{end + 1} = scObj.mainObj.xyCoordinatesMatrix;
    elseif isempty(scObj.mainObj.coordinateHistory)
         scObj.mainObj.scaleHistory{end + 1} = scObj.mainObj.xyScaleMatrix;
         scObj.mainObj.coordinateHistory{end + 1} = scObj.mainObj.xyCoordinatesMatrix;
    end
    hold on;
    line(x,y,...
         'parent',get(scObj.mainObj.hMainFig,'currentaxes'),...
         'color',scObj.mainObj.colorDataInd.linecolor,...
         'marker','o',...
         'linestyle','-',...
         'markeredgecolor',scObj.mainObj.colorDataInd.markerecolor,...
         'markerfacecolor',scObj.mainObj.colorDataInd.markerfcolor,...
         'markersize',8,...
         'tag','plotting',...
         'clipping','off');     
    set(scObj.mainObj.hCurveDataTable,'data',newCoordinates);
    set(scObj.mainObj.hSelectedXPoint,'string',num2str(newCoordinates(1,1),'%10.6e'));
    set(scObj.mainObj.hSelectedYPoint,'string',num2str(newCoordinates(1,2),'%10.6e'));
    scObj.mainObj.isGuiAlter = true;
    set(scObj.mainObj.hFitMenu,'enable','on');
end

