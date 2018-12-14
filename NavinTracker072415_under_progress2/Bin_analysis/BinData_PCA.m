function BinData_PCA(BinData,binwidth, starttime, endtime)


if(nargin<2)
    binwidth = 10;
end

if(nargin<4)
    starttime = floor(BinData.time(1));
    endtime = ceil(BinData.time(end));
end

instantaneous_fieldnames = {'speed','revSpeed','body_angle','head_angle','tail_angle','delta_dir_omegaupsilon','revlength','curv'};

freq_fieldnames = {'pure_lRev_freq','pure_sRev_freq','pure_omega_freq','pure_upsilon_freq', ...
    'lRevUpsilon_freq','lRevOmega_freq','sRevUpsilon_freq','sRevOmega_freq'};

% [~, freq_fieldnames] = get_BinData_fieldnames(BinData);

fieldnames = [instantaneous_fieldnames freq_fieldnames];
% fieldnames = [freq_fieldnames instantaneous_fieldnames];

close all

% re-bin to have the same binwidth for freqs and instaneous values
BinData = alternate_binwidth_BinData(BinData, binwidth, binwidth, starttime, endtime);
normalizedBinData = normalize_BinData(BinData);

% attribute x time/obs
normalized_bindata_matrix = BinData_to_matrix(normalizedBinData, fieldnames);


% time/obs x attribute
normalized_bindata_matrix = normalized_bindata_matrix';
% [eig_vec, eig_val] = eigenvector_data_matrix(normalized_bindata_matrix);

[pc_pc,eig_vec,eig_val] = princomp((normalized_bindata_matrix));

eig_vec = eig_vec';


figure(1);
cum_eigenval = cumsum(eig_val)./sum(eig_val);
plot(1:length(eig_val), cum_eigenval, 'o');
hold on;
box off
ylabel('Fraction of variance');
xlabel('PC number');
set(gcf,'color','w');
ylim([0 1]);
hold off

figure(2);
s = BinData.time;    1:length(eig_val);
plot(s, eig_vec(1,:),'b');
hold on;
plot(s, eig_vec(2,:),'c');
plot(s, eig_vec(3,:),'g');
plot(s, eig_vec(4,:),'y');
plot(s, eig_vec(5,:),'m');
plot(s, eig_vec(6,:),'r');
hold off;

figure(3);
corr_mat = corr(normalized_bindata_matrix);
imagesc(corr_mat);
colormap(blue_red_colormap);
axis square;

figure(4);
% x = 1:length(eig_val); 
% y = [];
% colors = {'b','c','g','y','m','r'};
for(k=1:6)
   subplot(2,3,k);
   bar(1:length(eig_val),pc_pc(:,k),1);
   xlim([0 17]);
   box off
end
set(gcf,'color','w');

% plot(1:length(eig_val),pc_pc(:,1),'b'); hold on;
% plot(1:length(eig_val),pc_pc(:,2),'c');
% plot(1:length(eig_val),pc_pc(:,3),'g');
% plot(1:length(eig_val),pc_pc(:,4),'y');
% plot(1:length(eig_val),pc_pc(:,5),'m');
% plot(1:length(eig_val),pc_pc(:,6),'r');


for(k=1:length(fieldnames))
    disp([num2str(k) ' ' fieldnames{k}])
end

return;
end
