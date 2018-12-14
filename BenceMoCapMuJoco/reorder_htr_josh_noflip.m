%% load the htr struct
htr_struct = load('E:\Dropbox (Olveczky)\JesseMarshall\mocap_for_josh\htr_struct_file_2.mat');
subfields = fieldnames(htr_struct.skeleton.(htr_struct.jointnames{kk}));

% the prime skeleton is the flipped one
htr_struct.skeleton_prime = htr_struct.skeleton;
% 
% %% re concat the new version
% filearray = {'Y:\Jesse\Data\Motionanalysis_captures\Vicon3\20170721\skeletoncaptures\nolj_Vicon3_recording_amphetamine_vid1.htr'}
% 
%     [htr_struct] = concat_htr(filearray);
% save('E:\Dropbox (Olveczky)\JesseMarshall\mocap_for_josh\htr_struct_file_2.mat','-struct','htr_struct');
%     


%% get the offset skeleton
null_skeleton = struct();
offset_skeleton = htr_struct.skeleton_prime;
for kk = 1:numel(htr_struct.jointnames)
    for ll = 1:numel(subfields)
        null_skeleton.(htr_struct.jointnames{kk}).(subfields{ll}) = nanmedian(htr_struct.skeleton_prime.(htr_struct.jointnames{kk}).(subfields{ll}));
    end
        for ll = 2:7
        % the position is simply the difference
        offset_skeleton.(htr_struct.jointnames{kk}).(subfields{ll}) = bsxfun(@minus,(htr_struct.skeleton_prime.(htr_struct.jointnames{kk}).(subfields{ll})),...
            null_skeleton.(htr_struct.jointnames{kk}).(subfields{ll}));
        end
        ll = 8;
         offset_skeleton.(htr_struct.jointnames{kk}).(subfields{ll}) = bsxfun(@rdivide,(htr_struct.skeleton_prime.(htr_struct.jointnames{kk}).(subfields{ll})),...
            null_skeleton.(htr_struct.jointnames{kk}).(subfields{ll}));
    
end

for kk=1:numel(htr_struct.jointnames)
    fprintf('mean for joint %s is fr %f Tx %f Ty %f Tz %f Rx %f Ry %f Rz %f SF %f \n',htr_struct.jointnames{kk},...
        struct2array(null_skeleton.(htr_struct.jointnames{kk})))
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

for kk = 1:numel(limbnames)
figure(33)
hold on
plot3(squeeze(limbposition.(limbnames{kk})(1,:,frameplot)),squeeze(limbposition.(limbnames{kk})(2,:,frameplot)),...
    squeeze(limbposition.(limbnames{kk})(3,:,frameplot)),'ko','Markersize',6)
plot3(squeeze(limbposition.(limbnames{kk})(1,:,frameplot)),squeeze(limbposition.(limbnames{kk})(2,:,frameplot)),...
    squeeze(limbposition.(limbnames{kk})(3,:,frameplot)))

end


htr_struct.null_skeleton

mean_position = median()