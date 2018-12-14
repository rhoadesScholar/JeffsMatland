function interpolated_values = linear_interpolate(x1, y1, x2, y2, x_inter)

% interpolated_values = interp1q([x1 x2],[y1 y2], x_inter);

[m,b] = fit_line([x1 x2], [y1 y2]);
interpolated_values = m*x_inter + b;

return;
end
