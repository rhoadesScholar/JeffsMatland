function x = rand_from_distribution(X, n)
% x = rand_from_distribution(X, n)
% returns n random values from the same normal distribution as vector X

mean = nanmean(X);
std = nanstd(X);

x = std*randn(1,n) + mean;

return;
end
