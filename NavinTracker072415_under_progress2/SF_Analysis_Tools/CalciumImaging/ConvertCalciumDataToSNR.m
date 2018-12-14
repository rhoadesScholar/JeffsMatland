function SNRTable = ConvertCalciumDataToSNR(CalciumData)
    nRows = length(CalciumData(:,1));
    nCols = length(CalciumData(1,:));
    for(i=1:nRows)
        WindowSize = 5;
        HalfWindow = (WindowSize-1)/2;
        SNRTable(i,1:HalfWindow) = NaN;  
        for(j=HalfWindow+1:(nCols-HalfWindow-1))
            DataHere = CalciumData(i,(j-HalfWindow):(j+HalfWindow));
            CheckForNans = sum(isnan(DataHere));
            if(CheckForNans<2)
            MeanHere = nanmean(DataHere);
            StDHere = nanstd(DataHere);
            SNRHere = MeanHere/StDHere;
            SNRTable(i,j) = SNRHere;
            else 
                SNRTable(i,j) = NaN;
            end
        end
        SNRTable(i,(nCols-HalfWindow):nCols) = NaN;
    end
end

        
