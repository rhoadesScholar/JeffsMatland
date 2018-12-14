function PeakVector = getPeakVector(cellData,FinalStretchTable)

    PeakTableIndex = 1;
    PeakStretches = [];

    for(i=1:length(FinalStretchTable(:,1)))
        
        %%%%%%%%%%Define Before/After Regions to get baseline, peak fluor
        
        StartIndex = FinalStretchTable(i,1);
        
        
        SizeofPreRegion = 150;
        
        
        if(StartIndex<=(SizeofPreRegion+10))
            SizeofPreRegion= StartIndex-1-10;
        end
        
        
        
        
        BeforeRegion = (StartIndex-(SizeofPreRegion+10)):(StartIndex-10);
        
        
        BeforeRegionTest = find(cellData(BeforeRegion,17)>0);
        if(length(BeforeRegionTest)>0)
            MostRecentInt = max(BeforeRegionTest);
            BeforeRegion = (StartIndex-(SizeofPreRegion+10)+MostRecentInt):(StartIndex-10);
        end
        
        originalFlInten = nanmean(cellData(BeforeRegion,23));
       
        peakFlInten = nanmean(cellData((FinalStretchTable(i,2)-50):(FinalStretchTable(i,2)+50),23));
        
        %%%%%%Now look for maintained decline to within 20% of original
        
        diffHere = peakFlInten-originalFlInten;
        TargetFl = peakFlInten-(.6321*diffHere);
        
        %%%%%Find first time after Peak that Fl=targetFl or lower for >3sec
        
        PeakFrame = FinalStretchTable(i,2);
        
        startPoint=PeakFrame+1;
        
        
        RunEnds = find(cellData(:,17)==1);
        
        EarlyRunEnds = find(RunEnds<PeakFrame+1);
        
        RunEnds(EarlyRunEnds) = [];
        
        if(length(RunEnds>0))
            stopPoint = min(RunEnds);
        else
            stopPoint = length(cellData(:,1));
        end
        
        
        
        if(i<length(FinalStretchTable(:,1)))
            NextPeakStart = FinalStretchTable(i+1,1);
        else
            NextPeakStart = 18001;
        end
        
       
        
        if(NextPeakStart<stopPoint)
            stopPoint = NextPeakStart;
        end
        
        
        
        
        DataToLookforEnd = cellData(startPoint:stopPoint,23);
        

        LowActBeginning = getStretches(DataToLookforEnd,TargetFl,50);
        display(i)
        display(LowActBeginning)
        PeakTable(PeakTableIndex,1) = FinalStretchTable(i,1);
        PeakTable(PeakTableIndex,2) = startPoint+LowActBeginning-1;
         
        PeakStretches = [PeakStretches PeakTable(PeakTableIndex,1):PeakTable(PeakTableIndex,2)];
        
        PeakTableIndex = PeakTableIndex+1;
        
        
    end
    
    PeakVector(1:(length(cellData(:,1)))) = 1;
    PeakVector(PeakStretches) = 2;
end
