function M = animate_skeleton(limbposition,frame_inds,limbnames,limbstart,clustnum)

h=  figure(370)
set(h,'Color','k')
mm = 1;
kk = 1;
plot3( [squeeze(limbposition.(limbnames{kk})(1,1,mm)) ...
    squeeze(limbposition.(limbnames{kk})(1,2,mm)) ],...
    [squeeze(limbposition.(limbnames{kk})(2,1,mm)) ...
    squeeze(limbposition.(limbnames{kk})(2,2,mm)) ],...
    [squeeze(limbposition.(limbnames{kk})(3,1,mm)) ...
    squeeze(limbposition.(limbnames{kk})(3,2,mm)) ],'linewidth',3)
grid on
ax = gca;
axis(ax,'manual')
set(gca,'Color','k')
grid on;
set(gca,'Xcolor',[1 1 1]);
set(gca,'Ycolor',[1 1 1]);
set(gca,'Zcolor',[1 1 1]);


   
    zlim([0 250])
    xlim([-350 350])
    ylim([-350 350])
    set(gca,'XTickLabels',[],'YTickLabels',[],'ZTickLabels',[])


%% visualize skeleton

for lk = frame_inds%1:10:10000
    
    
    ind_to_plot = lk;
    
    set(gca,'Nextplot','ReplaceChildren');

    
   for kk = limbstart:numel(limbnames)
        plot3( [squeeze(limbposition.(limbnames{kk})(1,1,ind_to_plot)) ...
            squeeze(limbposition.(limbnames{kk})(1,2,ind_to_plot)) ],...
            [squeeze(limbposition.(limbnames{kk})(2,1,ind_to_plot)) ...
            squeeze(limbposition.(limbnames{kk})(2,2,ind_to_plot)) ],...
            [squeeze(limbposition.(limbnames{kk})(3,1,ind_to_plot)) ...
            squeeze(limbposition.(limbnames{kk})(3,2,ind_to_plot)) ],'linewidth',3)
        hold on
    end
    
    %delete
    M(find(frame_inds == lk)) = getframe(gcf);
    
    
    drawnow
    hold off
    
    if (clustnum)
        title(strcat('Cluster number: ',num2str(clustnum),'  Frame: ' ,num2str(lk)),'Color','w')
    else
        title(strcat('Frame: ' ,num2str(lk)),'Color','w')
    end
    
end
set(gca,'Nextplot','add');

end