function [cluster_struct] = Cluster_GMM(agg_features,opts,frames)
%simple GMM clustering
% inputs: 


 %% could do a 'pre-pca' stage. To ignore this, set num_pcs1 high
      %  [coeff,score,latent,tsquared,explained] = pca(agg_features(:,frames)');
     %   num_pcs_1 = size(agg_features,1);
     
%         
%         pc_traces = score';
%         opts.num_pcs_1 = min(opts.num_pcs_1,size(agg_features,1));
%         
%         pc_spectrograms = cell(1,opts.num_pcs_1);
%         
%         if ~size(score,2)
%             fprintf('UH OH ERROR IN PCA \n')
%         else

%scales = helperCWTTimeFreqVector(minfreq,maxfreq,f0,dt,NumVoices)
wname = 'gaus1';
dt = 0.01;
downample = 3;
waveinfo(wname)
f0 = centfrq(wname);
minfreq = 0.5;
minscale = f0./(minfreq*dt);
s0 = minscale*dt;
numVoices = 10;
numOctave = 6;
a0 = 2^(1/numVoices);
scales = s0*a0.^(0:numOctave*numVoices);


%f0 = centfrq(wname);
%s = 0.02:0.5:31;
Freq = scal2frq(scales,wname,dt);
f = f0./(scales*dt);

% 
%   wavepower = conv2(log(abs(cfs)),[1 ones(1,10)./10],'same');
%   wavepower = log10(abs(cfs));
%   figure(11)
%   ax1 = subplot(2,1,1);
%   imagesc(1:3:500000,frequencies,wavepower)
% 
% ax2 = subplot(2,1,2);
% plot(1:3:500000,agg_features(k,1:3:500000))
% linkaxes([ax1,ax2],'x');
% 
pc_spectrograms = cell(1,size(agg_features,1));

        for k=1:size(agg_features,1)
          %  freq_range = 0.5:0.5:50;            
             
            fprintf('starting multiresolution spectrogram for feature %f \n',k);
            fr = [];
            freq_rev = fliplr(Freq);
            for mm =1:numOctave
                freq_subset = freq_rev(1+(mm-1)*numVoices:(mm)*numVoices);
                freq_delta_here = (max(freq_subset)-min(freq_subset))./numVoices;
                freq_range_here = min(freq_subset):freq_delta_here:max(freq_subset);
           %      freq_range_here
                [~,fr_temp,time_clustering,pc_spectrograms_temp] = spectrogram(agg_features(k,:),opts.clustering_window,...
                    opts.clustering_overlap,freq_range_here,opts.fps);
                pc_spectrograms{k} =   cat(1,pc_spectrograms{k},pc_spectrograms_temp);
                fr = cat(1,fr,fr_temp);
            end
            figure(44)
          %  uimagesc(1:size(pc_spectrograms{36},2),fr,log10(pc_spectrograms{36}))
                                         
%                        fprintf('starting wavelet for feature %f \n',k);
%                        tic 
%            time_clustering = 1:3:min(size(agg_features,2),1000000);
%               [pc_spectrograms{k},~,fr] =   cwt(agg_features(k,time_clustering),scales,wname,0.01,'scal'); 
%             pc_spectrograms{k} = abs(pc_spectrograms{k});
%             toc
%                         
            %  [~,~,time_clustering,pc_spectrograms{k}] = spectrogram(pc_traces(k,:),opts.clustering_window,opts.clustering_overlap,opts.fps,opts.fps);
            
%             parameters.numPeriods = 50;
%             parameters.samplingFreq = 245;
%             parameters.maxF = 100;
%             parameters.minF = 1;
%             parameters.omega0 = 5;
%             
%             [pc_spectrograms{k},f,scales] = findWavelets(agg_features(k,:)',20,parameters);
%             pc_spectrograms{k} = pc_spectrograms{k}';
        end
      %  fr = 0:opts.fps./2;
        num_fr = numel(fr);
        agg_spectrograms = cell2mat(pc_spectrograms'); %second dimension is time base
        
        %% normalize the spectrograms
        agg_spectrograms = log10(agg_spectrograms);
        agg_spectrograms(isinf(agg_spectrograms)) = -20;
         agg_spectrograms(isnan(agg_spectrograms)) = -20;
         
        timebase = size(pc_spectrograms{1},2);
        
        frames_per_bin = floor(size(agg_features,2)./timebase);
        
        [coeff2,score2,latent2,tsquared2,explained2] = pca(agg_spectrograms(:,:)');
        pca_agg_spectrogram =(score2');
        
        
        fprintf('number of PCS2 %f size of agg spectrogram %f \n',opts.num_pcs_2,size(pca_agg_spectrogram,1));
        opts.num_pcs_2 = min(size(pca_agg_spectrogram,1),opts.num_pcs_2);
        
        %% do a GMM clustering
        obj = fitgmdist((pca_agg_spectrogram(1:opts.num_pcs_2 ,:))',opts.num_clusters,...
            'Start', 'plus', 'Options', statset('MaxIter',1000),'RegularizationValue',0.1);
        clusterobj = cluster(obj,(pca_agg_spectrogram(1:opts.num_pcs_2 ,:))');
        
        labels = clusterobj;
        featurespectrogram = pca_agg_spectrogram(1:opts.num_pcs_2 ,:);

%below seems unused and can't find necessary script: feat_pcs_full
%                         feat_pcs_full = reshape(coeff2,num_fr,size(agg_features,1),size(coeff2,2));
%      cluster_struct.feat_pcs = feat_pcs_full(:,:,1:opts.num_pcs_2);
     
% feat_use = permute(cluster_struct.feat_pcs,[3 1 2]);
%                         
%                         %% get mu and var
%                         mu = obj.mu;
% sigma = obj.Sigma;
% feature_mu = mtimesx(mu,feat_use);
% 
% figure(44)
% imagesc(log10(abs(squeeze(feature_mu(6,:,:))))')
% 
% feature_sigma = zeros(size(feat_use,2),size(feat_use,3) , numclusters,size(feat_use,2),size(feat_use,3));
% for j = 1:numclusters
% feature_sigma(:,:,j,:,:) = mtimesx(permute(feat_use,[2 3 1]),mtimesx(squeeze(sigma(:,:,j),feat_use)));
% end
%                         
%         
V = coeff2(:,1:opts.num_pcs_2);

mu = obj.mu;
sigma = obj.Sigma;

feature_mu = mu * V';
feature_sigma = zeros(size(coeff2,1),size(coeff2,1) ,opts.num_clusters);
for j = 1:opts.num_clusters
feature_sigma(:,:,j) = V * sigma(:,:,j) * V';
end


%% convert the labels to be on each frame

labels_longer = zeros(1,numel(frames));
wtAll = zeros(size(featurespectrogram,1),numel(frames));

for jjj = 1:max(labels)
    ind_label = unique(reshape(bsxfun(@plus,round(time_clustering(find(labels==jjj))*opts.clustering_window)',...
                            -floor(opts.clustering_overlap):floor(opts.clustering_overlap)),1,[]));
                        ind_label(ind_label <1) = 1;
                        ind_label(ind_label>numel(frames)) = numel(frames);
    labels_longer(ind_label) = jjj;
end

for jjj = 1:size(featurespectrogram,2)
      ind_label = unique(reshape(bsxfun(@plus,round(time_clustering(jjj)*opts.clustering_window)',...
                            -floor(opts.clustering_overlap):floor(opts.clustering_overlap)),1,[]));
                        ind_label(ind_label <1) = 1;
                        ind_label(ind_label>numel(frames)) = numel(frames);
    wtAll(:,ind_label) = repmat(featurespectrogram(:,jjj),1,numel(ind_label));
end

                        
    cluster_struct = struct();
    cluster_struct.labels = labels_longer;
    cluster_struct.labels_orig = labels;
    cluster_struct.num_clusters = length(unique(cluster_struct.labels));
	cluster_struct.num_clusters_req = opts.num_clusters;
    cluster_struct.wtAll = wtAll';
    cluster_struct.fr = fr;
     
    cluster_struct.feature_mu = feature_mu;
    cluster_struct.feature_sigma = feature_sigma;
    cluster_struct.clustering_ind = frames;

     
%     cluster_struct.feature_labels = feature_labels;
%         cluster_struct.clustering_ind = 
%                 cluster_struct.clipped_index_agg = clipped_index_agg;
                        
        end

        