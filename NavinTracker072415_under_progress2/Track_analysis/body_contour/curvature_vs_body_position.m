function [curvature_vs_body_position_matrix, kappa_midbody] = curvature_vs_body_position(inputTrack, firstframe_idx, lastframe_idx)
% [curvature_vs_body_position_matrix, kappa_midbody] = curvature_vs_body_position(Track)

global Prefs;


if(nargin<3)
    Track = inputTrack;
else
    Track = extract_track_segment(inputTrack, firstframe_idx, lastframe_idx);
end

num_contour_points = Prefs.num_contour_points+2;

% if(nargin<3)
%     curvature_flag=0; % if 1, use curvature, else angles
% end

if(~isfield(Track, 'body_contour'))
    curvature_vs_body_position_matrix = zeros(Prefs.num_contour_points, length(Track.Frames))+NaN;
    kappa_midbody = zeros(1,length(Track.Frames))+NaN;
    return
end

if(isfield(Track.body_contour, 'kappa'))
    [curvature_vs_body_position_matrix, kappa_midbody] = curvature_vs_body_position_matrix_from_body_contour_array(Track.body_contour);
    return
end


body_contour_array = Track.body_contour;

curvature_vs_body_position_matrix(num_contour_points,length(body_contour_array)) = 0;
curvature_vs_body_position_matrix = curvature_vs_body_position_matrix + NaN;

for(i=1:length(body_contour_array))
    
    if(body_contour_array(i).head>0 && length(body_contour_array(i).x)>5)
        
        x = smooth(body_contour_array(i).x);
        y = smooth(body_contour_array(i).y);
        
        % spline to add more points to contour
        t = 1:length(x);
        ts = 1:(length(x)/(num_contour_points-1)):(length(x)+1);
        if(ts(end)<length(x))
            ts = [ts length(x)];
        end
        xx = (spline(t,x,ts));
        yy = (spline(t,y,ts));
        
%         if(curvature_flag==0)
            % angle at each contour point
            kappa = zeros(1,length(xx))+NaN;
            for(k=2:length(xx)-1)
                kappa(k) = ((180/pi)*atan2(-(yy(k-1)-yy(k)),(xx(k-1)-xx(k))));
            end
            dkappa = abs([NaN diff(kappa)]);
            jump_idx = find((dkappa)>=90);
            original_jump_len = length(jump_idx);
            ctr=0;
            while(~isempty(jump_idx))
                idx = jump_idx(1);
                if(idx>1)
                    if(kappa(idx-1)>0)
                        kappa(idx) = kappa(idx) + 360;
                    else
                        kappa(idx) = -360 + kappa(idx);
                    end
                end
                dkappa = abs([NaN diff(kappa)]);
                jump_idx = find((dkappa)>=90);
                ctr = ctr + 1;
                if(ctr>1000*original_jump_len)
                    break;
                end
            end
            kappa(find(kappa>360)) = 360;
            kappa(find(kappa<-360)) = -360;
            kappa = kappa - nanmedian(kappa);
            kappa(find(kappa>90)) = 90;
            kappa(find(kappa<-90)) = -90;
%         else
%             % curvature
%             % derivatives at each point
%             xp = smooth([0; diff(xx)']);
%             yp = smooth([0; diff(yy)']);
%             xpp = smooth([0; diff(xp)]);
%             ypp = smooth([0; diff(yp)]);
%             kappa = (xp.*ypp)-(yp.*xpp) ./ (xp .^2 + yp .^2) .^ (3/2);
%             kappa(find(kappa>0.5)) = 0.5;
%             kappa(find(kappa<-0.5)) = -0.5;
%             kappa(find(isnan(kappa))) = 0;
%             kappa = kappa/Track.PixelSize; % kappa is kappa = 1/pixel; convert to 1/mm
%         end
        
        curvature_vs_body_position_matrix(:,i) = kappa;
        
        
%                     subplot(1,2,1);
%                     imshow(Track.Image{i});
%                     hold on
%                     plot(body_contour_array(i).x-Track.bound_box_corner(i,1), body_contour_array(i).y-Track.bound_box_corner(i,2),'ob');
%                     plot(xx-Track.bound_box_corner(i,1), yy-Track.bound_box_corner(i,2),'.-g');
%         
%                     if(body_contour_array(i).head>0)
%                         plot(body_contour_array(i).x(body_contour_array(i).head)-Track.bound_box_corner(i,1), ...
%                             body_contour_array(i).y(body_contour_array(i).head)-Track.bound_box_corner(i,2),'*m','markersize',20);
%         
%         
%                         plot(body_contour_array(i).x(body_contour_array(i).neck)-Track.bound_box_corner(i,1), ...
%                             body_contour_array(i).y(body_contour_array(i).neck)-Track.bound_box_corner(i,2),'*c','markersize',20);
%         
%         
%                         plot(body_contour_array(i).x(body_contour_array(i).midbody)-Track.bound_box_corner(i,1), ...
%                             body_contour_array(i).y(body_contour_array(i).midbody)-Track.bound_box_corner(i,2),'*k','markersize',20);
%                     end
%         
%                     hold off
%                     subplot(1,2,2);
%                     % plot(ts/length(x), kappa,'.-'); xlim([0 1])
%                     plot((1/length(kappa)):(1/length(kappa)):1, kappa,'.-'); xlim([0 1]); ylim([-180 180])
%                     [i Track.Direction(i) Track.State(i)]
%                     pause(0.1)
       
        
        
    end
end

curvature_vs_body_position_matrix = matrix_replace(curvature_vs_body_position_matrix,'==',NaN,0); 
curvature_vs_body_position_matrix(1,:)=[]; 
curvature_vs_body_position_matrix(end,:)=[]; 

kappa_midbody = curvature_vs_body_position_matrix(round(num_contour_points/2),:);

% kappa_mean = [];
% for(i=2:18)
%     [tim, target_timeseries, source_timeseries] = align_timeseries(Track.Frames, kappa_midbody, curvature_vs_body_position_matrix(i,:));
%     kappa_mean = [kappa_mean; source_timeseries];
% end
% kappa_mean = nanmean(kappa_mean);
% idx = find(~isnan(tim));
% kappa_mean = kappa_mean(idx);

return;
end


function [curvature_vs_body_position_matrix, kappa_midbody] = curvature_vs_body_position_matrix_from_body_contour_array(body_contour_array)

global Prefs;

curvature_vs_body_position_matrix = zeros(Prefs.num_contour_points, length(body_contour_array))+NaN;
for(i=1:length(body_contour_array))
    if(~isempty(body_contour_array(i).kappa))
        curvature_vs_body_position_matrix(:,i) = body_contour_array(i).kappa;
    end
end
kappa_midbody = curvature_vs_body_position_matrix(round(Prefs.num_contour_points/2),:);

return;
end

