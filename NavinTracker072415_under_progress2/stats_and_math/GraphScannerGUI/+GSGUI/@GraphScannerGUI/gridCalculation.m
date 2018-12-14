function [xxLogInt,yyLogInt] = gridCalculation(data,scale,varargin)
%GRIDCALCULATION function calculates necessary data in order to plot a
%grid.
    pixelData = data(1:3,3:4);
    realData = data(1:3,1:2);
    xPixelInfo = diff(pixelData(1:2,1));
    yPixelInfo = diff(pixelData(1:2:3,2));
    if scale(1) == 2
        xLogTick = 10.^(log10(realData(1,1)):log10(realData(2,1)));
        xxLogInt = [pixelData(1,1),...
                    log10(2:10)*xPixelInfo/(numel(xLogTick)-1)+pixelData(1,1)]';
        xxLogInt = repmat(xxLogInt,1,numel(xLogTick)-1)+...
                   xPixelInfo/(numel(xLogTick)-1)*repmat(0:numel(xLogTick)-2,numel(xxLogInt),1);                
        xxLogInt = xxLogInt(:);
    else 
        xxLogInt = [];
    end
    if scale(2) == 2
        yLogTick = 10.^(log10(realData(1,2)):log10(realData(3,2)));
        yyLogInt = [pixelData(1,2),...
                    log10(2:10)*yPixelInfo/(numel(yLogTick)-1)+pixelData(1,2)]';
        yyLogInt = repmat(yyLogInt,1,numel(yLogTick)-1)+...
                   yPixelInfo/(numel(yLogTick)-1)*repmat(0:numel(yLogTick)-2,numel(yyLogInt),1);                
        yyLogInt = yyLogInt(:);
    else
        yyLogInt = [];
    end

end

