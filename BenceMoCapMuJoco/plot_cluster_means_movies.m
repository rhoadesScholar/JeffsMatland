function plot_cluster_means_movies(savedirectory_subcluster,cluster_struct,modular_cluster_properties,cluster_here,markers_preproc,do_movies,mocapstruct,do_cluster_plots) 

 
    cluster_size = zeros(1,cluster_struct.num_clusters);

    for ll = 1:cluster_struct.num_clusters
        %% ordering of the spectrogram
      %  fprintf('cluster %f \n',ll)
       % time_ordering = cat(1,time_ordering,find(cluster_objects{mmm}==ll));
       % cluster_vals = cat(1,cluster_vals,ll*ones(numel(find(cluster_objects{mmm}==ll)),1));
        cluster_size(ll) = numel(find(cluster_struct.labels==ll));
    end
    
    good_clusters = find(cluster_size>=1000);%intersect(find(cluster_size<25),find(cluster_size>=10)); %,
    
    frames_use_anim = 300;
 
    
    save_tags_temp = (num2str(good_clusters'));
    for kk =1:numel(good_clusters)
        save_tags{kk} = save_tags_temp(kk,:);
    end
    
   
    feature_mu_reshape = reshape(cluster_struct.feature_mu,size(cluster_struct.feature_mu,1),numel(cluster_struct.fr),[]);
    
    x_ind = size(feature_mu_reshape,2);
    y_ind = size(feature_mu_reshape,3);
    
    xcorr_features = zeros(numel(good_clusters),numel(good_clusters));
    euc_features = zeros(numel(good_clusters),numel(good_clusters));
    wave_features = zeros(numel(good_clusters),numel(good_clusters));
    mean_wave = zeros(max(good_clusters),size(cluster_struct.wtAll,2));
    for lkl = 1:max(good_clusters)
        mean_wave(lkl,:) = mean(cluster_struct.wtAll(find(cluster_struct.labels==lkl),:),1);
    end
    
    
    for jjj = good_clusters(1:end);
        for mkm = good_clusters(find(good_clusters == jjj):end)
            corr_c = xcorr2(squeeze(feature_mu_reshape(jjj,:,:)),squeeze(feature_mu_reshape(mkm,:,:)));
            xcorr_features(jjj,mkm) = corr_c(x_ind,y_ind);
            euc_features(jjj,mkm) = pdist2(cluster_struct.feature_mu(jjj,:),cluster_struct.feature_mu(mkm,:),'correlation');
            
            wave_features(jjj,mkm)  = pdist2(mean_wave(jjj,:),...
                mean_wave(mkm,:),'correlation');
        end
    end
    xcorr_t = xcorr_features';
    xcorr_features(find(tril(ones(size( xcorr_features)),0))) = xcorr_t(find(tril(ones(size( xcorr_features)),0)));
    
    euc_t = euc_features';
    euc_features(find(tril(ones(size( euc_features)),0))) = euc_t(find(tril(ones(size(euc_features)),0)));
    
    wave_t = wave_features';
    wave_features(find(tril(ones(size( wave_features)),0))) = wave_t(find(tril(ones(size( xcorr_features)),0)));
    %

    [idx,C,sumd,D] = kmeans(cluster_struct.feature_mu(good_clusters,:),min(12,numel(good_clusters)),'distance','correlation');
    % [idx,C,sumd,D] = kmeans( mean_wave(good_clusters,:),12,'distance','correlation');
    
    [vals,inds] = sort(idx,'ASCEND');
    
    
    figure(371)
    imagesc(xcorr_features(good_clusters(inds),good_clusters(inds)))
    caxis([-10 10])
    print('-depsc',strcat(savedirectory_subcluster,'xcorrclustered','.eps'))
    print('-dpng',strcat(savedirectory_subcluster,'xcorrclustered','.png'))
    
    figure(373)
    imagesc(euc_features(good_clusters(inds),good_clusters(inds)))
    caxis([0 3])
    print('-depsc',strcat(savedirectory_subcluster,'eucclustered','.eps'))
    print('-dpng',strcat(savedirectory_subcluster,'eucclustered','.png'))
    
    figure(372)
    imagesc(wave_features(good_clusters(inds),good_clusters(inds)))
    caxis([0 0.4])
    
    
    
    
    good_clusters_sorted=good_clusters(inds);
    
    
    
    %do_cluster_plots = 0;
    if (do_cluster_plots)
        
        for jjj =  good_clusters_sorted(1:end)%1:end);%58;%36;%good_clusters(1:end)
            
            
            save_ind = find(good_clusters_sorted(1:end)== jjj);
            
            figure(380)
            %subplot(1,2,1)
            
            uimagesc(1:size(feature_mu_reshape,3),cluster_struct.fr,squeeze(feature_mu_reshape(jjj,:,:)))
            set(gca,'XTick',1:3:3*size(feature_mu_reshape,3),'XTickLabels',cluster_struct.feature_labels);
            ylabel('frequency (Hz)')
            ylim([0 50])
                L = get(gca,'clim')
         %   caxis([L(1)./3 L(2)./3])
            xlabel('Marker')
            title('Feature weights')
            print('-depsc',strcat(savedirectory_subcluster,'coeffweightsfor',num2str(save_ind),'.eps'))
            print('-dpng',strcat(savedirectory_subcluster,'coeffweightsfor',num2str(save_ind),'.png'))
            
            
            %
            % figure(400)
            % %imagesc(squeeze(average_pose(2,:,:,jjj))./squeeze(average_pose(1,:,:,jjj)))
            % set(gca,'XTick',1:size(average_pose,2),'XTickLabels',marker_names);
            % set(gca,'YTick',1:size(average_pose,2),'YTickLabels',marker_names);
            % title('intermarker std./global std')
            
            
            
            figure(390)
            imagesc(cluster_struct.wtAll(find(cluster_struct.labels==jjj),:)')
           % caxis([0 0.1])
            set(gca,'YTick',1:3*numel(cluster_struct.fr):size(cluster_struct.wtAll,1),'YTickLabels',cluster_struct.feature_labels);
            xlabel('Time (frames at 100 fps)')
            title('Observed wavelet coeffs')
            L = get(gca,'clim')
          %  caxis([L(1)./3 L(2)./3])
            print('-depsc',strcat(savedirectory_subcluster,'coeffplotsfor',num2str(save_ind),'.eps'))
            print('-dpng',strcat(savedirectory_subcluster,'coeffplotsfor',num2str(save_ind),'.png'))
        end
        

        
        dH = designfilt('highpassiir', 'FilterOrder', 3, 'HalfPowerFrequency', 1/(mocapstruct.fps/2), ...
            'DesignMethod', 'butter');
        [f1,f2] = tf(dH);

        %    for mm = 1:size(abs_velocity_antialiased_hipass,1)
        %        abs_velocity_antialiased_hipass(mm,:)  = filtfilt(f1,f2,squeeze(marker_position(mm,:,3)));
        %    end
        
        for jjj =good_clusters_sorted(1)%:end)%1:end);%58;%36;%good_clusters(1:end)
            
            
            save_ind = find(good_clusters_sorted(1:end)== jjj);
            
            %label individual instances
            inst_label = zeros(1,numel(cluster_struct.clustering_ind));
            inst_label(cluster_struct.labels == jjj) = 1;
            pixellist = bwconncomp(inst_label);
            
            num_rand = 40;
            marker_align = 3;%cluster_markersets{mmm}(1);
            markers_to_plot = [3]%,5*3,find(cluster_markersets{mmm} == 17)*3];
            amt_extend_xcorr = 150; %in 3x downsample
            amt_extend_plot = 10;
            num_clust_sample = min(pixellist.NumObjects,  num_rand );
            
            if num_clust_sample
                rand_inds = randsample(1:pixellist.NumObjects,...
                    num_clust_sample);
                
                clust_ind_here = cell(1,num_clust_sample);
                trace_length_here = 2*amt_extend_xcorr*3+1;
                
                av_trace = zeros(1,trace_length_here);
                
                for lk =1:num_clust_sample
                    % clustmed = median(pixellist.PixelIdxList{rand_inds(lk)})
                    indexh = unique(bsxfun(@plus,floor(median(pixellist.PixelIdxList{rand_inds(lk)})),-amt_extend_xcorr:amt_extend_xcorr));
                    indexh(indexh<1) = 1;
                    indexh(  indexh>numel(cluster_struct.clustering_ind)) = numel(cluster_struct.clustering_ind);
                    indexh = unique(indexh);
                    clusterind = unique(cluster_struct.clustering_ind(indexh));
                    clust_ind_here{lk}  =clusterind;
                    % abs_velocity_antialiased
                    trace_add = modular_cluster_properties.agg_features{cluster_here}(marker_align,(clusterind(1):clusterind(end)) )./num_clust_sample;
                    
                    
                    av_trace(1:min(length(trace_add), trace_length_here)) = av_trace(1:min(length(trace_add), trace_length_here))...
                        +  trace_add(1:min(length(trace_add), trace_length_here))./num_clust_sample;
                end
                %  av_trace = av_trace+marker_velocity(marker_align,clusterind(1):clusterind(end) ,4)./num_clust_sample;
                
                
                for llll=1:2
                    av_trace = zeros(1,trace_length_here);
                    for lk =1:num_clust_sample
                        %[c,lags] =   xcorr(marker_velocity(marker_align,clust_ind_here{lk}(1):clust_ind_here{lk}(end) ,4),av_trace,amt_extend_xcorr);
                        [c,lags] =   xcorr(modular_cluster_properties.agg_features{cluster_here}...
                            (marker_align,clust_ind_here{lk}(1):clust_ind_here{lk}(end) ),av_trace,amt_extend_xcorr);
                        
                        [~,ind] = max(c);
                        %   lags(ind) = 0;
                        ind
                        clust_ind_here{lk} = bsxfun(@plus,clust_ind_here{lk}, lags(ind));
                        % av_trace = av_trace+marker_velocity(marker_align,clust_ind_here{lk}(1):clust_ind_here{lk}(end) ,4);
                        av_trace(1:min(length(trace_add), trace_length_here)) = av_trace(1:min(length(trace_add), trace_length_here))+...
                            trace_add(1:min(length(trace_add), trace_length_here))./num_clust_sample;
                        
                    end
                end
                
                
                y_gap = 3;
                for mm = 1:numel(markers_to_plot)
                    figure(500+mm)
                    velocity_size = size(modular_cluster_properties.agg_features{cluster_here},2);
                    for lk =1:min(pixellist.NumObjects,num_rand)
                        % subplot(2,numel(markers_to_plot)./2,mm)
                        %   subplot(1,1,mm)
                        velocity_plot = y_gap*lk+modular_cluster_properties.agg_features{cluster_here}(   markers_to_plot(mm), max(1,(clust_ind_here{lk}(1)-amt_extend_plot)):...
                            min(velocity_size,clust_ind_here{lk}(end)+amt_extend_plot));
                        
                        %                        position_plot = marker_position(   markers_to_plot(mm), max(1,(clust_ind_here{lk}(1)-amt_extend_plot)):...
                        %                            min(velocity_size,clust_ind_here{lk}(end)+amt_extend_plot),3);
                        %                        position_plot = bsxfun(@minus,position_plot,mean(position_plot));
                        %
                        %    plot(marker_velocity(   markers_to_plot(mm), (clust_ind_here{lk}(1)-amt_extend_plot):(clust_ind_here{lk}(end)+amt_extend_plot)  ,4))
                        plot(velocity_plot )
                        
                        
                        hold on
                    end
                    title(mocapstruct.markernames{floor(markers_to_plot(mm)./3)})
                    box off
                    max_time_val = (clust_ind_here{lk}(end)+amt_extend_plot)-(clust_ind_here{lk}(1)-amt_extend_plot);
                    xtickshere = 1:25:max_time_val;
                    xlim([1 max_time_val])
                    set(gca,'XTick',xtickshere,'XTickLabel',num2str(floor(1000*xtickshere./300)'))
                    ylabel('Marker velocity (mm/frame)')
                    xlabel('Time (ms)')
                    Lhere =  get(gca,'ylim');
                    %    ylim([0 20])
                    ylim([-10 max(30,min(Lhere(2),120))])
                    hold off
                end
                print(strcat(savedirectory_subcluster,'timetraces',num2str(save_ind),'.pdf'),'-dpdf','-bestfit')
                print('-dpng',strcat(savedirectory_subcluster,'timetraces',num2str(save_ind),'.png'))
                
                %
                %                 figure(480)
                %             plot(markers_preproc.HeadF(clust_ind_here{lk}(1):clust_ind_here{lk}(end),3))
                %              hold on
                % %
                
            end
        end
        
        

%% feature comparison

% look at auto regression!!!
xdata = modular_cluster_properties.agg_features{cluster_here}(1:3,:); % this is just feature data for the head, shape [d x frames];

numplots2make = 15;

for group = good_clusters_sorted(1:end)

% plot all on top of each other
%group = 127;
groupind = find(cluster_struct.labels==group);
% get sequential runs
jumpind = find(diff(groupind) > 1); jumpind = [1 jumpind];

% plot x,y,z
h = figure(560+group); hold on;
for j = 1:length(jumpind)-1
    indrange = groupind(jumpind(j)+1 : jumpind(j+1)-1);
    if numel(indrange) < 3; continue; end;
    subplot(3,2,1); hold on; title('x');
    plot(xdata(1,indrange) - xdata(1,indrange(1)));
    subplot(3,2,3); hold on; title('y')
    plot(xdata(2,indrange)- xdata(2,indrange(1)));
    subplot(3,2,5); hold on; title('z');
    plot(xdata(3,indrange)- xdata(3,indrange(1)));
end
xlabel('frame');

% plot x and y
subplot(3,2,[2 4]);hold on;
for j = 1:length(jumpind)-1
    indrange = groupind(jumpind(j)+1 : jumpind(j+1)-1);
    if numel(indrange) < 3; continue; end;
        
    % get rotation angle
    xvec = xdata(1,indrange) - xdata(1,indrange(1));
    yvec = xdata(2,indrange)- xdata(2,indrange(1));
    
    u = [xvec(2) - xvec(1), yvec(2) - yvec(1), 0];
    v = [xvec(2) - xvec(1), 0, 0];
    theta = atan2(norm(cross(u,v)),dot(u,v));
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    rotvec = [xvec; yvec]' * R;
    
    if abs(rotvec(2,2)) > 1e-4
        rotvec = (R*[xvec; yvec])';
    end
    
    plot(rotvec(:,1), rotvec(:,2));
end
xlabel('x'); ylabel('y');


% auto correlation
y = [];
counter = 1;
for j = 1:length(jumpind)-1
    indrange = groupind(jumpind(j)+1 : jumpind(j+1)-1);
    if numel(indrange) < 3; continue; end;
    
    ytemp = autocorr(xdata(1,indrange));
    ytemp = [ytemp nan(1,51 - length(ytemp))];
    y(:,counter) = ytemp;
    counter = counter+1;
end

subplot(3,2,6); errorbar(nanmean(y,2), nanstd(y,[],2) / sqrt(size(y,2)));
title('autocorrelation');

%suplabel([num2str([outP{:}]) ' group ' num2str(group)],'t');
%suplabel([' group ' num2str(group)],'t');

%savefig(h,[savedirectory_subcluster num2str(group) '.fig'])
saveas(h,[savedirectory_subcluster num2str(group) '.png']);
%close(h);

end
        
    end
    
    
    clipped_clustering_ind = cluster_struct.clipped_index_agg(cluster_struct.clustering_ind);
    num_ex = 15;
    if (do_movies)
        for jjj =  good_clusters_sorted(1:end)%1:end);%58;%36;%good_clusters(1:end)
            
            
            save_ind = find(good_clusters_sorted(1:end)== jjj);
            
            matlab_fr = 2;
            amt_extend = 50;
            
            figure(370)
            align_clusters = 1;
            if align_clusters
                %  movie_output{jjj} = animate_markers(markers_preproc,frame_inds,marker_names,markercolor,links,M,jjj);
                
                
                %label individual instances
                inst_label = zeros(1,numel(clipped_clustering_ind));
                inst_label(cluster_struct.labels == jjj) = 1;
                pixellist = bwconncomp(inst_label);
                
                indexh = unique(bsxfun(@plus,reshape(find(cluster_struct.labels == jjj),[],1),- amt_extend: amt_extend));
                indexh(indexh<1) = 1;
                indexh(  indexh>numel(clipped_clustering_ind)) = numel(clipped_clustering_ind);
                indexh= unique(indexh);
                
                clusterind_full =  unique(clipped_clustering_ind(indexh));
                cluster_mean =  nanmean(markers_preproc.SpineM( clusterind_full ,:),1);
                cluster_mean_array =  (markers_preproc.SpineM( clusterind_full ,:));
                
                
                
                markers_preproc_cluster_aligned = struct();
                markernames = fieldnames(markers_preproc);
                
                fprintf('rotating markers')
                rotangle = atan2(-(markers_preproc.SpineF(clusterind_full,2)-markers_preproc.SpineM(clusterind_full,2)),...
                    (markers_preproc.SpineF(clusterind_full,1)-markers_preproc.SpineM(clusterind_full,1)));
                global_rotmatrix = zeros(2,2,numel(rotangle));
                global_rotmatrix(1,1,:) = cos(rotangle);
                global_rotmatrix(1,2,:) = -sin(rotangle);
                global_rotmatrix(2,1,:) = sin(rotangle);
                global_rotmatrix(2,2,:) = cos(rotangle);
                
                M = [];
                
                %look at at most 50 clusters
                
                
                figure(370)
                
                %  v = VideoWriter(strcat(savedirectory_subcluster,'movie',save_tags{find(movies_to_examine==jjj)}),'MPEG-4');
                v = VideoWriter(strcat(savedirectory_subcluster,'movie',num2str(save_ind)),'MPEG-4');
                
                open(v)
                
                rand_inds = randsample(1:pixellist.NumObjects,...
                    min(pixellist.NumObjects,num_ex));
                
                for lk =1:min(pixellist.NumObjects,num_ex)
                    
                    indexh = unique(bsxfun(@plus,pixellist.PixelIdxList{rand_inds(lk)},-amt_extend:amt_extend));
                    indexh(indexh<1) = 1;
                    indexh(  indexh>numel(clipped_clustering_ind)) = numel(clipped_clustering_ind);
                    indexh = unique(indexh);
                    
                    clusterind = unique(clipped_clustering_ind(indexh));
                    
                    clustersubind = arrayfun(@(x)(find(clusterind_full == x)),clusterind);
                    
                    for mm = 1:numel(markernames);
                        markers_preproc_cluster_aligned.(markernames{mm}) = markers_preproc.(markernames{mm})(clusterind_full(clustersubind),:);
                        markers_preproc_orig.(markernames{mm}) = markers_preproc.(markernames{mm})(clusterind_full(clustersubind),:);
                    end
                    
                    
                    for mm = (1:numel(markernames));
                        markers_preproc_cluster_aligned.(markernames{mm}) =  bsxfun(@minus,...
                            markers_preproc_cluster_aligned.(markernames{mm}), cluster_mean_array(clustersubind,:));
                    end
                    
                    %% now make and apply a rotation matrix
                    
                    
                    for mm = (1:numel(markernames));
                        markers_preproc_cluster_aligned.(markernames{mm})(:,1:2) =  ...
                            squeeze(mtimesx(global_rotmatrix(:,:,clustersubind),(reshape(markers_preproc_cluster_aligned.(markernames{mm})(:,1:2)',2,1,numel(clusterind)))...
                            ))';
                        
                        markers_preproc_cluster_aligned.(markernames{mm}) = bsxfun(@plus,markers_preproc_cluster_aligned.(markernames{mm}), cluster_mean);
                    end
                    
                    
                    
                    %                 markers_preproc_anim = struct();
                    %         markernames = fieldnames(markers_preproc);
                    %         for mm = 1:numel(markernames);
                    %            markers_preproc_anim.(markernames{mm}) = markers_preproc_cluster_aligned.(markernames{mm})(clusterind,:);
                    %         end
                    frame_inds = 1:matlab_fr:min(frames_use_anim,numel( clusterind));
                    h=  figure(370)
                    movie_output_temp = animate_markers_clusteraligned(markers_preproc_cluster_aligned,markers_preproc_orig,frame_inds',...
                        mocapstruct.markernames,mocapstruct.markercolor,mocapstruct.links,M,jjj,lk,h,modular_cluster_properties.subcluster_names{cluster_here} );
                    
                    % writeVideo(v,movie_output{jjj})
                    writeVideo(v,movie_output_temp)
                    
                end
                close(v)
                
            else
                
                % title(strcat('cluster ',num2str(jjj)))
                frame_inds = (time_ordering_fulltrace{jjj}(1:matlab_fr:min(frames_use_anim,numel(time_ordering_fulltrace{jjj}))))';
                
                %          temp = animate_markers(markers_preproc,frame_inds,marker_names,markercolor,links,M,jjj);
                M = [];
                
                
                movie_output_temp = animate_markers(markers_preproc,frame_inds,marker_names,markercolor,links,M,jjj);
                
                
                v = VideoWriter(strcat(savedirectory_subcluster,'movie',save_tags{find(movies_to_examine==jjj)}),'MPEG-4');
                open(v)
                % writeVideo(v,movie_output{jjj})
                writeVideo(v,movie_output_temp)
                
                close(v)
            end
        end
    end