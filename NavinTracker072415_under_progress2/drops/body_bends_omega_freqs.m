function BodyBends = body_bends_omega_freqs(Tracks, localpath, FilePrefix)
% BodyBends = body_bends_omega_freqs(Tracks, localpath, FilePrefix)
% if isempty(FilePrefix), then don't save here

global Prefs;

if(nargin<3)
    localpath = '';
    FilePrefix = '';
end

body_bends_time = min_struct_array(Tracks,'Time'):1/Prefs.FrameRate:max_struct_array(Tracks,'Time'); % nanmean(Track_field_to_matrix(Tracks,'Time'));

liquid_omega_init_freq = nanmean(Track_field_to_matrix(Tracks,'liquid_omega_init'))/(1/Prefs.FrameRate);
liquid_omega_freqtime = (body_bends_time(1)+Prefs.FreqBinSize)/2:Prefs.FreqBinSize:body_bends_time(end);
liquid_omega_freq = [];
for(t=1:length(liquid_omega_freqtime)-1)
    idx = find(body_bends_time >= liquid_omega_freqtime(t) & body_bends_time < liquid_omega_freqtime(t+1));
    liquid_omega_freq(t) = nanmean(liquid_omega_init_freq(idx));
end
liquid_omega_freq(length(liquid_omega_freqtime)) = NaN;

mean_body_bends_per_sec = nanmean(Track_field_to_matrix(Tracks,'body_bends_per_sec'));

BodyBends.time = body_bends_time;
BodyBends.liquid_omega_freqtime = liquid_omega_freqtime;
BodyBends.mean_body_bends_per_sec = mean_body_bends_per_sec;
BodyBends.liquid_omega_freq = liquid_omega_freq;
BodyBends = make_single(BodyBends);

if(~isempty(FilePrefix))
    FileName = sprintf('%s.BodyBends.mat',FilePrefix);
    dummystring = sprintf('%s%s',localpath,FileName);
    save(dummystring,'BodyBends');
end

return;
end
