function stattext = stat_symbol(p)
% stattext = stat_symbol(p)

stattext = '   ';

if(nargin<1)
    return;
end

if(p<=0.05)
    stattext = '*';
end
if(p<0.01)
    stattext = '**';
end
if(p<0.001)
    stattext = '***';
end

return;
end

