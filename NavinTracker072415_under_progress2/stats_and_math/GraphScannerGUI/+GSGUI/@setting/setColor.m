function setColor(sObj,varargin)
%SETCOLOR function defines linecolor and both marker colors 
    handle = get(gcbo,'tag');
    switch handle
        case 'linecolor'
            lineColor = uisetcolor;
            sObj.mainObj.colorDataInd.linecolor = lineColor;
        case 'markerfstyle'
            markerFColor = uisetcolor;
            sObj.mainObj.colorDataInd.markerfcolor = markerFColor;   
        case 'markerestyle'
            markerEColor = uisetcolor;
            sObj.mainObj.colorDataInd.markerecolor = markerEColor;  
    end
end

