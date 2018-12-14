function batch_periodogram_plot(dataset,fs)
% % dataset: e.g. = results.binnedSpeed.N2;
% % fs: sampling frequency, how many data points per sec
% % fignum: which figure you want to put your plots in
dlen = length(dataset);
for di = 1:dlen
   z = dataset(di).Speed;
   plotrefbool = (di == 1);
   power_spectrum_fun(z,fs,plotrefbool);
end