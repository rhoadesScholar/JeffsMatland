function [max_freq, freq, power] = Tracks_fft(Tracks,field, starttime, endtime)

if(nargin<4)
    starttime = Tracks.Time(1);
    endtime = Tracks.Time(end);
end

index = find(Tracks.Time >= starttime  &  Tracks.Time <= endtime & (~isnan(Tracks.(field))));
binwidth = nanmean(diff(Tracks.Time));

Y = fft(Tracks.(field)(index));
n = length(Y);
Y(1) = 0; % Y(1) is simply the sum of the values

power = abs(Y(1:n/2)).^2; % power
period = binwidth*(1./((1:n/2)/(n/2)*(1/2)));
freq = 1./period;

% % plot(freq,power);
% semilogx(freq,power);
% dummystring = fix_title_string(sprintf('%s power',field));
% ylabel(dummystring);
% xlabel('freq (Hz)');

max_power_idx = find(power == max(power));
max_freq = freq(max_power_idx);

end
