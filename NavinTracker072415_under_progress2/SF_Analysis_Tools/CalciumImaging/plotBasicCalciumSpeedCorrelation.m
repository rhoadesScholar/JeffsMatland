function [RegSpeed RegCalcium Group_RegVar boxMat highest_NumData avRegCa avRegSp SpeedatBins] = plotBasicCalciumSpeedCorrelation(folder,minDataPoints,maxColorBar)

    [AllCalcium AllSmoothCalciumData AllSpeed AllSmoothSpeedData AllCalciumDerivErrorData] = collectDerivs(folder,10,10,2);

    RegSpeed = [];
    RegCalcium = [];
    RegDeriv = [];
    Group_RegVar = [];
for(j=1:length(AllCalcium))

     nBins = floor((length(AllCalcium(j).Calcium))/10)
     binnedSpeed = [];
     binnedCalcium = [];
     binnedDeriv = [];
     for(i=1:nBins)
         middleInd = (i*10)-5;
         binnedSpeed = [binnedSpeed AllSmoothSpeedData(j).Speed((i*10)-5)*(0.2/41)];
         binnedCalcium = [binnedCalcium AllSmoothCalciumData(j).Calcium((i*10)-5)];
         binnedDeriv = [binnedDeriv AllCalcium(j).Calcium((i*10)-5)];
         %binnedDeriv = [binnedDeriv nanmean(AllCalcium(j-2).Calcium(startInd:stopInd))];
     end
   
     RegSpeed = [RegSpeed binnedSpeed];
     RegCalcium = [RegCalcium binnedCalcium];
     RegDeriv = [RegDeriv binnedDeriv];
     
     GroupIndices = NaN(1,length(binnedCalcium));
     GroupIndices(1:length(binnedCalcium)) = j;
     
     Group_RegVar = [Group_RegVar GroupIndices];
     
     
     %%%%Uncomment if you want to look at individual animals
%      figure(2);
%      plot(binnedSpeed,binnedCalcium,'--s','LineWidth',.5,'MarkerSize',5);
%      hold on;
%      scatter(binnedSpeed,binnedCalcium,40,binnedDeriv,'filled'); caxis([-.25 .25]);colorbar;
%      pause;
%      clf;
end


edges = [0:.05:1];


[N,M] = histc(RegCalcium,edges);

avRegCa = [];
avRegSp = [];
errorRegSp = [];
SpeedatBins=struct('SpeedData',[]);
MostDataPoints=0;

firstDataInd = 0;
lastDataInd = 0;

for(j=2:20)
    binInd = find(M==j);
    avRegCa(j) = nanmean(RegCalcium(binInd));
    avRegSp(j) = nanmean(RegSpeed(binInd));
    SpeedatBins(j).SpeedData = RegSpeed(binInd);
    if(length(SpeedatBins(j).SpeedData)>minDataPoints)
        if(firstDataInd==0)
            firstDataInd = j;
        end
    end
    if(length(SpeedatBins(j).SpeedData)<minDataPoints)
        if(firstDataInd>0)
            if(lastDataInd==0)
            lastDataInd = j-1;
            end
        end
    end
    if(length(SpeedatBins(j).SpeedData)>MostDataPoints)
    	MostDataPoints = length(SpeedatBins(j).SpeedData);
    end
    errorRegSp(j) = nanstd(RegSpeed(binInd))/(sqrt(length(RegSpeed(binInd))));
end


boxMat = NaN(MostDataPoints,(lastDataInd-firstDataInd+1));

numColumnstoSkip = firstDataInd-1;

for(k=1:(lastDataInd-firstDataInd+1))
    display(k)
    display(numColumnstoSkip)
    NumData(k) = length(SpeedatBins(k+numColumnstoSkip).SpeedData);
    boxMat(1:NumData(k),k) = SpeedatBins(k+numColumnstoSkip).SpeedData;
end

Normalized_NumData = (NumData/(length(RegCalcium)));
highest_NumData = max(Normalized_NumData);

jet_cmap = colormap(jet);
display(jet_cmap)

for(j=1:length(NumData))
    DataHere = Normalized_NumData(length(NumData)-j+1);
    fractionMaxHere = round(DataHere/maxColorBar*64);
    ColorHere = jet_cmap(fractionMaxHere,:);
    ColorMatrix(j,1:3) = ColorHere;
    
    Xticks_here(j) = edges(j+numColumnstoSkip);
end

Xticks_here = [Xticks_here edges(length(NumData)+numColumnstoSkip+1)];
    
figure(4);
h=boxplot(boxMat,'outliersize',1,'whisker',.7193,'Notch','on','colors','k');
set(h(7,:),'Visible','off');
h = findobj(gca,'Tag','Box');

for (j=1:length(NumData))
patch(get(h(j),'XData'),get(h(j),'YData'),ColorMatrix(j,:));
end
set(gca,'Xtick',[.5:1:(length(NumData)+.5)],'XTickLabel',{Xticks_here})
colorbar





end



