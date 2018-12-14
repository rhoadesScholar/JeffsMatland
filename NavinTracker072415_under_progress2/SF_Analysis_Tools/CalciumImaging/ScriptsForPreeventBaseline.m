
%Define Data Table
DataTable = CalciumAcuteData_long_WT;
nRows = length(DataTable(:,1));

%%%%%%%%%GET CONTROL DATA
%ControlColumns = 2201:2500;
%ControlColumns = 2801:3100;
ControlColumns = 701:1000

ControlData = [];



for(i=1:length(ControlColumns))
    ControlData(i) = nanmean(DataTable(:,ControlColumns(i)));
    
end
nanmean(ControlData)