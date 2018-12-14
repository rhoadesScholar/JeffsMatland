function plotCalciumSpeedRelationship(AcuteCalciumData,AcuteSpeedData,errorStart,errorStop,center,baselineStart,baselineStop)

    for(m=1:length(AcuteCalciumData(1,:)))
        AverageSpeed(m) = nanmean(AcuteSpeedData(:,m));
        AverageCalcium(m) = nanmean(AcuteCalciumData(:,m));
        StdErrSpeed(m) = nanstd(AcuteSpeedData(:,m))/(sqrt(sum(~isnan(AcuteSpeedData(:,m)))));
        StdErrCalcium(m) = nanstd(AcuteCalciumData(:,m))/(sqrt(sum(~isnan(AcuteCalciumData(:,m)))));
    end
    
     %AverageSpeed = AverageSpeed.*(0.2/41); %%%%Convert to mm/sec
     %StdErrSpeed = StdErrSpeed.*(0.2/41); %%%%Convert to mm/sec
     



     
    [AX, H1, H2] = plotyy(((1:length(AcuteCalciumData(1,:)))/10)-(center/10),AverageCalcium,((1:length(AcuteCalciumData(1,:)))/10)-(center/10),AverageSpeed);
    set(H1,'Color',[0 0.502 0]);
    set(H2,'Color','b');

    set(AX(1),'YAxisLocation','left')
    set(AX(2),'YAxisLocation','left')
    set(AX(1),'YColor',[0 0.502 0]);
    set(AX(2),'YColor','b');
    delete(H1)
    delete(H2)
    
%%%%%%%%%%SpeedDataError
    xpoints = (errorStart:errorStop)/10 - center/10;
    upper = AverageSpeed(errorStart:errorStop)+StdErrSpeed(errorStart:errorStop);
    lower = AverageSpeed(errorStart:errorStop)-StdErrSpeed(errorStart:errorStop);
    color = [.804 .878 .969];
    edge=color;

if length(upper)==length(lower) && length(lower)==length(xpoints)
    msg='';
    filled=[upper,fliplr(lower)]; 
    xpoints=[xpoints,fliplr(xpoints)];
     
    ypoints = filled;
    

    
%     fillhandle=fill(xpoints,filled,color); %plot the data
%     set(fillhandle,'EdgeColor',edge,'FaceAlpha',transparency,'EdgeAlpha',transparency); %set edge color
    
    hold on;
    fillhandle = patch('Parent',AX(2),'XData',xpoints,'YData',ypoints,'FaceColor',color);
    set(fillhandle,'EdgeColor',edge);
    
    % dot_fill(xpoints,filled,color);
    

else
    msg='Error: Must use the same number of points in each vector';
end

%%%%%%%CalciumDataError
    xpoints = (errorStart:errorStop)/10 - center/10;
    upper = AverageCalcium(errorStart:errorStop)+StdErrCalcium(errorStart:errorStop);
    lower = AverageCalcium(errorStart:errorStop)-StdErrCalcium(errorStart:errorStop);
    color = [.839 .91 .851];
    edge=color;

if length(upper)==length(lower) && length(lower)==length(xpoints)
    msg='';
    filled=[upper,fliplr(lower)]; 
    xpoints=[xpoints,fliplr(xpoints)];
     
    ypoints = filled;
    

    
%     fillhandle=fill(xpoints,filled,color); %plot the data
%     set(fillhandle,'EdgeColor',edge,'FaceAlpha',transparency,'EdgeAlpha',transparency); %set edge color
    
    hold on;
    fillhandle = patch('Parent',AX(1),'XData',xpoints,'YData',ypoints,'FaceColor',color);
    set(fillhandle,'EdgeColor',edge);
    
    % dot_fill(xpoints,filled,color);
    

else
    msg='Error: Must use the same number of points in each vector';
end

%axes(AX(1));
hold on;
plot(((1:length(AcuteCalciumData(1,:)))/10)-(center/10),AverageCalcium,'Color',[0 0.502 0]);

%%%Pre-event baseline
PreCalcium = nanmean(AverageCalcium(baselineStart:baselineStop));
hold on;
plot(((1:length(AcuteCalciumData(1,:)))/10)-(center/10),PreCalcium,'Color',[0 0.502 0]);


axes(AX(2));
hold on;
plot(((1:length(AcuteCalciumData(1,:)))/10)-(center/10),AverageSpeed,'Color','b');

PreSpeed = nanmean(AverageSpeed(baselineStart:baselineStop));
hold on;
plot(((1:length(AcuteCalciumData(1,:)))/10)-(center/10),PreSpeed,'Color','b');

    %
    
    %%%%%For NSM Calcium Peaks
    
%     axis(AX(2),[-30 80 -.01 .14]);
%     set(gca,'XTick',[-30  0 30 60 ]);
%     set(gca,'Yaxislocation','left');
%     set(gca,'YTick',[0.03 .04 .05 .06 .07]);
%     axis(AX(1),[-30 80 -.35 .65]);
%     set(AX(1),'XTick',[-30  0 30 60 ]);
%     set(AX(1),'YTick',[.3 .4 .5 .6]);
    
    
    %%%%%For FRuns
    axis(AX(2),[-180 180 -.11 .15]);
    set(gca,'XTick',[-180 -120 -60 0 60 120 180]);
    set(gca,'Yaxislocation','left');
    set(gca,'YTick',[0.025 .05 .075 .1 .125]);
    axis(AX(1),[-180 180 .1 1.2]);
    set(AX(1),'XTick',[-180 -120 -60 0 60 120 180]);
    set(AX(1),'YTick',[.2 .3 .4 .5 .6]);
    
    

    
end
    
    
    