function char_freq = characteristic_frequency(signal, start_idx, end_idx)
% char_freq = characteristic_frequency(signal, start_idx, end_idx)
% takes the fourier transform of signal and returns the highest power
% frequency

if(nargin<2)
    start_idx = 1;
end

if(nargin<3)
    end_idx = length(signal);
end

if(start_idx<1)
    start_idx=1;
end
if(end_idx>length(signal))
    end_idx=length(signal);
end

local_signal = signal(start_idx:end_idx);
Y = fft(local_signal);
Y(1)=[];
n=length(Y);
power = abs(Y(1:floor(n/2))).^2;
freq = ((1:n/2)/(n/2)*(1/2));
[~,idx] = max(power);
char_freq = freq(idx(1));

return;
end

