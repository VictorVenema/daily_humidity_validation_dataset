function analyse_homogeneous_data_zamg

baseDirNameInput = ['/data/zamg_humidity/Homogeneous/'];

subDirs = dir(fullfile(baseDirNameInput, '*'));
subDirs = remove_invisible_dirs(subDirs);
noDirs = numel(subDirs);

datag = NaN*zeros(36525, 10, noDirs);
for iDir = 1:noDirs
    currentDirName = fullfile(baseDirNameInput, subDirs(iDir).name);
    [stationNo, date, data] = read_zamg(currentDirName, 1);
    noStations = numel(stationNo);
    datag(:,1:noStations,iDir) = data;
end
data = nanmean(nanmean(datag,3),2);

figure(10)
plot(date.decYear, data) 

[years, annualMeans] = compute_annual_means(date, data);

figure(11)
plot(years, annualMeans)

networkAnnualMeans = annualMeans;

%     figure(12)
%     plot(years, networkAnnualMeans)

halfWindowSize = 5;
windowSize = halfWindowSize * 2 + 1; % 11;
smoothNetworkAnnualMeans = filter(ones(1,windowSize)/windowSize,1,networkAnnualMeans);

figure(13)
x = years(1+halfWindowSize:end-halfWindowSize);
y = smoothNetworkAnnualMeans(windowSize:end);
plot(x, y, 'rx')
hold on            
plot(years, networkAnnualMeans)
hold off

range = max(y)-min(y);
variance = var(y);
fprintf(1, 'Range: %g\tVariance: %g\n', range, variance)
a=0;


function [uniqueYears, annualMeans] = compute_annual_means(date, data)

uniqueYears = unique(date.year);
noUniqueYears = numel(uniqueYears);
noStations = size(data, 2);
annualMeans = NaN*zeros(noUniqueYears, noStations);
for iYear = 1:noUniqueYears
    index = find(date.year==uniqueYears(iYear));
    for iStat=1:noStations
        annualMeans(iYear,iStat) = mean(data(index,iStat)); %#ok<FNDSB>
    end
end % iYear
