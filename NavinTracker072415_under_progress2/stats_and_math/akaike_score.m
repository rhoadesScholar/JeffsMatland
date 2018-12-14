function [aic, rss] = akaike_score(data, model, num_params)
%   aic = akaike_score(data, model, num_params) or 
% aic = akaike_score(n, rss, num_params) 
% n= # datapoints, rss = residual sum of squares, num_params = # parameters

if(nargin<1)
    disp(['aic = akaike_score(data, model, num_params) or aic = akaike_score(n, rss, num_params)'])
    return
end


if(isscalar(data) && isscalar(model))
    n = data;
    rss = model;
else
    n = length(data);
    rss = nansum((data-model).^2);
end

aic = n*log(rss/n) + 2*num_params + (2*num_params*(num_params+1))/(n-num_params-1);  

return;
end
