function n = bracketed_rand(lower, upper)

persistent run_today_flag;

if(isempty(run_today_flag))
    run_today_flag=1;
    if(isempty((findstr(version('-release'),'14'))))
        rand('state', sum(100*clock));
        RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
    end
end

if(nargin<2)
    upper = lower(2);
    lower = lower(1);
end

if(abs(lower-upper)<1e-4)
    n=lower+randn;
    return;
end

n = (lower + (upper-lower)*rand); 

return;
end
