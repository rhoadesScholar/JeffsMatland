function BinData = calc_and_propagate_BinData_error(BinData, i, timeindex, field, avg, sigma, err)

sigmafield = sprintf('%s_s',field);
errfield = sprintf('%s_err',field);

num = length(timeindex);

BinData.(field)(i) = nanmean(avg(timeindex));

nan_v = isnan(sigma(timeindex(1:num)));
n = num - sum(nan_v);
nanidx = find(nan_v==1) + timeindex(1)-1;
sigma(nanidx)=0;
err(nanidx)=0;

BinData.(sigmafield)(i) = sum(sigma(timeindex(1:num)).^2);
BinData.(errfield)(i)  = sum(err(timeindex(1:num)).^2);


if(n~=0)
    BinData.(sigmafield)(i) = sqrt(BinData.(sigmafield)(i))/n;
    BinData.(errfield)(i) = sqrt(BinData.(errfield)(i))/n;
end

return;
end
