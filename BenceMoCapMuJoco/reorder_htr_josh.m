%% load the htr struct
htr_struct = load('E:\Dropbox (Olveczky)\JesseMarshall\mocap_for_josh\htr_struct_file_w_skeleton.mat');
subfields = fieldnames(htr_struct.skeleton.(htr_struct.jointnames{kk}));

% the prime skeleton is the flipped one
htr_struct.skeleton_prime = htr_struct.skeleton;

%% segments to flip
segments_to_flip = {'RFemur','LFemur','SpineF','RScap','LScap','Rarm','LArm','LScap_2'};
for mm=1:numel(segments_to_flip)
    jointnum = find(strcmp(segments_to_flip{mm}, htr_struct.jointnames));
    
    %% get the scale factor and rotation matrix of the segment
    nframes = size(htr_struct.agg_rotations_eul{jointnum},1);
    rotmatrix = eul2rotm(deg2rad(htr_struct.agg_rotations_eul{jointnum}), htr_struct.skeleton.EulerRotationOrder);
    limbvec = zeros(3,1,nframes);
    limbvec(2,1,:) = htr_struct.skeleton.(htr_struct.jointnames{mm}).SF*1;
    
    %% get the local transformation
    transmatrix = htr_struct.agg_translations_local{jointnum};
    limbposition.(htr_struct.jointnames{jointnum}) = cat(2,transmatrix,transmatrix+ mtimesx(rotmatrix,limbvec));
    
    
    % reverse the ends and get the (-) rotation matrix
    htr_struct.skeleton_prime.(htr_struct.jointnames{mm}).Tx = squeeze(limbposition.(htr_struct.jointnames{jointnum})(1,2,:));
    htr_struct.skeleton_prime.(htr_struct.jointnames{mm}).Ty = squeeze(limbposition.(htr_struct.jointnames{jointnum})(2,2,:));
    htr_struct.skeleton_prime.(htr_struct.jointnames{mm}).Tz = squeeze(limbposition.(htr_struct.jointnames{jointnum})(3,2,:));
    %in radians, +- pi
    rotation_inverted = rotm2eul(-rotmatrix, htr_struct.skeleton.EulerRotationOrder);
    htr_struct.skeleton_prime.(htr_struct.jointnames{mm}).Rx = squeeze(rotation_inverted(:,1));
    htr_struct.skeleton_prime.(htr_struct.jointnames{mm}).Ry = squeeze(rotation_inverted(:,2));
    htr_struct.skeleton_prime.(htr_struct.jointnames{mm}).Rz = squeeze(rotation_inverted(:,3));
    
end

%% get the offset skeleton
null_skeleton = struct();
offset_skeleton = htr_struct.skeleton_prime;
for kk = 1:numel(htr_struct.jointnames)
    for ll = 1:numel(subfields)
        null_skeleton.(htr_struct.jointnames{kk}).(subfields{ll}) = nanmedian(htr_struct.skeleton_prime.(htr_struct.jointnames{kk}).(subfields{ll}));
    end
        for ll = 2:4
        % the position is simply the difference
        offset_skeleton.(htr_struct.jointnames{kk}).(subfields{ll}) = bsxfun(@minus,(htr_struct.skeleton_prime.(htr_struct.jointnames{kk}).(subfields{ll})),...
            null_skeleton.(htr_struct.jointnames{kk}).(subfields{ll}));
        end
    
end

htr_struct.null_skeleton = null_skeleton;
htr_struct.offset_skeleton = offset_skeleton;

newfile = 'E:\Dropbox (Olveczky)\JesseMarshall\mocap_for_josh\htr_struct_file_offsets.mat';
save(newfile,'-struct','htr_struct');



%% verify this tree structure by plotting the null pose
% also gives examples of searching through the tree
%search through the tree

%% get translation and rotation matricies
limbnames = htr_struct.jointnames;
    nframes = size(htr_struct.agg_rotations_eul{jointnum},1);

for kk = 1:numel(htr_struct.jointnames)
transmatrix = cat(2,htr_struct.skeleton_prime.(limbnames{kk}).Tx, htr_struct.skeleton_prime.(limbnames{kk}).Ty, htr_struct.skeleton_prime.(limbnames{kk}).Tz);
      rotmatrix_eul = cat(2,htr_struct.skeleton_prime.(limbnames{kk}).Rz, htr_struct.skeleton_prime.(limbnames{kk}).Ry, htr_struct.skeleton_prime.(limbnames{kk}).Rx);

transmatrix = reshape(transmatrix', 3,1,nframes);
rotmatrix = eul2rotm(deg2rad(rotmatrix_eul) ,htr_struct.skeleton_prime.EulerRotationOrder);

limbvec = zeros(3,1,nframes);
limbvec(2,1,:) = htr_struct.skeleton_prime.(limbnames{kk}).SF*1;

%% get the local transformation
limbposition.(limbnames{kk}) = cat(2,transmatrix,transmatrix+ mtimesx(rotmatrix,limbvec));
transmatricies{kk} = cell(1,1);
rotmatricies{kk} = cell(1,1);

transmatricies{kk}{1} =  transmatrix;
rotmatricies{kk}{1} =  rotmatrix;
end

%% get the root nodes (1)
root_nodes = [];
skeleton_names = fieldnames(htr_struct.skeleton_prime.tree);
for mm = 1:numel(skeleton_names)
    if (strcmp(htr_struct.skeleton_prime.tree.(skeleton_names{mm}),'GLOBAL'))
        root_nodes = cat(1,root_nodes,mm);
    end
end

%% get the overall limb positions
completed_node_list = root_nodes;
parent_node = root_nodes;
limbstart = 1;
while numel(completed_node_list)<numel(skeleton_names)
    new_parent_nodes = [];
    for kk = 1:numel(parent_node)
        children_nodes = getchildren(parent_node(kk),htr_struct.skeleton_prime.tree);
        for jj = 1:numel(children_nodes)
            %get list of parents
            %loop over all children and transform
            childind = limbstart+children_nodes(jj)-1;
            parentind = limbstart+parent_node(kk)-1;
            
            limbvec = zeros(3,1,nframes);
            limbvec(2,1,:) = htr_struct.skeleton_prime.(limbnames{childind}).SF*1;
            
            %% rotate the child
            %% apply transformation for each child index
            for mm = 1:numel(transmatricies{parentind})
                limbposition.(limbnames{childind}) = rotatechild(limbposition.(limbnames{childind}),rotmatricies{parentind}{mm},transmatricies{parentind}{mm});
                transmatricies{childind}{numel(transmatricies{childind})+1} = transmatricies{parentind}{mm};
                rotmatricies{childind}{numel(rotmatricies{childind})+1} = rotmatricies{parentind}{mm};
            end
            %% update the child matricies
            new_parent_nodes = cat(1,new_parent_nodes,children_nodes(jj));
            completed_node_list = cat(1,completed_node_list,children_nodes(jj));
        end
    end
    parent_node = new_parent_nodes;
end

%% plot the agg limb position
frameplot = 10000;
kk = 1:numel(limbposition)
figure(33)
plot3(squeeze(limbposition.SpineR(1,1,frameplot)),squeeze(limbposition.SpineR(2,1,frameplot)),squeeze(limbposition.SpineR(3,1,frameplot)))



htr_struct.null_skeleton

mean_position = median()