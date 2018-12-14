% find the longest contigious stretch of numbers in array x
% for example, if x = [ 1 2 6 9 12 16 17 18 19 20 21 22 30 31 32 40]
% return i=6 and j=12

function [i_best, j_best, best_len] = find_longest_contigious_stretch_in_array(x)

len_x = length(x);

best_len = 0;
i_best = 1;
j_best = len_x;

for(i=1:len_x)
    j = find_end_of_contigious_stretch(x, i);
    len = j-i+1;
    if(len > best_len)
        best_len = len;
        i_best = i;
        j_best = j;
    end
end

return;
end
