function weighted_mean = magnitude_weighted_mean(vv)

v = abs(vv);
sum_v = nansum(v);

if(sum_v==0)
    weighted_mean = 0;
    return;
end

weighted_mean = nansum(vv.*(v./sum_v));

return;
end
