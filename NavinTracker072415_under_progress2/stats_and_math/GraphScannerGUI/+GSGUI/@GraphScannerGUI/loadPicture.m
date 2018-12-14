function loadPicture(obj,varargin)
%LOADPICTURE function loads an image on the GUI panel.
  
    deletePicture(obj,varargin);
    [FileName,PathName,FilterIndex] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
                                                 '*.*','All Files' },'Select The Picture');
    if FilterIndex == 0
        return
    end
    imageData = importdata(fullfile(PathName,FileName));
    if isa(imageData,'struct')  
        imageData = imageData.data;
    elseif ~isa(imageData,'numeric')
        return
    end
    type = class(imageData);
    switch type
        case 'uint8'
            imageData = double(imageData)/255;
            [h,w,d] = size(imageData); % MATLAB R2009a does not allow to replace d to ~
        case 'uint16'
            imageData = double(imageData)/65535;
            [h,w,d] = size(imageData);
        otherwise
            [h,w,d] = size(imageData);
    end
    obj.origPicSize(1) = w;
    obj.origPicSize(2) = h;
    X = get(obj.hPicturePanel,'pos');
    hAxes = axes('parent',obj.hPicturePanel,...
                 'units','pixels',...
                 'pos',[X(1)*1.05 X(2)*1.05 w h],...
                 'tag','hAxes');
    image(imageData,'parent',hAxes',...
          'uicontextmenu',obj.hConMenu);
    set(hAxes,'xticklabel',{},...
        'yticklabel',{},...
        'xcolor','white',...
        'ycolor','white',...
        'drawmode','fast',...
        'box','off');
    set(obj.hCurveDataTable,'data',obj.tableData);
    set(obj.hScalePushPlus,'userdata',1,'enable','on');
    set(obj.hScalePushMinus,'userdata',1,'enable','on');
    obj.scaleValuePlusPre = 1;
    obj.scaleValueMinusPre = 1;
    set(findobj('label','Settings'),'enable','on');
    set(findobj('label','Resize...'),'enable','on');
    set(findobj('label','New Coordinates'),'enable','on');
    set(findobj('label','Resize...'),'enable','on');
    set(findobj('label','New Coordinates'),'enable','on');
    set(findobj('label','Curve'),'enable','on');
end

