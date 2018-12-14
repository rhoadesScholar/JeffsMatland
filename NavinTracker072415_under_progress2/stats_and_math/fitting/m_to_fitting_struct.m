function fitting_struct = m_to_fitting_struct(m, fitting_struct)

fitting_struct.m = [];
fitting_struct.un_norm_m = [];

for(i=1:4)
    if(fitting_struct.usage_vector(i)==1)
        fitting_struct.k(i) = m(i);
    else
        fitting_struct.k(i)=0;
    end
    fitting_struct.un_norm_m = [fitting_struct.un_norm_m fitting_struct.k(i)];
    fitting_struct.m = [fitting_struct.m fitting_struct.k(i)];
end

if(length(m)>4)
    i=5;
    for(d=1:length(fitting_struct.data))
        fitting_struct.data(d).k = fitting_struct.k;
        for(q=1:5)
            if(fitting_struct.usage_vector(i)==1)
                fitting_struct.data(d).gamma(q) = m(i);
                fitting_struct.data(d).un_norm_gamma(q) = fitting_struct.data(d).range*fitting_struct.data(d).gamma(q) + fitting_struct.data(d).minval;
                
                if(fitting_struct.data(d).un_norm_gamma(q) > fitting_struct.data(d).maxval + 2*fitting_struct.data(d).un_norm_median_std)
                    fitting_struct.data(d).un_norm_gamma(q) = fitting_struct.data(d).maxval + 2*fitting_struct.data(d).un_norm_median_std;
                    m(i) = (fitting_struct.data(d).un_norm_gamma(q) - fitting_struct.data(d).minval)/fitting_struct.data(d).range;
                    fitting_struct.data(d).gamma(q) = m(i);
                end
                if(fitting_struct.data(d).un_norm_gamma(q) < fitting_struct.data(d).minval - 2*fitting_struct.data(d).un_norm_median_std)
                    fitting_struct.data(d).un_norm_gamma(q) = fitting_struct.data(d).minval - 2*fitting_struct.data(d).un_norm_median_std;
                    m(i) = (fitting_struct.data(d).un_norm_gamma(q) - fitting_struct.data(d).minval)/fitting_struct.data(d).range;
                    fitting_struct.data(d).gamma(q) = m(i);
                end
                
                
                if(fitting_struct.data(d).un_norm_gamma(q) < 0)
                    fitting_struct.data(d).un_norm_gamma(q) = 1e-4;
                    m(i) = (fitting_struct.data(d).un_norm_gamma(q) -  fitting_struct.data(d).minval)/fitting_struct.data(d).range;
                    fitting_struct.data(d).gamma(q) = m(i);
                end
                
            else
                fitting_struct.data(d).gamma(q)=0;
                fitting_struct.data(d).un_norm_gamma(q) = 0;
            end
            fitting_struct.un_norm_m = [fitting_struct.un_norm_m fitting_struct.data(d).un_norm_gamma(q)];
            fitting_struct.m = [fitting_struct.m fitting_struct.data(d).gamma(q)];
            i=i+1;
        end
    end
end

return;
end

