function [x_bin, x_std, x_err, y_bin, y_std, y_err, n] = bin_continuous_xaxis_values(x, y, bincenters)

x_bin = []; x_std = []; x_err = []; n = [];
y_bin = []; y_std = []; y_err = []; 

if(nargin<2)
   disp('usage: [x_bin, x_std, x_err, y_bin, y_std, y_err, n] = bin_continuous_xaxis_values(x, y, bincenters)');
   return;
end

if(length(x)~=length(y))
    disp('usage: [x_bin, x_std, x_err, y_bin, y_std, y_err, n] = bin_continuous_xaxis_values(x, y, bincenters)');
    disp('numel(x) == numel(y)');
   return;
end

xmax = max(x);
xmin = min(x);

if(nargin<3)
    bincenters = linspace(xmin, xmax, 10);
end

bincenters(bincenters > xmax) = xmax;
bincenters(bincenters < xmin) = xmin;
bincenters = sort(unique(bincenters));

bin_edges = xmin;
for(i=1:length(bincenters)-1)
    bin_edges = [bin_edges (bincenters(i) + bincenters(i+1))/2];
end

[~,idx] = sort(x);
x = x(idx);
y = y(idx);

for(i = 2:length(bin_edges))
    idx = find((x>=bin_edges(i-1)) & (x<bin_edges(i)));
    y_bin = [y_bin nanmean(y(idx))];
    y_std = [y_std nanstd(y(idx))];
    y_err = [y_err nanstderr(y(idx))];
    
    x_bin = [x_bin nanmean(x(idx))];
    x_std = [x_std nanstd(x(idx))];
    x_err = [x_err nanstderr(x(idx))];
    
    n = [n length(idx)];
end

return;
end
