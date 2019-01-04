
filearray = {'E:\Bence\Data\Motionanalysis_captures\Vicon3\20170721\skeletoncaptures\nolj_Vicon3_recording_amphetamine_vid1.htr',...
    'E:\Bence\Data\Motionanalysis_captures\Vicon3\20170721\skeletoncaptures\nolj_Vicon3_recording_amphetamine_vid2.htr',...
    'E:\Bence\Data\Motionanalysis_captures\Vicon3\20170721\skeletoncaptures\nolj_Vicon3_recording_amphetamine_vid3.htr',...
    'E:\Bence\Data\Motionanalysis_captures\Vicon3\20170721\skeletoncaptures\nolj_Vicon3_recording_amphetamine_vid4.htr',...
    'E:\Bence\Data\Motionanalysis_captures\Vicon3\20170721\skeletoncaptures\nolj_Vicon3_recording_amphetamine_vid5.htr',...
    };

mocapfilearray = {'E:\Bence\Data\Motionanalysis_captures\Vicon3\20170721\Generated_C3D_files\Vicon3_recording_amphetamine_vid1_nolj.htr',...
    'E:\Bence\Data\Motionanalysis_captures\Vicon3\20170721\Generated_C3D_files\Vicon3_recording_amphetamine_vid2_nolj.htr',...
    'E:\Bence\Data\Motionanalysis_captures\Vicon3\20170721\Generated_C3D_files\Vicon3_recording_amphetamine_vid3_nolj.htr',...
    'E:\Bence\Data\Motionanalysis_captures\Vicon3\20170721\Generated_C3D_files\Vicon3_recording_amphetamine_vid4_nolj.htr',...
    'E:\Bence\Data\Motionanalysis_captures\Vicon3\20170721\Generated_C3D_files\Vicon3_recording_amphetamine_vid5_nolj.htr',...
    };



mocapmasterdirectory = '\\140.247.178.37\Jesse\Motionanalysis_captures\';
plotdirectory = '\\140.247.178.37\Jesse\Motionanalysis_captures\Vicon3\plots\';
mkdir(plotdirectory)
mocapfilestruct = loadmocapfilestruct('Vicon3',mocapmasterdirectory);

%% get the desired files
descriptor_struct_1 = struct();
descriptor_struct_1.day = 1;
descriptor_struct_1.tag = 'recording';
descriptor_struct_1.cond = 'seventeen';

% mocapfilearray = filearray;
% for kk = 1:numel(mocapfilearray)
% mocapfilearray{kk} = strrep(filearray{kk},'.htr','.cap');
% end

%% either load  or preprocess from scratch
[mocapstruct] = preprocess_mocap_data(mocapfilearray,mocapfilestruct,descriptor_struct_1);

%'E:\Bence\Data\Motionanalysis_captures\Vicon3\20170721\skeletoncaptures\nolj_Vicon3_recording_amphetamine_vid6.htr'

[limbposition,rotations,translations_local,translations_global] = concat_htr(filearray);

limbstart = 1;
limbnames = fieldnames(limbposition);
limbstop = numel(rotations );


%% get the euler angles

rotations_eul = cell(1,numel(rotations));
for mm = limbstart:limbstop
rotations_eul{mm} = rotm2eul(rotations{mm});
end



%% bad frame detector -- this could be very slow, may just want to run for all at once
 bad_threshold = 5;%seems like this shouldn't be the same for translation and euler angles...
 agg_features = cat(1,diff(squeeze(cell2mat(translations_local')),1,2), diff(cell2mat(rotations_eul)',1,2));
 bad_frames = find(abs(agg_features)>bad_threshold);
 [~,bad_inds] = ind2sub(size(agg_features),bad_frames);
 bad_inds = unique(bad_inds);
 agg_features(:,bad_inds) = 0;
 agg_features(isnan(agg_features)) = 0;

  agg_features = bsxfun(@rdivide,bsxfun(@minus,agg_features,nanmean(agg_features,2)),nanstd(agg_features,[],2));
feat_mean = nanmean(agg_features,2);
goodind = find(~isnan(feat_mean));

 figure(23)
 imagesc(agg_features(goodind,:))%displays standardized mean differences for all relevant features across all frames
 caxis([-5 5])
 
 
 figure(44)
 plot(agg_features(goodind(50),:))
 
 agg_features = agg_features(goodind,:);
 
 
 
 %% GMM cluster
 fps = 300;
   opts.clustering_window = fps;
   opts.clustering_overlap = floor(fps*0.5);
   opts.fps = fps;
   opts.num_pcs_1 = 200;
   opts.num_pcs_2 = 30;
   opts.num_clusters = 200;
   
   %% get clusters and metrics
[cluster_struct_spect] = Cluster_GMM(agg_features,opts,1:size(agg_features,2 ));


%% do clustering
cluster_here = [2];
    downsample = 3;
savedirectory_subcluster = strcat(plotdirectory,filesep,'subclusterplots_',num2str(cluster_here),filesep);
mkdir(savedirectory_subcluster);

  do_movies=1;
do_cluster_plots=1;
               plot_cluster_means_movies(savedirectory_subcluster,cluster_struct_spect,modular_cluster_properties,cluster_here,...
mocapstruct.markers_preproc,do_movies,mocapstruct,do_cluster_plots) 

  %% have to add other spectrogram features to get plots/movies
  make_cluster_descriptors(cluster_struct_spect,modular_cluster_properties.agg_features{cluster_here}(3,:),savedirectory_subcluster)

  
  

  
num_clusters =  opts.num_clusters;  
              time_ordering_fulltrace = cell(1,num_clusters);

              
                
  
[~,sort_ja] = sort(cluster_struct_spect.labels);
%[~,sort_global] = sort(clusterobj_global);

cluster_numbers = zeros(1,num_clusters);
for mm = 1:num_clusters
    cluster_numbers(mm) = numel(find(cluster_struct_spect.labels == mm));
end
              
        for ll = 1: opts.num_clusters

%              [~,~,times_here,~] = spectrogram(squeeze(agg_features(1,:)),opts.clustering_window,opts.clustering_overlap,fps,fps);
% 
%             time_ordering_fulltrace{ll} = (unique(bsxfun(@plus,round(times_here()*opts.clustering_window)',...
%                 -floor(opts.clustering_overlap):floor(opts.clustering_overlap))));
%             
%             time_ordering_fulltrace{ll}(time_ordering_fulltrace{ll}<1) = 1;
%             
%             time_ordering_fulltrace{ll}(time_ordering_fulltrace{ll} > max( clustering_ind)) = max( clustering_ind);
          time_ordering_fulltrace{ll}=   find(cluster_struct_spect.labels==ll);
        end
        
        
        figure(37)
subplot(2,1,1)
test = cat(2,time_ordering_fulltrace{:});
imagesc(agg_features(:,test))
caxis([-0.1 0.1])

subplot(2,1,2)
%plot(clusterobj(sort_ja))

        
        
frames_use = 10000;
savedirectory_subcluster = 'E:\Bence\Data\MOCAP\regression_animations\skeletontest2\';
mkdir(savedirectory_subcluster)
for jjj = find(cluster_numbers>1000);%58;%36;%good_clusters(1:end)
    matlab_fr = 10;
    figure(370)
    frame_inds = (time_ordering_fulltrace{jjj}(1:matlab_fr:min(frames_use,numel(time_ordering_fulltrace{jjj}))))';
    
    M = [];
    movie_output_temp = animate_skeleton(limbposition,frame_inds',limbnames,limbstart,jjj)
    %animate_markers(markers_preproc,frame_inds,marker_names,markercolor,links,M,jjj);
    
    v = VideoWriter(strcat(savedirectory_subcluster,'movie',num2str(jjj),'.mp4'),'MPEG-4');
    open(v)
    
    writeVideo(v,movie_output_temp)
    close(v)
end

  