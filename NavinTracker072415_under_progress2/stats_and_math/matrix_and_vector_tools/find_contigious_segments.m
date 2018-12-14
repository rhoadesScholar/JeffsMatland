function C = find_contigious_segments(x)
% C = find_contigious_segments(x, i)
% in array x, find contigious segments
% for example, if x = [1 2 5 8 10 15 16 17 18 19 20 25 34 40]
% return C = {[1 2], [5], [8], [10], [15 16 17 18 19 20], [25], [34], [40]}

len_x = length(x);

k=1;
i=1;
while(i<=len_x)

    j = find_end_of_contigious_stretch(x, i);
    C{k} = x(i:j);
    k=k+1;

    i = j+1;
end

return;
end
