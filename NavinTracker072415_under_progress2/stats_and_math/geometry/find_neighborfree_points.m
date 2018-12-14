function neighborfree_idx = find_neighborfree_points(x,y)

if(length(x)~=length(y))
    error('For neighborfree_idx = find_neighborfree_points(x,y) x and y must be vectors of the same length')
    return
end

neighborfree_idx = [];

j_idx = 1:length(x); 
xj = x; yj = y;
for(i=1:length(x))
    flag = 1;
    xj(i)=NaN;
    [minval_x,idx] = min(abs(x(i) - x(j_idx)));
    xj(i) = x(i);
    if(minval_x(1)<=1)
        yj(i)=NaN;
        [minval_y,idx] = min(abs(y(i) - y(j_idx)));
        yj(i) = y(i);
        if(minval_y(1)<=1)
            flag=0;
        end
    end
    if(flag==1)
        neighborfree_idx = [neighborfree_idx i];
    end
end

return;
end

% neighborfree_idx = 1:length(x);
% 
% for(i=1:length(x))
%     j=1;
%     while(j<=length(x))
%         if(j~=i)
%             if(abs(x(i) - x(j)) <= 1 && abs(y(i) - y(j)) <= 1) % i and j are neighbors
%                 neighborfree_idx(i)=length(x)+100;
%                 break;
%             end
%         end
%         j=j+1;
%     end
% end
% 
% neighborfree_idx = sort(neighborfree_idx);
% 
% i=1;
% while(neighborfree_idx(i)<=length(x))
%     i=i+1;
% end
% neighborfree_idx = neighborfree_idx(1:i-1);
% 
% return;
% end
