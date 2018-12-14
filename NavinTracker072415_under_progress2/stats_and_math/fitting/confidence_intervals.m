function fitting_struct = confidence_intervals(fitting_struct)
% fitting_struct = confidence_intervals(fitting_struct)
% uses the avg and std dev for the parameters i

for(d=1:length(fitting_struct.data))
    
    un_norm_y_fit_simulated_matrix = [];
    for(s=1:1000)
        if(fitting_struct.data(d).inst_freq_code == 1)
            t = fitting_struct.t;
        else
            t = fitting_struct.t_freq;
        end
        
        k = defined_randn(fitting_struct.k_avg, fitting_struct.k_std);
        while(~isempty(find(k<0)))
            k = defined_randn(fitting_struct.k_avg, fitting_struct.k_std);
        end
        
        gamma = defined_randn(fitting_struct.data(d).un_norm_gamma_avg, fitting_struct.data(d).un_norm_gamma_std);
        while(~isempty(find(gamma<0)))
            gamma = defined_randn(fitting_struct.data(d).un_norm_gamma_avg, fitting_struct.data(d).un_norm_gamma_std);
        end
        
        un_norm_y_fit_simulated_matrix =  [un_norm_y_fit_simulated_matrix; five_state_on_off(t, fitting_struct.t0, fitting_struct.t_end, fitting_struct.t_on, fitting_struct.t_off, k, gamma)];
            
    end
    
    fitting_struct.data(d).un_norm_y_fit_std = nanstd(un_norm_y_fit_simulated_matrix);
    clear('un_norm_y_fit_simulated_matrix');
end

return;
end

function fitting_struct = simulate_fitting_struct(m, fitting_struct)

fitting_struct = m_to_fitting_struct(m, fitting_struct);
fitting_struct =  fitting_struct_to_five_state_on_off_model(fitting_struct);
fitting_struct.score = score_five_state_on_off_model(m, fitting_struct);

return;
end





% function fitting_struct = monte_carlo_simulate_param_error(fitting_struct)
% % eh, not so good
% kT = 100;
% max_cycles=100000;
% 
% current_m = fitting_struct.m;
% num_moves=0;
% fitting_struct.un_norm_simulated_fit_matrix = []; 
% fitting_struct.simulated_fit_matrix = []; 
% j=1;
% i=1;
% while(i<=max_cycles)
%     num_moves = num_moves+1;
%     m = defined_randn(current_m, current_m/4);
%     
%     new_fitting_struct = simulate_fitting_struct(m, fitting_struct);
%     
%     if(rand < exp(-(new_fitting_struct.score - fitting_struct.score)/kT))
%         %disp([i num_moves fitting_struct.score new_fitting_struct.score])
%         fitting_struct = new_fitting_struct;
%         current_m = new_fitting_struct.m;
%         
%         if(mod(i,100)==0)
%             fitting_struct.un_norm_simulated_fit_matrix(j,:) = [fitting_struct.un_norm_m fitting_struct.score];
%             fitting_struct.simulated_fit_matrix(j,:) = [fitting_struct.m fitting_struct.score];
%             disp([j i num_moves fitting_struct.score new_fitting_struct.score])
%             j=j+1;
%         end
%         
%         i=i+1;
%     else
%         %disp([num_moves exp(-(new_fitting_struct.score - fitting_struct.score)/kT) fitting_struct.score new_fitting_struct.score])
%     end
% end
% 
% return;
% end