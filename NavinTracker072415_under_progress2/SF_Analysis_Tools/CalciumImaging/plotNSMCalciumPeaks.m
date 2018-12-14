function [AllHighCaRegions AllHighCaRegions_Speed AllHighCaRegions_FRuns] = plotNSMCalciumPeaks(folder,startPeak)


%%%%%%%%I set startPeak to 4920 for NSM-WT and 4955 for NSM-mod1.  This was
%%%%%%%%based on drawing a pre-event baseline from 4600-4800 (safely in
%%%%%%%%baseline territory) and looking for the earliest time point when
%%%%%%%%signal increased from baseline (i.e. peak began).  This time point
%%%%%%%%is set to be startPeak.



    [AllHighCaRegions AllHighCaRegions_Speed AllHighCaRegions_FRuns checkPeakOverlap_Reg checkPeakOverlap_noSp AllDiffBins CalciumPeakProps EveryCalcium AllPeakStarts StartStopMatrix] = FindAllCaRegions_byFrame(folder,0,.55);
    
    %%%%%%%%% THROWING OUT BAD PEAKS
    
    %%%Remove inconsistent peaks
inconsPeaks = find(CalciumPeakProps(:,15)<.5);
AllHighCaRegions(inconsPeaks,:) = [];
AllHighCaRegions_Speed(inconsPeaks,:) = [];
AllHighCaRegions_FRuns(inconsPeaks,:) = [];


%%%%%%%Remove peaks with not enough data: (1) If there are >50% NaNs or (2)
%%%%%%%if there is bias in position of Nans (all at end, or beginning)
%(1)
CalciumTable = AllHighCaRegions;
%CalciumTable = FRunCalciumAcuteData;
OverallRegion = 4700:5800;

%OverallRegion = 3100:4600;


NansHere = [];
for(i=1:length(CalciumTable(:,1)))
    NansHere(i) = sum(isnan(CalciumTable(i,OverallRegion)));
end
RowsToKill = find(NansHere>(length(OverallRegion)/2));


 AllHighCaRegions(RowsToKill,:) = [];
 AllHighCaRegions_Speed(RowsToKill,:) = [];
 AllHighCaRegions_FRuns(RowsToKill,:) = [];
 

%(2)

CalciumTable = AllHighCaRegions;
%CalciumTable = FRunCalciumAcuteData;
BeforeRegion = 4700:5000;

%BeforeRegion = 3100:4000;

numBeforeRegion = round(.66*(length(BeforeRegion)));

FirstPart_BeforeRegion = BeforeRegion(1):BeforeRegion(numBeforeRegion);

newRowsToKill = [];
for(i=1:length(CalciumTable(:,1)))
    NansHere = [];
    NansHere = sum(~isnan(CalciumTable(i,FirstPart_BeforeRegion)));

    if(sum(NansHere)==0)
        newRowsToKill = [newRowsToKill i];
    end
end

AfterRegion = 5000:5600;

%AfterRegion = 4000:4600;

numAfterRegion = round(.5*(length(AfterRegion)));

LastPart_AfterRegion = AfterRegion(end-numAfterRegion):AfterRegion(end);

for(i=1:length(CalciumTable(:,1)))
    NansHere = [];
    NansHere = sum(~isnan(CalciumTable(i,LastPart_AfterRegion)));

    if(sum(NansHere)==0)
        newRowsToKill = [newRowsToKill i];
    end
end

AllHighCaRegions(newRowsToKill,:) = [];
AllHighCaRegions_Speed(newRowsToKill,:) = [];
AllHighCaRegions_FRuns(newRowsToKill,:) = [];


%%Plot calcium/speed
figure(2)
plotCalciumSpeedRelationship(AllHighCaRegions,AllHighCaRegions_Speed,startPeak-300,startPeak+800,startPeak,startPeak-300,startPeak-150)


%Plot FRuns
startRegion= startPeak-300;
stopRegion = startPeak+800;
for(i=startRegion:stopRegion)
    numTotal = sum(~isnan(AllHighCaRegions_FRuns(:,i)));
    numFRun = length(find(AllHighCaRegions_FRuns(:,i)==2));
    percentFRun(i-startRegion+1) = numFRun/numTotal;
end
figure(3);
plot((startRegion-startPeak):(stopRegion-startPeak),percentFRun)


end