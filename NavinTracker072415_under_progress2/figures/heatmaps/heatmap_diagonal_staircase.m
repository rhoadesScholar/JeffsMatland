function heatmap_diagonal_staircase(num_cells)

for(i=1:num_cells)
    plot([(i-1)+0.5 i+0.5],[i-0.5 i-0.5],'k');
    plot([i+0.5 i+0.5],[(i-1)+0.5 i+0.5],'k')
end

return;
end
