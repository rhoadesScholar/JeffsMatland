minimization_functions = {'anneal', 'fminsearch', 'fminlbfgs', 'powell', 'GA'};

object_funcs = {'banana', 'egg', 'bukin6', 'holder_table'};

true_min = {[1 1], [512 404.2319], [-10 1], [8.05502 9.66459]};

x(1,:) = [0 0];
x(2,:) = [0.1 0.1];
x(3,:) = [0.1 -0.1];
x(4,:) = [-0.1 0.1];
x(5,:) = [-0.1 -0.1];
x(6,:) = [1 1];
x(7,:) = [1 -1];
x(8,:) = [-1 1];
x(9,:) = [-1 -1];
x(10,:) = [10 10];
x(11,:) = [-10 10];
x(12,:) = [10 -10];
x(13,:) = [-10 -10];
x(14,:) = [100 100];
x(15,:) = [-100 100];
x(16,:) = [100 -100];
x(17,:) = [-100 -100];
x(18,:) = [1000 1000];
x(19,:) = [-1000 1000];
x(20,:) = [1000 -1000];
x(21,:) = [-1000 -1000];

t=[];
err=[];
for(i=1:length(object_funcs))
   for(j=1:length(minimization_functions))
       for(k=1:size(x,1))
            x0 = x(k,:);
            command = sprintf('%s(@%s,x0)',minimization_functions{j},object_funcs{i});
            tic;
            x_min = eval(command);
            if(i==4) % holder_table has 4 symmetric minima
               x_min = abs(x_min);
            end
            t(i,j,k) = toc;
            err(i,j,k) = sqrt(sum((x_min-true_min{i}).^2));
       end
   end
end
