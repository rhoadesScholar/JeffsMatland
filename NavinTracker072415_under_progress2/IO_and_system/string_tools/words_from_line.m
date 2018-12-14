function [words, num_words] = words_from_line(line, commentcode)
% [words, num_words] = words_from_line(line, commentcode)

if(nargin>1)
    j = strfind(line,commentcode);
    if(~isempty(j))
        line = line(1:(j(1)-1));
    end
end

w=0;
i=1;

if(i<=length(line))
    while(isspace(line(i)))   % (line(i) == ' ')
        i=i+1;
        if(i>length(line))
            break;
        end
    end
end

while(i<=length(line))

    q=1;
    w=w+1;
    while(~isspace(line(i)))  %    (line(i) ~= ' ')
        words{w}(q) = line(i);
        q=q+1;
        i=i+1;
        if(i>length(line))
            break;
        end
    end
    

    if(i<=length(line))
        while(isspace(line(i))) %  (line(i) == ' ')
            i=i+1;
            if(i>length(line))
                break;
            end
        end
    end

end

num_words = w;

return;
end
