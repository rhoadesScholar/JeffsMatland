function cellSelection(scObj,varargin)
%CELLSELECTION function highlights point which is selected from the data table. 
    
    persistent oldIndex;
    index = varargin{1}(2);
    index = index{1}.Indices;
    if ~isempty(findobj('tag','cellselplot'))
        set(findobj('tag','cellselplot'),...
            'xdata',[],...
            'ydata',[],...
            'marker','none')
        if ~isempty(oldIndex) && isequal(oldIndex(1),index(1))
            set(scObj.mainObj.hSelectedXPoint,'fontweight','normal');
            set(scObj.mainObj.hSelectedYPoint,'fontweight','normal');
            delete(findobj('tag','cellselplot'))
            return
        end
        oldIndex = index;
    else
        oldIndex = index; 
    end
    if isempty(index) 
        set(scObj.mainObj.hSelectedXPoint,'fontweight','normal');
        set(scObj.mainObj.hSelectedYPoint,'fontweight','normal');
        delete(findobj('tag','cellselplot'))
        return
    end
    xData = scObj.mainObj.xDataHistory{get(scObj.mainObj.hCurveList,'userdata')};
    yData = scObj.mainObj.yDataHistory{get(scObj.mainObj.hCurveList,'userdata')};
    newCoordinates = [xData yData];
    h = line(newCoordinates(index(1),1),newCoordinates(index(1),2),...
             'parent',get(scObj.mainObj.hMainFig,'currentaxes'),...
             'marker','o',...
             'color',scObj.mainObj.colorDataInd.linecolor,...
             'markeredgecolor',scObj.mainObj.colorDataInd.markerecolor,...
             'markerfacecolor','y',...
             'markersize',10,...
             'tag','cellselplot',...
             'clipping','off');
    newCoordinates = get(scObj.mainObj.hCurveDataTable,'data');
    set(scObj.mainObj.hSelectedXPoint,'string',...
        num2str(newCoordinates(index(1),1),'%10.6e'));
    set(scObj.mainObj.hSelectedXPoint,'tooltipstring',...
        sprintf('x-value\nLast modification: point %d selected',index(1)));
    set(scObj.mainObj.hSelectedYPoint,'string',...
        num2str(newCoordinates(index(1),2),'%10.6e'));
    set(scObj.mainObj.hSelectedYPoint,'tooltipstring',...
        sprintf('y-value\nLast modification: point %d selected',index(1)));
    set(scObj.mainObj.hSelectedXPoint,'fontweight','bold');
    set(scObj.mainObj.hSelectedYPoint,'fontweight','bold');
end



