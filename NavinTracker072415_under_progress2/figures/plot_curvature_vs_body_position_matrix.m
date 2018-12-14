function plot_curvature_vs_body_position_matrix(curvature_vs_body_position_matrix, Frames)

global Prefs;

if(nargin<2)
    Frames=[];
end

if(isempty(Frames))
    Frames = 1:size(curvature_vs_body_position_matrix,2);
end

colormap(blue_red_colormap);
if(Frames(1)>1)
    im_curvature_vs_body_position_matrix = zeros(size(curvature_vs_body_position_matrix,1), Frames(1)-1);
    im_curvature_vs_body_position_matrix = [im_curvature_vs_body_position_matrix curvature_vs_body_position_matrix];
else
    im_curvature_vs_body_position_matrix = curvature_vs_body_position_matrix;
end

im_curvature_vs_body_position_matrix = matrix_replace(im_curvature_vs_body_position_matrix,'==',NaN,0);


%if(curvature_flag==0)
imagesc(im_curvature_vs_body_position_matrix,[-45 45]);
%else
%    imagesc(im_curvature_vs_body_position_matrix,[-5 5]);
%end

axis xy;
set(gca,'TickLength',[0 0]);
%set(gca,'ytick',[]);
xlim([Frames(1) Frames(end)]);
xlabel('Frame number');

ylim([1 Prefs.num_contour_points])

set(gca,'ytick',[1 Prefs.num_contour_points]);
set(gca,'yticklabel',{'A','P'});

clear('im_curvature_vs_body_position_matrix');

return;
end
