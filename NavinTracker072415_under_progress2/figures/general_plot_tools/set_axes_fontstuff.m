function set_axes_fontstuff(h, varargin)
% set_fontname_fontsize_handle(h)
% sets axes and axislabels to whatever in varargin

st = sprintf('set(h%s);',make_varargin_comma_string(varargin));
eval(st);

st = sprintf('set(get(h,''xlabel'')%s);',make_varargin_comma_string(varargin));
eval(st);

st = sprintf('set(get(h,''ylabel'')%s);',make_varargin_comma_string(varargin));
eval(st);


return;
end

function outstr = make_varargin_comma_string(args)

outstr = '';
for(i=1:length(args))
    if(ischar(args{i}))
        outstr = sprintf('%s%s''%s''', outstr,',', args{i});
    else
        outstr = sprintf('%s%s%s', outstr,',', num2str(args{i}));
    end
end

return;
end

