function output_path = filesep_convert(path)

output_path = strrep(path,'\',filesep);
output_path = strrep(path,'/',filesep);

return;
end
