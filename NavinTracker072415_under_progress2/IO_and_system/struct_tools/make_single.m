function SingleStruct = make_single(inputStruct)
% SingleStruct = make_single(inputStruct)

SingleStruct=inputStruct;

if(isnumeric(inputStruct))
    SingleStruct = single(inputStruct);
else
    if(isstruct(inputStruct))
        fn = fieldnames(inputStruct);
        numfields = length(fn);
        
        for(k=1:length(inputStruct))
            for(i=1:numfields)
                if(isnumeric(inputStruct(k).(fn{i})))
                    SingleStruct(k).(fn{i}) = single(inputStruct(k).(fn{i}));
                else
                    if(isstruct(inputStruct(k).(fn{i})))
                        SingleStruct(k).(fn{i}) = make_single(inputStruct(k).(fn{i}));
                    else
                        SingleStruct(k).(fn{i}) = (inputStruct(k).(fn{i}));
                    end
                end
            end
        end
    end
end



return;
end

% if(issparse(inputStruct))
%     inputStruct = full(inputStruct);
% end
%
% if(iscell(inputStruct))
%     SingleStruct = inputStruct;
%     return;
% end
%
% if(ischar(inputStruct))
%     SingleStruct = inputStruct;
%     return;
% end
%
% if(isinteger(inputStruct))
%     SingleStruct = inputStruct;
%     return;
% end
%
% if(islogical(inputStruct))
%     SingleStruct = inputStruct;
%     return;
% end
%
% if(isnumeric(inputStruct))
%     if(~isa(inputStruct,'single'))
%         SingleStruct = single(inputStruct); % single(full(inputStruct));
%     else
%         SingleStruct = inputStruct;
%     end
%     return;
% end

