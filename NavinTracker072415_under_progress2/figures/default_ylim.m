function [ymin, ymax, color, ylabelstring] = default_ylim(field)
% [ymin, ymax, color, ylabelstring] = default_ylim(field)

if(nargin<1)
   disp('usage: [ymin, ymax, color, ylabelstring] = default_ylim(field)');
   return
end

ymin = 0;
ymax = 0;
color = 'k';
ylabelstring = '';

if(strcmpi(field,'speed'))
    ymin = 0;
    ymax = 0.25;
    color = 'k';
    ylabelstring = sprintf('%s\n%s','speed', '(mm/sec)');
    return;
end

if(strcmpi(field,'angspeed'))
    ymin = 0;
    ymax = 30;
    color = 'g';
    ylabelstring = sprintf('%s\n%s','angular speed', '(deg/sec)');
    return;
end

if(strcmpi(field,'revspeed'))
    ymin = 0;
    ymax = 0.25;
    color = 'b';
    ylabelstring = sprintf('%s\n%s','revSpeed', '(mm/sec)');
    return;
end

if(strcmpi(field,'ecc_omegaupsilon'))
    ymin = 0.55;
    ymax = 0.85;
    color = 'r';
    ylabelstring = sprintf('%s\n%s','eccentricity','omega/upsilon');
    return;
end

if(strcmpi(field,'ecc'))
    ymin = 0.95;
    ymax = 0.96;
    color = 'k';
    ylabelstring = sprintf('%s','eccentricity');
    return;
end

if(strcmpi(field,'head_angle'))
    ymin = 135;
    ymax = 155;
    color = 'k';
    ylabelstring = sprintf('%s\n%s','head angle','(degrees)');
    return;
end

if(strcmpi(field,'body_angle'))
    ymin = 145;
    ymax = 175;
    color = 'k';
    ylabelstring = sprintf('%s\n%s','body angle','(degrees)');
    return;
end

if(strcmpi(field,'tail_angle'))
    ymin = 140;
    ymax = 160;
    color = 'k';
    ylabelstring = sprintf('%s\n%s','tail angle','(degrees)');
    return;
end

if(strcmpi(field,'revlength'))
    ymin = 0;
    ymax = 1; % 1.25;
    color = 'b';
    ylabelstring = sprintf('%s\n%s','reversal length','(bodylengths)');
    return;
end

if(strcmpi(field,'curv'))
    ymin = 0;
    ymax = 30;
    color = 'g';
    ylabelstring = sprintf('%s\n%s','path curvature','(deg/mm)');
    return;
end

if(~isempty(regexpi(field,'frac')))
    ymin = 0;
    ymax = 0.1;
    ylabelstring = field;
end

if(~isempty(regexpi(field,'freq')))
    ymin = 0;
    ymax = 0.25; % 1.5;
    ylabelstring = sprintf('%s\n%s',field,'(/min)');
end


if(strcmpi(field,'revlength_bodybends'))
    ymin = 0;
    ymax = 5;
    color = 'b';
    ylabelstring = sprintf('%s\n%s','reversal length','(bodybends)');
    return;
end

if(strcmpi(field,'delta_dir_omegaupsilon'))
    ymin = 0;
    ymax = 180;
    color = 'r';
    ylabelstring = sprintf('%s\n%s','delta direction omega/upsilon','(deg)');
    return;
end

if(strcmpi(field,'delta_dir_rev'))
    ymin = 0;
    ymax = 180;
    color = 'b';
    ylabelstring = sprintf('%s\n%s','delta direction reversals','(deg)');
    return;
end


if(~isempty(regexpi(field,'rev')))
    color = 'b';
end
if(~isempty(regexpi(field,'pure_rev')))
    color = 'b';
    return;
end

if(~isempty(regexpi(field,'lrev')))
    color = 'b';
end
if(~isempty(regexpi(field,'pure_lrev')))
    color = 'b';
    return;
end

if(~isempty(regexpi(field,'srev')))
    color = 'c';
end
if(~isempty(regexpi(field,'pure_srev')))
    color = 'c';
    return;
end


if(~isempty(regexpi(field,'omegaupsilon')))
    color = 'r';
end
if(~isempty(regexpi(field,'omegaupsilon')))
    color = 'r';
    return;
end

if(~isempty(regexpi(field,'omega')))
    color = 'r';
end
if(~isempty(regexpi(field,'pure_omega')))
    color = 'r';
    return;
end

if(~isempty(regexpi(field,'upsilon')))
    color = 'm';
end
if(~isempty(regexpi(field,'pure_upsilon')))
    color = 'm';
    return;
end

if(~isempty(regexpi(field,'revomega')) || ~isempty(regexpi(field,'revomegaupsilon')))
    color = 'r';
end

if(~isempty(regexpi(field,'lrevomega')) || ~isempty(regexpi(field,'lrevupsilon')))
    color = 'b';
    return;
end

if(~isempty(regexpi(field,'srevomega')) || ~isempty(regexpi(field,'srevupsilon')))
    color = 'c';
    return;
end





% if(nargout==0)
%     disp([sprintf('ylabelstring = %s',ylabelstring)]);
%     disp([sprintf('ylim = [%f %f]',ymin, ymax)]);
%     disp([sprintf('color = ''%s''', color)]);
% end

return;
end
