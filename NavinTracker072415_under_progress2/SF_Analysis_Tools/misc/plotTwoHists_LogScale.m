function plotTwoHists_LogScale(data1,data2,logLevel)
allData = [data1 data2];
minData = min(allData)
maxData = max(allData)
scales = 30;
for (j=1:20)
   scales(j+1) = scales(j)*logLevel;
end
nBins = min(find(scales>maxData));
%%%Get numbers
binCounts(1,1) = length(find(data1<=scales(1)));
display(length(find(data1<scales(j))))
binCounts(1,2) = length(find(data2<=scales(1)));
for (j=2:nBins)
    binCounts(j,1) = length(find(data1<=scales(j))) - sum(binCounts(1:j-1,1));
    binCounts(j,2) = length(find(data2<=scales(j))) - sum(binCounts(1:j-1,2));
end
display(scales)
display(nBins)
display(binCounts)
finalbinData(1:nBins,1) = binCounts(:,1)./sum(binCounts(:,1));
finalbinData(1:nBins,2) = binCounts(:,2)./sum(binCounts(:,2));
display(finalbinData(:,1))
bar(finalbinData,'grouped');




% [N,X] = hist(data1,bins);
% [N2,X2] = hist(data2,bins);
% if (X(bins) > X2(bins))
%     [N2,X2] = hist(data2,X);
%     alldata = [N./sum(N); N2./sum(N2)]';
% else
%     [N,X] = hist(data1,X2);
%      alldata = [N./sum(N); N2./sum(N2)]';
% end
%     
% bar(alldata,1.5);
% %percentileHist(data1,bins); hold on; percentileHist(data2,X);
% children = get(gca, 'Children');
% set(children(1),'XData', X/60);
% set(children(2),'XData', X/60);
% legend(Name1,Name2)
% xlabel('state duration (min)')
% ylabel('fraction of events')
end