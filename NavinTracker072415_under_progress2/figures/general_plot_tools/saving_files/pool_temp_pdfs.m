function pool_temp_pdfs(fignum, localpath, prefix, temp_prefix)

if(length(fignum)==1)
    fignum = [fignum fignum];
end

if(nargin<4)
    temp_prefix = sprintf('temp.%d',randint(10000));
end

if(~isempty(prefix))
    if(~isempty(localpath))
        outprefix = sprintf('%s%s',localpath,prefix);
    else
        outprefix = prefix;
    end
    
    command = sprintf('pdftk');
    
    for(i=fignum(1):fignum(2))
        command = sprintf('%s %s%s.%d.pdf',command, tempdir,temp_prefix, i);
        tempoutfile = sprintf('%s%s.%d.fig',tempdir, temp_prefix, i);
        rm(tempoutfile);
    end
    
    tempoutfile = sprintf('%s.pdf',tempname);
    command = sprintf('%s cat output %s',command, tempoutfile);
    
    disp([sprintf('linking pdfs in to a single file')]);
    %disp(sprintf('%s', command));
    
    [status, result] = run_command(command);
    
    while(file_existence(tempoutfile)==0 && status==0)
        pause(1);
    end
    pause(1);
    
    outfile = sprintf('%s.pdf',outprefix);

    disp([sprintf('copying pdf from tempdir')]);
    
    mv(tempoutfile, outfile);
    
    for(i=fignum(1):fignum(2))
        tempoutfile = sprintf('%s%s.%d.pdf',tempdir, temp_prefix, i);
        rm(tempoutfile);
    end
end

return;
end
