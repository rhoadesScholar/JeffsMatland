function [covOutputAve covOutputErr SpecificCells NoLongerSig ConCatMatrices]= getCrossCorr(folder)

%%%%%%Get each track
 PathofFolder = sprintf('%s',folder);
 
 fileList = ls(PathofFolder);

 numFiles = length(fileList(:,1));
 
 AllTracks_Speed = [];
 AllTracks_Calcium = [];
 
 overallIndex = 1;
 covOutput =[];
 
 SpecCellInd = 1;
 
 for(k=3:1:numFiles)
            string2 = deblank(fileList(k,:));
            fileToOpen = sprintf('%s/%s',PathofFolder,string2);
        
            [cellData  FinalStretchTable ForwardRunStarts AllSmoothData] = ProcessCalciumImaging(fileToOpen,1);
    if(length(cellData(:,2))>2500)
    
%%%%%%%%%%%%Break into fragments, identify those fragments that are long enough for XCorrs
            checkContinuity = [];
            numRows = length(cellData(:,1));
            checkContinuity = cellData(2:numRows,1) - cellData(1:(numRows-1),1);
            MoreThanIndices = find(checkContinuity>50);
            checkVector = [];
            checkVector(1:length(cellData(:,1))) = 0;
            checkVector(MoreThanIndices)=1;
            
            
    EndsofStretches = find(checkVector>0);
    EndsofStretches = [EndsofStretches length(cellData(:,2))];
    Begins = EndsofStretches+1;
    Begins = Begins(1:(length(Begins)-1));
    BeginningsofStretches = [1 Begins];
    StartStopData(1:length(EndsofStretches),1) = BeginningsofStretches;
    StartStopData(1:length(EndsofStretches),2) = EndsofStretches;

    CheckLengthStretches = EndsofStretches-BeginningsofStretches;
    LongStretchInd = find(CheckLengthStretches>3000)
    
    if(length(LongStretchInd)>0)
        for(j=1:length(LongStretchInd))
            cellData_Spec = [];
            cellData_Spec = cellData(StartStopData(LongStretchInd(j),1):StartStopData(LongStretchInd(j),2),:);
            
%%%%%%Bin by 1sec
    
    NumRows = length(cellData_Spec(:,1));
    NumBins = floor(NumRows/10);
    TrackSpeed = [];
    TrackCalcium = [];
    MeanSpeed = nanmean(cellData_Spec(:,19));
    MeanCalcium = nanmean(cellData_Spec(:,23));
    for (i=2:NumBins)  %%%%Omit bin 1 because it is NaN
        SpeedData = cellData_Spec(((i*10)-9):(i*10),19);
        TrackSpeed(i) = nanmean(SpeedData);
        CalciumData = cellData_Spec(((i*10)-9):(i*10),23);
        TrackCalcium(i) = nanmean(CalciumData);
    end
        
%%%%%%Deal with NaNs

        TrackSpeed(isnan(TrackSpeed)) = 0;
        TrackCalcium(isnan(TrackCalcium)) = 0;

    for(i=1:151)
        display(k)
        display(j)
        display(i)
        display(length(cellData_Spec(:,1)))
        display(StartStopData)
        SpecificCells(SpecCellInd).CrossMatrix(i).Matrix(:,1) = TrackSpeed(i:end)';
        SpecificCells(SpecCellInd).CrossMatrix(i).Matrix(:,2) = TrackCalcium(1:(end-(i-1)))';
        [RHO,SpecificCells(SpecCellInd).pValue(i).pValue] = corr(SpecificCells(SpecCellInd).CrossMatrix(i).Matrix);
        SpecificCells(SpecCellInd).CrossMatrix2(i).Matrix(:,1) = TrackCalcium(i:end)';
        SpecificCells(SpecCellInd).CrossMatrix2(i).Matrix(:,2) = TrackSpeed(1:(end-(i-1)))';
        [RHO,SpecificCells(SpecCellInd).pValue2(i).pValue] = corr(SpecificCells(SpecCellInd).CrossMatrix2(i).Matrix);
        SpecificCells(SpecCellInd).AutoMatrix(i).Matrix(:,1) = TrackCalcium(i:end)';
        SpecificCells(SpecCellInd).AutoMatrix(i).Matrix(:,2) = TrackCalcium(1:(end-(i-1)))';
        [RHO,SpecificCells(SpecCellInd).AutopValue(i).pValue] = corr(SpecificCells(SpecCellInd).AutoMatrix(i).Matrix);
    end
    SpecCellInd = SpecCellInd+1;
    
    

   TempCov = normxcorr2(TrackCalcium,TrackCalcium);%SpeedFirst
   %TempCov = xcorr(TrackCalcium);
   MiddleZeroIndex = length(TrackCalcium);
   StartIndex = MiddleZeroIndex-150;
   StopIndex = MiddleZeroIndex+150;

   
    covOutput(overallIndex,1:301) = TempCov(StartIndex:StopIndex);
   overallIndex =overallIndex+1;
%%%Run
        end
    end
    end
 end
 for(i=1:301) covOutputAve(i) = nanmean(covOutput(:,i)); end
 for(i=1:301) covOutputErr(i) = nanstd(covOutput(:,i))/(sqrt(length(covOutput(:,1)))); end
 %plot(-600:600,covOutputAve)
 
 indexSig = 1;
 
 for(j=1:length(SpecificCells))
     Temp_pVal_Database_X1 = [];
     Temp_pVal_Database_X2 = [];
     Temp_pVal_Database_Auto = [];
     if(size(SpecificCells(j).CrossMatrix,1)>0)
         if(SpecificCells(j).pValue(1).pValue(1,2)<0.01)
             for(i=2:length(SpecificCells(j).pValue))
                 pValHere = SpecificCells(j).pValue(i).pValue(1,2);
                 if(pValHere>0.05)
                     Temp_pVal_Database_X1 = [Temp_pVal_Database_X1 i];
                 end
             end
             for(i=2:length(SpecificCells(j).pValue2))
                 pValHere = SpecificCells(j).pValue2(i).pValue(1,2);
                 if(pValHere>0.05)
                     Temp_pVal_Database_X2 = [Temp_pVal_Database_X2 i];
                 end
             end
             for(i=2:length(SpecificCells(j).AutopValue))
                 %display(j)
                 %display(i)
                 %display(SpecificCells(j).pValue(i).pValue)
                 %display(SpecificCells(j).AutopValue(i).pValue)
                 pValHere = SpecificCells(j).AutopValue(i).pValue(1,2);
                 if(pValHere>0.05)
                     Temp_pVal_Database_Auto = [Temp_pVal_Database_Auto i];
                 end
             end
             if(length(Temp_pVal_Database_X1)>0)
             NoLongerSig(indexSig,2) = min(Temp_pVal_Database_X1);
             [Rho, p] = corr(SpecificCells(j).CrossMatrix(1).Matrix);
             NoLongerSig(indexSig,1) = Rho(1,2);
             else
                 NoLongerSig(indexSig,2) = 250;
                 [Rho, p] = corr(SpecificCells(j).CrossMatrix(1).Matrix);
                 NoLongerSig(indexSig,1) = Rho(1,2);
             end
             if(length(Temp_pVal_Database_X2)>0)
             NoLongerSig(indexSig,3) = min(Temp_pVal_Database_X2);
             else
                 NoLongerSig(indexSig,3) = 250;
             end
             if(length(Temp_pVal_Database_Auto)>0)
             NoLongerSig(indexSig,4) = min(Temp_pVal_Database_Auto);
             else
                 NoLongerSig(indexSig,4) = 250;
             end
             NoLongerSig(indexSig,5) = j;
             indexSig = indexSig+1;
         end
     end
 
 
 
 end
 
 ConCatMatrices(i).XMatrix1 = [];
 ConCatMatrices(i).XMatrix2 = [];
 ConCatMatrices(i).AutoMatrix = [];
for(i=1:151) 
 ConCatMatrices(i).XMatrix1 = [];
 ConCatMatrices(i).XMatrix2 = [];
 ConCatMatrices(i).AutoMatrix = [];
    for(j=1:length(SpecificCells))
        ConCatMatrices(i).XMatrix1 = [ConCatMatrices(i).XMatrix1; SpecificCells(j).CrossMatrix(i).Matrix];
        ConCatMatrices(i).XMatrix2 = [ConCatMatrices(i).XMatrix2; SpecificCells(j).CrossMatrix2(i).Matrix];
        ConCatMatrices(i).AutoMatrix = [ConCatMatrices(i).AutoMatrix; SpecificCells(j).AutoMatrix(i).Matrix];
    end
end


%plot(-300:300,c)
%corrLength=length(a)+length(b)-1;

%c=fftshift(ifft(fft(a,corrLength).*conj(fft(b,corrLength))));
