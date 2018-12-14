function [funfcn, tol, display_flag, m_limits, m_length, m1, bitsize, bit_signs, bin_vec_length] = parse_inputs_binary_optimization(x)


funfcn = x{1};
m_limits = x{2};

funfcn = fcnchk(funfcn,2);

if(length(x)<3)
    tol = 1e-5;
else
    tol = x{3};
end

if(length(x)<4)
    display_flag=1;
else
    display_flag = x{4};
end

% number of variables .. but no limits or guesses given
if(length(m_limits)==1)
    x = m_limits;
    m_limits = [];
    for(i=1:x)
        m_limits(i,:) = [-10 10];
    end
end

m1 = [];
% gave initial guess instead of limits
if(isvector(m_limits))
    m1 = m_limits;
    x = m_limits;
    m_limits = [];
    for(i=1:length(x))
%         if(x(i)~=0)
%             m_limits(i,:) = [x(i)/2 x(i)*2];
%         else
%             m_limits(i,:) = [-10 10];
%         end
        m_limits(i,:) = [min(x(i)/2, -10-abs(x(i))) max(x(i)*2,10+abs(x(i)))];
    end
end

m_length = size(m_limits,1);

% bitsize(i,1) = size of the integer portion of locus i, in bits
% bitsize(i,2) = size of the fractional portion of locus i, in bits
bitsize = [];
for(i=1:m_length)
    bitsize(i,1) = ceil(log2(max(abs(m_limits(i,:)))+1));
    bitsize(i,2) = ceil(abs(log2(sqrt(tol))));
end

bit_signs = [];
for(i=1:size(m_limits,1))
    if(m_limits(i,1)<=0 && m_limits(i,2)>=0) % positive or negative allowed
        bit_signs = [bit_signs zeros(1,sum(bitsize(i,:)))];
    else
        if(m_limits(i,1)>=0 && m_limits(i,2)>0) % only positive allowed
            bit_signs = [bit_signs ones(1,sum(bitsize(i,:)))];
        else
            if(m_limits(i,1)<0 && m_limits(i,2)<=0) % only negative allowed
                bit_signs = [bit_signs -1*ones(1,sum(bitsize(i,:)))];
            end
        end
    end
end

bin_vec_length = sum(sum(bitsize));

return;
end

