function SNRVector = ConvertCalciumVectorToSNR(CalciumVector)
    nRows = length(CalciumVector);
        WindowSize = 5;
        HalfWindow = (WindowSize-1)/2;
        SNRVector(1:HalfWindow) = NaN;
        
        for(j=HalfWindow+1:(nRows-HalfWindow-1))
            DataHere = CalciumVector((j-HalfWindow):(j+HalfWindow));
            CheckForNans = sum(isnan(DataHere));
            if(CheckForNans<2)
            MeanHere = nanmean(DataHere);
            StDHere = nanstd(DataHere);
            SNRHere = MeanHere/StDHere;
            SNRVector(j) = StDHere;
            else 
                SNRVector(j) = NaN;
            end
        end
        SNRVector((nRows-HalfWindow):nRows) = NaN;
end