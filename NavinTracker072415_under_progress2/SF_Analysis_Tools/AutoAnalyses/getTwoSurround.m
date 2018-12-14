function beforeAndAfter = getTwoSurround (stateDurationMaster)
    place = 1;
    for (i = 1:length(stateDurationMaster))
        tempInd = find((stateDurationMaster(i).stateCalls(:,2,:) < 18) & (stateDurationMaster(i).stateCalls(:,1,:) ==2));
        for (j= 1:length(tempInd))
            
            if (((tempInd(j))) > 2)
                if(tempInd(j) < (length((stateDurationMaster(i).stateCalls(:,2,:) )))-1)
            beforeInd = (tempInd(j)-2):(tempInd(j)-1);
            afterInd = (tempInd(j)+1):(tempInd(j)+2);
            allInd = [beforeInd afterInd];
            beforeAndAfter(place).surr = [];
            display(i)
            display(tempInd(j))
            beforeAndAfter(place).surr = stateDurationMaster(i).stateCalls(allInd,:,:);
            place = place + 1;
                end
               
        end
    end
end
