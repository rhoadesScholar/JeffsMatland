function [coef, pval] = nancorr(x, y)

x = matrix_to_vector(x)';
y = matrix_to_vector(y)';

nan_x_idx = find(isnan(x));
nan_y_idx = find(isnan(y));

nan_idx = unique([nan_x_idx; nan_y_idx]);

x(nan_idx) = [];
y(nan_idx) = [];

[coef, pval] = corr(x, y);

return;
end
