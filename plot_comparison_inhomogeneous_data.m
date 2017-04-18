function plot_comparison_inhomogeneous_data

plotAllNew = 0; 
plotCrossCorrelationsNew = 0;
plotCrossSeasonalNew = 0;
plotScatterNew = 0;
plotCDFNew = 0;
plotACFNew = 0;

baseDirNameData = ['/data/zamg_humidity/Netzwerke_Metainformation/'];
baseDirNameSimul = {'/data/zamg_humidity/Inhomogeneous/deterministic/', '/data/zamg_humidity/Inhomogeneous/stochastic/', ...
                                    '/data/zamg_humidity/Reference/deterministic/', '/data/zamg_humidity/Reference/stochastic/', ...
                                    '/data/zamg_humidity/Inhomogeneous/realistic/', '/data/zamg_humidity/Reference/realistic/'};

for iSimul =  5:6 % 1:6 % 3:4 %
    baseDirNameSurr = baseDirNameSimul{iSimul};
    subDirsSurr = dir(baseDirNameSurr);
    subDirsSurr = remove_invisible_dirs(subDirsSurr);
    noDirsSurr = numel(subDirsSurr);

    for iDir = 1:noDirsSurr
        currentDirNameSurr = fullfile(baseDirNameSurr, subDirsSurr(iDir).name);
        fprintf(1, '%s\n', currentDirNameSurr)
        currentDirNameData = fullfile(baseDirNameData, subDirsSurr(iDir).name(1:end-3)); 
        fprintf(1, '%s\n', currentDirNameData)
        temp = split_string(currentDirNameData, dirdelim);
        currentFileNameData = temp{end};

        [stationNoData, dateData, data, metaData] = read_zamg(currentDirNameData);  
        data(metaData==1) = NaN;

        noStations1 = numel(stationNoData);
        noValuesData = size(data,1);
        completeData = 1;
        [stationNoSurr, dateSurr, surr] = read_zamg(currentDirNameSurr, completeData);
        noNeg = numel(find(surr(:)<0));
        if ( noNeg > 0 )
            fprintf(1, '\n');
            fprintf(1, '%s\n', currentDirNameSurr)
            fprintf(1, 'Number of negative values: %d\n', noNeg);
            fprintf(1, '%f\t', surr(surr(:)<0));
            fprintf(1, '\n');
            fprintf(1, '\n');
        end
        noStations2 = numel(stationNoSurr);
        if ( noStations1 == noStations2 )
            noStations = noStations1;
        else
            error('Number of stations is different in surrogate and observations.\n')
        end

        noValuesFinite = sum(isfinite(data(:)));
        averageStationLength = ceil(noValuesFinite/noStations1);
        lengthSurr = size(surr,1);
        partIndex = lengthSurr-averageStationLength+1:lengthSurr;
        surrPart   = surr(partIndex,:);
        dateSurrPart.decYear   = dateSurr.decYear(partIndex,:);

        close all
        dirFileName = fullfile(currentDirNameSurr, 'comparison_overview_image.png');
        if (exist(dirFileName, 'file') == 0 || plotAllNew == 1)
            figure(1)    
    %         ax = get(gcf, 'position');
    %         ax(3) = 1100; ax(4) = 880;
            ax = [20   100  1100   800];
            set(gcf, 'position', ax);       

            subplot(1,2,1)
            imagesc(1:noStations, dateData.decYear, data)
            set(gca,'XTick', 1:noStations)
            set(gca,'XTickLabel',stationNoData)
            xlabel('Station no.')
            ylabel('Year')
            title(['Observation network ', currentFileNameData], 'interpreter', 'none')
            colorbar

            subplot(1,2,2)
            imagesc(1:noStations, dateSurrPart.decYear, surrPart)
            set(gca,'XTick', 1:noStations)
            set(gca,'XTickLabel',stationNoSurr)
            xlabel('Station no.')
            ylabel('Year')
            title(['Surrogate network part', subDirsSurr(iDir).name], 'interpreter', 'none')
            colorbar                

            save_current_figure(dirFileName)
        end % if overview image already exists

        dirFileName = fullfile(currentDirNameSurr, 'cross_correlations.png');
        if (exist(dirFileName, 'file') == 0  || plotAllNew == 1 || plotCrossCorrelationsNew == 1)
            crosscorrData = NaN*zeros(noStations);
            crosscorrSurr2 = NaN*zeros(noStations);
            for iStat1 = 1:noStations
                for iStat2 = 1:noStations
                    index = find(isfinite(data(:,iStat1)) & isfinite(data(:,iStat2)));
                    temp = corrcoef(data(index,iStat1), data(index,iStat2));
                    crosscorrData(iStat1, iStat2) = temp(2);
                    
                    index = find(isfinite(surr(:,iStat1)) & isfinite(surr(:,iStat2)));
                    temp = corrcoef(surr(index,iStat1), surr(index,iStat2));
                    crosscorrSurr2(iStat1, iStat2) = temp(2);
                end
            end
            crosscorrSurr = corrcoef(surr);
            minVal = min([min(crosscorrSurr2(:)) min(crosscorrSurr(:)) min(crosscorrData(:))]);
            maxVal = max([max(crosscorrSurr2(:)) max(crosscorrSurr(:)) max(crosscorrData(:))]);

            if 0
                figure(2)    
                ax = get(gcf, 'position');
                ax(3) = 1200; ax(4) = 500;
                set(gcf, 'position', ax);
                subplot(1,2,1)        
                imagesc(crosscorrData, [minVal maxVal])
                colorbar
                ylabel('Station no.')
                xlabel('Station no.')        
                title(['Cross correlation observations ', currentFileNameData], 'interpreter', 'none')

                subplot(1,2,2)        
                imagesc(crosscorrSurr, [minVal maxVal])
                colorbar        
                ylabel('Station no.')
                xlabel('Station no.')        
                title(['Cross correlation surrogate ', subDirsSurr(iDir).name], 'interpreter', 'none')
                save_current_figure(dirFileName)
            end

            figure(12)    
%             ax = get(gcf, 'position');
%             get(gca, 'position')    0.5703    0.1100    0.2805    0.8150
%             ax(3) = 1200; ax(4) = 500;
            ax = [44         425        1200         500];
            set(gcf, 'position', ax);
            subplot(1,2,1)        
            imagesc(crosscorrData, [minVal maxVal])
            colorbar
            ylabel('Station no.')
            xlabel('Station no.')        
            title(['Cross correlation observations ', currentFileNameData], 'interpreter', 'none')

            subplot(1,2,2)        
            imagesc(crosscorrSurr2, [minVal maxVal])
            colorbar        
            ylabel('Station no.')
            xlabel('Station no.')        
            title(['Cross correlation surrogate ', subDirsSurr(iDir).name], 'interpreter', 'none')
%             pause(1)
            save_current_figure(dirFileName)                
        end % if cross_correlations image already exists

        % Seasonal cycle of the cross correlations (mean cross correlation matrix)
        dirFileName = fullfile(currentDirNameSurr, 'seasonal_cycle_correlations.png');
        if (exist(dirFileName, 'file') == 0  || plotAllNew == 1 || plotCrossSeasonalNew == 1)
            seasonalCycleData = NaN*zeros(1,12);
            seasonalCycleSurr = NaN*zeros(1,12);
            for iMonth = 1:12
                crosscorrData = NaN*zeros(noStations);
                for iStat1 = 1:noStations
                    for iStat2 = 1:noStations                    
                        if ( iStat1 ~= iStat2 )
                            index = find(dateData.month == iMonth & isfinite(data(:,iStat1)) & isfinite(data(:,iStat2)));
                            temp = corrcoef(data(index,iStat1), data(index,iStat2));
                            crosscorrData(iStat1, iStat2) = temp(2);
                            
                            index = find(dateSurr.month == iMonth & isfinite(surr(:,iStat1)) & isfinite(surr(:,iStat2)));
                            temp = corrcoef(surr(index,iStat1), surr(index,iStat2));
                            crosscorrSurr(iStat1, iStat2) = temp(2);                            
                        else
                            crosscorrData(iStat1, iStat2) = 1;
                            crosscorrSurr(iStat1, iStat2) = 1;
                        end
                    end
                end
                seasonalCycleData(iMonth) = nanmean(crosscorrData(:));
                seasonalCycleSurr(iMonth) = nanmean(crosscorrSurr(:));
            end % for iMonth

            figure(3)    
            plot(1:12, seasonalCycleData, 'r-')
            hold on
            plot(1:12, seasonalCycleSurr, 'b-')
            hold off
            legend('Observations', 'Surrogates', 'location', 'south')
            legend boxoff
            xlabel('Months')
            ylabel('Mean correlation matrix')        
            title(['Seasonal cycle correlation maxtrix ', currentFileNameData], 'interpreter', 'none')        
            save_current_figure(dirFileName)
        end % if seasonal_cycle_correlations image already exists


        % Scatterplots of the first station with the others.
        dirFileName = fullfile(currentDirNameSurr, 'comparison_scatterplots.png');
        if (exist(dirFileName, 'file') == 0  || plotAllNew == 1 || plotScatterNew == 1)
            figure(4)    
    %         ax = get(gcf, 'position');
    %         ax(4) = 500;
    %         ax(3) = 1300;
            ax = [1 100 1300 500];
            set(gcf, 'position', ax);
            maxVal = max(data(:));
            minVal = min(data(:));
            iStat1 = 1;
            for iStat2 = (iStat1+1):noStations                
                iStat = iStat2-1 + (iStat1-1)*(noStations-1);
                subplot(2, noStations-1, iStat)
                plot(data(:,iStat1), data(:,iStat2), 'r.', 'markerSize', 0.01)
                axis([minVal maxVal minVal maxVal])
                axis square
                if ( iStat1 == 1 )
                    if ( floor(iStat2+1*2)==noStations )
                        title(['Scatterplots network ', currentFileNameData], 'interpreter', 'none')
                    else
                        title('Observations')
                    end
                end
                xlabel(['Obs. station no. ', num2str(stationNoData(iStat1))])
                ylabel(['Obs. station no. ', num2str(stationNoData(iStat2))])
                subplot(2, noStations-1, iStat+(noStations-1))
                plot(surrPart(:,iStat1), surrPart(:,iStat2), 'b.', 'markerSize', 0.01)
                axis([minVal maxVal minVal maxVal])
                axis square 
                title('Surrogates')
                     
                xlabel(['Surr. station no. ', num2str(stationNoData(iStat1))])
                ylabel(['Surr. station no. ', num2str(stationNoData(iStat2))])
            end
            save_current_figure(dirFileName)
        end % if comparison_scatterplots already exists

        % Plot Cumulative distribution function 
        dirFileName = fullfile(currentDirNameSurr, 'cdf_all_stations.png');
        if (exist(dirFileName, 'file') == 0  || plotAllNew == 1 || plotCDFNew == 1)
            figure(5)    

            dataFinite = data(isfinite(data));
            noValuesFinite = numel(dataFinite);
            x = (0:noValuesFinite-1) / (noValuesFinite-1);
            plot(x, sort(dataFinite(:)), 'k-', 'linewidth', 2)
            hold on

            surrFinite = surr(isfinite(surr));        
            noValuesSurr = numel(surrFinite); 
            x = (0:noValuesSurr-1) / (noValuesSurr-1);
            plot(x, sort(surrFinite(:)), 'r--')
            hold off
            legend('Observations', 'Surrogates', 'location', 'SouthEast')
            legend boxoff

            save_current_figure(dirFileName)
        end % if CDF plot exists
    %     a=0;

        if 1
            % Plot Autocorrelation function 
            dirFileName = fullfile(currentDirNameSurr, 'acfs.png');
            if  (exist(dirFileName, 'file') == 0  || plotAllNew == 1 || plotACFNew == 1 )
                figure(6)    
    %             ax = get(gcf, 'position');
    %             ax(4) = 850;
    %             ax(3) = 700;        
                ax = [200   100  700   700];
                set(gcf, 'position', ax);

                maxlags = 100;        
                maxLags1 = maxlags+1;
                for iStat = 1:noStations
                    dataStation = data(:,iStat);
                    index = find(isfinite(dataStation));
                    dataStation = dataStation(index(1):index(end));
                    dataStation = dataStation - nanmean(dataStation(:));
                    acfData = xcorr(dataStation(isfinite(dataStation)), maxlags, 'coeff');

                    surrStation = surr(:,iStat);
                    index = find(isfinite(surrStation));     
                    surrStation = surrStation(index(1):index(end));
                    surrStation = surrStation - nanmean(surrStation(:));                    
                    acfSurr = xcorr(surrStation(isfinite(surrStation)), maxlags, 'coeff');

                    subplot(3,2,iStat)
                    plot(0:maxlags, acfData(maxLags1:end), 'k-', 'linewidth', 2)
                    hold on
                    plot(0:maxlags, acfSurr(maxLags1:end),  'r--')
                    hold off
                    if ( iStat == 1 )                    
                        title(['Observation network ', currentFileNameData], 'interpreter', 'none')
                    else
                        title('Auto-correlation function', 'interpreter', 'none')
                    end
                    xlabel(['Lag (days), station no. ', num2str(stationNoData(iStat))])
                    ylabel('Correlation')
                    grid
                    if ( iStat == 1 )
                        legend('Observations', 'Surrogates')
                        legend boxoff
                    end
                end
                save_current_figure(dirFileName)
            end
        end % if plot ACF
        a=0; %#ok<NASGU>
    end
end % for iSimulations
a=0; %#ok<NASGU>
    