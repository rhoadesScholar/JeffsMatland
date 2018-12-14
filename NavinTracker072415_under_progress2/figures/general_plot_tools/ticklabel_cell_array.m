function ouput_cell_array = ticklabel_cell_array(first,tickstep,last,labelstep)

xtick = first:tickstep:last;

for(i=1:length(xtick))
    ouput_cell_array{i} = '';
    if(mod(i,labelstep)==0)
        ouput_cell_array{i} = num2str(xtick(i));
    end
end

return;
end
