load('celgvectors_adult_WB180_SK.mat');
aMean = 0;
figure(1)
imagesc((conn>0));
colormap('hot');
figure(2)
[U, S, V] = svd(conn - aMean*mean(mean(conn))*ones(size(conn)));
s = diag(S);
plot(s, 'o');
iV = zeros(281, 2); 
iU = zeros(281, 2); 
for (i=1:2)
    figure(i+2)
    u = U(:, i);
    v = V(:, i);
    [x iV(:, i)] = sort(v, 'descend');
    [x iU(:, i)] = sort(u, 'descend');
    sv(i).conn=(conn(iU(:, i), iV(:, i))>0);
    imagesc(sv(i).conn);
    colormap('hot');
end
figure(i+3)
preConnects = sum(conn(:, iV(:, 1)), 1);
postConnects = sum(conn(iU(:, 1), :), 2);
subplot(2, 1, 1);
bar(preConnects, 'k');
subplot(2, 1, 2);
bar(postConnects, 'k');
preNames = idt(iV(:, 2));
postNames = idt(iU(:, 2));

%%

figure('Units','pixels','Position',[0 0 2*282+80 2*282]);
sv(2).color=zeros(281);
    set(gca,'Position',[0 0 .98 1]);

for i=1:281
    for j=1:281
        if (sv(2).conn(i,j))
            sv(2).color(i,j)=3*(idt_type_array(iU(i,2))-1)+idt_type_array(iV(j,2));
        end
    end
end
axis image; 
axis off;
image(sv(2).color+1);j=jet(10);j(1,:)=[0 0 0]; j(4,:)=[1 1 1];colormap(j);colorbar;
set(colorbar,'YTickLabel',{'none','s->s','s->i','s->m','i->s','i->i','i->m','m->s','m->i','m->m'});

%%
figure;hist(sv(2).color(:),[0:9]);xlim([0.5 9.5]);ylim([0 1000]);
set(gca,'XTick',1:9);
set(gca,'XTickLabel',{'s->s','s->i','s->m','i->s','i->i','i->m','m->s','m->i','m->m'});
ylabel('# of connections');
save2pdf('conn_type_histo.pdf');