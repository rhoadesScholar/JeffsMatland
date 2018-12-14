function SpeedFluorTable = CalciumSpeedCorrelation(cellData,binSize)
    
    outputIndex = 1;

    binSize = binSize*10; % 10fps
    
    EndsofStretches = find(cellData(:,17)>0)';
    EndsofStretches = [EndsofStretches length(cellData(:,2))];
    Begins = EndsofStretches+1;
    Begins = Begins(1:(length(Begins)-1));
    BeginningsofStretches = [1 Begins];
    display(EndsofStretches)
    StartStopData(1:length(EndsofStretches),1) = BeginningsofStretches;
    StartStopData(1:length(EndsofStretches),2) = EndsofStretches;
    display(StartStopData)
    
    %%%%%Break data into pieces
    
    for(i=1:length(StartStopData(:,1)))
        NumFramesHere = StartStopData(i,2)-StartStopData(i,1);
        numBins = floor(NumFramesHere/binSize);
        for(j=1:numBins)
            StopFrame = StartStopData(i,1)+(j*binSize)-1;
            StartFrame = StopFrame-99;
            Fluor = nanmean(cellData(StartFrame:StopFrame,23));
            Speed = nanmean(cellData(StartFrame:StopFrame,19));
            if(~isnan(Fluor))
                if(~isnan(Speed))
            SpeedFluorTable(outputIndex,1) = Speed;
            SpeedFluorTable(outputIndex,2) = Fluor;
            SpeedFluorTable(outputIndex,3) = StartFrame;
            SpeedFluorTable(outputIndex,4) = StopFrame;
            outputIndex = outputIndex+1;
                end
            end
        end
    end
end
            
            
            