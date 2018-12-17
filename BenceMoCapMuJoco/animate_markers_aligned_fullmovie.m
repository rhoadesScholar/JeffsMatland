function M = animate_markers_aligned_fullmovie(mocapstruct,frame_inds,fighand)
%matlab_fr = 10;
if nargin<3
    h=figure(370)
else
    h=fighand;
end
% frame_inds = time_ordering_fulltrace{jjj}(1:matlab_fr:min(frames_use,numel(time_ordering_fulltrace{jjj})));

%M{jjj} = movie;
%Mhere = movie;
frame_last = 0;

marker_plot = ones(1,numel(mocapstruct.markernames));


%% initialize the figure
    set(h,'Color','k')
%     plot3( squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{1})(1,1)),...
%         squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{1})(1,2)),...
%         squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{1})(1,3)),'o','Color',mocapstruct.markercolor{1},'MarkerFaceColor',mocapstruct.markercolor{1},'MarkerSize',6)
%    
    
xx = squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{1})(1,1));
yy = squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{1})(1,2));
zz = squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{1})(1,3));
line(xx,yy,zz,'Marker','o','Color',mocapstruct.markercolor{1},'MarkerFaceColor',mocapstruct.markercolor{1},'MarkerSize',6);

    
    ax = gca;
    axis(ax,'manual')
    set(gca,'Color','k')
    grid on;
    set(gca,'Xcolor',[1 1 1 ]);
    set(gca,'Ycolor',[1 1 1]);
    set(gca,'Zcolor',[1 1 1]);
    
    zlim([-110 120])
    xlim([-120 120])
    ylim([-120 120])
    set(gca,'XTickLabels',[],'YTickLabels',[],'ZTickLabels',[])
        view([-22, 12]);

        base_time = datenum(mocapstruct.mocapfiletimes{1});

        
       % datestr(datenum(mocapstruct_social.mocapfiletimes{1})+300./(300*60*60*24))
for lk = reshape(frame_inds,1,[])%1:10:10000
     cla;
    
  %  set(handles.t4,'String',num2str(lk));
    
 mocapstruct.links{20} = [];
        mocapstruct.links{22} = [];
 %mocapstruct.links{13} = [6 8];
 %mocapstruct.markercolor{7} = 'r';
  %mocapstruct.markercolor{8} = 'r';
  
    
    ind_to_plot = lk;

    %% Plot markers that are tracked in the frame
  set(gca,'Nextplot','ReplaceChildren');
    handles_here = cell(1,numel(mocapstruct.markernames));
    for jj = 1:numel(mocapstruct.markernames)
        % don't plot markers that drop out
        if ~isnan(sum(mocapstruct.markers_preproc.(mocapstruct.markernames{jj})(ind_to_plot,:),2))
        if (~sum(mocapstruct.markers_preproc.(mocapstruct.markernames{jj})(ind_to_plot,:),2) == 0)      
            xx = squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{jj})(ind_to_plot,1));
                yy = squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{jj})(ind_to_plot,2));
                zz = squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{jj})(ind_to_plot,3));
                handles_here{jj} = line(xx,yy,zz,'Marker','o','Color',mocapstruct.markercolor{jj},'MarkerFaceColor',mocapstruct.markercolor{jj},'MarkerSize',9);
                
                
            
            hold on
            marker_plot(jj) = 1;
        else
            marker_plot(jj) = 0;
        end
        
        end
    end
   
  %% plot the links between markers
  for mm = 1:numel(mocapstruct.links)
      if numel(mocapstruct.links{mm})
          if (ismember(mocapstruct.links{mm}(1),1:numel(mocapstruct.markernames)) && ismember(mocapstruct.links{mm}(2),1:numel(mocapstruct.markernames)))
              if (marker_plot(mocapstruct.links{mm}(1)) == 1 && marker_plot(mocapstruct.links{mm}(2)) == 1)
                  
                  xx = [squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{mocapstruct.links{mm}(1)})(ind_to_plot,1)) ...
                      squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{mocapstruct.links{mm}(2)})(ind_to_plot,1)) ];
                  yy = [squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{mocapstruct.links{mm}(1)})(ind_to_plot,2)) ...
                      squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{mocapstruct.links{mm}(2)})(ind_to_plot,2))];
                  zz = [squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{mocapstruct.links{mm}(1)})(ind_to_plot,3)) ...
                      squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{mocapstruct.links{mm}(2)})(ind_to_plot,3))];
                  line(xx,yy,zz,'Color',mocapstruct.markercolor{mocapstruct.links{mm}(1)},'LineWidth',3);
              end
              
          end
      end
  end
%   
%   trios = {[1,2,3],[4,5,7],[5,6,8],[5,7,8]};
%   for nn = 1:numel(trios)
%   xx_mat = cell(1,3);
%   for kk = 1:3
%         xx_mat{kk} = [squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{trios{nn}(1)})(ind_to_plot,kk)) ...
%                       squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{trios{nn}(2)})(ind_to_plot,kk)) ...
%                       squeeze(mocapstruct.markers_aligned_preproc.(mocapstruct.markernames{trios{nn}(3)})(ind_to_plot,kk))];
%   end
%              patch('XData',xx_mat{1},'YData',xx_mat{2},'ZData',xx_mat{3},...
%                  'FaceColor',mocapstruct.markercolor{trios{nn}(1)},'EdgeColor',mocapstruct.markercolor{trios{nn}(1)})
%   end
                 
    
       % title(strcat('  Frame: ' ,datestr(base_time+lk./(mocapstruct.fps*60*60*24))),'Color','w')
    
    
    drawnow 
    hold off
  
    frame_last = lk;
    
        M(find(frame_inds == lk)) =  getframe(gcf);

    %clf
end
%set(gca,'Nextplot','add');

end