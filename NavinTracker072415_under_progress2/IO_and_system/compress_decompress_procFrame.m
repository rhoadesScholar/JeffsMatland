function procFrame = compress_decompress_procFrame(input_procFrame)

global Prefs;
Prefs = define_preferences(Prefs);

procframe_scalars = {'frame_number','bkgnd_index','threshold','timestamp'};
worm_scalars = {'tracked', 'level', 'size', 'next_worm_idx', 'ecc', 'majoraxis', 'ringDist'};
worm_matricies = {'coords', 'bound_box_corner'};
clump_scalars = {'level', 'num_worms'};
clump_matricies = {'coords', 'bound_box_corner'};

procFrame = [];

% compress since given a full procFrame input
if(length(fieldnames(input_procFrame))==6) && isfield(input_procFrame, 'worm')
    
    
    for(i=1:length(input_procFrame))
        input_procFrame(i).timestamp = 0;
        
        for(j=1:length(input_procFrame(i).worm))
            if(isempty(input_procFrame(i).worm(j).next_worm_idx))
                input_procFrame(i).worm(j).next_worm_idx = 0;
            end
        end
        
        for(j=1:length(input_procFrame(i).clump))
            if ~(isfield(input_procFrame(i).clump(j), 'parent_idx')) || (isempty(input_procFrame(i).clump(j).parent_idx))
                input_procFrame(i).clump(j).parent_idx = 0;
            elseif(length(input_procFrame(i).clump(j).parent_idx)>1)
                input_procFrame(i).clump(j).parent_idx = input_procFrame(i).clump(j).parent_idx(end);
            end
        end
    end
    
    
    
    for(i=1:length(input_procFrame))
        % scalars
        procFrame(i).scalars = zeros(1,length(procframe_scalars))+NaN;
        for(s=1:length(procframe_scalars))
            procFrame(i).scalars(s) = input_procFrame(i).(procframe_scalars{s});
        end
        
        % worm
        % each row has data for a worm
        procFrame(i).worm_matrix = [];
        procFrame(i).worm_contour = zeros(3, Prefs.num_contour_points+2, length(input_procFrame(i).worm));
        for(j=1:length(input_procFrame(i).worm))
            wrm_mtrx = [];
            for(s=1:length(worm_scalars))
                wrm_mtrx = [wrm_mtrx input_procFrame(i).worm(j).(worm_scalars{s})];
            end
            
            for(s=1:length(worm_matricies))
                wrm_mtrx = [wrm_mtrx input_procFrame(i).worm(j).(worm_matricies{s})];
            end
            
            procFrame(i).worm_matrix = [procFrame(i).worm_matrix; wrm_mtrx input_procFrame(i).worm(j).body_contour.midbody];
            
            procFrame(i).worm_image{j} = input_procFrame(i).worm(j).image;
            
            % contour is actually defined
            if(sum(input_procFrame(i).worm(j).body_contour.kappa)>0)
                procFrame(i).worm_contour(1,:,j) = input_procFrame(i).worm(j).body_contour.x;
                procFrame(i).worm_contour(2,:,j) = input_procFrame(i).worm(j).body_contour.y;
                procFrame(i).worm_contour(3,2:Prefs.num_contour_points+1,j) = input_procFrame(i).worm(j).body_contour.kappa;
            end
        end
        
        % clump
        % each row has data for a clump
        procFrame(i).clump_matrix = [];
        for(j=1:length(input_procFrame(i).clump))
            wrm_mtrx = [];
            for(s=1:length(clump_scalars))
                wrm_mtrx = [wrm_mtrx input_procFrame(i).clump(j).(clump_scalars{s})];
            end
            
            for(s=1:length(clump_matricies))
                wrm_mtrx = [wrm_mtrx input_procFrame(i).clump(j).(clump_matricies{s})];
            end
            procFrame(i).clump_matrix = [procFrame(i).clump_matrix; wrm_mtrx];
            procFrame(i).clump_image{j} = input_procFrame(i).clump(j).image;
            
        end
        
    end
    procFrame = make_single(procFrame);
    return;
end

% decompress
for(i=1:length(input_procFrame))
    for(s=1:length(procframe_scalars))
        procFrame(i).(procframe_scalars{s}) =  input_procFrame(i).scalars(s);
    end
    
    num_worms = length(input_procFrame(i).worm_image);
    for(j=1:num_worms)
        
        for(s=1:length(worm_scalars))
            procFrame(i).worm(j).(worm_scalars{s}) =  input_procFrame(i).worm_matrix(j,s);
        end
        k = length(worm_scalars)+1;
        for(s=1:length(worm_matricies))
            procFrame(i).worm(j).(worm_matricies{s}) =  input_procFrame(i).worm_matrix(j,[k k+1]);
            k=k+2;
        end
        
        procFrame(i).worm(j).image = input_procFrame(i).worm_image{j};
        
        procFrame(i).worm(j).body_contour.x = input_procFrame(i).worm_contour(1,:,j);
        procFrame(i).worm(j).body_contour.y = input_procFrame(i).worm_contour(2,:,j);
        procFrame(i).worm(j).body_contour.midbody = input_procFrame(i).worm_matrix(j,end);
        
        procFrame(i).worm(j).body_contour.head = 0;
        procFrame(i).worm(j).body_contour.tail = 0;
        procFrame(i).worm(j).body_contour.neck = 0;
        procFrame(i).worm(j).body_contour.lumbar = 0;
        
        procFrame(i).worm(j).body_contour.kappa = input_procFrame(i).worm_contour(3,2:Prefs.num_contour_points+1,j);
        
        
        if(procFrame(i).worm(j).next_worm_idx == 0)
            procFrame(i).worm(j).next_worm_idx = [];
        end
    end
    
    num_clumps = size(input_procFrame(i).clump_matrix,1);
    if num_clumps == 0
        for(s=1:length(clump_scalars))
            procFrame(i).clump(1).(clump_scalars{s}) =  [];
        end
        for(s=1:length(clump_matricies))
            procFrame(i).clump(1).(clump_matricies{s}) =  [];
        end
        procFrame(i).clump(1).image = [];
    else
        for(j=1:num_clumps)

            for(s=1:length(clump_scalars))
                procFrame(i).clump(j).(clump_scalars{s}) =  input_procFrame(i).clump_matrix(j,s);
            end
            k = length(clump_scalars)+1;
            for(s=1:length(clump_matricies))
                procFrame(i).clump(j).(clump_matricies{s}) =  input_procFrame(i).clump_matrix(j,[k k+1]);
                k=k+2;
            end
            procFrame(i).clump(j).image = input_procFrame(i).clump_image{j};
        end
    end
end

procFrame = make_single(procFrame);

return;
end
