function fontsize = scaled_fontsize_for_subplot(plot_rows, plot_columns)
% fontsize = scaled_fontsize_for_subplot(plot_rows, plot_columns)

fontsize = round((plot_rows*plot_columns)*(-2/5) + 16);

if(fontsize > 10)
    fontsize = 10;
end

if(fontsize < 1)
    fontsize = 1;
end


return;
end
