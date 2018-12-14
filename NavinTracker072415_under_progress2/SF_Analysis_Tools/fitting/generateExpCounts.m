function [h,p,st] = generateExpCounts(data1,data2) 
    bins = 10;
    bins2 = 0:9
    [N,X] = hist(data1,bins);
[N2,X2] = hist(data2,bins);
if (X(bins) > X2(bins))
    [N2,X2] = hist(data2,X);
    alldata = [N./sum(N); N2./sum(N2)]';
else
    [N,X] = hist(data1,X2);
     alldata = [N./sum(N); N2./sum(N2)]';
end

[h,p,st] = chi2gof(bins2,'ctrs',bins2,...
                        'frequency',N, ...
                        'expected',N2)
                       
end