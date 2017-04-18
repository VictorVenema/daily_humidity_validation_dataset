function generate_surrogate_zamg
% This is the first function that needs to be called to generate the
% validation dataset. It reads the observations, computes its statistical
% properties and generates surrogates time series with these properties.
% The next function to be called is:
% generate_homogeneous_data_zamg_additive.m

computeNew = 1;
baseDirNameInput = ['/data/zamg_humidity/Netzwerke_Metainformation/'];
baseDirNameOutput = ['/data/zamg_humidity/Surrogate/'];
subDirs = dir(baseDirNameInput);
subDirs = remove_invisible_dirs(subDirs);

noDirs = numel(subDirs);
noRep = 10;

% Set properties surrogate
beginYear = 1901;
% endYear   = 1905;
endYear   = 2000;

% Settings for SIAAFT algorithm
interationsThreshold = +inf; % 100; 24; Set to +inf if the other settings should take precedence.
timeThreshold = 0.05*3600; % 20; % 0.05*3600; % 2 Hours % 0.15*3600; % 9 Hours % 0.025*3600; % (2 Hours) % 0.75*3600; % 8*3600; 1; iteration time (of one of the two stages) in seconds
counterThreshold = +inf; % This iteration threshold is set to 100 to make the first run fast, a better value is 1000 or 10.000 or +inf if the other settings should take precedence.

for iRep = 1:noRep
    for iDir = 1:noDirs
        currentDirName = fullfile(baseDirNameInput, subDirs(iDir).name);
        fprintf(1, '%s\n', currentDirName)
        saveDirName = unique_filename(fullfile(baseDirNameOutput, [subDirs(iDir).name, '.']), '', 1, '%02.f');
        if ( exist(saveDirName, 'file') == 0 || computeNew == 1 )

            [stationNo, date, data, metaData] = read_zamg(currentDirName);
            noStations = numel(stationNo);

%             figure(1)
%             mplot(data)

            % Compute statistical properties for surrogate from observation
            % Remove annual cycle 
            [data, monthlyMeans] = remove_annual_cycle(data, date);

    %         figure(2)
    %         mplot(data)
    %         meanValue = nanmean(data(:));
    %         data = data - meanValue;
    
            % Compute distributions setting filled values to NaN
            [sortedValues, categories, standardDeviation, surrogateDate] = compute_sorted_values_differences_categories(date, data, beginYear, endYear, metaData);

            % Calculate complex Fourier coefficients 
            fourierCoeff = compute_fourier_coefficients(data, surrogateDate, date, metaData);

            % Scale the total variance to the power spectrum to the
            % variance of the amplitude distribution (the station series). 
    %         noValues = numel(surrogateDate.day);
            for iStat = 1:noStations
                dataCat = [];
                for iCat = 1:12
                    dataCat = [dataCat; sortedValues{iCat}{iStat,iStat}]; %#ok<AGROW>
                end            
                totalVariancePdf = var(dataCat(:));
                fourierCoeffStat = fourierCoeff(:,iStat);
                surrogate = fft(fourierCoeffStat);
                totalVarianceSpec = var(surrogate(:));

                fourierCoeffStat = fourierCoeffStat.^2;
                fourierCoeffStat =  fourierCoeffStat * totalVariancePdf / totalVarianceSpec; 

                fourierCoeff(:,iStat) = sqrt(fourierCoeffStat);   
            end

            % Generate surrrogate    
             [surrogate, spectralDiff] = iaaft_loop_cat_1dm_difference(fourierCoeff, sortedValues, categories, standardDeviation, ...
                                                        counterThreshold, [], timeThreshold, interationsThreshold);
            surrogate = add_annual_cycle(surrogate, surrogateDate, monthlyMeans);
            
            save_zamg(saveDirName, stationNo, surrogateDate, surrogate, spectralDiff, 1)
        end % if output file already exists
    end % for iDir
end % for iRep

% plot_comparison_data_surrogate
% plot_comparison_data_surrogate_all_scatterplots
% generate_homogeneous_data_zamg_additive
