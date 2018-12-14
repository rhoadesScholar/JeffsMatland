% find indicies a and b that bracket target_val in vector x

function [a,b] = find_bracketing_indicies(x, target_val)

b=1;
a=1;
while(x(a)<target_val)
    a=a+1;
    if(a>length(x))
        a=length(x);
        break;
    end
end
if(a>1)
    p=a-1;
    a=p;
    while(x(a) == x(p))
        a=a-1;
        if(a==0)
           break; 
        end
    end
    a=a+1;
end

if(x(a) < target_val)

    b=a;
    while(x(b)==x(a))
        b=b+1;
        if(b>length(x))
            b=length(x);
            break;
        end
    end

    if(x(b) > target_val)

        if(b>1)
            c=b;
            while(x(b)==x(c))
                b=b+1;
                if(b>length(x))
                    break;
                end
            end
            b=b-1;
        end

        if(b>length(x))
            b=length(x);
        end
    end

end

return;
end


