function selectPoint(scObj,varargin)
%SELECTPOINT function selects point from the curve and highlights the
%selected point. Also a box appears next to selected point which encompasses data values.
    h1 = line('parent',get(scObj.mainObj.hMainFig,'currentaxes'),...
              'xdata',[],...
              'ydata',[],...
              'visible','off',...
              'clipping','off',...
              'linestyle','none');
    data = scObj.mainObj.xyCoordinatesMatrix;
    xyScaleMatrix = scObj.mainObj.xyScaleMatrix;       
    while 1
        try 
            mouseDown = waitforbuttonpress;
            if mouseDown == 0
                if exist('hTextBox','var') && ishandle(hTextBox)
                    delete(hTextBox)
                end
                if isequal(get(gcf,'selectiontype'),'alt') 
                    set(scObj.mainObj.hMainFig,'pointer','arrow');
                    if ishandle(h1)
                        delete(h1)
                    end
                    if exist('hTextBox','var') && ishandle(hTextBox)
                        delete(hTextBox)
                    end
                    break
                end
                pt = get(get(scObj.mainObj.hMainFig,'currentaxes'),'currentpoint');
                pts = [pt(1,1),pt(1,2)];
                [xOut,yOut] = GSGUI.GraphScannerGUI.outOfRange(data,pts(1),pts(2));
                if (xOut && xyScaleMatrix(1) == 2) || (yOut && xyScaleMatrix(2) == 2)
                    if ishandle(h1)
                        delete(h1)
                    end
                    if exist('hTextBox','var') && ishandle(hTextBox)
                        delete(hTextBox)
                    end
                    break
                end
                newCoordinates = get(scObj.mainObj.hCurveDataTable,'data');
                xdata = scObj.mainObj.xDataHistory{get(scObj.mainObj.hCurveList,'userdata')};
                ydata = scObj.mainObj.yDataHistory{get(scObj.mainObj.hCurveList,'userdata')};
                [x,y,place] = GSGUI.GraphScannerGUI.checkDistance(xdata,ydata,pts,'select',1);
                set(h1,'xdata',place(1),...
                    'ydata',place(2),...
                    'marker','o',...
                    'color',scObj.mainObj.colorDataInd.linecolor,...
                    'markeredgecolor',scObj.mainObj.colorDataInd.markerecolor,...
                    'markerfacecolor','y',...
                    'markersize',10,...
                    'visible','on');  
                set(scObj.mainObj.hSelectedXPoint,'string',...
                    num2str(newCoordinates(place(3),1),'%10.6e'));
                set(scObj.mainObj.hSelectedXPoint,'tooltipstring',...
                    sprintf('x-value\nLast modification: point %d selected',place(3)));
                set(scObj.mainObj.hSelectedYPoint,'string',...
                    num2str(newCoordinates(place(3),2),'%10.6e'));
                set(scObj.mainObj.hSelectedYPoint,'tooltipstring',...
                    sprintf('y-value\nLast modification: point %d selected',place(3)));
                pos.one = get(scObj.mainObj.hMainFig,'currentpoint');
                pos.two = get(scObj.mainObj.hMainFig,'pos');
                pos.three = get(scObj.mainObj.hPicturePanel,'pos');
                w = 125;
                h = 45;
                x1 = pos.one(1) + 5;
                y1 = pos.one(2) - 55;
                if (pos.two(1) + pos.two(3))*pos.three(3) < (pos.one(1) + w)
                    x1 = pos.one(1) - 10 - w;
                    y1 = pos.one(2) + 10;
                elseif y1 < (pos.two(2) + pos.two(4))*pos.three(2)
                    x1 = pos.one(1) - 10 - w;
                    y1 = pos.one(2) + 10;
                end
                hTextBox = annotation('textbox',...
                                      'units','pixels',...
                                      'pos',[x1 y1 w h],...
                                      'backgroundcolor',[1 1 0.8],...
                                      'color','red',...
                                      'edgecolor','black',...
                                      'fontname','helvetica',...
                                      'margin',5,...
                                      'linewidth',1,...
                                      'fitboxtotext','on',...
                                      'string',{['\bullet x = ',num2str(newCoordinates(place(3),1),'%6.4e')],...
                                                ['\bullet y = ',num2str(newCoordinates(place(3),2),'%6.4e')]});
            else
                if ishandle(h1)
                    delete(h1)
                end
                if exist('hTextBox','var') && ishandle(hTextBox)
                    delete(hTextBox)
                end
                break
            end
        catch ME
            if ishandle(h1)
                delete(h1)
             end
             errordlg(ME.message,ME.identifier)
             if exist('hTextBox','var') && ishandle(hTextBox)
                 delete(hTextBox)
             end
             break 
        end 
    end
    return
end 


