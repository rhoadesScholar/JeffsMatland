function [freq_spectrum, max_amplitude] = characteristic_freq_sliding_window(signal, windowsize)

HalfWinSize = floor(windowsize/2);

freq_spectrum = []; max_amplitude = [];
for(i=1:HalfWinSize)
    freq_spectrum = [freq_spectrum characteristic_frequency(signal, 1, i+HalfWinSize)];
    max_amplitude = [max_amplitude (max(abs(signal(1:i+HalfWinSize))))];
end

for(i=HalfWinSize+1:length(signal)-HalfWinSize)
    freq_spectrum = [freq_spectrum characteristic_frequency(signal, i-HalfWinSize, i+HalfWinSize)];
    max_amplitude = [max_amplitude (max(abs(signal(i-HalfWinSize:i+HalfWinSize))))];
end

for(i=length(signal)-HalfWinSize+1:length(signal))
    freq_spectrum = [freq_spectrum characteristic_frequency(signal, i-HalfWinSize, length(signal))];
    max_amplitude = [max_amplitude (max(abs(signal(i-HalfWinSize: length(signal)))))];
end

return;
end
