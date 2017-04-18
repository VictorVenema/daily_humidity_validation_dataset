function data = add_annual_cycle(data, date, monthlyMeans)

noStations = size(data,2);
for iStat = 1:noStations
    for iMonth = 1:12
        index = find(date.month==iMonth & isfinite(data(:,iStat))) ;    
        data(index,iStat) = data(index,iStat) + monthlyMeans(iMonth, iStat);
    end
end