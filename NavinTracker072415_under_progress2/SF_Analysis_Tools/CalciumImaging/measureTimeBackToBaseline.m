function TimeBackToBaseline = measureTimeBackToBaseline(Data,StartIndex,DirIndex)

    NumRows = length(Data(:,1));
    
    %%%%%Adjust StartIndex for binning
    StartIndex = StartIndex/50;
    
    %%%%%%Turn Data into 5sec bins (50datapoints/bin)
    numCol = length(Data(1,:));
    numBins = floor(numCol/50);
    for(j=1:NumRows)
    for(i=1:numBins)
        BinnedData(j,i) = nanmean(Data(j,((i*50)-49):(i*50)));
    end
    end

    AveData = nanmean(BinnedData,1);
    
    AveData_AfterStart = AveData(StartIndex:end);
    
    BinnedData_AfterStart = BinnedData(:,StartIndex:end);
    
    display(AveData_AfterStart)
    
    if(DirIndex==1)
        PeakInd = find(AveData_AfterStart==max(AveData_AfterStart(1:20)));
    else
        PeakInd = find(AveData_AfterStart==min(AveData_AfterStart(1:20)));
    end
    display(PeakInd)
    %%%%%%%%Note that PeakInd refers to AveData_AfterStart vector
    
    Baseline_Vector = BinnedData(:,16);
    Baseline_Vector = Baseline_Vector(~isnan(Baseline_Vector));
    display(mean(Baseline_Vector))
    
    %%%%%%%%%%Now move one bin at a time from peak to end of vector - find
    %%%%%%%%%%out when comparison is no longer significant
    NoSigDiff = [];
    for(i=PeakInd:length(AveData_AfterStart))
        TempCompVector = BinnedData_AfterStart(:,i);
        TempCompVector = TempCompVector(~isnan(TempCompVector));
        TempLogSpace = i;
        display(i)
        display(mean(TempCompVector));
        [h,p] = ttest2(TempCompVector,Baseline_Vector,0.01);
        display(p)
        if(h==0)
            NoSigDiff = [NoSigDiff i];
        end
    end

    stopIndex = min(NoSigDiff);
    
    %%%%Convert StopIndex to seconds
    
    TimeBackToBaseline = stopIndex *5; 
    
    
end
