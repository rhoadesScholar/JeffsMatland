function DoubleStruct = make_double(inputStruct)

if(isempty(inputStruct))
   DoubleStruct=inputStruct;
   return;
end

if(issparse(inputStruct))
   inputStruct = full(inputStruct);
end

if(iscell(inputStruct))
   DoubleStruct = inputStruct;
   return;
end

if(iscellstr(inputStruct))
   DoubleStruct = inputStruct;
   return;
end

if(ischar(inputStruct))
   DoubleStruct = inputStruct;
   return;
end

if(isinteger(inputStruct))
   DoubleStruct = inputStruct;
   return;
end

if(islogical(inputStruct))
   DoubleStruct = inputStruct;
   return;
end

if(isnumeric(inputStruct))
   DoubleStruct = double(inputStruct);
   return;
end

if(isstruct(inputStruct))
   fn = fieldnames(inputStruct);
   numfields = length(fn);
   for(k=1:length(inputStruct))
   for(i=1:numfields)
       field = char(fn(i));
       DoubleStruct(k).(field) = make_double(inputStruct(k).(field));
   end
   end
end

return;
end