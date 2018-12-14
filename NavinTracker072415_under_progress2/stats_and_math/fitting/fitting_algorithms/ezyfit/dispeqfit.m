function dispeqfit(f,fp)
%DISPEQFIT   Display the equation of a fit.
%   DISPEQFIT(F) displays the equation of the fit F in the command window,
%   using the settings defined in FITPARAM. The fit structure F is
%   obtained from EZFIT. By default, DISPEQFIT is automatically called from
%   FIT when no output argument is specified.
%
%   Example:
%      plotsample('power')
%      f = ezfit('alpha/x^n');
%      dispeqfit(f);
%
%   See also FITPARAM, EZFIT, SHOWFIT, SELECTFIT, SHOWEQBOX

%   F. Moisy, moisy_at_fast.u-psud.fr
%   Revision: 1.20,  Date: 2006/10/18
%   This function is part of the EzyFit Toolbox

% History:
% 2006/02/08: v1.00, first version.
% 2006/02/13: v1.10, compatible with 'y(x)=..' (free function name)
% 2006/10/18: v1.20, new argument fp

if nargin<2
    % loads the default fit parameters:
    try
        fp=fitparam;
    catch
        error('No fitparam file found.');
    end
end

streq='';
if(isfield(f,'eq'))
    streq = f.eq;
end
if strcmp(fp.eqreplacemode,'on'),
    for n=1:length(f.m),
        streq = strrep(streq, f.param{n}, num2str(f.m(n), fp.numberofdigit));
    end
    streq = strrep(streq,'+-','-');
    if(isfield(f,'yvar'))
        disp(['Equation: ' f.yvar '(' f.xvar ') = ' streq]);
    end
else
    if(isfield(f,'yvar'))
        disp(['Equation: ' f.yvar '(' f.xvar ') = ' streq]);
    end
    for i=1:length(f.m)
        if(isfield(f,'m_error'))
            disp([ '     ' f.param{i} ' = ' num2str(f.m(i), fp.numberofdigit) ' +/- ' num2str(f.m_error(i), fp.numberofdigit)   ]);
        else
            if(isfield(f,'m_std'))
                disp([ '     ' f.param{i} ' = ' num2str(f.m(i), fp.numberofdigit) ' +/- ' num2str(f.m_std(i), fp.numberofdigit)   ]);
            else
                disp([ '     ' f.param{i} ' = ' num2str(f.m(i), fp.numberofdigit)]);
            end
        end
    end
end

if(isfield(f,'chi2'))
    lastline=['chi2 = ' num2str(f.chi2, fp.numberofdigit) '  '];
    disp(['     ' lastline]);
end

if(isfield(f,'aic'))
    lastline=['aic = ' num2str(f.aic, fp.numberofdigit) '  '];
    disp(['     ' lastline]);
end

lastline='';
switch lower(fp.corrcoefmode),
    case 'r2', lastline=['R^2 = ' num2str(f.r2, fp.numberofdigit) '  '];
end
if strcmp(fp.linlogdisp,'on');
    if(isfield(f,'fitmode'))
        lastline=[lastline '(' f.fitmode ')'];
    end
end
if ~isempty(lastline)
    disp(['     ' lastline]);
end
