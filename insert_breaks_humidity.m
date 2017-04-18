function [dataDet, breaksDet, dataSto, breaksSto, perturbations2DDet, perturbations2DSto] = insert_breaks_humidity(data, date, stationNo, taperBreakFreqBegin)
% Insert uncorrelated break points in the benchmark dataset.
% The breaks are inserted such, that the end values are unchanged.
% Furthermore, no breaks are inserted if there are no measurements before
% or after this break, as these would be undetectable.
% 
% data:     A matrix with multiple stations of an additative variable, e.g. temperature
% noBreaks: The average number of breaks per measurement station.

breakSizeMeanDet = 0.7; 
breakSizeMeanSto = 0.35;
breakSizeDeformation = 1.5; 
seasonalBreakSizeDet = 0.7;
seasonalBreakSizeSto = 0.35;
trendBias = 0.02; % Bias of the perturbaition in % per year, leading to a trend bias in the inhomogeneous data
noValues     = size(data, 1);
noStations   = size(data, 2);

% Compute postions of the breaks
[breaks, noRandomBreaksNetwork] = compute_positions_breaks_network(data, date, noValues, stationNo, taperBreakFreqBegin);

% Implement the breaks
humidity = 1:100;
dataDet = data;
if ( noRandomBreaksNetwork > 0 ) 
    for iStation = 1:noStations
        stationBreaks = breaks([breaks.iStation]==iStation);    
        noStationBreaks = numel(stationBreaks);
        if ( noStationBreaks > 0 )
            [dummy, index] = sort([stationBreaks.iPos], 'ascend');
            for iBreak = 1:noStationBreaks                    
                if ( iBreak == 1 )
                    sectionIndices = 1:stationBreaks(index(iBreak)).iPos;
                else
                    sectionIndices = stationBreaks(index(iBreak-1)).iPos+1:stationBreaks(index(iBreak)).iPos;
                end
                
                seasonalBreakPerturb =  compute_seasonal_deviations(seasonalBreakSizeDet);
                breakBias = trendBias * ( stationBreaks(index(iBreak)).time.year - date.year(end) );
                deterministicPerturb = compute_deterministic_perturbations(breakSizeMeanDet, breakSizeDeformation, breakBias);
                perturbations2DDet = taper_perturbations_near_saturation(seasonalBreakPerturb, deterministicPerturb); % Taper near 100% and 0% humidity to prevent unphysical values
                
                figure(11)
                imagesc(perturbations2DDet)
                colorbar
                xlabel(humidity)
                ylabel(month)
                                
                excess = 0;     
                deficit = 0;
                for iVal = sectionIndices
                    if ( isfinite( dataDet(iVal, iStation) ) )
                        perturbation = interp1(humidity, perturbations2DDet(date.julianDay(iVal), :), data(iVal, iStation));
                        perturbation = perturbation+excess+deficit;
                        newVal = dataDet(iVal, iStation) + perturbation;
                        if ( newVal >= 0 && newVal <= 100 )
                            dataDet(iVal, iStation)  = newVal;
                        end
                        if ( newVal > 100 )
                            excess = newVal - 100;
                            deficit = 0;
                            dataDet(iVal, iStation)  = 100;
                        end
                        if ( newVal < 0 )
                            deficit = newVal;
                            excess = 0;
                            dataDet(iVal, iStation)  = 0;
                        end    
                    end % if finite value
                end
             end % for all breaks in station
        end % if there are breaks
    end % for all stations
else
    breaks(1).stationNo = NaN; 
    breaks(1).iStation = NaN; 
    breaks(1).time.year = NaN; 
    breaks(1).time.month = NaN; 
    breaks(1).time.day = NaN; 
    breaks(1).time.julianDay = NaN; 
    breaks(1).time.decYear = NaN; 
    breaks(1).iPos = NaN; 
    breaks(1).type = NaN;    
end

% Generate the stochastic inhomogeneities
dataSto = dataDet;   % The stochastic inhomogeneities consists of the deterministic inhomogeneities plus noisy inhomogeneities.
if ( noRandomBreaksNetwork > 0 )
    for iStation = 1:noStations
        stationBreaks = breaks([breaks.iStation]==iStation);    
        noStationBreaks = numel(stationBreaks);
        if ( noStationBreaks > 0 )
            [dummy, index] = sort([stationBreaks.iPos], 'ascend');
            for iBreak = 1:noStationBreaks          
                if ( iBreak == 1 )
                    sectionIndices = 1:stationBreaks(index(iBreak)).iPos;
                else
                    sectionIndices = stationBreaks(index(iBreak-1)).iPos+1:stationBreaks(index(iBreak)).iPos;
                end
                
                seasonalBreakPerturb =  compute_seasonal_deviations(seasonalBreakSizeSto);
                seasonalBreakPerturb = seasonalBreakPerturb - min(seasonalBreakPerturb);
                breakBias = -1 * trendBias * ( stationBreaks(index(iBreak)).time.year - date.year(end) );
                stochasticPerturb = compute_stochastic_perturbations(breakSizeMeanSto, breakBias);
                perturbations2DSto = taper_perturbations_near_saturation(seasonalBreakPerturb, stochasticPerturb);                
                
                excess = 0;     
                deficit = 0;
                for iVal = sectionIndices
                    if ( isfinite( dataSto(iVal, iStation) ) )
                        perturbationSize = interp1(humidity, perturbations2DSto(date.julianDay(iVal), :), data(iVal, iStation), 'linear', 'extrap');
                        perturbation = randn(1)*perturbationSize+excess+deficit;
                        newVal = dataSto(iVal, iStation) + perturbation;
                        if ( newVal >= 0 && newVal <= 100 )
                            dataSto(iVal, iStation)  = dataSto(iVal, iStation) + perturbation;
                        end
                        if ( newVal > 100 )
                            excess = newVal - 100;
                            deficit = 0;
                            dataSto(iVal, iStation)  = 100;
                        end
                        if ( newVal < 0 )
                            deficit = newVal;
                            excess = 0;
                            dataSto(iVal, iStation)  = 0;
                        end                
                    end % if finite value
                end % for all values in this homogeneous subperiod
            end % for all breaks in station
        end % if there are breaks
    end % for all stations
else
    breaks(1).stationNo = NaN; 
    breaks(1).iStation = NaN; 
    breaks(1).time.year = NaN; 
    breaks(1).time.month = NaN; 
    breaks(1).time.day = NaN; 
    breaks(1).time.julianDay = NaN; 
    breaks(1).time.decYear = NaN; 
    breaks(1).iPos = NaN; 
    breaks(1).type = NaN;    
end

breaksDet = breaks;
breaksSto = breaks;

% figure(20)
% diff = data-dataDeterm;
% imagesc(diff')
% axis xy
% colorbar
% 
% figure(21)
% mplot(diff)

a=0;
