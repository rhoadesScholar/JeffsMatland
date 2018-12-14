function [m, bestscore] = HQM(varargin)

[funfcn, tol, display_flag, m_limits, m_length, m1, bitsize, bit_signs, bin_vec_length] = parse_inputs_binary_optimization(varargin);


bestscore = 1e10;
if(~isempty(m1))
    m = m1;
else
    for(p=1:bin_vec_length)
        m_current=[];
        for(i=1:m_length)
            m_current(i) = bracketed_rand(m_limits(i,:));
        end
        score = funfcn(m_current);
        if(score<bestscore)
            bestscore = score;
            m = m_current;
            if(display_flag==1)
                disp([num2str(p) ' ' num2str(bestscore) ' ' timeString ' ' num2str(m)])
            end
        end
    end
end
bin_vec = decimal_to_binary(m, bitsize);
bestscore = funfcn(m);

func_eval = 0;
stopflag=0;
cyc_num=0;
while(stopflag==0)
    stopflag = 1;
    idx = randint(bin_vec_length,bin_vec_length);
    cyc_num = cyc_num+1;
    
    while(~isempty(idx))
        
        n = idx(end); % pick a random bit position
        
        % go through all allowed bits at that position
        allowed_bits = permitted_bits(bit_signs(n));
        for(i=1:length(allowed_bits))
            bin_vec_current = bin_vec;
            bin_vec_current(n) = allowed_bits(i);
            m_current = binary_to_decimal(bin_vec_current, bitsize);
            score = funfcn(m_current); func_eval = func_eval+1;
            if(score<bestscore)
                stopflag=0;
                bin_vec = bin_vec_current;
                bestscore = score;
                m = m_current;
                if(display_flag==1)
                    disp([num2str(cyc_num) ' ' num2str(n) ' ' num2str(func_eval) ' ' num2str(bestscore) ' ' timeString ' ' num2str(m)])
                end
            end
        end
        
        idx(end)=[];
    end
    
end

return;
end

