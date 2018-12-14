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

for(i=1:(n-1))
    Y(i) = mean + err;
end

Y(n) = n*mean - (n-1)*Y(1);

return;
end
