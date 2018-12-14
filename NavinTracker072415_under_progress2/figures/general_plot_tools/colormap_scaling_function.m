function y = colormap_scaling_function(x, A, B, maxlim, minlim, slope)

if(nargin < 6)
    slope=1;
end

y =   slope*((A-B)/(maxlim - minlim))*(x-maxlim) + A ;

y = matrix_replace(y,'>=',A,A);
y = matrix_replace(y,'<=',B,B);

return;
end
