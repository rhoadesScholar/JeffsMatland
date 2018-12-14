function pool_figs_to_pdf(fignum, prefix, rotateflag)

if(nargin<3)
    rotateflag=0;
end

for(i=1:length(fignum))
   save_pdf(fignum(i),sprintf('temp.%d.pdf',fignum(i)), rotateflag);
end
    
if(~isempty(strfind(prefix,'.pdf')))
    prefix = prefix(1:end-4);
end

    rm(sprintf('%s.pdf',prefix));

    command = sprintf('pdftk');
    
    for(i=1:length(fignum))
        command = sprintf('%s temp.%d.pdf',command, fignum(i));
    end
    
    command = sprintf('%s cat output %s.pdf',command, prefix);
    
    run_command(command);
    
    while(file_existence(sprintf('%s.pdf',prefix))==0)
        pause(1);
    end
    pause(1);
    
    
    for(i=1:length(fignum))
        rm(sprintf('temp.%d.pdf',fignum(i)));
    end

return;
end
