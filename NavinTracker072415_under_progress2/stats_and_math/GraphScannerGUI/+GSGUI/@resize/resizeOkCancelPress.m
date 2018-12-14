function resizeOkCancelPress(rObj,varargin)
%RESIZEOKPRESS function accepts user inputs and closes the Resize figure.
    handle = get(gcbo,'string');
    switch handle
        case 'Ok'
            w_value = str2double(get(findobj('tag','pixelsizewidth'),'string'));
            h_value = str2double(get(findobj('tag','pixelsizeheigth'),'string'));
            if ~isfinite(w_value) || ~isfinite(h_value) ||...
               sign(w_value) ~= 1 ||  sign(h_value) ~= 1 % Check user inputs 
                str_1 = 'You must enter a numeric pixel width/heigth value.';
                str_2 = 'The values must be greater than 0.';
                errordlg(sprintf('%s\n%s',str_1,str_2),'Value error')
                uiwait(gcf)
                return
            else
                setpixelposition(get(rObj.mainObj.hMainFig,'currentaxes'),...
                                 [rObj.pictureSize(1:2),w_value,h_value]);
                set(findobj('tag','pixelsizewidth'),...
                    'string',num2str(w_value));
                set(findobj('tag','pixelsizeheigth'),...
                    'string',num2str(h_value));
                delete(rObj.hResizeFigure);
            end
        case 'Cancel'
            delete(rObj.hResizeFigure);
    end     
end

