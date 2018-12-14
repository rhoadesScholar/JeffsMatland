function [signal, A] = on_pathway_intermediate(t, x) 

y_1 = x(1);
y_2 = x(2);
y_3 = x(3);
k12 = x(4);
k23 = x(5);


initial_conditions = [1 0 0];
[t,A] = integrate_kinetics(k12,  k23,  t, initial_conditions);

signal = A(:,1)*y_1 + A(:,2)*y_2 + A(:,3)*y_3;

signal = signal';

end

% plot(t,A(:,1),'-r'); hold on; plot(t,A(:,2),'-g'); hold on; plot(t,A(:,3),'-b');

function [t,A] = integrate_kinetics(k12,  k23,  t_range, initial_conditions)

[t,A] = ode15s(@ode_function,t_range, initial_conditions);

% Define the ODE function as nested function,
    function dA_dt = ode_function(t, A)
        
        dA_dt = zeros(3,1);    % a column vector
        
        dA_dt(1) = -k12*A(1); % -k12*A(1) + k21*A(2)  ;
        dA_dt(2) = k12*A(1)- k23*A(2); %      k12*A(1) + k32*A(3) -(k21 + k23)*A(2);
        dA_dt(3) = k23*A(2) ; % -k32*A(3) + k23*A(2) ;
    end

end
