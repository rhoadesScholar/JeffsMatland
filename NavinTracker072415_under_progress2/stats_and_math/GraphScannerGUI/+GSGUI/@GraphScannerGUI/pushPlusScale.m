function pushPlusScale(obj,varargin)
%PUSHPLUSSCALE function scales up the current size of the picture.
    hAxes = get(obj.hMainFig,'currentaxes');
    [x1] = get(hAxes,'pos');
    scale = get(obj.hScalePushPlus,'userdata') + obj.scaleIndex;
    if obj.scaleValuePlusPre > scale && scale >= 1
        val = scale;
        scale = 1/obj.scaleValuePlusPre;
        obj.scaleValuePlusPre = val;
        set(hAxes,'units','pixels',...
                  'pos',[x1(1) x1(2) x1(3)*scale x1(4)*scale]);
        set(obj.hScalePushPlus,'userdata',scale);
    elseif scale > obj.scaleValuePlusPre && scale >= 1
        set(hAxes,'units','pixels',...
                  'pos',[x1(1) x1(2) x1(3)*scale x1(4)*scale]);
        obj.scaleValuePlusPre = scale;
        set(obj.hScalePushPlus,'userdata',scale);
    end

end

