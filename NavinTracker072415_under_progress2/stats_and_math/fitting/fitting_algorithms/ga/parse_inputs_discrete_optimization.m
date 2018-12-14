function [funfcn, tol, display_flag, m_limits, m_length, m1] = parse_inputs_discrete_optimization(x)
% [funfcn, tol, display_flag, m_limits, m_length, m1] = parse_inputs_discrete_optimization(x)

tol = 1e-5;
display_flag=1;

funfcn = x{1};
m_limits = x{2};

funfcn = fcnchk(funfcn,2);

m1 = [];

if(length(x)>2)
    n=3;
    while(n<=length(x))
        if(ischar(x{n}))
            if(strncmpi('tol',x{n},3))
                n = n+1;
                tol = x{n};
                n = n+1;
            else
                if(strncmpi('disp',x{n},4))
                    n = n+1;
                    display_flag = x{n};
                    n = n+1;
                else
                    disp(sprintf('Error: Do not recognize %s',x{n}));
                    return
                end
            end
        else % either initial guess or limits
            mm = x{n};
            if(iscell(mm)) % then x{2} is probably initial guess m1
                m1 = m_limits;
                m_limits = mm;
            else
                m1 = mm;
            end
            clear('mm');
            n = n+1;
        end
    end
end

    






clear('x');

% number of variables .. but no limits or guesses given
if(length(m_limits)==1)
    x = m_limits;
    m_limits = [];
    for(i=1:x)
        m_limits{i} = [-128 -64 -32 -16 -8 -4 -2 -1 -0.5 -0.1 0 0.1 0.5 1 2 4 8 16 32 64 128];
    end
    
    m_length = length(m_limits);
    return;
end




% gave initial guess instead of limits
if(~iscell(m_limits))
    if(isempty(m1))
        m1 = m_limits;
    end
    x = m_limits;
    m_limits = [];
    for(i=1:length(x))
%         if(x(i)~=0)   
%             m_limits{i} = unique([linspace(x(i)/2,2*x(i)/2,10) x(i)]);
%         else
%             m_limits{i} = unique([linspace(x(i)/2,2*x(i)/2,10) x(i) -1 -0.75 -0.5 -0.25 -0.1 0 0.1 0.25 0.5 0.75 1]);
%         end
        m_limits{i} = unique([-linspace(x(i)/2,2*x(i)/2,10) linspace(x(i)/2,2*x(i)/2,10) x(i) -1 -0.75 -0.5 -0.25 -0.1 0 0.1 0.25 0.5 0.75 1]);
    end
end

m_length = length(m_limits);



return;
end

