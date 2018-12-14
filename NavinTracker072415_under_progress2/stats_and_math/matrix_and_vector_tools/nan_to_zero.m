function x = nan_to_zero(a)
% x = nan_to_zero(a)

x = matrix_replace(a, '==', NaN,  0);

return;
end
