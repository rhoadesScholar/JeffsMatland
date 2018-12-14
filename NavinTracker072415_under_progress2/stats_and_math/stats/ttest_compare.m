function p = ttest_compare(mean_X, std_X, nx, mean_Y, std_Y, ny, tail_type)
% p = ttest_compare(mean_X, std_X, nx, mean_Y, std_Y, ny, tail_type)
% compares (mean_X, std_X, nx and mean_Y, std_Y, ny via the t-test
% returns p
% tail is 'both' (default; p(X==Y)), 'right' p(Y>X), or 'left' p(X>Y)

if(nargin<4)
    disp('p = ttest_compare(mean_X, std_X, nx, mean_Y, std_Y, ny, tail_type)')
    return
end

if(nargin<6)
    std_Y=[];
    ny=[];
end

if(nargin<7)
    tail_type = 'both';
end

x = simulate_data_from_mean_stddev_n(mean_X, std_X, nx);

if(isempty(std_Y))
    [h,p] = ttest(x,mean_Y);
   return; 
end
y = simulate_data_from_mean_stddev_n(mean_Y, std_Y, ny);

[h,p] = ttest2(x,y,0.05,tail_type);

return;
end
