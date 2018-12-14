function [htr_struct] = concat_htr(filearray)

num_files = numel(filearray);
agg_limbposition = [];
agg_rotations = [];
agg_translations_local = [];
agg_translations_global = [];

for mmk = 1:numel(filearray)
    htrfile = filearray{mmk};

skeleton = htrReadFile(htrfile);
%skeleton2 = htrReadFile(htrfile2);


limbnames = fieldnames(skeleton);
limbstart = 15;
limbstop = numel(limbnames);
num_limbs = limbstop-limbstart;


limb_start = zeros(3,num_limbs);
limb_stop = zeros(3,num_limbs);
nframes = numel(skeleton.(limbnames{limbstart}).Tx);

limbposition = struct();
transmatricies = cell(1,limbstop);
rotmatricies = cell(1,limbstop);

angvelocity_local = cell(1,limbstop);
transvelocity_local = cell(1,limbstop);
transvelocity_global = cell(1,limbstop);

transmatricies_local = cell(1,limbstop);
rotmatricies_local = cell(1,limbstop);
rotmatricies_eul_local = cell(1,limbstop);
rotmatricies_quat_local = cell(1,limbstop);

%% obtain rotation and translationmatricies
for kk = limbstart:limbstop;

    %badframes = find(squeeze(sum(transmatrix_to_interp,2)) >10000);
    %transmatrix_to_interp(badframes,:) = nan;
    
    %% running interpolation
    fprintf('Running interpolation \n')
     scalematrix_to_interp = skeleton.(limbnames{kk}).SF;
     scalematrix_to_interp(isnan(scalematrix_to_interp)) = nanmean(scalematrix_to_interp);
         transmatrix_to_interp = cat(2,skeleton.(limbnames{kk}).Tx, skeleton.(limbnames{kk}).Ty, skeleton.(limbnames{kk}).Tz);
      rotmatrix_to_interp = cat(2,skeleton.(limbnames{kk}).Rz, skeleton.(limbnames{kk}).Ry, skeleton.(limbnames{kk}).Rx);
      %find bad frames
    badframes = find(squeeze(sum(rotmatrix_to_interp,2)) >10^6);
    %set to nan
    rotmatrix_to_interp(badframes,:) = nan;
       transmatrix_to_interp(badframes,:) = nan;
        scalematrix_to_interp(badframes,:) = nan;

    [ rotmatrix_eul,fake_frames] = markershortinterp(rotmatrix_to_interp,60,5);    
    [ transmatrix,fake_frames] = markershortinterp(transmatrix_to_interp,60,5);
     [  skeleton.(limbnames{kk}).SF,fake_frames] = markershortinterp(scalematrix_to_interp,60,5);
   
     %rotmatrix = rotmatrix_to_interp;
    % transmatrix = transmatrix_to_interp;
    %  skeleton.(limbnames{kk}).SF =scalematrix_to_interp;
     
    %reshape
     transmatrix = reshape(transmatrix', 3,1,nframes);
           rotmatrix_quat = eul2quat(deg2rad(rotmatrix_eul), skeleton.EulerRotationOrder);

      rotmatrix = eul2rotm(deg2rad(rotmatrix_eul), skeleton.EulerRotationOrder);
 
   %  rotmatrix = reshape(transmatrix, 3,1,nframes);
     
     
    
% transmatrix =   reshape(cat(2,skeleton.(limbnames{kk}).Tx, skeleton.(limbnames{kk}).Ty, skeleton.(limbnames{kk}).Tz)',3,1,nframes);

 
 
 limbvec = zeros(3,1,nframes);
 limbvec(2,1,:) = skeleton.(limbnames{kk}).SF*1;
 
 %% get the local transformation
  limbposition.(limbnames{kk}) = cat(2,transmatrix,transmatrix+ mtimesx(rotmatrix,limbvec));
  transmatricies{kk} = cell(1,1);
    rotmatricies{kk} = cell(1,1);

    transmatricies{kk}{1} =  transmatrix;
     rotmatricies{kk}{1} =  rotmatrix;
     
      transvelocity_global{kk} = diff(squeeze(transmatrix),1,2);
    transvelocity_local{kk} =  diff(squeeze(transmatrix),1,2);%diff along second dim
      angvelocity_local{kk} =  diff(cat(2,(skeleton.(limbnames{kk}).Rz),...
     (skeleton.(limbnames{kk}).Ry),...
     (skeleton.(limbnames{kk}).Rx )),1,1)';
      
        
    transmatricies_local{kk} =  transmatrix;
      rotmatricies_local{kk} =  rotmatrix;
      rotmatricies_eul_local{kk} = rotmatrix_eul;
rotmatricies_quat_local{kk} = rotmatrix_quat;

end

root_nodes = [];
skeleton_names = fieldnames(skeleton.tree);
for mm = 1:numel(skeleton_names)
    if (strcmp(skeleton.tree.(skeleton_names{mm}),'GLOBAL'))
root_nodes = cat(1,root_nodes,mm);
    end
end


completed_node_list = root_nodes;
parent_node = root_nodes;

while numel(completed_node_list)<numel(skeleton_names)
    new_parent_nodes = [];
for kk = 1:numel(parent_node)
children_nodes = getchildren(parent_node(kk),skeleton.tree);
for jj = 1:numel(children_nodes)


%get list of parents
%loop over all children and transform
    childind = limbstart+children_nodes(jj)-1;
    parentind = limbstart+parent_node(kk)-1;
    
     limbvec = zeros(3,1,nframes);
 limbvec(2,1,:) = skeleton.(limbnames{childind}).SF*1;
  
  %% rotate the child
% limbposition.(limbnames{childind}) = cat(2,transmatricies{parentind}+mtimesx(rotmatricies{parentind},limbposition.(limbnames{childind})(:,1,:)) ,...
% transmatricies{parentind}+mtimesx(rotmatricies{parentind},limbposition.(limbnames{childind})(:,2,:)));
%% apply transformation for each child index
for mm = 1:numel(transmatricies{parentind})
limbposition.(limbnames{childind}) = rotatechild(limbposition.(limbnames{childind}),rotmatricies{parentind}{mm},transmatricies{parentind}{mm});
transmatricies{childind}{numel(transmatricies{childind})+1} = transmatricies{parentind}{mm};
rotmatricies{childind}{numel(rotmatricies{childind})+1} = rotmatricies{parentind}{mm};

transvelocity_global{childind} = transvelocity_global{childind}+diff(squeeze(transmatricies{parentind}{mm}),1,2);

end
%% update the child matricies


new_parent_nodes = cat(1,new_parent_nodes,children_nodes(jj));
completed_node_list = cat(1,completed_node_list,children_nodes(jj));
end
end
parent_node = new_parent_nodes;

end

% clear unneeded parental (repeated) matricies
clear transmatricies
clear rotmatricies


%% save to the batch

if (mmk == 1)
agg_limbposition = limbposition;
agg_rotations = rotmatricies_local;
agg_rotations_quat = rotmatricies_quat_local;
agg_rotations_eul = rotmatricies_eul_local;

agg_translations_local = transmatricies_local;
agg_translations_global = transvelocity_global;


else
    for mmm = 1:numel(agg_rotations)
        agg_rotations{mmm} = cat(3,agg_rotations{mmm},rotmatricies_local{mmm});
                agg_rotations_quat{mmm} = cat(1,agg_rotations_quat{mmm},rotmatricies_quat_local{mmm});
        agg_rotations_eul{mmm} = cat(1,agg_rotations_eul{mmm},rotmatricies_eul_local{mmm});

        
agg_translations_local{mmm} = cat(3,agg_translations_local{mmm},transmatricies_local{mmm});
agg_translations_global{mmm} = cat(2,agg_translations_global{mmm},transvelocity_global{mmm});
    end
       fn_limb = fieldnames(agg_limbposition);    
   for jj = 1:numel(fn_limb)
       agg_limbposition.( fn_limb{jj}) = cat(3,agg_limbposition.( fn_limb{jj}),limbposition.(fn_limb{jj}));
   end
   
    
    
end


end

agg_rotations_eul = agg_rotations_eul(~cellfun('isempty',agg_rotations_eul)) ;

agg_rotations = agg_rotations(~cellfun('isempty',agg_rotations)) ;
agg_rotations_quat = agg_rotations_quat(~cellfun('isempty',agg_rotations_quat)) ;

for mm = 1:numel(agg_rotations_eul)
    agg_rotations_quat{mm} = eul2quat(deg2rad(agg_rotations_eul{mm}), skeleton.EulerRotationOrder);

      agg_rotations{mm} = eul2rotm(deg2rad(agg_rotations_eul{mm}), skeleton.EulerRotationOrder);
end

agg_translations_local = agg_translations_local(~cellfun('isempty',agg_translations_local)) ;
agg_translations_global = agg_translations_global(~cellfun('isempty',agg_translations_global)) ;

%% get rid of the conjugations in the quaternions which can cause it to rotate 2:1
for mm = 1:numel(agg_rotations_quat)

    initial_sign = agg_rotations_quat{mm}(1,:);
        sign_product = sum(bsxfun(@times,(agg_rotations_quat{mm}(:,2:4)),initial_sign(2:4)),2);

agg_rotations_quat{mm} = bsxfun(@times,agg_rotations_quat{mm},sign(sign_product));
end


htr_struct = struct();
htr_struct.agg_rotations = agg_rotations;
htr_struct.agg_rotations_eul = agg_rotations_eul;
htr_struct.agg_rotations_quat = agg_rotations_quat;
htr_struct.tree = skeleton.tree;
htr_struct.jointnames = fieldnames(skeleton.tree);

htr_struct.agg_limbposition = agg_limbposition;
htr_struct.agg_translations_local = agg_translations_local;
htr_struct.agg_translations_global = agg_translations_global;


end
