function [m_best, bestscore] = fminsearch_space(funfcn, m_limits, num_starts)
% usage [m_best, bestscore] = fminsearch_space(@(m) myfunction(m), m_limits, num_starts)
% fminsearch with sampling over all axes given m_limits

funfcn = fcnchk(funfcn,2);

fminsearchoptions = optimset('Display','off');

% number of variables .. but no limits or guesses given
if(length(m_limits)==1)
    x = m_limits;
    m_limits = [];
    for(i=1:x)
        m_limits(i,:) = [-10 10];
    end
end

m_length = size(m_limits,1);
m_best = zeros(1,m_length);
bestscore=1e10;

% gave initial guess instead of limits
if(isvector(m_limits))
    [m_best, bestscore] = fminsearch(@(m) funfcn(m), m_limits, fminsearchoptions);
        
    x = m_limits;
    m_limits = [];
    for(i=1:length(x))
        if(x(i)~=0)
            m_limits(i,:) = [x(i)/100 x(i)*100];
        else
            m_limits(i,:) = [-10 10];
        end
    end
end

if(nargin<3)
    num_starts = m_length*100;
end

for(i=1:num_starts)
    m0=[];
    for(j=1:m_length)
       m0(j) = bracketed_rand(m_limits(j,:));
    end
    [m, score] = fminsearch(@(m) funfcn(m), m0, fminsearchoptions);
    if(score<bestscore)
        m_best = m;
        bestscore = score;
    end
end

return;
end

