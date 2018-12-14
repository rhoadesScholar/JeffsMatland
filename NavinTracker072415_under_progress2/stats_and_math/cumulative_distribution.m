function [cumdist, t] = cumulative_distribution(x, cutoff)
% [cumdist, t] = cumulative_distribution(x, cutoff)
% Returns the cumulative distribution in a manner analogous to hist.
% Edits out repetitive values in cumdist (these values are used for the
% calculation however)


% % for delta-ecc and angspeed
% q = sort(x(find(~isnan(x))));
% % idx = find(q<=1e-3);
% % q = q(idx(end):end);
% % clear('idx');
% m = length(q);
% k=1;
% for(i=1:20:m)
%     idx(k) = randint(m);
%     k=k+1;
% end
% w = q(idx);
% p = sort(w(find(~isnan(w))));

% p = p(find(p>=0.4));  %  for inter-event intervals

cumdist = [];
t = [];

p = sort(x(find(~isnan(x))));

if(nargin>1)
    p = p(find(p>=cutoff)); 
end

n = length(p);
i = 1:n;
cd = (n-i)./n;

% deal w/ repetitive values

k=0;
i=1;
while(i<=n)
   
    k = k+1;
    t(k) = p(i);
    cumdist(k) = cd(i);
    
    while(t(k) == p(i))
       i = i+1; 
       if(i>n)
           break
       end
    end
end

clear('cd');
clear('p');

return;

end

