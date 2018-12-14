function overlay_movie_BinData_over_average_BinData(attribute, AvgBinData, MovieBinDataArray)


for(i=1:length(MovieBinDataArray))
    plot(MovieBinDataArray(i).freqtime, MovieBinDataArray(i).(attribute),'color', [rand rand rand]);
    hold on;
end

plot(AvgBinData.freqtime, AvgBinData.(attribute), 'color', 'r','linewidth',2);
hold on;
errfield = sprintf('%s_err',attribute);
errorline(AvgBinData.freqtime, AvgBinData.(attribute), AvgBinData.(errfield), 'r');
hold off

return;
end
