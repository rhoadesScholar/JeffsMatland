function AverageData = SlidingAverage(Data)
    DataLen = length(Data);
    RegionLen = 20
    HalfRegionLen = RegionLen/2;
    
        
        
    AverageData = [];
    AverageData(1:DataLen) = NaN;
    for(i=(1+HalfRegionLen):(DataLen-HalfRegionLen))
        AverageData(i) = nanmean(Data((i-HalfRegionLen):1:(i+HalfRegionLen)));
    end

end
