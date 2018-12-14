function plot_state_transition_probab_matrix(t_vector, state_transition_probab_matrix, err_matrix, stimulus,colorcode)

state_class_vector = {'F','P','\upsilon','R','\Omega'};

if(nargin<5)
    colorcode = '.k';
end

n=0;
for(i=1:5)
    for(j=1:5)
        n=n+1;
        if(~((i==3 && j==5) || (i==5 && j==3)) ) % && (i~=j))
            subplot(5,5,n);
            ylims(1) = max(0, min(state_transition_probab_matrix(:,i,j))-0.05*(min(state_transition_probab_matrix(:,i,j))));
            ylims(2) = 1.05*max(state_transition_probab_matrix(:,i,j)); % min(1, 1.05*max(state_transition_probab_matrix(:,i,j)));
            if(ylims(1) == ylims(2))
                ylims(1)=0;
                ylims(2)=1;
            end
            if(ylims(1)>ylims(2))
               yy =  ylims(1);
               ylims(1) = ylims(2);
               ylims(2) = yy;
            end
            stimulusShade(stimulus, ylims(1), ylims(2));
            hold on;
            errorline(t_vector',state_transition_probab_matrix(:,i,j),err_matrix(:,i,j),colorcode);
            ylim(ylims);
            xlim([floor(t_vector(1)) ceil(t_vector(end))]);
            hold off;
        end
        
        if(i==1)
            if(i==j)
                subplot(5,5,n);
            end
            text(0.5, 1.1, state_class_vector{j},'units','normalized','fontsize',14,'fontweight','bold');
%             if(i==j)
%                 axis off
%                 set(gca,'color','w');
%             end
        end
        if(j==1)
            text(-0.5, 0.5, state_class_vector{i},'units','normalized','fontsize',14,'fontweight','bold');
        end
    end
end

set(gcf,'color','w');
orient landscape

return;
end
