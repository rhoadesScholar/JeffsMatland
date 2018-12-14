function newx = trim(x,k)

[d1 d2] = size(x);

if k==1
    for m=d1:-1:1
        if sum(x(m,:)) ~= 0
            break
        end
    end
    x = x(1:m,:);
end

if k==2
    for m=d2:-1:1
        if sum(x(:,m)) ~= 0
            break
        end
    end
    x = x(:,1:m);
end

newx = x;