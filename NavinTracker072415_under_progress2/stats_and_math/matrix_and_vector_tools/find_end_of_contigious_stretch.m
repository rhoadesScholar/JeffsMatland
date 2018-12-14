function j = find_end_of_contigious_stretch(x, i)
% j = find_end_of_contigious_stretch(x, i)
% in array x, find index j contigiously linked to index i
% for example, if x = [1 2 5 8 10 15 16 17 18 19 20 25 34 40], and i=6,
% return 11

len_x = length(x);

if(i==len_x)
    j=i;
    return;
end

j=i+1;

while(x(j) - x(i) == 1)
    j=j+1;
    i=i+1;
    if(j>len_x)
        break;
    end
end
j=j-1;

return;
end
