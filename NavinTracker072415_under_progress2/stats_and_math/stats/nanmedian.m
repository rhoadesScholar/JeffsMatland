function med = nanmedian(x)

med = [];

if(size(x,1)==1 || size(x,2)==1)
    rr = x;
    rr(isnan(rr))=[];
    med = median(rr);
    return;
end


for(i=1:size(x,2))
    rr = x(:,i);
    rr(isnan(rr))=[];
    med = [med median(rr)];
end



return;

end
