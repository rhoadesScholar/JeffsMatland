function p_value_vector = multicompare_to_base_value(means, stddev, n, groupnames, base_idx, alpha_list)
% p_value_vector = multicompare_to_base_value(means, stddev, n, groupnames, base_idx)
% (default) Tukey-Cramer for multiple comparisons to the value means(base_idx) +/- stddev(base_idx)
% returns p-value summary length(means), NaN for the base index

p_value_vector = zeros(1,length(means)) + NaN;

if(nargin<4)
    disp('p_value_vector = multicompare_to_base_value(means, stddev, n, groupnames, <base_idx>, <alpha_list>)');
    disp('means, stddev, n, groupnames must all have the same size');
    return;
end

if(length(means)~=length(stddev) || length(means)~=length(n) || length(means)~=length(groupnames) || ...
        length(stddev)~=length(n) || length(stddev)~=length(groupnames) || ...
        length(n)~=length(groupnames) )
    disp('p_value_vector = multicompare_to_base_value(means, stddev, n, groupnames, <base_idx>, <alpha_list>)');
    disp('means, stddev, n, groupnames must all have the same size');
    return;
end

if(nargin<5)
    base_idx = 1;
end

if(nargin<6)
    alpha_list = [0.05 0.01 0.001 0.0001];
end

% some weird stuff happens with zero values
for(i=1:length(means))
    if(means(i)==0)
        means(i) = eps('single');
    end
    if(stddev(i)==0)
        stddev(i) = eps('single');
    end
    if(n(i)<=1)
        return; % can't do stats w/ n=1!
    end
end

% FDR to p-value w/ respect to base_idx value
base_mean = means(base_idx);
base_std = stddev(base_idx);
base_n = n(base_idx);
p_value_vector = [];
for(i=1:length(means))
    if(i~=base_idx)
        p_value_vector = [p_value_vector ttest_compare(means(i), stddev(i), n(i), base_mean, base_std, base_n)];
    else
        p_value_vector = [p_value_vector NaN];
    end
end
[~,~,p_value_vector ] = fdr_bh(p_value_vector);
return;


% Tukey-Kramer to p-value w/ respect to base_idx value
[datavector, groupvector] = simulate_group_data_from_summary_stats(means, stddev, n, groupnames);
multcompare_output = anova1multicompare(datavector, groupvector, alpha_list);

% [ idx_i idx_j diff alpha_index pval ]

for(j=1:size(multcompare_output.stats,1))
    
    if(multcompare_output.stats(j,1) == base_idx || multcompare_output.stats(j,2) == base_idx)
        if(multcompare_output.stats(j,1) ~= base_idx)
            k = multcompare_output.stats(j,1);
        else
            k = multcompare_output.stats(j,2);
        end
        p_value_vector(k) = multcompare_output.stats(j,5);
    end
end

return;
end
