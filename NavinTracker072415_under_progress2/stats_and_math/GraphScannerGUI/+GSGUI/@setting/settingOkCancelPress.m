function settingOkCancelPress(sObj,varargin)
%SETTINGOKPRESS function either accepts settings and closes the figure or 
%ignores the settigns and closes the figure.
    handle = get(gcbo,'string');
    switch handle
        case 'Ok'
            sObj.mainObj.defaultCurveName{2} = get(sObj.hCurveNameSet,'string');
            if isempty(sObj.mainObj.curveNames) 
                sObj.mainObj.curveNames{end + 1} = sObj.mainObj.defaultCurveName{2};
            else 
                sObj.mainObj.curveNames{get(sObj.mainObj.hCurveList,'userdata')} =...
                sObj.mainObj.defaultCurveName{2};
            end
            set(sObj.mainObj.hCurveList,'string',sObj.mainObj.curveNames)
            set(sObj.mainObj.hCurveList,'value',get(sObj.mainObj.hCurveList,'userdata'))
            plothandle = findobj('tag','plotting');
            if get(findobj('tag','hDisplayLine'),'value') == 0
                set(plothandle,'linestyle','none');
            else
                set(plothandle,'linestyle','-')
            end
            set(plothandle,'color',sObj.mainObj.colorDataInd.linecolor);
            if get(findobj('tag','hDisplayMarker'),'value') == 0
                set(plothandle,'marker','none');
            else
                set(plothandle,'marker','o');
            end
            set(plothandle,'markeredgecolor',sObj.mainObj.colorDataInd.markerecolor);
            set(plothandle,'markerfacecolor',sObj.mainObj.colorDataInd.markerfcolor);
            sObj.mainObj.xAxisLabel = get(sObj.hXLabel,'string');
            sObj.mainObj.yAxisLabel = get(sObj.hYLabel,'string');
            if get(findobj('tag','hDisplayGrid'),'value') == 1
                if ~isempty(findobj('tag','plotxline')) 
                    set(findobj('tag','plotxline'),'visible','off');
                end
                if ~isempty(findobj('tag','plotyline'))
                    set(findobj('tag','plotyline'),'visible','off');
                end
                if ~isempty(findobj('tag','plotxlogline')) 
                    set(findobj('tag','plotxlogline'),'visible','off');
                end
                if ~isempty(findobj('tag','plotylogline'))
                    set(findobj('tag','plotylogline'),'visible','off');
                end
                if ~isempty(findobj('tag','plotrec'))
                    set(findobj('tag','plotrec'),'visible','off');
                end
                
                if isempty(sObj.mainObj.coordinateHistory)
                    data = sObj.mainObj.xyCoordinatesMatrix;
                    scale = sObj.mainObj.xyScaleMatrix;
                else
                    data = sObj.mainObj.coordinateHistory{get(sObj.mainObj.hCurveList,'userdata')};
                    scale = sObj.mainObj.scaleHistory{get(sObj.mainObj.hCurveList,'userdata')};
                end
                Z = ones(4,1);
                Z(1) = data(1,3);
                Z(2) = data(3,4);
                Z(3) = abs(diff(data(1:2,3)));
                Z(4) = abs(diff(data(1:2:3,4)));
                if ~all(Z)
                    errordlg('All coordinates are zeros, check your coordinates',...
                             'Value error')
                    uiwait(gcf)
                    return
                end
                if sign(diff(data(1:2,3))) == -1
                    Z(1) = data(2,3);
                end
                if sign(diff(data(1:2:3,4))) == 1
                    Z(2) = data(1,4);
                end
                rectangle('parent',get(sObj.mainObj.hMainFig,'currentaxes'),...
                          'pos',Z,...
                          'linestyle','-',...
                          'edgecolor','b',...
                          'linewidth',2,...
                          'tag','plotrec',...
                          'visible','on');
                ii = str2double(get(findobj('tag','hXTickNP'),'string'));
                nn = str2double(get(findobj('tag','hYTickNP'),'string'));
                if ~isfinite(ii) || ~isfinite(nn)
                    errordlg('Error::Number of spacings values must be numeric',...
                             'Numerical error')
                    uiwait(gcf)
                    return
                elseif sign(ii) ~= 1 || sign(nn) ~= 1 
                    errordlg('Error::Number of spacings must be greater or equal than 1',...
                             'Numerical error')
                    uiwait(gcf)
                    return
                else       
                    plotXLine = zeros(ii,1);
                    plotYLine = zeros(nn,1);
                    if ii > 1 && scale(1) ~= 2
                        for k = 1:ii
                            plotXLine(k) = line([Z(1)+k*Z(3)/ii Z(1)+k*Z(3)/ii],...
                                                [data(1,4) data(3,4)],...
                                                 'color','b',...
                                                 'visible','on',...
                                                 'tag','plotxline',...
                                                 'linestyle','-',...
                                                 'linewidth',1,...
                                                 'parent',...
                                                 get(sObj.mainObj.hMainFig,'currentaxes'));
                        end
                    end
                    if nn > 1 && scale(2) ~= 2
                        for k=1:nn
                            plotYLine(k) = line([data(1,3) data(2,3)],...
                                                [Z(2)+k*Z(4)/nn Z(2)+k*Z(4)/nn],...
                                                 'color','b',...
                                                 'visible','on',...
                                                 'tag','plotyline',...
                                                 'linestyle','-',...
                                                 'linewidth',1,...
                                                 'parent',...
                                                 get(sObj.mainObj.hMainFig,'currentaxes'));
                        end
                    end
                end
                [xxLogInt,yyLogInt] = GSGUI.GraphScannerGUI.gridCalculation(data,...
                                      sObj.mainObj.xyScaleMatrix,varargin);                                
                if ~isempty(xxLogInt)
                    plotXLogLine = zeros(numel(xxLogInt),1);
                    for k = 1:numel(xxLogInt)
                        plotXLogLine(k) = line([xxLogInt(k) xxLogInt(k)],...
                                               [data(1,4) data(3,4)],...
                                                'color','b',...
                                                'visible','on',...
                                                'tag','plotxlogline',...
                                                'linestyle','-',...
                                                'linewidth',1,...
                                                'parent',...
                                                get(sObj.mainObj.hMainFig,'currentaxes'));
                    end
                end
                if ~isempty(yyLogInt)
                    plotYLogLine = zeros(numel(yyLogInt),1);
                    for k = 1:numel(yyLogInt)
                        plotYLogLine(k) = line([data(1,3) data(2,3)],...
                                               [yyLogInt(k) yyLogInt(k)],...
                                                'color','b',...
                                                'visible','on',...
                                                'tag','plotylogline',...
                                                'linestyle','-',...
                                                'linewidth',1,...
                                                'parent',...
                                                get(sObj.mainObj.hMainFig,'currentaxes'));
                    end
                end
                sObj.mainObj.gridSpacing(1) = ii;
                sObj.mainObj.gridSpacing(2) = nn;
            else
                sObj.mainObj.gridSpacing(1) = 1;
                sObj.mainObj.gridSpacing(2) = 1;
                if ~isempty(findobj('tag','plotrec'))
                    set(findobj('tag','plotrec'),'visible','off')
                    set(findobj('tag','plotxline'),'visible','off')
                    set(findobj('tag','plotyline'),'visible','off')
                    set(findobj('tag','plotxlogline'),'visible','off')
                    set(findobj('tag','plotylogline'),'visible','off')
                end
            end
            delete(gcbf);
        case 'Cancel'
            delete(gcbf);
    end
end

