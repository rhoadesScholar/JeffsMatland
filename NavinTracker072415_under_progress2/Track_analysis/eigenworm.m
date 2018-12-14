% function eigenworm(linkedTracks)
% eigenworm(linkedTracks)

%linkedTracks = lt;

global Prefs; Prefs = []; Prefs = define_preferences(Prefs); Prefs.ignoreRingFlag = 1;

x = ls('*.linkedTracks.mat');
ltt = [];
for(i=1:size(x,1))
    i
   p = sort_tracks_by_pathlength(load_Tracks(x(i,:)));
   for(j=1:min(100, length(p)))
      ltt = [ltt p(j)]; 
   end
   clear('p');
end
ltt = sort_tracks_by_pathlength(ltt);
save('ltt','ltt');


% 
% % load('lt.mat');
% 
% lt = sort_tracks_by_length(lt);
% num_tracks = 250;
% for(i=1:num_tracks)
%     i
%     temp_tr = lt(i);
%     % recalc body contour
%     for(j=1:length(temp_tr.Image))
%         temp_tr.body_contour(j) = body_contour_from_image(temp_tr.Image{j}, temp_tr.bound_box_corner(j,:));
%     end
%     temp_tr = AnalyseTrack(temp_tr);
%     
%     ltt(i) = temp_tr;
%     clear('temp_tr');
% end
% save('ltt','ltt');

% load('ltt.mat')

% clear('big_angle_matrix');
% clear('col_sum');
% clear('covm');
% clear('cum_eigenval');
% clear('eig_val');
% clear('eig_vec');
% clear('i');
% clear('idx');
% clear('k');        
% clear('m');
% clear('matr');
% clear('s');
% clear('state_vector');

num_tracks = length(ltt);

big_angle_matrix = [];
for(i=1:num_tracks)
    disp([i])
    big_angle_matrix = [big_angle_matrix ltt(i).curvature_vs_body_position_matrix'];
end
save('big_angle_matrix','big_angle_matrix');


theta_vector = [];
for(i=1:num_tracks)
    disp([i])
    theta_vector = [theta_vector ltt(i).Direction];
end
save('theta_vector','theta_vector');

% filtered
% big_angle_matrix = [];
% for(i=1:num_tracks)
% disp([i])
%     state_vector = ltt(i).State;
%     
%     idx = find(abs(state_vector-num_state_convert('pause'))<1e-4);
%     state_vector(idx)=0;
% %     state_vector = floor(state_vector);
% %     idx = find(state_vector==num_state_convert('omega'));
% %     state_vector(idx)=0;
% %     idx = find(state_vector==num_state_convert('upsilon'));
% %     state_vector(idx)=0;
% %     idx = find(state_vector==num_state_convert('lRev'));
% %     state_vector(idx)=0;
% %     idx = find(state_vector==num_state_convert('sRev'));
% %     state_vector(idx)=0;
%     
%     idx = find(state_vector>0);
%     state_vector(idx)=1;
%     
%     matr = ltt(i).curvature_vs_body_position_matrix';
%     for(k=1:length(state_vector))
%         matr(:,k) = state_vector(k)*matr(:,k);
%     end
%     
%     big_angle_matrix = [big_angle_matrix matr];
% end


% purge all-zero columns from big_angle_matrix
col_sum = nansum(big_angle_matrix);
bAm = big_angle_matrix;
bAm(:,find(col_sum==0)) = [];
theta_vector(find(col_sum==0))=[];


% matrix m is now rows x columns image_number x angles

m = bAm';
clear('bAm');
[eig_vec, eig_val] = eigenvector_data_matrix(m);

rand_idx = randint(size(m,2),size(m,2),'unique');
rand_m = m(:,rand_idx);
[rand_eig_vec, rand_eig_val] = eigenvector_data_matrix(rand_m);

s = 1/length(eig_val):1/length(eig_val):1;

figure(1);
for(i=1:6)
    subplot(2,3,i);
    plot(s, eig_vec(:,i)); ylim([-0.5 0.5]);
    text(0.1,0.5, num2str(i),'fontsize',12,'verticalalign','top','horizontalalign','left');
    box off
end
set(gcf,'color','w');

figure(2);
cum_eigenval=[]; rand_cum_eigenval=[];
for(i=1:length(eig_val))
    if(i>1)
        cum_eigenval(i) = cum_eigenval(i-1) + eig_val(i);
        rand_cum_eigenval(i) = rand_cum_eigenval(i-1) + rand_eig_val(i);
    else
        cum_eigenval(i) = eig_val(i);
        rand_cum_eigenval(i) = rand_eig_val(i);
    end
end
plot(1:length(eig_val), cum_eigenval, 'o');
hold on;
plot(1:length(rand_eig_val), rand_cum_eigenval, '.k');
box off
ylim([0 1]); xlim([0 12]);
ylabel('Fraction of variance');
xlabel('Eigenworm number');
set(gcf,'color','w');

save_pdf(1,'all_eigenworms');
save('eigen_all.mat', 'eig_val', 'eig_vec');


for(k=1:size(m,1))
    angle_vs_s_vector = m(k,:);
    w=[];
    for(i=1:6)
        w(i) = dot(eig_vec(:,i)',angle_vs_s_vector);
    end
    
    figure(6);
    plot(s, angle_vs_s_vector, '.b'); % ,'linewidth',3);
    hold on;
    newsum =  zeros(1,length(s));
    for(i=1:6)
        newsum = newsum + w(i)*eig_vec(:,i)';
    end
    plot(s, newsum,'r','linewidth',2); ylim([-90 90]);
    hold off;
    pause;
    
end
%result = hist2(a, b, min(a):0.1:max(a), min(b):0.1:max(b)); figure(1); imagesc(result); figure(2); imagesc(log(result));



% return;
% end

w_matrix = []; for(i=1:length(ltt)) w_matrix = [w_matrix Track_to_eigenworm_weights(ltt(i))]; end
k=1; for(i=1:6) for(j=1:6) if(j>i) subplot(6,6,k); imagesc((hist2(w_matrix(i,:),w_matrix(j,:), -1:0.05:1, -1:0.05:1))); end; k=k+1; end; end;
 for(i=1:100) w = Track_to_eigenworm_weights(ltt(i)); subplot(2,1,1); plot(ltt(i).Frames(1:end), (circ_rad2ang(atan2(w(2,:),w(1,:)))));  xlim([ltt(i).Frames(1) ltt(i).Frames(300)]); hold off; subplot(2,1,2); single_Track_ethogram(extract_track_segment(ltt(i),1,300)); pause; end







