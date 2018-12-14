function addNewPoint(scObj,varargin)
%ADDNEWPOINT function adds new point(s) to the picture.
    [pointerShape, pointerHotSpot] = GSGUI.GraphScannerGUI.createPointer;
    set(scObj.mainObj.hMainFig,'pointer','custom',...
        'pointershapecdata',pointerShape,...
        'pointershapehotspot',pointerHotSpot);
    data = scObj.mainObj.xyCoordinatesMatrix;
    xyScaleMatrix = scObj.mainObj.xyScaleMatrix;
    while 1 % allow multiple selection
        try
            mouseDown = waitforbuttonpress;
            if mouseDown == 0
                if isequal(get(gcf,'selectiontype'),'alt')
                    set(scObj.mainObj.hMainFig,'pointer','arrow');
                    break
                end
                pt = get(get(scObj.mainObj.hMainFig,'currentaxes'),'currentpoint');
                pts = [pt(1,1),pt(1,2)];
                [xOut,yOut] = GSGUI.GraphScannerGUI.outOfRange(data,pts(1),pts(2));          
                if (xOut && xyScaleMatrix(1) == 2) || (yOut && xyScaleMatrix(2) == 2)
                    % end of new point selection
                    set(scObj.mainObj.hMainFig,'pointer','arrow');
                    break
                end
                [x,y,place] = GSGUI.GraphScannerGUI.checkDistance(...
                              cell2mat(scObj.mainObj.xDataHistory(get(scObj.mainObj.hCurveList,'userdata'))),...
                              cell2mat(scObj.mainObj.yDataHistory(get(scObj.mainObj.hCurveList,'userdata'))),...
                              pts,'add',1);
                scObj.mainObj.xDataHistory{get(scObj.mainObj.hCurveList,'userdata')} = x;
                scObj.mainObj.yDataHistory{get(scObj.mainObj.hCurveList,'userdata')} = y;
                newCoordinates = GSGUI.GraphScannerGUI.calculation(x,y,data,xyScaleMatrix);
                scObj.mainObj.xyDataValues{get(scObj.mainObj.hCurveList,'userdata')} = newCoordinates;
                set(scObj.mainObj.hCurveDataTable,'data',newCoordinates);
                scObj.mainObj.isGuiAlter = true;
                notify(scObj.mainObj,'updateGraph');
                set(scObj.mainObj.hSelectedXPoint,'string',...
                    num2str(newCoordinates(place,1),'%10.6e'));
                set(scObj.mainObj.hSelectedXPoint,'tooltipstring',...
                    sprintf('x-value\nLast modification: point added'));
                set(scObj.mainObj.hSelectedYPoint,'string',...
                    num2str(newCoordinates(place,2),'%10.6e'));
                set(scObj.mainObj.hSelectedYPoint,'tooltipstring',...
                    sprintf('y-value\nLast modification: point added'));
            elseif mouseDown == 1
                set(scObj.mainObj.hMainFig,'pointer','arrow');
                break
            end
        catch ME
            set(scObj.mainObj.hMainFig,'pointer','arrow');
            errordlg(ME.message,ME.identifier)
            break
        end
    end
    return
end

