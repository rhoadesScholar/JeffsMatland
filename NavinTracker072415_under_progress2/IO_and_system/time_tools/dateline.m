% for 2/9/09, returns 2_9_09

function result = dateline(target_date)

if(nargin==0)
    target_date = date;
end

k = datevec(target_date);
p = num2str(k(1));
result = sprintf('%d_%d_%s',k(2),k(3),p(3:4)); % 2_9_09

return;
 
end
