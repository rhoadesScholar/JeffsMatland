function [DwTable RoTable DwTablePercOutput RoTablePercOutput] = processOrderRandD(orderRandD)
    DwTableIndex = 1;
    RoTableIndex = 1;
    for(i=1:length(orderRandD(:,1)))
        NumDataPoints = length(find(orderRandD(i,:)>0));
        NumRowsforDw = ceil(NumDataPoints/2)-1;
        
        for(j=1:NumRowsforDw)
            startData = (j*2)-1;
            endData = startData+2;
            DwTable(DwTableIndex,1:3) = orderRandD(i,startData:endData);
            DwTableIndex = DwTableIndex+1;
           
        end
        
        NumRowsforRo = floor(NumDataPoints/2)-1;
        
        for(j=1:NumRowsforRo)
            startData = (j*2);
            endData = startData+2;
            RoTable(RoTableIndex,1:3) = orderRandD(i,startData:endData);
            RoTableIndex = RoTableIndex+1;
           
        end
        
        
   
    %%%%%%%%%%%Create percentile rank tables with same indices
    
    
    
    
    
        
    
    
    
    
    end
    
    lengthofDwTable = length(DwTable(:,1));
    lengthofRoTable = length(RoTable(:,1));
    
    DwTable_Perc(1:lengthofDwTable,1) = tiedrank(DwTable(:,1))/length(DwTable(:,1));
    DwTable_Perc(1:lengthofDwTable,2) = tiedrank(DwTable(:,2))/length(DwTable(:,2));
    DwTable_Perc(1:lengthofDwTable,3) = tiedrank(DwTable(:,3))/length(DwTable(:,3));
    
    RoTable_Perc(1:lengthofRoTable,1) = tiedrank(RoTable(:,1))/length(RoTable(:,1));
    RoTable_Perc(1:lengthofRoTable,2) = tiedrank(RoTable(:,2))/length(RoTable(:,2));
    RoTable_Perc(1:lengthofRoTable,3) = tiedrank(RoTable(:,3))/length(RoTable(:,3));
    
    MaxDwTable1Values = max(DwTable(:,1));
    index = 1;
    Binvalues = [];
    addtobins = 30;
    while((addtobins/2)<MaxDwTable1Values)
        Binvalues = [Binvalues addtobins];
        addtobins = addtobins*2;
    end
    
    IndicesHere = find(DwTable(:,1)<=30);
    SecondDwellPercValues = DwTable(IndicesHere,2);
    averagepercentile = mean(SecondDwellPercValues);
    DwTablePercOutput(index,1) = 30;
    DwTablePercOutput(index,2) = averagepercentile;
    index = index+1;
    
    for(i=2:length(Binvalues))
        maxHere = Binvalues(i);
        minHere = Binvalues(i-1)+1;
        IndicesHere = find(DwTable(:,1)<=maxHere);
        Subindices = find(DwTable(IndicesHere,1)>=minHere);
        GoodIndices = IndicesHere(Subindices);
        display(maxHere)
        display(length(GoodIndices))
        SecondDwellPercValues = DwTable(GoodIndices,2);
        averagepercentile = mean(SecondDwellPercValues);
        DwTablePercOutput(index,1) = maxHere;
        DwTablePercOutput(index,2) = averagepercentile;
        index = index+1;
        
        
    end
    
    MaxRoTable1Values = max(RoTable(:,1));
    index = 1;
    Binvalues = [];
    addtobins = 30;
    while((addtobins/2)<MaxRoTable1Values)
        Binvalues = [Binvalues addtobins];
        addtobins = addtobins*2;
    end
    
    IndicesHere = find(RoTable(:,1)<=30);
    SecondRoamPercValues = RoTable(IndicesHere,2);
    averagepercentile = mean(SecondRoamPercValues);
    RoTablePercOutput(index,1) = 30;
    RoTablePercOutput(index,2) = averagepercentile;
    index = index+1;
    
    for(i=2:length(Binvalues))
        maxHere = Binvalues(i);
        minHere = Binvalues(i-1)+1;
        IndicesHere = find(RoTable(:,1)<=maxHere);
        Subindices = find(RoTable(IndicesHere,1)>=minHere);
        GoodIndices = IndicesHere(Subindices);
        display(maxHere)
        display(length(GoodIndices))
        SecondRoamPercValues = RoTable(GoodIndices,2);
        averagepercentile = mean(SecondRoamPercValues);
        RoTablePercOutput(index,1) = maxHere;
        RoTablePercOutput(index,2) = averagepercentile;
        index = index+1;
        
        
    end
    
end

    