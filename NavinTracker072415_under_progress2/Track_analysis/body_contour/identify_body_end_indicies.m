function bodyend_indicies = identify_body_end_indicies(neighbor_matrix)

bodyend_indicies=[];

if(isempty(neighbor_matrix))
    return;
end

% bodyend has only one neighbor
for(k=1:length(neighbor_matrix(:,1)))
    if(length(find(neighbor_matrix(k,:)>0)) == 1)
        bodyend_indicies = [bodyend_indicies k];
    end
end

% % filters out midbody spurs
% % a bodyend neighbor has only one additional neighbor in addition to the bodyend itself
% if(length(bodyend_indicies) > 2)
%     q=1;
%     while(q <= length(bodyend_indicies))
%         if( length(find(neighbor_matrix(find(neighbor_matrix(bodyend_indicies(q),:) > 0),:)>0)) > 2)
%             bodyend_indicies(q) = [];
%         end
%         q=q+1;
%     end
% end

% % a bodyends-neighbor neighbor has only one additional neighbor in addition to the bodyend-neighbor itself
% if(length(bodyend_indicies) > 2)
%     q=1;
%     while(q <= length(bodyend_indicies))
%         q_neighbor = neighbor_matrix(bodyend_indicies(q),  find(neighbor_matrix(bodyend_indicies(q),:) > 0));
%         q_neighbor_neighbors = neighbor_matrix(q_neighbor,  find(neighbor_matrix(q_neighbor,:) > 0));
%         qnn = q_neighbor_neighbors(find(q_neighbor_neighbors~=q_neighbor));
%         
%         if( length(qnn) > 1)
%             bodyend_indicies(q) = [];
%         end
%         q=q+1;
%     end
% end

return;
end
