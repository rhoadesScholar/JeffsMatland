function NormSpeedTable = normalizeSpeedTable(SpeedTable)
    
    NormCols = 851:1000;
    
    nRows = length(SpeedTable(:,1));
    nCols = length(SpeedTable(1,:));
    
    for(i=1:nRows)
        PreData = SpeedTable(i,NormCols);
        PreAvg = nanmean(PreData);
        NormSpeedTable(i,1:nCols) = SpeedTable(i,:)/PreAvg;
    end
end
