function prefix = prefix_from_path(localpath)

localpath = char(localpath);

% replace the filesep slashes w/ underscores
prefix = regexprep(localpath, '/', '_');
prefix = regexprep(prefix, '\', '_');

% remove the tailing underscore
if(prefix(length(prefix))=='_')
    prefix = prefix(1:length(prefix)-1);
end

% remove the heading underscore
while(prefix(1)=='_')
    prefix = prefix(2:length(prefix));
end

return;

end


