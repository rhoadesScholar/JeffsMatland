function conc = A260_to_nM(ng_uL, length)
% conc = A260_to_nM(ng_uL, length)

if(nargin<2)
    disp('conc = A260_to_nM(ng_uL, length)');
    return
end


conc = (ng_uL*1e6)./(length*660);

return;
end
