function plotSpeedAngSpeed(finalTracks,TrackNumber)
    NumFrames = length(finalTracks(TrackNumber).AngSpeed);
    %NumFrames = finalTracks(TrackNumber).NumFrames;
        xaxis_1 = 1:1:NumFrames;
        xaxis_2 = xaxis_1/180;
    ax = plotyy(xaxis_2,finalTracks(TrackNumber).AngSpeed,xaxis_2,finalTracks(TrackNumber).Speed);
    axis(ax(1),[0 90 -500 200]);
    axis(ax(2),[0 90 0 .3]);
    %axis([0 6 -500 200]);
    xlabel('time (min)');
    ylabel('Angular Speed (deg/sec)');
end