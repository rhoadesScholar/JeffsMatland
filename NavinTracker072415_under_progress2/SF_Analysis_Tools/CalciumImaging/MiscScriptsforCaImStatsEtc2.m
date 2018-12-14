
%Define Data Table
DataTable = AllHighCaRegions_Speed_mod1;
nRows = length(DataTable(:,1));

%%%%%%%%%GET CONTROL DATA

%15sec  of data 30sec prior to NSM peak onset
ControlColumns = 4701:4850;

%15sec of data at 2 min before FRun
%ControlColumns = 2801:2950;

%2min prior to FRun
%ControlColumns = 2801:3200;
%
%15sec of data at 3 min before FRun
%ControlColumns = 2201:2350;


%%%%%%%%%%GET TEST DATA

%15sec after NSM peak onset
ExpColumns = 5001:5150;

%15sec of data at beginning of FRun
%ExpColumns = 4001:4150;

%1min prior to FRun
%ExpColumns = 3401:3800;

%%%%%%%%%%%%COLLECT DATA DEFINED BY ABOVE COLUMNS


ControlData = [];
ExpData = [];


for(i=1:nRows)
    ControlData(i) = nanmean(DataTable(i,ControlColumns));
    ExpData(i) = nanmean(DataTable(i,ExpColumns));
end

%Find datapoints with NaNs

ControlNan = find(isnan(ControlData));
ExpNaN = find(isnan(ExpData));
ControlInf = find(isinf(ControlData));
ExpInf = find(isinf(ExpData));

AllNan = unique([ControlNan ExpNaN ControlInf ExpInf]);

%Reduce Data to only non-NaN rows

ControlData(AllNan) = [];
ExpData(AllNan) = [];

[h,p,ci] = ttest(ControlData,ExpData)


%%%%%FOR COMPARING BETWEEN TWO TABLES

ColsForBaseline_WT = 4700:4850;
ColsForBaseline_mod1 = 4700:4850;

Table1_Pre = AllHighCaRegions_Speed_WT;
Table2_Pre = AllHighCaRegions_Speed_mod1;

for(i=1:length(Table1_Pre(:,1)))
    baselineSpeed_1(i) = nanmean(Table1_Pre(i,ColsForBaseline_WT));
end

for(i=1:length(Table2_Pre(:,1)))
    baselineSpeed_2(i) = nanmean(Table2_Pre(i,ColsForBaseline_mod1));
end

averageBaseline_1 = nanmean(baselineSpeed_1);
AllHighCaRegions_Speed_Norm = Table1_Pre/averageBaseline_1;

averageBaseline_2 = nanmean(baselineSpeed_2);
AllHighCaRegions_Speed_mod1_Norm = Table2_Pre/averageBaseline_2;

%%%Same for Table2_Pre

Table1 = AllHighCaRegions_Speed_Norm;
Table2 = AllHighCaRegions_Speed_mod1_Norm;
ColsToTest1 = 5000:5150; % +10 to +30 wrt adjusted start - WT
ColsToTest2 = 5000:5150; % mod-1

ControlData = [];
ExpData = [];
%Generally
for(i=1:length(Table1(:,1)))
    ControlData(i) = nanmean(Table1(i,ColsToTest1));
    
end

for(i=1:length(Table2(:,1)))
    ExpData(i) = nanmean(Table2(i,ColsToTest2));
end

ControlNan = find(isnan(ControlData));
ExpNaN = find(isnan(ExpData));
ControlInf = find(isinf(ControlData));
ExpInf = find(isinf(ExpData));

AllConNan = unique([ControlNan ControlInf]);
AllExpNan = unique([ExpNaN ExpInf]);

ControlData(AllConNan) = [];
ExpData(AllExpNan) = [];

[h,p,ci] = ttest2(ControlData,ExpData)



%%%%%%FOR DOING CHI-SQUARED TEST TO LOOK AT NUM ANIM IN FRUN

Table1 = AllHighCaRegions_FRuns_WT;
Table2 = AllHighCaRegions_FRuns_mod1;

WT_FractioninRun = []
numTotal_mod1 = [];
Observed_mod1_FRun = [];

%Do this twice, set to 4620 for WT data, 4655 for mod1 data

for(j=1:18)
        StartInd = 4700+(j*50)-49;
        
        StopInd = 4700+(j*50);
        
        FRunCall = [];
        for(i=1:length(Table1(:,1)))
            DataOfInt = Table1(i,StartInd:StopInd);
            numFRun = length(find(DataOfInt==2));
            totalNum = length(find(DataOfInt>0));
            FRunCall(i) = round(numFRun/totalNum);

        end
       
        numFRun = length(find(FRunCall==1));
        numTotal = length(find(FRunCall>-1));
        
        WT_FractioninRun(j) = numFRun/numTotal;  %%%% Avg numb animals in FRun

     
        FRunCall = [];
        for(i=1:length(Table2(:,1)))
            DataOfInt = Table2(i,StartInd:StopInd);
            numFRun = length(find(DataOfInt==2));
            totalNum = length(find(DataOfInt>0));
            FRunCall(i) = round(numFRun/totalNum);
        end
        
        numFRun = length(find(FRunCall==1));
        numTotal_mod1(j) = length(find(FRunCall>-1));
        
        Observed_mod1_FRun(j) = numFRun;
        
end
Expected_mod1_FRun = [];
 for(j=1:18)
    Expected_mod1_FRun(j) = WT_FractioninRun(j) * numTotal_mod1(j);
 end
    bins = 0:17;
    [h,p,st] = chi2gof(bins,'ctrs',bins,'frequency',Observed_mod1_FRun,'expected',Expected_mod1_FRun,'emin',0)
