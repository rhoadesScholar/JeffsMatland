function RasterMatrix = convertPeakStartsToRasters(FRunPeakStartData,StartIndex,EndIndex)

    
    allData = [];
    rowIndex = 1;
    
    nRows = length(FRunPeakStartData(:,1));
    
    for(i=1:nRows)
        
        startPoint = min(find(~isnan(FRunPeakStartData(i,:))==1));
        display(startPoint)
        EndPoint = max(find(~isnan(FRunPeakStartData(i,:))==1));
        display(EndPoint)
        
        if(startPoint <= StartIndex)
            if(EndPoint >= EndIndex)
                RasterMatrix(rowIndex,:) = FRunPeakStartData(i,:);
                DataHere = find(FRunPeakStartData(i,:)==1);
                display(DataHere)
                TooEarly = find(DataHere<StartIndex);
                if(length(TooEarly)>0)
                    DataHere(TooEarly) = [];
                end
                TooLate = find(DataHere>EndIndex);
                if(length(TooLate)>0)
                    DataHere(TooLate) = [];
                end
                display(DataHere)
                DataHere = DataHere + ((rowIndex-1)*10000);
                display(DataHere)
                allData = [allData DataHere];
                rowIndex = rowIndex+1;
            end
        end
    end
    display(allData)
    
    
    nFunctionalRows = rowIndex; 
    display(nFunctionalRows)
    rasterplot(allData,nFunctionalRows,10000);
end
        
        
