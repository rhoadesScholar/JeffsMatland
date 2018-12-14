function percentileHist(data,binNum)
[N, X] = hist(data,binNum);

plot(X, N./sum(N));

end