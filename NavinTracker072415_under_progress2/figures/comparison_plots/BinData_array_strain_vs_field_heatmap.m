function h = BinData_array_strain_vs_field_heatmap(BinData_array, stimulus, fieldnames, base_index)
% h = BinData_array_strain_vs_field_heatmap(BinData_array, stimulus, fieldnames)
% blue->red heatmap for Z-score difference from BinData_array(1)
% blocks colored only if significantly (p<0.05) different from control BinData_array(1)

global Prefs;
Prefs = define_preferences(Prefs);

alpha = 0.05;
scale_type = 'ratio'; % 'ratio'; % Z-score

if(nargin<2)
    stimulus = [];
end

if(nargin<3)
    fieldnames = [];
end

if(nargin<4)
    base_index = 1;
end

num_movies_vector=[];
for(i=1:length(BinData_array))
    strainames{i} = BinData_array(i).Name;
    num_movies_vector(i) = BinData_array(i).num_movies;
end

if(isempty(fieldnames))
    fieldnames = Prefs.fieldnames;
end

[summary_matrix_bindata_array_mean, summary_matrix_bindata_array_stddev, summary_matrix_bindata_array_n, stimsummary_length]  =  bindata_array_to_summary_matrix(BinData_array, stimulus,fieldnames);
mean_stddev = nanmean(summary_matrix_bindata_array_stddev);

if(~isnumeric(base_index))
    if(strcmp(base_index,'mean'))
        mean_BinData = mean_BinData_from_BinData_array(BinData_array, 'mean');
        [mean_BinData_mean, mean_BinData_stddev, mean_BinData_n, stimsummary_length]  =  bindata_array_to_summary_matrix(mean_BinData, stimulus,fieldnames);

        summary_matrix_bindata_array_mean = [summary_matrix_bindata_array_mean;  mean_BinData_mean];
        summary_matrix_bindata_array_stddev = [summary_matrix_bindata_array_stddev; mean_BinData_stddev];
        base_index = size(summary_matrix_bindata_array_mean,1);
        num_movies_vector(base_index) = mean_BinData.num_movies;
    else
        error('h = BinData_array_strain_vs_field_heatmap(BinData_array, stimulus, fieldnames, base_index), base_index is index or ''mean''');
    end
end

% subtract pre-stim baseline for real stimuli
% stimuli has pre-stim, on-response, equilib, off-response, post-stim
if(isnumeric(stimulus))
    for(k=1:5:5*length(fieldnames))
        summary_matrix_bindata_array_mean(:,k:k+4) = bsxfun(@minus,summary_matrix_bindata_array_mean(:,k:k+4), summary_matrix_bindata_array_mean(:,k));
    end
end

base_vector = summary_matrix_bindata_array_mean(base_index,:);

if(strcmp(scale_type,'Z-score'))    % Z-score ... # std deviations
    im = bsxfun(@rdivide,(bsxfun(@minus,summary_matrix_bindata_array_mean, base_vector)), mean_stddev);
else % scaled ratio
    % im = bsxfun(@rdivide,summary_matrix_bindata_array_mean, base_vector);
    im = bsxfun(@rdivide,(bsxfun(@minus,summary_matrix_bindata_array_mean, base_vector)), base_vector);
end
im = matrix_replace(im,'==',Inf,NaN);
im = matrix_replace(im,'==',-Inf,NaN);
im = matrix_replace(im,'==',NaN,0);
%c = 2*nanstd(matrix_to_vector(im));
cmap_lim = [-1 1];


% v = matrix_to_vector(im); [y,x] = hist(v,sshist(v)); plot(x,y/sum(y)); figure(2);


p_val_matrix = ones(size(summary_matrix_bindata_array_mean));

% % p-value matrix; show color only if significant else white
% p_val_matrix=zeros(size(summary_matrix_bindata_array_mean))+NaN;
% for(i=1:length(base_vector))
%     p_val_matrix(:,i) = multicompare_to_base_value(summary_matrix_bindata_array_mean(:,i), summary_matrix_bindata_array_stddev(:,i), num_movies_vector, strainames, base_index);
% end
% for(i=1:size(p_val_matrix,1))
%     for(j=1:size(p_val_matrix,2))
%         if(p_val_matrix(i,j)>alpha)
%             p_val_matrix(i,j)=0;
%         else
%             if(isnan(p_val_matrix(i,j)))
%                 p_val_matrix(i,j)=0;
%             else
%                 p_val_matrix(i,j)=1;
%             end
%         end
%     end
% end
% im = im.*p_val_matrix;


% h1 = subplot(1,3,1);
[~,~,cluster_idx] = dendrogram(linkage(pdist(im,'euclidean'), 'average'),0,'labels',strainames,'orientation','left');
% box off; axis off; 
im = im(cluster_idx,:);
strainames = strainames(cluster_idx);
% pos1 = get(h1,'position');

%h2 = subplot(1,3,[2 3]);
imagesc(im, cmap_lim);
set(gca, 'yticklabel', strainames, 'box', 'off', 'ticklength', [0 0],  'ytick',1:length(BinData_array));
set(gca, 'XAxisLocation','top','xticklabel', fix_title_string(fieldnames), 'box', 'off', 'ticklength', [0 0],  'xtick',1.25:stimsummary_length:stimsummary_length*(length(fieldnames)));
xticklabel_rotate([],90);
axis equal; axis tight; box off; 
colormap(blue_red_colormap);
colorbar;
%pos2 = get(h2,'position');

% set(h1,'position',[pos1(1) pos2(2) pos1(3) pos2(4)]);



return;
end
