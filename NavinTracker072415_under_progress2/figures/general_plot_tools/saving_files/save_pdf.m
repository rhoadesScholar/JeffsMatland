function save_pdf(gcf, filename, rotateflag)
% save_pdf(gcf, filename, rotateflag)

if(nargin<1)
   disp('usage: save_pdf(gcf, filename, rotateflag)');
   return;
end

% if(ismac)
%     disp('save_pdf is not mac friendly yet');
%     return;
% end

if(nargin<3)
    rotateflag=0;
end

if(isempty(strfind(filename,'pdf')))
    filename = sprintf('%s.pdf',filename);
end

rm(filename);

if(length(gcf)>1)
   pool_figs_to_pdf(gcf, filename, rotateflag); 
   return;
end

h = figure(gcf);
% old_units = get(h,'units');
% set(h,'units','normalized');
% orginal_pos_vector = get(h,'position');
% set(h,'position',[0 0 1 1]);
% set(h,'PaperPositionMode','auto');

tempstr  = sprintf('%s.pdf',tempname);
fig2pdf(h, filename)


% set(h,'position',orginal_pos_vector);
% set(h,'units',old_units);

if(rotateflag==0)
    mv(tempstr,filename);
    return;
end

if(rotateflag==1)
    % rotate  the pdf
    tempstr2  = sprintf('%s.pdf',tempname);
    command = sprintf('pdftk %s cat 1-endE output %s',tempstr,tempstr2); % rotate clockwise 90deg
    run_command(command);

    mv(tempstr2,filename);
    rm(tempstr);
end

return;
end   


function fig2pdf(gcf, filename)

    % figure_handle = sprintf('-f%d',gcf);
    % print(figure_handle,'-dpdf',filename);
    
    print(gcf,'-dpdf',filename);

return;
end

