function [freq, power] = spectrum_timeseries(s)

Y = fft(s);
Y(1)=[]; % sum of data

n=length(Y);
power = abs(Y(1:floor(n/2))).^2;
nyquist = 1/2;
freq = ((1:n/2)/(n/2)*nyquist);


plot(freq,power)
ylabel('Power')
xlabel('Frequency')

return;
end
