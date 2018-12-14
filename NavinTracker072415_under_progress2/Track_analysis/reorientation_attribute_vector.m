function attribute_vector = reorientation_attribute_vector(Tracks, input_attribute, starttime, endtime)

attribute_vector=[];

if(nargin<4)
    starttime = min_struct_array(Tracks,'Time');
    endtime = max_struct_array(Tracks,'Time');
end

reori_class = '';
[words, num_words] = words_from_line(input_attribute);
attribute = words{1};
if(num_words > 1)
    reori_class = words{end};
end
reori_class = lower(reori_class);

len_Tracks = length(Tracks);

i=1;
while(isempty(Tracks(i).Reorientations))
    i=i+1;
    if(i>len_Tracks)
        return;
    end
end
if(~isfield(Tracks(i).Reorientations(1),attribute))
    disp(sprintf('error: Cannot find %s in Reorientations',attribute))
    return;
end

if(strcmp(attribute,'class'))
    for(i=1:len_Tracks)
        for(j=1:length(Tracks(i).Reorientations))
            if(Tracks(i).Time(Tracks(i).Reorientations(j).start) >= starttime && Tracks(i).Time(Tracks(i).Reorientations(j).end) <= endtime)
                if(isempty(strfind(Tracks(i).Reorientations(j).class,'ring')))
                    if(isempty(reori_class))
                        attribute_vector = [attribute_vector num_state_convert(Tracks(i).Reorientations(j).class)];
                    else
                        if(~isempty(strfind(lower(Tracks(i).Reorientations(j).class), reori_class))) % if(strcmpi(Tracks(i).Reorientations(j).class, reori_class))
                            attribute_vector = [attribute_vector num_state_convert(Tracks(i).Reorientations(j).class)];
                        end
                    end
                else
                    at = Tracks(i).Reorientations(j).class(1:end-5);
                    if(isempty(reori_class))
                        attribute_vector = [attribute_vector num_state_convert(at)];
                    else
                        if(~isempty(strfind(lower(at), reori_class)))
                            attribute_vector = [attribute_vector num_state_convert(at)];
                        end
                    end
                end
            end
        end
    end
    return;
end


for(i=1:len_Tracks)
    for(j=1:length(Tracks(i).Reorientations))
        if(Tracks(i).Time(Tracks(i).Reorientations(j).start) >= starttime && Tracks(i).Time(Tracks(i).Reorientations(j).end) <= endtime)
            %    if(isempty(strfind(Tracks(i).Reorientations(j).class,'ring')))
            if(isempty(reori_class))
                attribute_vector = [attribute_vector Tracks(i).Reorientations(j).(attribute)];
            else
                if(~isempty(strfind(lower(Tracks(i).Reorientations(j).class), reori_class))) % if(strcmpi(Tracks(i).Reorientations(j).class, reori_class))
                    attribute_vector = [attribute_vector Tracks(i).Reorientations(j).(attribute)];
                end
            end
            %    end
        end
    end
end

return;
end
