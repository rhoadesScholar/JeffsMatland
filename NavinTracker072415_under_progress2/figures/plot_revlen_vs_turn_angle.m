function dd_matrix = plot_revlen_vs_turn_angle(Tracks)

% 2D revlen vs delta-dir histograms
delta_dir = abs(attribute_histogram(Tracks,'delta_dir rev'));
% bb = attribute_histogram(Tracks,'revLenBodyBends');
% bb(isnan(bb))=0;
rL = attribute_histogram(Tracks,'revLen rev');
rL(isnan(rL))=0;

anglebin = 10;
revlen_bin = 0.1;

% % bodybends
% dd_matrix=[]; dd_matrix(8,uint8(180/anglebin)+1)=0; 
% for(i=1:length(delta_dir)) 
%         dd_matrix(min(8,bb(i)),uint8(delta_dir(i)/anglebin)+1) = dd_matrix(min(8,bb(i)),uint8(delta_dir(i)/anglebin)+1)+1;
% end
% dd_matrix = dd_matrix/nansum(nansum(dd_matrix));
% subplot(1,2,1); imagesc((dd_matrix)); axis square; box off;
% set(gca,'ytick',1:8); set(gca,'yticklabel',num2cell(1:8)); 
% ylabel('Reversal length (bodybends)');
% set(gca,'xtick',1:uint8(180/anglebin)+1); set(gca,'xticklabel',ticklabel_cell_array(anglebin,anglebin,180,2)); 
% xlabel('Reorientation angle (degrees)');

dd_matrix=[]; dd_matrix(uint8(2/revlen_bin),uint8(180/anglebin))=0; 
for(i=1:length(delta_dir)) 
        dd_matrix(max(1,  min(uint8(2/revlen_bin),uint8(rL(i)/revlen_bin)) ),max(1,  uint8(delta_dir(i)/anglebin) )) = ...
            dd_matrix(max(1,  min(uint8(2/revlen_bin),uint8(rL(i)/revlen_bin)) ),max(1,  uint8(delta_dir(i)/anglebin) ))+1; 
end;
% dd_matrix(1:2,:)=[];
dd_matrix = dd_matrix/nansum(nansum(dd_matrix));
dd_matrix(dd_matrix==0)=NaN;
imagesc(log2(dd_matrix)); 
colormap(jet);  
axis square; box off; 
colorbar('northoutside'); 
set(gca,'ytick',1:uint8(2/revlen_bin)); set(gca,'yticklabel',ticklabel_cell_array(revlen_bin,revlen_bin,2,2)); 
ylabel('Reversal length (bodylengths)');
set(gca,'xtick',1:uint8(180/anglebin)); set(gca,'xticklabel',ticklabel_cell_array(anglebin,anglebin,180,2)); 
xlabel('Reorientation angle (degrees)');

return;
end



