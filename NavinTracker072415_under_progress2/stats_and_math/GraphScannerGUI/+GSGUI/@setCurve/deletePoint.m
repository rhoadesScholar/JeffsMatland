function deletePoint(scObj,varargin)
%DELETEPOINT function deletes user defined point(s) from the picture.
    data = scObj.mainObj.xyCoordinatesMatrix;
    xyScaleMatrix = scObj.mainObj.xyScaleMatrix;
    while 1 % allow multiple selection
        try
            mouseDown = waitforbuttonpress;
            if mouseDown == 0
                if isequal(get(gcf,'selectiontype'),'normal')
                    pt = get(get(scObj.mainObj.hMainFig,'currentaxes'),'currentpoint');
                    pts = [pt(1,1),pt(1,2)];
                    [xOut,yOut] = GSGUI.GraphScannerGUI.outOfRange(data,pts(1),pts(2));           
                    if (xOut && xyScaleMatrix(1) == 2) || (yOut && xyScaleMatrix(2) == 2) ||...
                        isempty(scObj.mainObj.xDataHistory(get(scObj.mainObj.hCurveList,'userdata')))
                        set(gcbf,'WindowButtonMotionFcn','')
                        set(gcbf,'WindowButtonUpFcn','')
                        % quit the selection  
                        break
                    end
                    [x,y,place] = GSGUI.GraphScannerGUI.checkDistance(...
                                  cell2mat(scObj.mainObj.xDataHistory(get(scObj.mainObj.hCurveList,'userdata'))),...
                                  cell2mat(scObj.mainObj.yDataHistory(get(scObj.mainObj.hCurveList,'userdata'))),...
                                  pts,'delete',1);
                    scObj.mainObj.xDataHistory{get(scObj.mainObj.hCurveList,'userdata')} = x;
                    scObj.mainObj.yDataHistory{get(scObj.mainObj.hCurveList,'userdata')} = y;
                    if isempty(x)
                        set(scObj.mainObj.hCurveDataTable,'data',[]);
                        set(findobj('tag','plotting'),'XData',[],'YData',[]);
                        set(scObj.mainObj.hSelectedXPoint,'string',num2str(place(1),'%10.6e'));
                        set(scObj.mainObj.hSelectedXPoint,'tooltipstring',...
                            sprintf('x-value\nLast modification: point deleted'));
                        set(scObj.mainObj.hSelectedYPoint,'string',num2str(place(2),'%10.6e'));
                        set(scObj.mainObj.hSelectedYPoint,'tooltipstring',...
                            sprintf('y-value\nLast modification: point deleted'));
                        scObj.mainObj.curveNames(get(scObj.mainObj.hCurveList,'userdata')) = [];
                        scObj.mainObj.xDataHistory(get(scObj.mainObj.hCurveList,'userdata')) = [];
                        scObj.mainObj.yDataHistory(get(scObj.mainObj.hCurveList,'userdata')) = [];
                        scObj.mainObj.xyDataValues(get(scObj.mainObj.hCurveList,'userdata')) = [];
                        scObj.mainObj.scaleHistory(get(scObj.mainObj.hCurveList,'userdata')) = [];
                        scObj.mainObj.coordinateHistory(get(scObj.mainObj.hCurveList,'userdata')) = [];
                        if ~isempty(scObj.mainObj.curveNames)  
                            set(scObj.mainObj.hCurveList,'string',scObj.mainObj.curveNames)
                            if isequal(get(scObj.mainObj.hCurveList,'userdata'),1)
                                set(scObj.mainObj.hCurveList,'value',get(scObj.mainObj.hCurveList,'userdata'))
                                set(scObj.mainObj.hCurveList,'userdata',numel(scObj.mainObj.curveNames))
                                scObj.mainObj.curveListFcn(scObj.mainObj,varargin)
                            else
                                set(scObj.mainObj.hCurveList,'value',get(scObj.mainObj.hCurveList,'userdata') - 1)
                                set(scObj.mainObj.hCurveList,'userdata',numel(scObj.mainObj.curveNames))
                                scObj.mainObj.curveListFcn(scObj.mainObj,varargin)
                            end
                        end
                        if isempty(scObj.mainObj.curveNames)
                            set(findobj('label','Add Point'),'enable','off');
                            set(findobj('label','Delete Point'),'enable','off');
                            set(findobj('label','Move Point'),'enable','off');
                            set(findobj('label','Select Point'),'enable','off');
                            set(scObj.mainObj.hSelectedXPoint,'string','');
                            set(scObj.mainObj.hSelectedYPoint,'string','');
                            scObj.mainObj.curveNames = {};
                            scObj.mainObj.xDataHistory = {};
                            scObj.mainObj.yDataHistory = {};
                            scObj.mainObj.xyDataValues = {};
                            scObj.mainObj.scaleHistory = {};
                            scObj.mainObj.coordinateHistory = {};
                            set(scObj.mainObj.hCurveList,...
                                'string',scObj.mainObj.defaultCurveName{1},...
                                'value',1,'userdata',1);
                            set(scObj.mainObj.hFitMenu,'enable','off');
                            scObj.mainObj.isGuiAlter = false;
                            set(gcbf,'WindowButtonMotionFcn','')
                            set(gcbf,'WindowButtonUpFcn','')
                            break
                        end
                    elseif ~isempty(x)
                        place = GSGUI.GraphScannerGUI.calculation(place(1),place(2),...
                                                               data,xyScaleMatrix);
                        newCoordinates = GSGUI.GraphScannerGUI.calculation(x,y,data,...
                                                               xyScaleMatrix);
                        scObj.mainObj.xyDataValues{get(scObj.mainObj.hCurveList,'userdata')} = newCoordinates;                                   
                        set(scObj.mainObj.hCurveDataTable,'data',newCoordinates);
                        scObj.mainObj.isGuiAlter = true;
                        notify(scObj.mainObj,'updateGraph');
                        set(scObj.mainObj.hSelectedXPoint,'string',num2str(place(1),'%10.6e'));
                        set(scObj.mainObj.hSelectedXPoint,'tooltipstring',...
                            sprintf('x-value\nLast modification: point deleted'));
                        set(scObj.mainObj.hSelectedYPoint,'string',num2str(place(2),'%10.6e'));
                        set(scObj.mainObj.hSelectedYPoint,'tooltipstring',...
                            sprintf('y-value\nLast modification: point deleted'));
                    else
                        set(gcbf,'WindowButtonMotionFcn','')
                        set(gcbf,'WindowButtonUpFcn','')
                        break
                    end
                elseif isequal(get(gcf,'selectiontype'),'alt')
                    pt = get(get(scObj.mainObj.hMainFig,'currentaxes'),'currentpoint');
                    xinit = pt(1,1);
                    yinit = pt(1,2);
                    lineprop = {'parent',get(scObj.mainObj.hMainFig,'currentaxes'),...
                                'linewidth',1,...
                                'linestyle',':',...
                                'color','b',...
                                'clipping','off'};
                    h.line1 = line([xinit xinit],[yinit yinit],lineprop{:});
                    h.line2 = line([xinit xinit],[yinit yinit],lineprop{:});
                    h.line3 = line([xinit xinit],[yinit yinit],lineprop{:});
                    h.line4 = line([xinit xinit],[yinit yinit],lineprop{:});
                    set(scObj.mainObj.hMainFig,'WindowButtonMotionFcn',{@wbmFcn,h,xinit,yinit})
                    set(scObj.mainObj.hMainFig,...
                        'WindowButtonUpFcn',{@wbuFcn,scObj,h,xinit,yinit,data,xyScaleMatrix})
                    try
                        waitfor(h.line1,'userdata','complete')
                    catch ME
                        errordlg(ME.message,ME.identifier)
                    end 
                    break
                elseif isequal(get(gcf,'selectiontype'),'extend')
                    set(gcbf,'WindowButtonMotionFcn','')
                    set(gcbf,'WindowButtonUpFcn','')
                    break
                end
            elseif mouseDown ~= 0
                set(gcbf,'WindowButtonMotionFcn','')
                set(gcbf,'WindowButtonUpFcn','')
                break
            end
        catch ME
            errordlg(ME.message,ME.identifier)
            break    
        end  
    end
end

%--------------------------------------------------------------------------
function wbmFcn(varargin)
    h = varargin{3};
    xinit = varargin{4};
    yinit = varargin{5};
    pt = get(get(gcbf,'currentaxes'),'currentpoint');
    set(h.line1,'xdata',[xinit,pt(1,1)],'ydata',[yinit yinit]);
    set(h.line2,'xdata',[xinit,pt(1,1)],'ydata',[pt(1,2) pt(1,2)]);
    set(h.line3,'xdata',[xinit,xinit],'ydata',[yinit pt(1,2)]);
    set(h.line4,'xdata',[pt(1,1),pt(1,1)],'ydata',[yinit pt(1,2)]);
end

%--------------------------------------------------------------------------  
function wbuFcn(varargin)
    scObj = varargin{3};
    h = varargin{4};
    xinit = varargin{5};
    yinit = varargin{6};
    data = varargin{7};
    xyScaleMatrix = varargin{8};
    pt = get(get(gcbf,'currentaxes'),'currentpoint');
    x = scObj.mainObj.xDataHistory{get(scObj.mainObj.hCurveList,'userdata')};
    y = scObj.mainObj.yDataHistory{get(scObj.mainObj.hCurveList,'userdata')};
    if pt(1,1) > xinit
        xLimits = [xinit,pt(1,1)];
    else
        xLimits = [pt(1,1),xinit];
    end
    if pt(1,2) > yinit
        yLimits = [yinit,pt(1,2)];
    else
        yLimits = [pt(1,2),yinit];
    end
    index = find(x >= xLimits(1) & x <= xLimits(2) & y >= yLimits(1) & y <= yLimits(2)); 
    if numel(index) == numel(x)
        set(scObj.mainObj.hCurveDataTable,'data',[]);
        set(findobj('tag','plotting'),'xdata',[],'ydata',[]);
        scObj.mainObj.curveNames(get(scObj.mainObj.hCurveList,'userdata')) = [];
        scObj.mainObj.xDataHistory(get(scObj.mainObj.hCurveList,'userdata')) = [];
        scObj.mainObj.yDataHistory(get(scObj.mainObj.hCurveList,'userdata')) = [];
        scObj.mainObj.xyDataValues(get(scObj.mainObj.hCurveList,'userdata')) = [];
        scObj.mainObj.scaleHistory(get(scObj.mainObj.hCurveList,'userdata')) = [];
        scObj.mainObj.coordinateHistory(get(scObj.mainObj.hCurveList,'userdata')) = [];
        if ~isempty(scObj.mainObj.curveNames)  
            set(scObj.mainObj.hCurveList,'string',scObj.mainObj.curveNames)
            if isequal(get(scObj.mainObj.hCurveList,'userdata'),1)
                set(scObj.mainObj.hCurveList,'value',get(scObj.mainObj.hCurveList,'userdata'))
                set(scObj.mainObj.hCurveList,'userdata',numel(scObj.mainObj.curveNames))
                scObj.mainObj.curveListFcn(scObj.mainObj,varargin)
            else
                set(scObj.mainObj.hCurveList,'value',get(scObj.mainObj.hCurveList,'userdata') - 1)
                set(scObj.mainObj.hCurveList,'userdata',numel(scObj.mainObj.curveNames))
                scObj.mainObj.curveListFcn(scObj.mainObj,varargin)
            end
        end
        if isempty(scObj.mainObj.curveNames)
            set(findobj('label','Add Point'),'enable','off');
            set(findobj('label','Delete Point'),'enable','off');
            set(findobj('label','Move Point'),'enable','off');
            set(findobj('label','Select Point'),'enable','off');
            set(scObj.mainObj.hSelectedXPoint,'string','');
            set(scObj.mainObj.hSelectedYPoint,'string','');
            scObj.mainObj.curveNames = {};
            scObj.mainObj.xDataHistory = {};
            scObj.mainObj.yDataHistory = {};
            scObj.mainObj.xyDataValues = {};
            scObj.mainObj.scaleHistory = {};
            scObj.mainObj.coordinateHistory = {};
            set(scObj.mainObj.hCurveList,...
                'string',scObj.mainObj.defaultCurveName{1},...
                'value',1,'userdata',1);
            set(scObj.mainObj.hFitMenu,'enable','off');
            scObj.mainObj.isGuiAlter = false;
        end
    elseif ~isempty(index) && numel(index) < numel(x)
        x(index) = [];
        y(index) = [];
        scObj.mainObj.xDataHistory{get(scObj.mainObj.hCurveList,'userdata')} = x;
        scObj.mainObj.yDataHistory{get(scObj.mainObj.hCurveList,'userdata')} = y;
        newCoordinates = GSGUI.GraphScannerGUI.calculation(x,y,data,xyScaleMatrix);
        scObj.mainObj.xyDataValues{get(scObj.mainObj.hCurveList,'userdata')} = newCoordinates;                                   
        set(scObj.mainObj.hCurveDataTable,'data',newCoordinates);
        scObj.mainObj.isGuiAlter = true;
        notify(scObj.mainObj,'updateGraph');
    end
        
    if ishandle([h.line1,h.line2,h.line3,h.line4]) 
        set(h.line1,'userdata','complete')
        delete([h.line1,h.line2,h.line3,h.line4])
    end
    set(gcbf,'WindowButtonMotionFcn','')
    set(gcbf,'WindowButtonUpFcn','')
end 
