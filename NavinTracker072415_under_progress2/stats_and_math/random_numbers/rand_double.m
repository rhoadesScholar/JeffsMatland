% returns random double between 0 and n

function y = rand_double(n, len)

persistent run_today_flag;

if(isempty(run_today_flag))
    run_today_flag=1;
    rand('state', sum(100*clock));
end

if(nargin==1)
    y = n*rand;
    return;
end

y = n*rand(1,len);

return;

end
