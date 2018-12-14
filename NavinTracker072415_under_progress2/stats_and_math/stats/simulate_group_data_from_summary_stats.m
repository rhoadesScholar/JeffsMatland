function [x, group] = simulate_group_data_from_summary_stats(means, stddevs, n, groupnames)
% [x, group] = simulate_group_data_from_summary_stats(means, stddevs, n, groupnames)
% converts summary means, stddev, n, and groupnames into output suitable
% for anova etc functions in the Statistics Toolbox
% means = [mean1 mean2 ... mean_i]; stddevs = [std1 std2 ... std_i]; n = [n1 n2 ... n_i]; groupnames = {'name1','name2',...'name_i'};
% x = [x1a x1b x1c ... x2a x2b x2c ... x3a x3b x3c ...] 
% group = {'name1','name1','name1', ... 'name2','name2','name2', ...'name3','name3','name3' ... }
%
% Navin Pokala 2012

if(nargin<1)
    disp('usage [x, group] = simulate_group_data_from_summary_stats(means, stddevs, n, groupnames)');
    return;
end

num_groups = length(means);
if(length(stddevs)~=num_groups || length(n)~=num_groups || length(groupnames)~=num_groups)
    error('means, stddevs, n, and groupnames must all have the same number of elements');
    return;
end

if(isnan(n))
   error('n must be a number');
   return;
end

if(n == 0)
    x = []; 
    group = {};
    return;
end

if(n == 1)
    x(1) = means(1);
    group{1} = groupnames{1};
    return;
end

x=[];
group=[];
k=1;
for(i=1:num_groups)
    if(~isnan(n(i)) && n(i)>0)
        x = [x simulate_data_from_mean_stddev_n(means(i), stddevs(i), n(i)) ];
        for(j=1:n(i))
            group{k} = groupnames{i};
            k=k+1;
        end
    else
        x = [x NaN];
        group{k} = groupnames{i};
        k=k+1;
    end
end

return;
end

function Y = simulate_data_from_mean_stddev_n(mean, stddev, n)
% Y = simulate_data_from_mean_stddev_n(mean, stddev, n)
% creates n datapoints with mean, stddev
% based on Larson The American Statistician, Vol. 46, No. 2 (May, 1992), pp. 151-152

if(nargin<1)
    disp('Y = simulate_data_from_mean_stddev_n(mean, stddev, n)');
    return
end

array_len = length(mean);

if(length(stddev)~=array_len || length(n)~=array_len)
    error('simulate_data_from_mean_stddev_n mean, stddev, n must all be the same size');
    return
end

err = stddev/sqrt(n);

Y=[];
for(i=1:(n-1))
    Y(i) = mean + err;
end

if(~isempty(Y))
    Y(n) = n*mean - (n-1)*Y(1);
else
    Y(1) = mean;
end

return;
end


