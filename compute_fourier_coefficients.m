function fourierCoeff = compute_fourier_coefficients(data, surrogateDate, dataDate, metaData)
% This function computes the fourierCoeffecients for a (typically longer)
% surrogate based on the fourierCoefficients of the stations, which all
% have a different lenght. The Fourier coefficients of the stations thus
% have to be interpolated to the ones of the surrogate.

% First compute the Fourier frequencies and initialise the fourier Matrix
noStations = size(data,2);
noValues = size(surrogateDate.day,1);
freqSurrogate = calc_fourier_frequencies(1, noValues);
fourierCoeff = NaN*zeros(numel(freqSurrogate), noStations);

onlyHighfrequencies = 0;
if onlyHighfrequencies
    cutOffFreq = 1/(2.5*365.24); % Frequencies below this threshold (time scales above this threshold) are not taken into account in generating the surrogate
    freqSurrogate(abs(freqSurrogate)<cutOffFreq) = NaN;
    for iStat = 1:noStations
        stationData = data(:,iStat);
        index = find(isfinite(stationData));
        firstIndex = index(1);
        lastIndex  = index(end);
        stationData = stationData(firstIndex:lastIndex);

        freqStation = calc_fourier_frequencies(1, numel(stationData));
        stationData = stationData - mean(stationData(:));
        hammingWindow = hamming(numel(stationData));
        stationData = stationData .* hammingWindow;
        coeffStation = abs(ifft(stationData));
        coeffStationInterpol = interp1(freqStation, coeffStation, freqSurrogate); % yi = interp1(x,Y,xi)
        fourierCoeff(:,iStat) = coeffStationInterpol;
    end
else
    hammingWindow = hamming(noValues); % Observational series are windowed to reduce cross-talk
    % The fourier series is computed for every series individually because
    % they all have different lenghts.
    for iStat = 1:noStations
        % Select segment with data
        stationData = data(:,iStat);
        index = find(isfinite(stationData));
        firstIndex = index(1);
        lastIndex  = index(end);
        stationData = stationData(firstIndex:lastIndex);
        stationYear = dataDate.year(firstIndex:lastIndex);
        stationMonth = dataDate.year(firstIndex:lastIndex);        
        
        % If there is a long section with missing data, select the longest
        % segment without such a segment. Filled values are treated as
        % missing.
        noVal = numel(stationData);
        if ( exist('metaData', 'var') > 0 ) % If metadata on filled values is available use this. Was done in final version for article
            stationDataNaN = metaData(firstIndex:lastIndex,iStat);
        else % If no metadata on filled values is available, estimate which values are filled. Was done in a first version of the code when no metadata was given to me yet.
            t = 2:noVal;
            t1=1:noVal-1;
            indexFilled1 =  abs((stationData(t)-stationData(t1))) < 1e-3 & (stationData(t)<98) ;
            t2 = 1:noVal-1;
            t3=2:noVal;
            indexFilled2 =  abs((stationData(t2)-stationData(t3))) < 1e-3 & (stationData(t2)<98) ;
            stationDataNaN = zeros(size(stationData));
            stationDataNaN(t(indexFilled1)) = 1;
            stationDataNaN(t2(indexFilled2)) = 1;
        end
        % Perform a median filtering to detect long segments with missing
        % data, but ignore short missing data segments.
        stationDataNaN = medfilt1(stationDataNaN,100); %  the function considers the signal to be 0 beyond the end points.
%         figure(12), plot(stationDataNaN, 'rx')
        
        % Select the longest segment if necessary
        index = find(stationDataNaN == 1);
        while ( numel(index)  > numel(stationData) * 0.1 )
            inDataSection = 0;
            ibMax = 1;
            ieMax = noVal;
            lengthDataSectionSegment = -inf;
            lengthDataSectionMax = -inf;
            for iVal = 1:noVal
                if ( inDataSection == 1 && stationDataNaN(iVal) == 0 ) % Futher values in data segment found
                    lengthDataSectionSegment = lengthDataSectionSegment + 1;                    
                end                 
                if ( inDataSection == 0 && stationDataNaN(iVal) == 0 ) % First value of data segment found
                    lengthDataSectionSegment = 1;
                    inDataSection = 1;
                    ib = iVal;
                end
                if ( inDataSection == 1 && stationDataNaN(iVal) == 1 ) % Used to be in data segment, now a NaN is found
                    inDataSection = 0;
                    ie = iVal - 1;
                    if ( lengthDataSectionSegment > lengthDataSectionMax )
                        lengthDataSectionMax = lengthDataSectionSegment;
                        ibMax = ib;
                        ieMax = ie;
                    end
                end 
            end            
            stationData = stationData(ibMax:ieMax);           
            stationDataNaN = stationDataNaN(ibMax:ieMax);           
            index = find(stationDataNaN == 1);
        end
        
        % Make the observational data the same length as the surrogate data
        % we need by mirroring it and cutting it to size.
        stationData = lengthen_shorten_dataset_daily_zamg(stationYear, stationMonth, stationData, noValues);
        % Compute Fourier spectrum
        stationData = stationData - mean(stationData(:));
        stationData = stationData .* hammingWindow;
        coeffStation = abs(ifft(stationData));
        fourierCoeff(:,iStat) = coeffStation;
    end
end
a=0; %#ok<NASGU>