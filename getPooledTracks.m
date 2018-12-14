function pool = getPooledTracks(varList, strains)%varList should be cell array of finalTracks structures

for s = 1:length(strains)
    for t = 1:length(varList)
        if (t == 1) && isfield(varList{t}, strains{s})
           pool.(strains{s}) = varList{t}.(strains{s});
        elseif isfield(varList{t}, strains{s})
           oldPool = pool.(strain);
           try
               pool.(strains{s}) = [oldPool varList{t}.(strains{s})];
           catch
               newPool = varList{t}.(strains{s});
               newFields = fields(newPool);
               oldFields = fields(oldPool);
               if length(newFields) > length(oldFields)
                   newPool = rmfield(newPool, setdiff(newFields, oldFields));
               elseif length(oldFields) > length(newFields)
                   oldPool = rmfield(oldPool, setdiff(oldFields, newFields));
               end 
               pool.(strain) = [oldPool newPool];
           end
        end
    end
end

return
end