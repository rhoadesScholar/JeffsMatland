function plotThreeHists(data1,data2,data3,Name1,Name2,Name3,bins)
[N,X] = hist(data1,bins);
[N2,X2] = hist(data2,bins);
[N3,X3] = hist(data3,bins);
%[N4,X4] = hist(data4,bins);

maxvalues = [X(bins) X2(bins) X3(bins)];
maximumV = max(maxvalues);
maxIndex = find(maxvalues==maximumV);
allfour = [1 2 3];

others = find(allfour~=maxIndex);

Xvalues(1).Xs = X;
Xvalues(2).Xs = X2;
Xvalues(3).Xs = X3;
%Xvalues(4).Xs = X4;
Xvalues(1).Ns = N;
Xvalues(2).Ns = N2;
Xvalues(3).Ns = N3;
%Xvalues(4).Ns = N4;
Xvalues(1).data = data1;
Xvalues(2).data = data2;
Xvalues(3).data = data3;
%Xvalues(4).data = data4;
display(others);
display(maxIndex);

if(length(others)>0)
[Xvalues(others(1)).Ns,Xvalues(others(1)).Xs] = hist(Xvalues(others(1)).data,Xvalues(maxIndex).Xs);
else
    [Xvalues(maxIndex(2)).Ns,Xvalues(maxIndex(2)).Xs] = hist(Xvalues(maxIndex(2)).data,Xvalues(maxIndex(1)).Xs);
    [Xvalues(maxIndex(3)).Ns,Xvalues(maxIndex(3)).Xs] = hist(Xvalues(maxIndex(3)).data,Xvalues(maxIndex(1)).Xs);
    %[Xvalues(maxIndex(4)).Ns,Xvalues(maxIndex(4)).Xs] = hist(Xvalues(maxIndex(4)).data,Xvalues(maxIndex(1)).Xs);
end
if(length(others)>1)
[Xvalues(others(2)).Ns,Xvalues(others(2)).Xs] = hist(Xvalues(others(2)).data,Xvalues(maxIndex).Xs);
else
    [Xvalues(maxIndex(2)).Ns,Xvalues(maxIndex(2)).Xs] = hist(Xvalues(maxIndex(2)).data,Xvalues(maxIndex(1)).Xs);
    %[Xvalues(maxIndex(3)).Ns,Xvalues(maxIndex(3)).Xs] = hist(Xvalues(maxIndex(3)).data,Xvalues(maxIndex(1)).Xs);
end
% if(length(others)>2)
% [Xvalues(others(3)).Ns,Xvalues(others(3)).Xs] = hist(Xvalues(others(3)).data,Xvalues(maxIndex).Xs);
% else
%     [Xvalues(maxIndex(2)).Ns,Xvalues(maxIndex(2)).Xs] = hist(Xvalues(maxIndex(2)).data,Xvalues(maxIndex(1)).Xs);
% end

alldata = [Xvalues(1).Ns./sum(Xvalues(1).Ns); Xvalues(2).Ns./sum(Xvalues(2).Ns); Xvalues(3).Ns./sum(Xvalues(3).Ns)]';



% if (X(bins) > X2(bins))
%     [N2,X2] = hist(data2,X);
%     alldata = [N./sum(N); N2./sum(N2)]';
% else
%     [N,X] = hist(data1,X2);
%      alldata = [N./sum(N); N2./sum(N2)]';
% end
%     
bar(alldata,1.5);
%percentileHist(data1,bins); hold on; percentileHist(data2,X);
children = get(gca, 'Children');
set(children(1),'XData', X);
set(children(2),'XData', X);
set(children(3),'XData', X);
%set(children(4),'XData', X/60);

legend(Name1,Name2,Name3)
xlabel('speed')
ylabel('fraction of events')
% xlabel('state duration (min)')
% ylabel('fraction of events')
end