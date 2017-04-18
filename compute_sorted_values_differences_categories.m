function [sortedValues, categoriesLong, standardDeviation, surrogateDate] = compute_sorted_values_differences_categories(inputDate, inputData, beginYear, endYear, metaData)
% This function computes vectors with sorted values that determine the
% values of the surrogate time series. This version also computes the
% distribution of the difference time series (which together define the
% correlations in the network). Every month is treated as a separate
% category, in this way the surrogates also mimick the seasonal cycle in
% the distributions and cross-correlations.

% inputData, decYear, decYearLong
% [noValues noStations] = size(inputData);

% Remove filled values, which are determined by having the same value as
% the last or next observation. Near 100% this may happen more often, thus 
% here no adjustments are made. The filled values are averages and should
% not be that high.

noStations = size(inputData,2);
noVal = size(inputData,1);
if ( exist('metaData', 'var') > 0 )
    % If file contains metadata on filled values, the filled datapoints can be and are set to NaN;
    % 1: Filled, 0: measured, non-filled
    inputData(metaData==1) = NaN;
else
    for iStat = 1:noStations
        t = 2:noVal;
        t1=1:noVal-1;
        indexFilled1 =  abs((inputData(t,iStat)-inputData(t1,iStat))) < 1e-3 & (inputData(t,iStat)<98) ;
        t2 = 1:noVal-1;
        t3=2:noVal;
        indexFilled2 =  abs((inputData(t2,iStat)-inputData(t3,iStat))) < 1e-3 & (inputData(t2,iStat)<98) ;
        inputData(t(indexFilled1),iStat) = NaN;
        inputData(t2(indexFilled2),iStat) = NaN;
    end
end

% Compute vectors with the dates of the surrogate
% First compute vector with the years, taking leap years into account
noValuesYear = [365 366];
noValuesAll = 0;
for iYear = beginYear:endYear
    noValuesAll = noValuesAll + noValuesYear(is_leap(iYear)+1);
end
[year, julian] = generateYearDay(noValuesAll, beginYear);

% Compute the dates within the year
month = zeros(noValuesAll, 1);
day = zeros(noValuesAll, 1);
decYear = zeros(noValuesAll, 1);
for iDay = 1:noValuesAll
     [day1, month1] = julian2date(julian(iDay), year(iDay));
    month(iDay) = month1;
    day(iDay) = day1;
    decYear(iDay) = calcDecYear(year(iDay), julian(iDay));
end
surrogateDate.day = day;
surrogateDate.month = month;
surrogateDate.year = year;
surrogateDate.julianDay = julian;
surrogateDate.decYear = decYear;

% The month is used as category (every month has its own distribution)
categoriesLong = surrogateDate.month; % For legacy reasons the surrogate is assumed to be the longer time series (often is)
categoriesShort = inputDate.month;        % Short denotes the observations used as input

uniqueCategories = sort(unique(categoriesLong));
noCategories = numel(uniqueCategories);
sortedValues = cell(1,noCategories);
allData = []; % Vector to gather data from every category to compute the total standard deviation later on.
for iCat = 1:noCategories    
    currentCategorie = uniqueCategories(iCat);
    index = find(categoriesShort == currentCategorie);
    inputDataCat  = inputData(index,:); %#ok<FNDSB>
    noValuesWanted = numel(find(categoriesLong == currentCategorie));

    for iStat1 = 1:noStations
        for iStat2 = iStat1:noStations
            if ( iStat1 == iStat2 )  
                inputDataStat = inputDataCat(:,iStat1);
                allData = [allData; inputDataStat];     %#ok<AGROW>
            else
                inputDataStat = inputDataCat(:,iStat1) - inputDataCat(:,iStat2) ; 
            end
            inputDataStat = inputDataStat(isfinite(inputDataStat));
            dataCatStat = interpolate_distribution(inputDataStat, noValuesWanted, 'nearest_neighbour_wide');
            sortedValues{iCat}{iStat1,iStat2} = sort(dataCatStat);
        end
    end    
end
standardDeviation = nanstd(allData);
