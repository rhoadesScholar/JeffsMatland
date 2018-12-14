function [powerx,freqx]=power_spectrum_fun(X,fs,plotrefbool)

if plotrefbool
    xx = 1:540; yy = sin(2*pi*xx/fs);
    [power1,freq1]=periodogram(yy,[],[],fs);
    figure;hold all;
    plot(freq1,power1/sum(power1),'color',.5*ones(1,3),'linewidth',1.5)
end

X=X(:)-smooth(X,20);X=X-mean(X);
[powerx,freqx]=periodogram(X,[],[],fs);

plot(freqx,powerx/sum(powerx),'linewidth',1.5)
return
end