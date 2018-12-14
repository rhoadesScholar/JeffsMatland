function state = num_state_convert(s)
% state = num_state_convert(s)

state = [];

if(isnumeric(s))
    
    if(length(s)>1)
       for(i=1:length(s))
            state{i} = num_state_convert(s(i));
       end
       return;
    end
    
    if(are_these_equal(s, 1.1))
        state = 'pause'; end
    if(are_these_equal(s, 1))
        state = 'fwd'; end
    if(are_these_equal(s, 2))
        state = 'reori'; end
    if(are_these_equal(s, 3))
        state = 'Upsilon'; end
    if(are_these_equal(s, 4))
        state = 'lRev'; end
    if(are_these_equal(s, 5))
        state = 'sRev'; end
    if(are_these_equal(s, 7))
        state = 'omega'; end
    if(are_these_equal(s, 8))
        state = 'liquid_omega'; end    
    
    if(are_these_equal(s, 4.7))
        state = 'lRevOmega'; end
    if(are_these_equal(s, 7.4))
        state = 'OmegalRev'; end
    
    if(are_these_equal(s, 5.7))
        state = 'sRevOmega'; end
    if(are_these_equal(s, 7.5))
        state = 'OmegasRev'; end
    
    if(are_these_equal(s, 4.3))
        state = 'lRevUpsilon'; end
    if(are_these_equal(s, 3.4))
        state = 'UpsilonlRev'; end
    
    if(are_these_equal(s, 5.3))
        state = 'sRevUpsilon'; end
    if(are_these_equal(s, 3.5))
        state = 'UpsilonsRev'; end
    
    if(are_these_equal(s, 99))
        state = 'ring'; end
    if(are_these_equal(s, 100))
        state = 'missing'; end
    
    if(are_these_equal(s, 200))
        state = 'join'; end
    
    if(are_these_equal(s, 3.1))
        state = 'pure_Upsilon'; end
    if(are_these_equal(s, 4.1))
        state = 'pure_lRev'; end
    if(are_these_equal(s, 5.1))
        state = 'pure_sRev'; end
    if(are_these_equal(s, 7.1))
        state = 'pure_omega'; end
    if(~isempty(state))
        return;
    end
    
    error('Cannot find state %.1f\n',s);
end


% is a character array ... return the state code
if(ischar(s))
    switch lower(s)
        case {'ringmiss','missring'} % either ring or missing
            state = 99;
            
        case {'fwdstate', 'fwd_state'}
            state = 1.3;
            
        case {'straight'}
            state = 1.3;
        case {'loop'}
            state = 1.2;
        case {'pause'}
            state = 1.1;
        case {'fwd','forward'}
            state = 1;
            
            
        case {'reori','reorientation'}
            state = 2;
            
        case {'upsilon'}
            state = 3;
        case {'lrev','l_rev','longrev','long_rev'}
            state = 4;
        case {'srev','s_rev','shortrev','short_rev'}
            state = 5;
        case {'omega','om'}
            state = 7;
        case {'liquid_omega','liq_om','liq_omega'}
            state = 8;    
        
        case {'rev'}
            state = [4 5];    
        case {'omega_upsilon', 'upsilon_omega','omegaupsilon','upsilonomega'}
            state = [3 7]; 
            
        case {'pure_upsilon','pureupsilon'}
            state = 3.1;
        case {'pure_lrev','pure_l_rev','pure_longrev','pure_long_rev',...
                'purelrev','purel_rev','purelongrev','purelong_rev' }
            state = 4.1;
        case {'pure_srev','pure_s_rev','pure_shortrev','pure_short_rev',...
                'puresrev','pures_rev','pureshortrev','pureshort_rev' }
            state = 5.1;
        case {'pure_omega','pure_om','pureomega','pureom'}
            state = 7.1;
         
        case {'pure_rev'}
            state = [4.1 5.1];
        case {'pure_omegaupsilon','pure_upsilonomega'}
            state = [3.1 7.1];    
            
        case {'lrevomega','lrev_omega'}
            state = 4.7;
        case {'omegalrev','omega_lrev'}
            state = 7.4;
            
        case {'srevomega','srev_omega'}
            state = 5.7;
        case {'omegasrev','omega_srev'}
            state = 7.5;
            
        case {'lrevupsilon','lrev_upsilon'}
            state = 4.3;
        case {'upsilonlrev','upsilon_lrev'}
            state = 3.4;
            
        case {'srevupsilon','srev_upsilon'}
            state = 5.3;
        case {'upsilonsrev','upsilon_srev'}
            state = 3.5;
            
        case {'nonupsilon_reori','nonupsilon'}
            state = [4.1 5.1 7.1 4.7 5.7 4.3 5.3];
        case {'revomega'}
            state = [4.7 5.7];    
        case {'revupsilon'}
            state = [4.3 5.3];    
        case {'revomegaupsilon','revupsilonomega'} 
            state = [4.7 5.7 4.3 5.3];    
            
        case {'ring'}
            state = 99;
        case {'miss','missing'}
            state = 100;
            
        case {'join'}
            state = 200;
    end
    if(~isempty(state))
        state = single(state);
        return;
    end
    
    error('Cannot find state %s\n',s);
end

return;
end
