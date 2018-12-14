function plotTwoHists(data1,data2,Name1,Name2,bins)
[N,X] = hist(data1,bins);
[N2,X2] = hist(data2,bins);
if (X(bins) > X2(bins))
    [N2,X2] = hist(data2,X);
    %display(X)
    alldata = [N./sum(N); N2./sum(N2)]';
else
    [N,X] = hist(data1,X2);
    %display(X)
     alldata = [N./sum(N); N2./sum(N2)]';
end
    
bar(alldata,1.5);
%percentileHist(data1,bins); hold on; percentileHist(data2,X);
children = get(gca, 'Children');
set(children(1),'XData', X);
set(children(2),'XData', X);
legend(Name1,Name2)
xlabel('state duration (min)')
ylabel('fraction of events')
end