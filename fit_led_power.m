function [alpha, beta, gamma, R_fit] = fit_led_power(led_power, led_setting)

% f = ezfit(led_power, led_setting,'led_setting(led_power) = alpha*(led_power^beta)+gamma; alpha=400; beta=1; gamma=1');
% gamma = f.m(3);

f = ezfit(led_power, led_setting,'led_setting(led_power) = alpha*(led_power^beta); alpha=400; beta=1');
gamma = 0;


alpha = f.m(1);
beta = f.m(2);

R_fit = f.r2;

clear('f');

end

