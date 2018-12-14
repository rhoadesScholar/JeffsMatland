% converts a string of number seperated by delimiter (Default whitespace)
% into an array

function x = numstring_to_array(proc_input, delim)

if(nargin<2)
    delim = 'whitespace';
end

s = textscan(proc_input, '%d', 'delimiter', delim);
    
x = s{1};
x = x';

return;
end
