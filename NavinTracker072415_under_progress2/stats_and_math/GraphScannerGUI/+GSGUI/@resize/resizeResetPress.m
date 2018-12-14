function resizeResetPress(rObj,varargin)
%RESIZERESETPRESS function resets the figure size to original value.
    set(findobj('tag','pixelsizewidth'),...
        'string',num2str(rObj.mainObj.origPicSize(1)));
    set(findobj('tag','pixelsizeheigth'),...
        'string',num2str(rObj.mainObj.origPicSize(2)));   
end

