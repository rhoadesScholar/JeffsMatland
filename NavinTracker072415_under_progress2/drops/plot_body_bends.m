function plot_body_bends(BodyBends, Tracks, localpath, FilePrefix, stimulus)

if(nargin<5)
    stimulus=[];
end

subplot(length(Tracks)+2,1,1);
ymin = 0; ymax = max(BodyBends.liquid_omega_freq); 
stimulusShade(stimulus, ymin, ymax);  hold on;
plot(BodyBends.liquid_omega_freqtime, BodyBends.liquid_omega_freq,'.-r');
xlabel('Time (sec)');
ylabel('omega freq (/sec)');
axis([BodyBends.time(1) BodyBends.time(end) ymin ymax]);

subplot(length(Tracks)+2,1,2);
ymin = 0; ymax = max(BodyBends.mean_body_bends_per_sec); 
stimulusShade(stimulus, ymin, ymax);  hold on;
plot(BodyBends.time, BodyBends.mean_body_bends_per_sec);
xlabel('Time (sec)');
ylabel('mean Body bends (/sec)');
axis([BodyBends.time(1) BodyBends.time(end) ymin ymax]);


for(i=1:length(Tracks))
    subplot(length(Tracks)+2,1,i+2);
    ymin = 0; ymax = max(Tracks(i).body_bends_per_sec); 
    stimulusShade(stimulus, ymin, ymax); hold on;
    plot(Tracks(i).Time, Tracks(i).body_bends_per_sec);
    hold on
    omega_init_idx = find(Tracks(i).liquid_omega_init>0);
    plot(Tracks(i).Time(omega_init_idx), Tracks(i).liquid_omega_init(omega_init_idx)*(max(Tracks(i).body_bends_per_sec)),'*r','markersize',10); 
    title(sprintf('Track %d',i));
    xlabel('Time (sec)');
    ylabel('Body bends (/sec)');
    axis([BodyBends.time(1) BodyBends.time(end) ymin ymax]);
end

if(~isempty(FilePrefix))
    FileName = sprintf('%s.BodyBends.pdf',FilePrefix);
    if(isempty(localpath))
        dummystring = sprintf('%s',FileName);
    else
        dummystring = sprintf('%s%s%s',localpath,filesep,FileName);
    end
    save_pdf(gcf,dummystring);
end

return;
end
