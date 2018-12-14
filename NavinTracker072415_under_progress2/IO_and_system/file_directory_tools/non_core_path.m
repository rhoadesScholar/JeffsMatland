% extract the non-MATLAB core directories in the command path in a form 
% read by addpath and rmpath

function result = non_core_path()



q = path;
ret = sprintf('!');
path2 = strrep(q, ';', ret);


j=1; k=1;
for(i=1:length(path2))
    if(path2(i)~='!')
        path3(j,k) = path2(i);
        k=k+1;
    else
        j=j+1;
        k=1;
    end
end

root_path = matlabroot;

j=0;
for(i=1:length(path3(:,1)))
    if(isempty(strfind(path3(i,:),root_path)))
        j=j+1;
        path4(j,:) = path3(i,:);
    end
end


if(j > 0)

    for(i=1:length(path4(:,1)))
        if(i>1)
            result = sprintf('%s;%s',result,deblank(path4(i,:)));
        else
            result = sprintf('%s',deblank(path4(i,:)));
        end
    end
else
    result='';
end

return;

end
