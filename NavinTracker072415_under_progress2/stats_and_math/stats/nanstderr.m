function y = nanstderr(varargin)
%NANSTDERR Standard error of the mean, ignoring NaNs.

y = (nanstd(varargin{:}))./sqrt(sum(~isnan(varargin{1})));

return;
end
