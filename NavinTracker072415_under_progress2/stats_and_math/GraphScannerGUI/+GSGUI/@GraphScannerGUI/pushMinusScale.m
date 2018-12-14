function pushMinusScale(obj,varargin)
%PUSHMINUSSCALE function scales down the current size of the picture.
    hAxes = get(obj.hMainFig,'currentaxes'); 
    [x1] = get(hAxes,'pos');
    scale = get(obj.hScalePushMinus,'userdata') - obj.scaleIndex;
    if obj.scaleValueMinusPre > scale && scale < 1
        set(hAxes,'units','pixels',...
                  'pos',[x1(1) x1(2) x1(3)*scale x1(4)*scale]);
        obj.scaleValueMinusPre = scale;
        set(obj.hScalePushMinus,'userdata',scale);
    elseif scale > obj.scaleValueMinusPre && scale < 1
        val = scale;
        scale = 1/obj.scaleValueMinusPre;
        obj.scaleValueMinusPre = val;
        set(hAxes,'units','pixels',...
                  'pos',[x1(1) x1(2) x1(3)*scale x1(4)*scale]);
        set(obj.hScalePushMinus,'userdata',scale);
    end

end
