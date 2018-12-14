%Go through AllChOPHits, gather binned Speed/AngSpeed for center of each
%bin - column1 = Xaxis column2 = speed column3 = angspeed

function AllBinnedData = gatherBinnedDataChOP(AllChOPHits,AllChOPInfo_forBinnedData)
    index1 = 1;
    for(i=1:length(AllChOPHits(:,1)))
        StartCol_Speed = AllChOPInfo_forBinnedData(i,3);
        StopCol_Speed = AllChOPInfo_forBinnedData(i,4);
        StartCol_AngSpeed = AllChOPInfo_forBinnedData(i,5);
        StopCol_AngSpeed = AllChOPInfo_forBinnedData(i,6);
        
        %%% Get the bins
        
        nBins = (StopCol_Speed-StartCol_Speed+1)/30;
        
        for(j=1:nBins)
            StartSpeed = StartCol_Speed + ((j-1)*30);
            StopSpeed = StartCol_Speed + (j*30) - 1;
            StartAngSpeed = StartCol_AngSpeed + ((j-1)*30);
            StopAngSpeed = StartCol_AngSpeed + (j*30) - 1;
            
            SpeedDataHere = nanmean(AllChOPHits(i,StartSpeed:StopSpeed));
            AngSpeedDataHere = nanmean(abs(AllChOPHits(i,StartAngSpeed:StopAngSpeed)));
            XdataPointHere = (StartSpeed+14)-4;   %In Frames, w/ first Frame of AllChOPHits=1
            
            AllBinnedData(index1,1) = XdataPointHere/3; %Devide by 3 to convert to seconds, which is used in final graph
            AllBinnedData(index1,2) = SpeedDataHere;
            AllBinnedData(index1,3) = AngSpeedDataHere;
            if(SpeedDataHere<0)
                display(StartSpeed)
                display(StopSpeed)
                display(StartAngSpeed)
                display(StopAngSpeed)
                display(AllChOPInfo_forBinnedData(i,:))
            end
            index1= index1+1;
        end
    end
end

            