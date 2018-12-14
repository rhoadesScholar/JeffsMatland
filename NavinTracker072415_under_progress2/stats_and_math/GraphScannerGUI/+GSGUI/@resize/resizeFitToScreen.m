function resizeFitToScreen(rObj,varargin)
%RESIZEFITTOSCREENPRESS function resizes the graph to fit entirely into panel  
    if get(gcbo,'value') == 1
        pos1 = get(rObj.mainObj.hPicturePanel,'pos'); % picture panel position
        pos2 = get(rObj.mainObj.hMainFig,'pos'); % main figure position
        set(findobj('tag','pixelsizewidth'),...
            'string',num2str(floor(pos1(3)*pos2(3))));
        set(findobj('tag','pixelsizeheigth'),...
            'string',num2str(floor(pos1(4)*pos2(4))));
    end
end

