function [xnew, y_mean, y_std, y_err, y_n] = bin_discrete_xaxis_values(x, y)
% given x array of value labels and y values array
% return xnew mean_y for those w/ the same x
% x = [1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 4 5 5 5 5 5 5];
% y = [5 5 5 4 4 4 4 3 3 3 3 2 2 2 2 2 1 1 1 1 1 1];
% xnew = [1 2 3 4 5];
% mean = [5 4 3 2 1];
% std, err = [0 0 0 0 0];
% n = [3 4 4 5 6]

eps = 1e-4;

[~,idx] = sort(x);
x = x(idx);
y = y(idx);

xnew=[];
y_mean=[];
y_std=[];
y_err=[];
y_n=[];
i=1;
while(i<=length(x))
    if(isnan(x(i)))
        break;
    end
    current_x = x(i);
    xnew = [xnew current_x];
    y_local=[];
    while(abs(x(i) - current_x)<eps)
        y_local = [y_local y(i)];
        i=i+1;
        if(i>length(x))
            break;
        end
    end
    y_n = [y_n length(y_local)];
    y_mean = [y_mean nanmean(y_local)];
    y_std = [y_std nanstd(y_local)];
    y_err = [y_err y_std(end)/sqrt(y_n(end))];
end

return;
end

