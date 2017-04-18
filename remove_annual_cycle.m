function [dataOut, monthlyMeans] = remove_annual_cycle(data, date)

dataOut = NaN*zeros(size(data));
noStations = size(data,2);
monthlyMeans = NaN*zeros(12, noStations);

for iStat = 1:noStations
    for iMonth = 1:12
        index = find(date.month==iMonth & isfinite(data(:,iStat))) ;
        monthlyMeans(iMonth, iStat)  = mean(data(index,iStat));
        dataOut(index,iStat) = data(index,iStat) - monthlyMeans(iMonth, iStat);
    end
end