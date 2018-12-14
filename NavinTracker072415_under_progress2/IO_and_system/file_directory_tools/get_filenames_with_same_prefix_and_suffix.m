function filenames = get_filenames_with_same_prefix_and_suffix(dirname, prefix, suffix)

filenames=[];

dummystring = sprintf('%s%s%s.*.%s',dirname,filesep,prefix,suffix);
fileinfo = dir(dummystring);

for(i=1:length(fileinfo))
    filenames{i} = fileinfo(i).name;
end

return;
end
