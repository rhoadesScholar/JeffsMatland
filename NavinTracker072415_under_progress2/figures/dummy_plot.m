function dummy_plot(localpath, prefix, temp_prefix)
% dummy_plot(localpath, prefix, temp_prefix)
% used when BinData or BinData.time is empty

close all;
hidden_figure(1);
title_string = fix_title_string(sprintf('%s is empty',prefix));
text(0.5,0.95,title_string,'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');

if(~isempty(prefix))
    save_figure(1, tempdir, temp_prefix, num2str(1),1);
    pool_temp_pdfs(1, localpath, prefix, temp_prefix);
    close all;
else
    show_figure(1);
end



return;
end
