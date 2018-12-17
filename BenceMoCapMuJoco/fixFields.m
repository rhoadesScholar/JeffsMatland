function newStruct = fixFields(struct1, struct2, varargin)
%     if nargin > 2
%         keep = varargin{1};
%     else
%         keep = false;
%     end
    
    allFields = {};
    
    if ~isstruct(struct2)
        mergeField = struct2;
        
        for i = 1:length(struct1)
            fields{i,:} = fieldnames(struct1(i).(mergeField));
            allFields(end + 1: end + length(fields{i})) = fields{i, :};
        end

        allFields = unique(allFields);
        goodFields = allFields;

        for i = 1:length(struct1)
            goodFields = goodFields(ismember(goodFields, fields{i,:}));
        end        
        badFields =  allFields(~ismember(allFields, goodFields));

%         if keep
%             for i = 1:length(struct1)
%                 newStruct = [newStruct rmfield(struct1(i).(mergeField), allFields(~ismember(allFields, goodFields)))];
%             end
%         else
            for i = 1:length(struct1)
                theseBaddies = badFields(ismember(badFields, fields{i,:}));
                if ~isempty(theseBaddies)
                    thisStruct = rmfield(struct1(i).(mergeField), theseBaddies);
                    cellfun(@(x) disp(['Removed ' x]), theseBaddies);
                else
                    thisStruct = struct1(i).(mergeField);
                end
                
                if i == 1
                    newStruct = thisStruct;
                else
                    newStruct = [newStruct thisStruct];
                end
            end
%         end
    else
        allFields = unique([fieldnames(struct1); fieldnames(struct2)]);
        goodFields = allFields;
        
        goodFields = goodFields(ismember(goodFields, fieldnames(struct1)));
        goodFields = goodFields(ismember(goodFields, fieldnames(struct2)));        
        badFields =  allFields(~ismember(allFields, goodFields));
        
        if any(ismember(badFields, fieldnames(struct1)))
            cellfun(@(x) disp(['Removed ' x]), badFields(ismember(badFields, fieldnames(struct1))));
            struct1 = rmfield(struct1, badFields(ismember(badFields, fieldnames(struct1))));
        end
        if any(ismember(badFields, fieldnames(struct2)))
            cellfun(@(x) disp(['Removed ' x]), badFields(ismember(badFields, fieldnames(struct2))));
            struct2 = rmfield(struct2, badFields(ismember(badFields, fieldnames(struct2))));
        end
        newStruct = [struct1 struct2];        
    end
    
    return
end