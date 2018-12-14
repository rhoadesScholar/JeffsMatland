function [drop_x, drop_y, strain_names] = get_drop_centers(MovieName, localpath, prefix)

ok_flag = 'N';
figure;
while(strcmpi(ok_flag,'N')==1)
    
    Mov = aviread_to_gray(MovieName,1);
    imshow(Mov.cdata);
    [drop_x, drop_y] = ginput2('*r'); % picks drop centers w/ the mouse
    hold on;
    
    num_drops = length(drop_x);
    
    same_strain_wells = questdlg('Do all the drops contain the same strain?', 'Do all the drops contain the same strain?', 'Yes', 'No','Yes');
    
    if(same_strain_wells(1)=='N')
    for(i=1:num_drops)
        text(drop_x(i), drop_y(i), num2str(i), 'color','r','FontSize',14);
        strain_names{i} = char(inputdlg(sprintf('What is the strain name for well %d?',i)));
        
        text(drop_x(i), drop_y(i), fix_title_string(sprintf('%s.%d',strain_names{i},i)), 'color','r','FontSize',14);
        
    end
    
    else
        for(i=1:num_drops)
            strain_names{i} = num2str(i);
            text(drop_x(i), drop_y(i), fix_title_string(sprintf('%d',i)), 'color','r','FontSize',14);
        end
    end
    hold off;
    
    ok_flag = questdlg('Drops defined correctly?', 'Drops defined correctly?', 'Yes', 'No', 'Yes');
    
end

if(~isempty(prefix))
    if(isempty(localpath))
        localpath = '';
    else
        localpath = sprintf('%s%s',localpath,filesep);
    end
    filename = sprintf('%s%s_drops',localpath, prefix);
    save_pdf(gcf, filename);
    
end

close all;
pause(0.2);

return;
end
