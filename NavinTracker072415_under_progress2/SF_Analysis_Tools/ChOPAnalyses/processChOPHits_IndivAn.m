function indivAnimMeans = processChOPHits_IndivAn(AllChOPHits,RoamDwellFlag,startTime,stopTime)
    indivAnimMeans = [];

    startIndex = 150+((startTime*3)-2)+4;
    stopIndex = 150 + (stopTime*3) +4;
    
    if(RoamDwellFlag==2)
        RoamStartIndices = find(AllChOPHits(:,3)==2);
        AllChOPHits = AllChOPHits(RoamStartIndices,:);
    else
        DwellStartIndices = find(AllChOPHits(:,3)==1);
        AllChOPHits = AllChOPHits(DwellStartIndices,:);
    end
    
    for(j=1:length(AllChOPHits(:,1)))
        AnimMeanHere = nanmean(AllChOPHits(j,startIndex:stopIndex));
        indivAnimMeans = [indivAnimMeans AnimMeanHere];
    end
end
