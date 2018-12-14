function addStimPlot(speed, cal, stim, refed)
%     fig = gcf;
%     t = fig.UserData;
    pre = find(refed == 1,1) - 1;
    post = length(refed) - pre - 1;
    t = [-pre:post]/10;%t in seconds, for 10Hz framerate
    if max(xlim) <= 20
        t = t/60;%t in minutes
    end
    
    yyaxis left
    plot(t, cal, 'Color', 'k')
%     refeed = find(t==0);
%     plot(t(refeed:refeed+length(stim)-1), stim, 'Color', 'r');
    
    yyaxis right
    plot(t, speed, 'Color', 'k');

end