% function plot_surrogate_validation
% This function computes and plots the statistics shown in the validation
% figure of the article showing how well the statistics of the surrogates
% match the observational data.

baseDirNameInput = ['/data/zamg_humidity/Netzwerke_Metainformation/'];
baseDirNameOutput = ['/data/zamg_humidity/Surrogate/'];
baseDirNamePlot = ['/data/zamg_humidity/Plot/'];
subDirs = dir(baseDirNameInput);
subDirs = remove_invisible_dirs(subDirs);

noDirs = numel(subDirs);
noRep = 10;
FontSize = 36;

% Set properties surrogate
beginYear = 1901;
endYear   = 2000;

dataFileDirName = fullfile(baseDirNamePlot, 'data3.mat');
if 1 % exist(dataFileDirName, 'file') == 0
    % Read observational data and input statistics of the surrogates
    dataCell = cell(1,noDirs);
    sortedValuesCell = cell(1,noDirs);
    stationDataCell = cell(1,noDirs);
     for iDir = 1:noDirs
        currentDirName = fullfile(baseDirNameInput, subDirs(iDir).name);
        fprintf(1, '%s\n', currentDirName)
        saveDirName = unique_filename(fullfile(baseDirNameOutput, [subDirs(iDir).name, '.']), '', 1, '%02.f');
        if ( exist(saveDirName, 'file') == 0 || computeNew == 1 )
            [stationNo, date, data, metaData] = read_zamg(currentDirName);
            noStations = numel(stationNo);

            % Compute distributions setting filled values to NaN
            [sortedValues, categories, standardDeviation, surrogateDate] = compute_sorted_values_differences_categories(date, data, beginYear, endYear, metaData);

            % Calculate complex Fourier coefficients 
            [fourierCoeff, stationData] = compute_fourier_coefficients_plot(data, surrogateDate, date, metaData);            

            dataCell{iDir} = data;
            sortedValuesCell{iDir} = sortedValues;
            stationDataCell{iDir}  = stationData;

            a=0;
        end % if file exists
     end % for all dirs
     
    % Read surrogate data
    baseDirNameSurr = ['/data/zamg_humidity/Surrogate/'];

    subDirsSurr = dir(baseDirNameSurr);
    subDirsSurr = remove_invisible_dirs(subDirsSurr);
    noDirsSurr = numel(subDirsSurr);

    surrCell = cell(1,noDirs);
    for iDir = 1:noDirsSurr
        currentDirNameSurr = fullfile(baseDirNameSurr, subDirsSurr(iDir).name);
        fprintf(1, '%s\n', currentDirNameSurr)

        [stationNoData, dateData, surr, metaData] = read_zamg(currentDirNameSurr);
        surrCell{iDir} = surr;
    end % for loop over all surrogate dirs
     
     save(dataFileDirName, 'dataCell', 'sortedValuesCell', 'stationDataCell', 'surrCell')
else
    load(dataFileDirName)
end
 
% Compute the autocorrelation functions of the station series and average them.
% Unpack the observed values
maxLags = 100;        
maxLags1 = maxLags+1;
noLags = maxLags + maxLags1;
sumAcfData = zeros(noLags,1);
sumCounter = 0;
noDirs = length(dataCell);
for iDir = 1:noDirs
    networkData = dataCell{iDir};
    noStations = size(networkData,2);
    for iStat = 1:noStations
        dataStation = networkData(:,iStat);
        index = find(isfinite(dataStation));
        dataStation = dataStation(index(1):index(end));
        dataStation = dataStation - nanmean(dataStation(:));
        acfData = xcorr(dataStation(isfinite(dataStation)), maxLags, 'coeff');
        sumAcfData = sumAcfData + acfData;
        sumCounter = sumCounter + 1;
    end
end
meanAcfData = sumAcfData / sumCounter;

% Unpack the surrogate values
sumAcfSurr = zeros(noLags,1);
sumCounter = 0;
noDirs = length(surrCell);
for iDir = 1:noDirs
    networkData = surrCell{iDir};
    noStations = size(networkData,2);
    for iStat = 1:noStations
        dataStation = networkData(:,iStat);
        index = find(isfinite(dataStation));
        dataStation = dataStation(index(1):index(end));
        dataStation = dataStation - nanmean(dataStation(:));
        acfData = xcorr(dataStation(isfinite(dataStation)), maxLags, 'coeff');
        sumAcfSurr = sumAcfSurr + acfData;
        sumCounter = sumCounter + 1;
    end
end
meanAcfSurr = sumAcfSurr / sumCounter;

% Unpack the station Data used to compute Fourier Coefficient
sumAcfStation = zeros(noLags,1);
sumCounter = 0; % counter for number of stations
noValCounter = 0;  % counter for number of data points
noDirs = length(stationDataCell);
for iDir = 1:noDirs
    networkData = stationDataCell{iDir};
    noStations = size(networkData,2);
    for iStat = 1:noStations
        dataStation = networkData(:,iStat);
        index = find(isfinite(dataStation));
        dataStation = dataStation(index(1):index(end));
        dataStation = dataStation - nanmean(dataStation(:));
        acfData = xcorr(dataStation(isfinite(dataStation)), maxLags, 'coeff');
        sumAcfStation = sumAcfStation + acfData;
        sumCounter = sumCounter + 1;
        noValCounter = noValCounter + numel(dataStation);
    end
end
meanAcfStation = sumAcfStation / sumCounter;
disp(noValCounter)

%%% Compute the Empirical Distribution Function of the data itself
% Unpack the surrogate values
surr = [];
noDirs = length(surrCell);
for iDir = 1:noDirs
    a = surrCell{iDir};
    b=a(isfinite(a));        
    surr = [surr; b];
end

% Unpack the observed values
data = [];
noDirs = length(dataCell);
for iDir = 1:noDirs
    a = dataCell{iDir};
    b=a(isfinite(a));        
    data = [data; b];
end

% Unpack the sorted values of the same station
sortedValues = [];
for iDir = 1:noDirs
    a = sortedValuesCell{iDir};
    for iMonth = 1:12
        b=a{iMonth};
        noStations = length(b);
        for iStat = 1:noStations
            sortedValues = [sortedValues; b{iStat,iStat}];
        end
    end    
end

percentageSaturatedData    = 100*numel(find(data==100))/numel(data);
percentageSaturatedSorted = 100*numel(find(sortedValues==100))/numel(sortedValues);
percentageSaturatedSurr     = 100*numel(find(surr==100))/numel(surr);
disp(percentageSaturatedData)
disp(percentageSaturatedSorted)
disp(percentageSaturatedSurr)

[fData, xData] = ecdf(data);
[fSortedValues, xSortedValues] = ecdf(sortedValues);
[fSurr, xSurr] = ecdf(surr);

mean(data)
mean(sortedValues)
mean(surr)
std(data)
std(sortedValues)
std(surr)

figure(1)
set(gcf, 'Color', [1 1 1]);
% figure('Color', [1 1 1]);
ax = [20   10  1000   1000];
set(gcf, 'position', ax);
plot(xData, fData, 'k', 'LineWidth', 4)
hold on
plot(xSortedValues, fSortedValues, 'g--', 'LineWidth', 2)
res = length(xSurr)/25;
index = round([1:res:length(xSurr), length(xSurr)]);
plot(xSurr(index), fSurr(index), 'bo', 'MarkerSize', 12, 'LineWidth',2)
hold off
grid
[legend_h,object_h,plot_h,text_strings] = legend('Observations', 'Statistics', 'Surrogate', 'location', 'NorthWest');
legend('boxoff')
% pos = get(object_h(1), 'position');
% text(40, pos(2), {2.332, 2.322, 2.222}, 'FontSize', FontSize, 'VerticalAlignment', 'Bottom')

title('ECDF','fontsize',FontSize*1.1)
xlabel('Humidity (%)', 'fontsize',FontSize)
ylabel('Cummulative probability','fontsize',FontSize)
set(gca,'FontSize',FontSize)
axis square
set(gca,'Color', [1 1 1]);
dirFileName = fullfile(baseDirNamePlot, 'ecfd_series.png');
save_current_figure(dirFileName)



% Plot the ACFs
maxLagsPlotVals = [10, 100];
indexPlot = {1:11, [1:5, 6:5:maxLags1, maxLags1] };
for iPlot = 1:2 
    maxLagsPlot = maxLagsPlotVals(iPlot);
    maxLagsPlotEnd = maxLags + maxLagsPlot + 1;
    figure(iPlot+2)    
    set(gcf, 'Color', [1 1 1]);
    ax = [20   10  1000   1000];
    % ax = [200   100  700   700];
    set(gcf, 'position', ax);
    plot(0:maxLagsPlot, meanAcfData(maxLags1:maxLagsPlotEnd), 'k-', 'linewidth', 4)
    hold on
    plot(0:maxLagsPlot, meanAcfStation(maxLags1:maxLagsPlotEnd), 'g--', 'LineWidth', 2)
    t = 0:maxLags;
    y = meanAcfSurr(maxLags1:end);
    index = indexPlot{iPlot}; % [1:5, 6:5:maxLags, maxLags];
    plot(t(index), y(index) , 'bo', 'MarkerSize', 12, 'LineWidth',2)
    hold off
    grid
    % legend('Observations', 'Statistics', 'Surrogate', 'location','NorthWest') 
    % legend('boxoff')
    title('Autocorrelation function','fontsize',FontSize*1.1)
    xlabel('Lag (days)','fontsize',FontSize)
    ylabel('Correlation','fontsize',FontSize)
    set(gca,'FontSize',FontSize)
    axis square
    fileName = ['acf_series_', num2str(maxLagsPlot), '.png'];
    dirFileName = fullfile(baseDirNamePlot, fileName);
    save_current_figure(dirFileName)
end




%%% Compute the Empirical Distribution Function of the difference series
% Unpack the surrogate values
surr = [];
noDirs = length(surrCell);
for iDir = 1:noDirs
    a = surrCell{iDir};
    noStations = size(a,2);    
    for iStat1 = 1:noStations
        for iStat2 = iStat1:noStations
            if iStat2 > iStat1
                b = a(:,iStat1)-a(:,iStat2);
                b = b(isfinite(b));         
                surr = [surr; b];
            end
        end
    end
end

% Unpack the observed values
data = [];
noDirs = length(dataCell);
for iDir = 1:noDirs
    a = dataCell{iDir};
    noStations = size(a,2);    
    for iStat1 = 1:noStations
        for iStat2 = iStat1:noStations
            if iStat2 > iStat1
                b = a(:,iStat1)-a(:,iStat2);
                b = b(isfinite(b));        
                data = [data; b];
            end
        end
    end
end


% Unpack the sorted values of the same station
sortedValues = [];
for iDir = 1:noDirs
    a = sortedValuesCell{iDir};
    for iMonth = 1:12
        b=a{iMonth};
        noStations = length(b);
        for iStat1 = 1:noStations
            for iStat2 = iStat1:noStations
                if iStat2 > iStat1
                    sortedValues = [sortedValues; b{iStat1,iStat2}];
                end
            end
        end
    end    
end

[fData, xData] = ecdf(data);
[fSortedValues, xSortedValues] = ecdf(sortedValues);
[fSurr, xSurr] = ecdf(surr);

mean(data)
mean(sortedValues)
mean(surr)
std(data)
std(sortedValues)
std(surr)

figure(2)
set(gcf, 'Color', [1 1 1]);
ax = [20   10  1000   1000];
% ax = [200   100  700   700];
set(gcf, 'position', ax);
plot(xData, fData, 'k', 'LineWidth', 4)
hold on
plot(xSortedValues, fSortedValues, 'g--', 'LineWidth', 2)
res = length(xSurr)/25;
index = round([1:res:length(xSurr), length(xSurr)]);
plot(xSurr(index), fSurr(index), 'bo', 'MarkerSize', 12, 'LineWidth',2)
hold off
grid
% legend('Observations', 'Statistics', 'Surrogate', 'location','NorthWest') 
% legend('boxoff')
title('ECDF difference series','fontsize',FontSize*1.1)
xlabel('Humidity difference (%)','fontsize',FontSize)
ylabel('Cummulative probability','fontsize',FontSize)
set(gca,'FontSize',FontSize)
axis square
dirFileName = fullfile(baseDirNamePlot, 'ecfd_difference.png');
save_current_figure(dirFileName)




% set(h, 'Position', [110 140 scrsz(3)*0.8 0.8*scrsz(4)-120]);
% ylabel('George''s Popularity','fontsize',12,'fontweight','b')
% axis tight
% ax = axis;
% ax(3) = 0;
% axis(ax)

a=0;
% noMissingData = 355 + 746 + 179 + 552 + 746 + 18;
% noObservations = 34344 +  40164 + 22874 + 24649 + 32854 + 16053;
