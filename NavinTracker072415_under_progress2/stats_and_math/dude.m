        

x__ref = x;
        try
            m = fminsearch(@fitlin, m0,options);
        catch
            error('Ezyfit:ezfit:fminsearchError','Fit: error during the fminsearch procedure');
        end
        y_fit = eval(eqml);
        ssr = sum(abs(y_fit-mean(y)).^2);
        sse = sum(abs(y_fit-y).^2);
        f.r=sqrt(ssr/(sse+ssr));
        f.chi2 = fitlin(m);
        
        x = fminsearch(@(x) obj_function(x,p), x0, fminsearchoptions);
        

score = obj_function(x,p)

score = 0.0;

t = p.t;
y = p.y;
y_s = p.y_s;

y0 = x(1);
ymaxResp = x(2);
yfinal = x(3);
alpha1 = x(4);
tau1 = x(5);
alpha2 = x(6);
tau2 = x(7);
t_switch = x(8);

yfit=[];
for(i=1:length(y))
    
    if(~isnan(y(i)))
        
        yfit(i) =  double_sigmoid_function(t(i), [y0,ymaxResp,yfinal,alpha1,tau1,alpha2,tau2,t_switch]);
        %     score = score + ( (y(i) - yfit(i) )^2 );
        
        if(y_s(i)==0)
            score = score + ( (y(i) - yfit(i) )^2 );
        else
            score = score + ( (y(i) - yfit(i) )^2 )/y_s(i) ;
        end
        
    end


function y = dude(x, A, B, C, D, E, F)

for(i=1:length(x))
     y(i) =  sin(A*log(C*x(i) + B*x(i)^2 + D*x(i) + sin(E*x(i))) + F);
%     if(rand<0.5)
%         y(i) =  y(i) + rand/3;
%     else
%         y(i) =  y(i) - rand/3;
%     end
end

return;
end
