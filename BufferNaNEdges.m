%%%find contiguous NaNs in each row (>10) and then make surrounding 10 data
%%%points NaN also (they appear to be volatile
function cleanedMatrix = BufferNaNEdges(allCaData)

allCaDataOrig = allCaData;

for(i=1:length(allCaData(:,1)))
    dataHere = allCaData(i,:);
    NanInd = isnan(dataHere);
    counter = 0;
    inclusionFlag=0;
    AllStretches = [];
    AllStretchesInd = 1;
    for(j=1:length(NanInd))
        if(NanInd(j)==0)
            if(inclusionFlag==1)
                %then stretch has ended; log start/stop
                firstFrameOfStretch = j-counter;
                lastFrameOfStretch = j-1;
                AllStretches(AllStretchesInd,1:2) = [firstFrameOfStretch lastFrameOfStretch];
                AllStretchesInd=AllStretchesInd+1;
            end
            counter=0;
            inclusionFlag=0;
        else
            counter = counter+1;
        end
        if(counter>9) % then we have entered a long stretch
            inclusionFlag=1;
        end

    end
    
    test = size(AllStretches);
    if(test(1)>0)
    AllStretches(:,3) = AllStretches(:,1)-10;
    AllStretches(:,4) = AllStretches(:,2)+10;
    
    %Now NaN Out the Data
    
    for(k=1:length(AllStretches(:,1)))
        firstPass = AllStretches(k,3):AllStretches(k,1);
        if(firstPass(1)>0)
            dataHere(firstPass) = NaN;
        end
        secondPass = AllStretches(k,2):AllStretches(k,4);
        if(secondPass(end)<length(dataHere))
            dataHere(secondPass) = NaN;
        end
    end
    allCaData(i,:) = dataHere;
    end
end

cleanedMatrix = allCaData;

%%%%%To assess output
% for(i=1:length(allCaData(:,1)))
%     figure()
%     plot(1:length(allCaData(i,:)),allCaDataOrig(i,:)); 
%     hold on; plot(1:length(allCaData(i,:)),allCaData(i,:),'k')
%     pause;
% end

end



