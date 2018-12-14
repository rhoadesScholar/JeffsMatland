function n = defined_randn(mean, std)
% n = defined_randn(mean, std) normal dist random numbers w/ mean and std

persistent run_today_flag;

if(isempty(run_today_flag))
    run_today_flag=1;
    if(isempty((findstr(version('-release'),'14'))))
        rand('state', sum(100*clock));
        RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
    end
end

if(isscalar(mean))
    if(isscalar(std))
        n = mean + std*randn;
        return;
    end
end

n = mean + std.*randn(size(mean));


return;
end
