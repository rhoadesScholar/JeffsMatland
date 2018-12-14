function d = custom_str2double(x)
% d = custom_str2double(x)
% faster than str2num or str2double .. less overhead

d = sscanf(x,'%f');

return;
end
