function [PositiveStretches FinalPositiveStretches StretchTable FinalStretchTable] = findPositiveStretches(Data,cellData,StretchLength,PositiveDataCutoff,FluorChangeCutoff)
    %StretchLength = 55;
    %PositiveDataCutoff = 0.04
    PositiveData = find(Data>PositiveDataCutoff);
    
    DiffPosData = diff(PositiveData);
    
    StretchIndicator=0;
    
    AllStretchFrames = [];
    FinalStretches = [];
    
    indexHere=1;
    
    StretchTable = [];
    FinalStretchTable = [];
    
    for(i=1:(length(DiffPosData)-StretchLength))
        display(i)
        DataToTest = DiffPosData(i:(i+StretchLength-1));
        if(sum(DataToTest)==StretchLength)
            if(StretchIndicator==0)
             %%%%%%%%%Then this is a stretch---find boundaries'
                StretchIndicator=1;
                StretchStart = PositiveData(i);
            end
        else
            if(StretchIndicator==1)
                StretchStop = PositiveData(i+StretchLength-1);
                StretchIndicator=0;
                ThisStretch= StretchStart:StretchStop;
                StretchTable(indexHere,1) = StretchStart;
                StretchTable(indexHere,2) = StretchStop;
                indexHere=indexHere+1;
                AllStretchFrames = [AllStretchFrames ThisStretch];
            end
        end
    end
    
    RowsToNan = [];
    
    ConsStretch=0;
    sizeSt = size(StretchTable);
    if(sizeSt(1)>0)
    for(i=2:length(StretchTable(:,1)))
        interStretchInt = StretchTable(i,1)-StretchTable(i-1,2);
        if(interStretchInt<70)
            if(ConsStretch==1)
               NewStart = StretchTable(i-1,1);
                NewStop = StretchTable(i,2); 
                StretchTable(ConsStartRow,2) = NewStop;
                RowsToNan = [RowsToNan i];
                AllStretchFrames = [AllStretchFrames NewStart:NewStop];
            else
            NewStart = StretchTable(i-1,1);
            NewStop = StretchTable(i,2);
            StretchTable(i-1,2) = NewStop;
            RowsToNan = [RowsToNan i];
            AllStretchFrames = [AllStretchFrames NewStart:NewStop];
            ConsStretch=1;
            ConsStartRow=i-1;
            end
        else
            ConsStretch=0;
        end
    end
    
    StretchTable(RowsToNan,:) = [];
    
    for(i=1:length(StretchTable(:,1)))
        StartIndex = StretchTable(i,1);
        StopIndex = StretchTable(i,2);
        
        SizeofPreRegion = 200;
        SizeofPostRegion = 200;
        
        if(StartIndex<=(SizeofPreRegion+10))
            SizeofPreRegion= StartIndex-1-10;
        end
        if((StopIndex+SizeofPostRegion)>=length(cellData(:,1)))
            SizeofPostRegion= length(cellData(:,1)) - StopIndex;
        end
        
        
        
        BeforeRegion = (StartIndex-(SizeofPreRegion+10)):(StartIndex-10);
        AfterRegion = (StopIndex):(StopIndex+SizeofPostRegion);
        
        BeforeRegionTest = find(cellData(BeforeRegion,17)>0);
        if(length(BeforeRegionTest)>0)
            MostRecentInt = max(BeforeRegionTest);
            BeforeRegion = (StartIndex-(SizeofPreRegion+10)+MostRecentInt):(StartIndex-10);
        end
        
        AfterRegionTest = find(cellData(AfterRegion,17)>0);
        if(length(AfterRegionTest)>0)
            FirstInt = min(BeforeRegionTest);
            AfterRegionNewEnd = StopIndex+FirstInt;
            AfterRegion = StopIndex:AfterRegionNewEnd;
        end
        
        if(length(BeforeRegion)>40)
            if(length(AfterRegion)>40)
        
        BeforeFluor = nanmean(cellData(BeforeRegion,23));
        AfterFluor = nanmean(cellData(AfterRegion,23));
        RatioFluor = AfterFluor/BeforeFluor;
        StretchTable(i,3) = BeforeFluor;
        StretchTable(i,4) = AfterFluor;
        StretchTable(i,5) = RatioFluor;
            else 
                StretchTable(i,3) = 1;
                StretchTable(i,4) = 1;
                StretchTable(i,5) = 1;
            end
        else
                StretchTable(i,3) = 1;
                StretchTable(i,4) = 1;
                StretchTable(i,5) = 1;
        end
    end
    %FluorChangeCutoff = 1.4;
    FluorChangeIndex = find(StretchTable(:,5)>FluorChangeCutoff);
    
    AlmostFinalStretchTable = StretchTable(FluorChangeIndex,:);
    
    averageFluor = nanmean(cellData(:,23));
    MinPeakFluorIndex = find(AlmostFinalStretchTable(:,4)>averageFluor);
    
    FinalStretchTable = AlmostFinalStretchTable(MinPeakFluorIndex,:);
    
    FinalStretches = [];
    for(i=1:length(FinalStretchTable(:,1)))
        StretchHere = FinalStretchTable(i,1):FinalStretchTable(i,2);
        FinalStretches = [FinalStretches StretchHere];
    end
    
    end
    
   
        PositiveStretches(1:length(Data)) = 1;
    PositiveStretches(AllStretchFrames) = 2;
    
    FinalPositiveStretches(1:length(Data)) = 1;
    FinalPositiveStretches(FinalStretches) = 2;
                
        end