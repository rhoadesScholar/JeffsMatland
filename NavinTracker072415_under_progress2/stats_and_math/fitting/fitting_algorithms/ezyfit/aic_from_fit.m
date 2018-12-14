function [aic, ss] = aic_from_fit(f)

if(nargin<1)
    disp(['[aic, ss] = aic_from_fit(f)'])
    return
end

if(isfield(f,'m'))
    num_var = length(f.m);
else
    num_var = length(f.param);
end

[aic, ss] = akaike_score(f.y, f.yfit, num_var);

return;
end
