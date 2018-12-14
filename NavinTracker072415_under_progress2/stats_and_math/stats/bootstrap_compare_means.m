function p = bootstrap_compare_means(sample, ctrl, n)
%  p = bootstrap_compare(sample, ctrl, [n=1000])

if(nargin<2)
    disp('usage: p = bootstrap_compare(sample, ctrl, [n=1000])');
    return;
end

if(nargin<3)
    n=10000;
end

% check for dimensions and convert to row vectors
if(size(ctrl,1)~=1)
    ctrl = ctrl';
end
if(size(sample,1)~=1)
    sample = sample';
end

% purge nans
ctrl(isnan(ctrl))=[];
sample(isnan(sample))=[];

n_ctrl = length(ctrl);
n_sample = length(sample);
n_total = n_ctrl+n_sample;


mean_diff_vector(n) = 0;
for(i=1:n)
    pooled_data = [sample ctrl];
    
    idx = randint(n_total,n_ctrl);
    dummy_ctrl = pooled_data(idx);
    pooled_data(idx) = [];
    dummy_sample = pooled_data;
    
    
    mean_diff_vector(i) = (mean(dummy_ctrl) - mean(dummy_sample));
    
end

if(sum(mean_diff_vector)==0)
    p=1;
    return;
end

p = 1-normcdf(abs(mean(ctrl) - mean(sample)), mean(mean_diff_vector), std(mean_diff_vector));

% [mean_diff p normcdf(abs(mean_diff), mean(mean_diff_vector), std(mean_diff_vector))]
% figure(100);
% hist(mean_diff_vector,sshist(mean_diff_vector));
% pause
% figure(1);

return;
end
