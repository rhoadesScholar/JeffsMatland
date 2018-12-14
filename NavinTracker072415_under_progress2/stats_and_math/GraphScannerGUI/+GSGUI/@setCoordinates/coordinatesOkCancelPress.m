function coordinatesOkCancelPress(scObj,varargin)
%COORDINATESOKPRESS function either closes the SetCoordinates figure, 
%accepts settings and checks inputs or ignores settings and closes the
%figure.
    handle = get(gcbo,'string');
    switch handle
        case 'Ok'
            xyScaleMatrix(1) = get(scObj.hXaxesPopupmenu,'value');
            xyScaleMatrix(2) = get(scObj.hYaxesPopupmenu,'value');
            scObj.mainObj.xyScaleMatrix = xyScaleMatrix;
            xyCoordinatesMatrix = get(scObj.hAxesDataTable,'data');
            scObj.mainObj.xyCoordinatesMatrix = xyCoordinatesMatrix;
            set(findobj('tag','hDisplayGrid'),'enable','on');
            % Check possible errors in CoordinateMatrix 
            if any(~isfinite(xyCoordinatesMatrix(:)))
                errordlg('All coordinate values must be numeric!',...
                         'Value error')
                uiwait(gcf);
                return
           elseif ~all(all(xyCoordinatesMatrix(1:3,1:2))) &&...
               xyScaleMatrix(1) == 2 && xyScaleMatrix(2) == 2
               errordlg('Zero value in the logaritmic scale???',...
                        'Value error')
               uiwait(gcf);
               return
           elseif ~all(xyCoordinatesMatrix(1:3,1)) &&...
               xyScaleMatrix(1) == 2
               errordlg('Zero value in the logaritmic scale???',...
                        'Value error')
               uiwait(gcf);
               return
           elseif ~all(xyCoordinatesMatrix(1:3,2)) &&...
               xyScaleMatrix(2) == 2
               errordlg('Zero value in the logaritmic scale???',...
                        'Value error')
               uiwait(gcf);
               return
           elseif sign(diff(xyCoordinatesMatrix(1:2:3,1))) ~= 0
               errordlg('X-axis values not equal? Check values!',...
                        'Value error')
               uiwait(gcf)
               return
           elseif sign(diff(xyCoordinatesMatrix(1:2,2))) ~= 0
               errordlg('Y-axis values not equal? Check values!',...
                        'Value error')
               uiwait(gcf)
               return
           elseif ~any(xyCoordinatesMatrix(:))
               str_1 = 'All the values in the xy-coordinate colums are zero.';
               str_2 = 'Check your coordinates!';
               warndlg(sprintf('%s\n%s',str_1,str_2),'Value warning')
               uiwait(gcf)
               return  
            elseif ~any(any(xyCoordinatesMatrix(1:3,1:2)))
               str_1 = 'All the data values in the xy-coordinate columns are zero?';
               str_2 = 'Check your coordinates!';
               warndlg(sprintf('%s\n%s',str_1,str_2),'Value warning')
               uiwait(gcf)
               return 
            elseif ~any(any(xyCoordinatesMatrix(1:3,3:4)))
               str_1 = 'All the coordinate values in the xy-coordinate columns are zero?';
               str_2 = 'Check your coordinates!';
               warndlg(sprintf('%s\n%s',str_1,str_2),'Value warning')
               uiwait(gcf)
               return 
            else
               if isempty(scObj.mainObj.coordinateHistory)
                   scObj.mainObj.scaleHistory{end + 1} = xyScaleMatrix;
                   scObj.mainObj.coordinateHistory{end + 1} = xyCoordinatesMatrix;
               end
               delete(gcbf);
            end
        case 'Cancel'
            delete(gcbf);
    end
end

