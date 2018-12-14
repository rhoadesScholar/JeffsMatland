function newCoordinates = calculation(x,y,data,xyScaleMatrix)
%CALCULATION function performs calculation on point(s) and maps them to
%correspond the real coordinate values.
    pixelData = data(1:3,3:4);
    realData = data(1:3,1:2);
    xPixelInfo = diff(pixelData(1:2,1));
    yPixelInfo = diff(pixelData(1:2:3,2));
    xRealInfo = diff(realData(1:2,1));
    yRealInfo = diff(realData(1:2:3,2));
    newCoordinates = zeros(size([x,y]));
    newCoordinates(:,1) = (x-pixelData(1,1))*1/xPixelInfo*xRealInfo+realData(1,1);
    newCoordinates(:,2) = (y-pixelData(1,2))*1/yPixelInfo*yRealInfo+realData(1,2);
    newCoordinates(:,1) = str2num(sprintf('%10.6e\n',newCoordinates(:,1)));
    newCoordinates(:,2) = str2num(sprintf('%10.6e\n',newCoordinates(:,2)));
    if xyScaleMatrix(1) == 2
        xLogTick = 10.^(log10(realData(1,1)):log10(realData(2,1)));
        xLogInt = [pixelData(1,1),...
                   log10(2:10)*xPixelInfo/(numel(xLogTick)-1)+pixelData(1,1)]';
        xLogInt = repmat(xLogInt,1,numel(xLogTick)-1)+...
                  xPixelInfo/(numel(xLogTick)-1)*repmat(0:numel(xLogTick)-2,numel(xLogInt),1);
        [m,n] = size(xLogInt);      
        xLogInt = xLogInt(:);
        [row,col] = find(xLogInt(:,:,ones(1,length(x'))) >=...
                    reshape(repmat(x',length(xLogInt(:)),1),[],1,length(x')));
        row = row(diff([0;col]) == 1);
        [r,c] = ind2sub([m,n],row);
        newCoordinates(:,1) = xLogTick(c)'.*(r-1)+(abs(x-xLogInt(row-1)))./...
                              abs((xLogInt(row)-xLogInt(row-1))).*xLogTick(c)';        
        newCoordinates(:,1) = str2num(sprintf('%10.6e\n',newCoordinates(:,1)));
    end
    if xyScaleMatrix(2) == 2
        yLogTick = 10.^(log10(realData(1,2)):log10(realData(3,2)));
        yLogInt = [pixelData(1,2),...
                   log10(2:10)*yPixelInfo/(numel(yLogTick)-1)+pixelData(1,2)]';
        yLogInt = repmat(yLogInt,1,numel(yLogTick)-1)+...
                   yPixelInfo/(numel(yLogTick)-1)*repmat(0:numel(yLogTick)-2,numel(yLogInt),1);
        [m,n] = size(yLogInt);       
        yLogInt = yLogInt(:);
        [row,col] = find(yLogInt(:,:,ones(1,length(y'))) <=...
                    reshape(repmat(y',length(yLogInt(:)),1),[],1,length(y')));
        row = row(diff([0;col]) == 1);
        [r,c] = ind2sub([m,n],row);
        newCoordinates(:,2) = yLogTick(c)'.*(r-1)+(abs(y-yLogInt(row-1)))./...
                              abs((yLogInt(row)-yLogInt(row-1))).*yLogTick(c)';        
        newCoordinates(:,2) = str2num(sprintf('%10.6e\n',newCoordinates(:,2)));
    end  

end

