function [attribute_vector,x,y] = attribute_histogram(Tracks, attribute, numbins, starttime, endtime)
% [attribute_vector,x,y] = attribute_histogram(Tracks, attribute, numbins, starttime, endtime)
% if numbins not defined, then sshist to get optimal number of bins
% if numbins == 0, then x,y is the cumulative distribution

if(nargin<1)
    disp('usage: [attribute_vector,x,y] = attribute_histogram(Tracks, attribute, numbins, starttime, endtime)')
    return
end

epsilon = 1e-4;

y=[];
x=[];

if(nargin < 3)
    numbins = [];
end

if(nargin<5)
    starttime = min_struct_array(Tracks,'Time');
    endtime = max_struct_array(Tracks,'Time');
end

if(isempty(starttime) || isempty(endtime))
    starttime = min_struct_array(Tracks,'Time');
    endtime = max_struct_array(Tracks,'Time');
end

if(~isfield(Tracks(1),attribute))
    attribute_vector = (reorientation_attribute_vector(Tracks, attribute, starttime, endtime));
    
    if(nargin < 3 || isempty(numbins))
        numbins = sshist(attribute_vector);
    end
    
    if(numbins > 0)
        [y,x] = hist(attribute_vector, numbins);
        y = y/nansum(y);
    else
        [y,x] = cumulative_distribution(attribute_vector);
    end
    return;
end

if(~isfield(Tracks(1),attribute))
    disp(sprintf('error: Cannot find %s in Tracks',attribute))
    return
end

attribute_matrix = single(create_attribute_matrix_from_Tracks(Tracks, attribute, starttime, endtime));
state_matrix = single(create_attribute_matrix_from_Tracks(Tracks, 'State', starttime, endtime));

ring_state_matrix = state_matrix;
ring_state_matrix = matrix_replace(ring_state_matrix,'<',num_state_convert('ring'),1);
ring_state_matrix = matrix_replace(ring_state_matrix,'>=',num_state_convert('ring'),NaN);
attribute_matrix = attribute_matrix.*ring_state_matrix;

attribute_vector = single(matrix_to_vector(attribute_matrix));
state_vector = single(matrix_to_vector(state_matrix));


if(strcmpi(attribute,'Speed') || strcmpi(attribute,'Eccentricity') || strcmpi(attribute,'head_angle') || strcmpi(attribute,'tail_angle') || strcmpi(attribute,'body_angle') || strcmpi(attribute,'midbody_angle'))
   state_vector(state_vector > num_state_convert('fwd_state')) = NaN;
   attribute_vector(isnan(state_vector))=[];
   attribute_vector = abs(attribute_vector);
end

if(strcmpi(attribute,'AngSpeed'))
   state_vector(state_vector > num_state_convert('fwd_state')) = NaN;
   attribute_vector(isnan(state_vector))=[];
   attribute_vector = corrected_bearing(attribute_vector);
   attribute_vector = abs(attribute_vector);
end

if(strcmpi(attribute,'Curvature') || strcmpi(attribute,'custom_metric'))
   % fwd and pureupsilon/omega
   idx = find(state_vector < num_state_convert('fwd_state') | abs(state_vector - num_state_convert('pure_upsilon'))<epsilon | abs(state_vector - num_state_convert('pure_omega')) < epsilon);
   state(~idx) = NaN;
   attribute_vector(isnan(state))=[];
end

if(nargin < 3 || isempty(numbins))
    numbins = sshist(attribute_vector);
end

if(numbins>0)
    [y,x] = hist(attribute_vector, numbins);
    y = y/nansum(y);
else
    [y,x] = cumulative_distribution(attribute_vector);
end

return;
end


