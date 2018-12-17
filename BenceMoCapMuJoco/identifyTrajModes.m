% function behStruct = identifyTrajModes(behStruct)
% % IDENTIFYTRAJMODES identify modes in trajectory data

%% construct data set across all sessions

sess_list = find(cellfun(@(x) ~isempty(x.Ltraj) && ~isempty(x.Rtraj), {behStruct.traj}));

% allTraj = cellfun(@(x) cat(4, x.Ltraj(:,:,1:2,:), x.Rtraj(:,:,1:2,:)), {behStruct(sess_list).traj}, 'unif', 0);
% allTraj = cellfun(@(x) cat(4, x.Ltraj(:,:,1:2,1), x.Rtraj(:,:,1:2,1)), {behStruct(sess_list).traj}, 'unif', 0); % only paws
% allTraj = cellfun(@(x) cat(4, x.Rtraj(:,:,1:2,1)), {behStruct(sess_list).traj}, 'unif', 0); % only R paw
allTraj = cellfun(@(x) x.Ltraj(:,:,1:2,1), {behStruct(sess_list).traj}, 'unif', 0); % only L paw
allTraj = cat(1,allTraj{:});
allTraj = reshape(allTraj, size(allTraj,1), size(allTraj,2), size(allTraj,3)*size(allTraj,4));

IPI = cellfun(@(x) (x.tap2Times(:,5) - x.tap1Times(:,5))/3e4, {behStruct(sess_list).tapTimes}, 'unif', 0);
IPI = cat(1,IPI{:});

sessInd = arrayfun(@(x) [ones(length(behStruct(x).firstIntervals),1)*x, (1:length(behStruct(x).firstIntervals))'], sess_list, 'unif', 0);
sessInd = vertcat(sessInd{:});

%%
oldModes = zeros(size(IPI));
for s = sess_list
    % find matching session in old_behStruct
    old_s = find([old_behStruct.exptID] == behStruct(s).exptID & [old_behStruct.defID] == behStruct(s).defID,1);
    
    if ~isempty(old_s) && ~isempty(old_behStruct(old_s).modes)
        oldModes(sessInd(:,1) == s) = old_behStruct(old_s).modes;
    end    
end

modeList = unique(oldModes);
modeList = modeList(modeList > 0);

%% Deal with NaNs in trajectory data
 
preTap = 0.5; % s
postTap = 1.5; % s
frate = 120; % Hz

startT = -0.05;
endT = IPI + 0.05;

tTraj = -preTap : 1/frate : postTap;

% trSet = ~isnan(IPI) & sessInd(:,1) == 48;
% trSet = IPI > 0.65 & IPI < 0.75;
trSet = ~isnan(IPI) & IPI > 0;
% trSet = ~isnan(IPI) & ismember(sessInd(:,1), [168:170]);

startFr = find(tTraj <= startT, 1, 'last');
endFr = NaN(size(IPI));
endFr(trSet) = arrayfun(@(x) find(tTraj > x, 1, 'first'), endT(trSet));

tap1Fr = find(tTraj >= 0, 1, 'first');
tap2Fr = NaN(size(IPI));
tap2Fr(trSet) = arrayfun(@(x) find(tTraj > x, 1, 'first'), IPI(trSet));

FrNanCnt = NaN(size(endFr));
FrNanCnt(trSet) = cellfun(@(x,y) max(sum(isnan(x(1,startFr-1:y+1,:)),2),[],3), num2cell(allTraj(trSet,:,:), [2,3]), num2cell(endFr(trSet))); % count number of max NaNs over objects in trial

NanThresh = 5; % ignore all trials with more NaNs than this

trSet = trSet & FrNanCnt <= NanThresh;

% interpolate over remaining NaNs for each object trajectory 
NaNind = find(FrNanCnt > 0 & trSet);
for tr = NaNind'
    for o = 1 : size(allTraj, 3)
        if any(squeeze(isnan(allTraj(tr,:,o))))
            nan_pts = squeeze(isnan(allTraj(tr,:,o)));
            t = 1:size(allTraj,2);
            allTraj(tr,nan_pts,o) = interp1(t(~nan_pts), squeeze(allTraj(tr,~nan_pts,o)), t(nan_pts), 'linear', 'extrap');            
        end
    end
end

trSet = find(trSet);

%% subtract position at first tap from dataset

allTraj_m = allTraj - repmat(nanmean(allTraj(:, tap1Fr-2:tap1Fr+2, :), 2), 1, size(allTraj,2), 1);

%% Warp all trials to same timescale

% warp only tap1 - tap2 segment of the trajectory
nw_samp = round(nanmedian(IPI) * frate);
allTraj_w = zeros(length(trSet), nw_samp + (tap1Fr-startFr) + nanmedian(endFr-tap2Fr), size(allTraj_m,3));

% for tr = 1 : length(trSet)
%     allTraj_w(tr,:,:) = interp1(tTraj, squeeze(allTraj_m(trSet(tr),:,:)), ...
%         [tTraj(startFr : tap1Fr-1), ... % pre tap 1
%         linspace(tTraj(tap1Fr), tTraj(tap2Fr(trSet(tr))), nw_samp), ... % tap1-tap2 warped
%         tTraj(tap2Fr(trSet(tr))+1:endFr(trSet(tr)))], ... % post tap 2
%         'linear', 'extrap');        
% end


for tr = 1 : length(trSet)
    allTraj_w(tr,:,:) = interp1(tTraj, squeeze(allTraj_m(trSet(tr),:,:)), ...
        [tTraj(startFr : tap1Fr-1), ... % pre tap 1
        linspace(tTraj(tap1Fr), tTraj(tap2Fr(trSet(tr))), nw_samp), ... % tap1-tap2 warped
        tTraj(tap2Fr(trSet(tr))+1 : tap2Fr(trSet(tr))+round(0.05*frate))], ... % post tap 2
        'linear', 'extrap');        
end

% % warp everything from startFr to endFr linearly
% nw_samp = nanmedian(endFr) - startFr;
% allTraj_w = zeros(length(trSet), nw_samp, size(allTraj,3));
% 
% for tr = 1 : length(trSet)
%     allTraj_w(tr,:,:) = interp1(tTraj, squeeze(allTraj(trSet(tr),:,:)), ...
%         linspace(startT, endT(trSet(tr)), nw_samp), 'linear', 'extrap');        
% end

%% Compute reduced dim PCA projection of data

nPCs = 2;
[~,beh,lt] = pca(reshape(allTraj_w, numel(allTraj_w(:,:,1)), []), 'NumComponents', nPCs);
beh = reshape(beh, size(allTraj_w,1), size(allTraj_w,2), nPCs);


% reshape along time and object dim
dat = reshape(allTraj_w, size(allTraj_w,1), []);

% reduce dimensionality to 20
[dat_coeff, dat_pc20] = pca(dat, 'NumComponents', 20);

%% Define subset of bins for GMM clustering and/or tSNE

n_map = 20000;
if size(allTraj_w,1) > n_map
    subs = round(linspace(1,size(allTraj_w,1),n_map));
else
    subs = 1:size(allTraj_w,1);
end

%% Do tSNE over sample trials

% computing tSNE

tic;
% mapTraj = tsne(reshape(allTraj_w, length(trSet), numel(allTraj_w(1,:,:)))); % full dataset
mapTraj = tsne(reshape(allTraj_w(subs,:,:), length(subs), numel(allTraj_w(1,:,:))), 'Distance', 'euclidean'); % dataset subset

% mapTraj = tsne(reshape(allTraj_w(subs,:,2), length(subs), numel(allTraj_w(1,:,2))), 'Distance', @dtw_dist); % dataset subset

% mapBeh = tsne(reshape(beh, length(trSet), numel(beh(1,:,:)))); % full dataset
mapBeh = tsne(reshape(beh(subs,:,:), length(subs), numel(beh(1,:,:))), 'Distance', 'correlation'); % dataset subset
toc;

%% plot tSNE map

figure; plot(mapTraj(:,1), mapTraj(:,2), '.');

%% GMM clustering

k_range = 1:8;

gmm_test = cell(length(k_range),1);
for k = 1:length(k_range)
    disp(k_range(k));
    gmm_test{k} = fitgmdist(dat_pc20(subs,:), k_range(k), 'Replicates', 5, 'Start', 'plus', 'Options', statset('MaxIter',1000));
end 

bic = zeros(size(k_range));
aic = zeros(size(k_range));
for k = 1 : length(k_range)
   bic(k) = gmm_test{k}.BIC;
   aic(k) = gmm_test{k}.AIC;
end

figure;
plot(k_range,bic(:),'bo-','DisplayName','BIC');
hold on;
% plot(k_range,aic(:),'o-','DisplayName','AIC');
ylabel('BIC');
xlabel('k');

[~,i] = min(bic);
k_final = k_range(i);

%% Fit optimal GMM model

gmm = fitgmdist(dat_pc20(subs,:), k_final, 'Replicates', 20, 'Start', 'plus', 'Options', statset('MaxIter',1000));

cl = gmm.cluster(dat_pc20);

%% Cluster DP

addpath('C:\Users\Ashesh\Dropbox\Code\General\clusterDP\');
[~,cl] = clusterDP(mapTraj,0.02);


%% Visualize fit

cl_nums = unique(cl);
% cl_col = distinguishable_colors(length(cl_nums));
cl_col = jet(length(cl_nums));

if any(cl_nums==0)
    cl_col(cl_nums==0,:) = [.75,.75,.75];
end

figure;
for c = 1 : length(cl_nums)   
    plot(mapTraj(cl==cl_nums(c),1), mapTraj(cl==cl_nums(c),2), '.', 'Color', cl_col(c,:), 'markersize', 5);
    hold on;    
end

cl_nums2 = cl_nums(cl_nums~=0);
[~,i] = sort(cl);
i = i(cl(i) ~= 0);

figure;
if size(allTraj_w,3) == 20
    subplot(4,1,1);
    imagesc(1:length(subs(i)), startT:1/frate:nanmedian(endT), -allTraj_w(subs(i),:,2)');
    hold on;
    for c = 1 : length(cl_nums2)
        c_count = sum(cl(cl~=0) <= cl_nums2(c));
        plot([c_count, c_count], [startT, nanmedian(endT)], 'w--');
    end
    title('L paw');
    conditionPlot(gca);
    ylabel('Time from tap 1 (s)');
    caxis([-100,30]);
    
    subplot(4,1,2);
    imagesc(1:length(subs(i)), startT:1/frate:nanmedian(endT), -allTraj_w(subs(i),:,12)');
    hold on;
    for c = 1 : length(cl_nums2)
        c_count = sum(cl(cl~=0) <= cl_nums2(c));
        plot([c_count, c_count], [startT, nanmedian(endT)], 'w--');
    end
    title('R paw');
    conditionPlot(gca);
    ylabel('Time from tap 1 (s)');
    caxis([-50,75]);

    subplot(4,1,3);
    imagesc(1:length(subs(i)), startT:1/frate:nanmedian(endT), -allTraj_w(subs(i),:,8)');
    hold on;
    for c = 1 : length(cl_nums2)
        c_count = sum(cl(cl~=0) <= cl_nums2(c));
        plot([c_count, c_count], [startT, nanmedian(endT)], 'w--');
    end
    title('L ear');
    conditionPlot(gca);
    ylabel('Time from tap 1 (s)');
    caxis([-50,50]);

    subplot(4,1,4);
    imagesc(1:length(subs(i)), startT:1/frate:nanmedian(endT), -allTraj_w(subs(i),:,10)');
    hold on;
    for c = 1 : length(cl_nums2)
        c_count = sum(cl(cl~=0) <= cl_nums2(c));
        plot([c_count, c_count], [startT, nanmedian(endT)], 'w--');
    end
    title('L back');
    conditionPlot(gca);
    ylabel('Time from tap 1 (s)');
    caxis([-25,25]);
    
elseif size(allTraj_w,3) == 24
    subplot(4,1,1);
    imagesc(1:length(subs(i)), startT:1/frate:nanmedian(endT), -allTraj_w(subs(i),:,2)');
    hold on;
    for c = 1 : length(cl_nums2)
        c_count = sum(cl(cl~=0) <= cl_nums2(c));
        plot([c_count, c_count], [startT, nanmedian(endT)], 'w--');
    end
    title('L paw');
    conditionPlot(gca);
    ylabel('Time from tap 1 (s)');
    caxis([-100,30]);
    
    subplot(4,1,2);
    imagesc(1:length(subs(i)), startT:1/frate:nanmedian(endT), -allTraj_w(subs(i),:,14)');
    hold on;
    for c = 1 : length(cl_nums2)
        c_count = sum(cl(cl~=0) <= cl_nums2(c));
        plot([c_count, c_count], [startT, nanmedian(endT)], 'w--');
    end
    title('R paw');
    conditionPlot(gca);
    ylabel('Time from tap 1 (s)');
    caxis([-50,75]);

    subplot(4,1,3);
    imagesc(1:length(subs(i)), startT:1/frate:nanmedian(endT), -allTraj_w(subs(i),:,8)');
    hold on;
    for c = 1 : length(cl_nums2)
        c_count = sum(cl(cl~=0) <= cl_nums2(c));
        plot([c_count, c_count], [startT, nanmedian(endT)], 'w--');
    end
    title('L ear');
    conditionPlot(gca);
    ylabel('Time from tap 1 (s)');
    caxis([-50,50]);

    subplot(4,1,4);
    imagesc(1:length(subs(i)), startT:1/frate:nanmedian(endT), -allTraj_w(subs(i),:,10)');
    hold on;
    for c = 1 : length(cl_nums2)
        c_count = sum(cl(cl~=0) <= cl_nums2(c));
        plot([c_count, c_count], [startT, nanmedian(endT)], 'w--');
    end
    title('L back');
    conditionPlot(gca);
    ylabel('Time from tap 1 (s)');
    caxis([-25,25]);
else
    subplot(2,1,1);
    imagesc(1:length(subs(i)), startT:1/frate:nanmedian(endT), -allTraj_w(subs(i),:,1)');
    hold on;
    for c = 1 : length(cl_nums2)
        c_count = sum(cl(cl~=0) <= cl_nums2(c));
        plot([c_count, c_count], [startT, nanmedian(endT)], 'w--');
    end
    title('L paw');
    conditionPlot(gca);
    ylabel('Time from tap 1 (s)');
    caxis([-100,30]);
    
    subplot(2,1,2);
    imagesc(1:length(subs(i)), startT:1/frate:nanmedian(endT), -allTraj_w(subs(i),:,2)');
    hold on;
    for c = 1 : length(cl_nums2)
        c_count = sum(cl(cl~=0) <= cl_nums2(c));
        plot([c_count, c_count], [startT, nanmedian(endT)], 'w--');
    end
    title('R paw');
    conditionPlot(gca);
    ylabel('Time from tap 1 (s)');
    caxis([-50,75]);
end
    

%% Plot tSNE map with color corresponding to IPI

IPI_bins = 0.2:0.1:1;
[~,~,binInd] = histcounts(IPI(trSet(subs)), IPI_bins);

plot_cols = zeros(length(trSet(subs)), 3);
IPI_cols = cool(length(IPI_bins)-1);

for b = 1 : length(IPI_bins)-1
    plot_cols(binInd==b,:) = repmat(IPI_cols(b,:), sum(binInd==b),1);
end
figure;
scatter(mapTraj(:,1), mapTraj(:,2),5,plot_cols,'.');

%% Plot tSNE map with color corresponding to time in box

s_bins = linspace(0,floor(subs(end)),10);

[~,~,binInd] = histcounts(subs, s_bins);

plot_cols = zeros(length(trSet(subs)), 3);
s_cols = jet(length(s_bins)-1);

for b = 1 : length(s_bins)-1
    plot_cols(binInd==b,:) = repmat(s_cols(b,:), sum(binInd==b),1);
end
figure;
scatter(mapTraj(:,1), mapTraj(:,2),8,plot_cols,'.');


%%
    
% figure;
% imagesc(-allTraj(trSet(subs(i)),:,2)');

%% If clustering has been carried out on a trial subset, then propagate modes to all trials

if length(subs) < size(allTraj_w,1)
            
    % Find closest match for each sub
    sub_dist = pdist2(reshape(allTraj_w, size(allTraj_w,1), numel(allTraj_w(1,:,:))), reshape(allTraj_w(subs,:,:), length(subs), numel(allTraj_w(1,:,:))));
    
    [~,sub_match] = min(sub_dist,[],2);
    cl_final = cl(sub_match);
    
else
    cl_final = cl;    
end

%% Assign modes to behStruct

% assume that 0 in cl means a mode has not been assigned

for s = 1 : length(behStruct)
    sess_modes = zeros(size(behStruct(s).firstIntervals));
    
    sess_trSet = find(sessInd(trSet,1) == s);    
    if ~isempty(sess_trSet)
        sess_modes(sessInd(trSet(sess_trSet),2)) = cl_final(sess_trSet);
    end
    behStruct(s).modes = sess_modes;
end



%% Pairwise DTW


