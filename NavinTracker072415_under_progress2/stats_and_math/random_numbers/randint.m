% returns random int>0 between 0 and n

function y = randint(n, len, unique_flag)


if(nargin==0)
    disp(['usage: y = randint(n, len, unique_flag)']);
    return;
end

persistent run_today_flag;

if(isempty(run_today_flag))
    run_today_flag=1;
    if(isempty((findstr(version('-release'),'14'))))
        rand('state', sum(100*clock));
        RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
    end
end

if(nargin==1)
    y=0;
    while(y==0)
        y = floor(rand_double(n+1));
    end
    return;
end

if(nargin<3)
    unique_flag=1;
end

if(unique_flag == 1)
   if(len>n)
       unique_flag = 0;
   else  
       y = randperm(n,len);
       return;
   end
end

y = floor(rand_double(n+1, len ));

for(i=1:len)
    while(y(i)==0)
        y(i) = floor(rand_double(n+1));
    end
end


% purge and replace non-unique values
if(unique_flag==1)
    
    y = unique(y);
    
    while(length(y)<len)
        y = [y randint(n)];
        y = unique(y);
    end
   
    % now re-scramble since unique is sorted
    y1 = y;
    y = [];
    while(length(y)<len)
        idx = randint(length(y1));
        y = [y y1(idx)];
        y1(idx) = [];
    end
end

return;
end
