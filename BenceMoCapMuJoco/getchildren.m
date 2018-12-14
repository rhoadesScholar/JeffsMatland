function children_nodes = getchildren(parent_node,tree)
%input a structure tree and get the children of a specific parent 

skeleton_names = fieldnames(tree);
parent_name = skeleton_names(parent_node);

children_nodes = [];
for mm = 1:numel(skeleton_names)
    if (strcmp(tree.(skeleton_names{mm}),parent_name))
children_nodes = cat(1,children_nodes,mm);
    end
end

end