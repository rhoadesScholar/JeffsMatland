function get_struct_fieldsizes(inputStruct, verbose)

if(nargin==1)
    verbose=0;
end

    fn = fieldnames(inputStruct);
    numfields = length(fn);
    
    
    for(i=1:numfields)
        field = char(fn(i));
        x = inputStruct.(field);
        w = whos('x');
        s(i) = w.bytes;
        if(verbose)
            disp([sprintf('%s\t%d bytes',field, s(i))])
        end
        clear('x');
    end
    
    i = find(s == max(s));

    max_field = sprintf('%s',char(fn(i)));
    max_size = s(i);
    
    disp([sprintf('\ntotal = %d bytes\tmax:\t%s\t%d bytes',sum(s),max_field, s(i))])
    
return;
end
