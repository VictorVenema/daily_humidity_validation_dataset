function plot_zamg_data

baseDirName = ['/data/zamg_humidity/Netzwerke/'];
subDirs = dir(baseDirName);
subDirs = remove_invisible_dirs(subDirs);
noDirs = numel(subDirs);

for iDir = 1:noDirs
    currentDirName = fullfile(baseDirName, subDirs(iDir).name);
    fprintf(1, '%s\n', currentDirName)
    
    [stationNo, date, data] = read_zamg(currentDirName);
    noStations = numel(stationNo);
    
    dirFileName = fullfile(currentDirName, 'overview_image.png');
    if (exist(dirFileName, 'file') == 0 )
        figure(1)    
        imagesc(1:noStations, date.decYear, data)
        set(gca,'XTick', 1:noStations)
        set(gca,'XTickLabel',stationNo)
        xlabel('Station no.')
        ylabel('Year')
        title(['Overview network ', subDirs(iDir).name], 'interpreter', 'none')
        colorbar
        save_current_figure(dirFileName)
    end % if overview image already exists
    
    dirFileName = fullfile(currentDirName, 'overview_plot.png');
    if (exist(dirFileName, 'file') == 0 )
        figure(2)    
        ax = get(gcf, 'position');
        ax(4) = 800;
        set(gcf, 'position', ax);
        mplot(date.decYear, data)
        ylabel('Station no.')
        xlabel('Relative humidity [%]')
        subplot(noStations, 1, 1)
        title(['Overview network ', subDirs(iDir).name], 'interpreter', 'none')
        save_current_figure(dirFileName)
    end % if overview image already exists
        
    dirFileName = fullfile(currentDirName, 'scatterplot.png');
    if (exist(dirFileName, 'file') == 0 )
        figure(3)    
        ax = get(gcf, 'position');
        ax(4) = 900;
        ax(3) = 900;
        set(gcf, 'position', ax);
        maxVal = max(data(:));
        minVal = min(data(:));
        for iStat1 = 1:noStations
            for iStat2 = (iStat1+1):noStations                
                iStat = iStat2-1 + (iStat1-1)*(noStations-1);
                subplot(noStations-1, noStations-1, iStat)
                plot(data(:,iStat1), data(:,iStat2), 'r.', 'markerSize', 0.01)
                axis([minVal maxVal minVal maxVal])
                axis square
                if ( iStat1 == 1 )
                    if ( floor(iStat2+1*2)==noStations )
                        title(['Scatterplots network ', subDirs(iDir).name], 'interpreter', 'none')
                    end
                end
            end
        end        
        save_current_figure(dirFileName)
    end
    
    % Plot average seasonal cycle
    dirFileName = fullfile(currentDirName, 'average_seasonal_cycle.png');
    if (exist(dirFileName, 'file') == 0 )    
        seasonalCycleMean = zeros(1,365);
        seasonalCycleMax = zeros(1,365);
        seasonalCycleMin = zeros(1,365);
        for iJulian = 1: 365
            dataIndex = data(date.julianDay==iJulian,:);
            seasonalCycleMean(iJulian) = nanmean(dataIndex(:));
            seasonalCycleMax(iJulian) = nanmax(dataIndex(:));
            seasonalCycleMin(iJulian) = nanmin(dataIndex(:));
        end
        figure(4)    
        plot(1:365, seasonalCycleMax, 'r-')        
        hold on
        plot(1:365, seasonalCycleMean, 'k-')        
        plot(1:365, seasonalCycleMin, 'g-')
        hold off
        xlabel('Julian day')
        ylabel('Relative humidity [%]')
        legend('Maximum', 'Mean', 'Minimum', 'location', 'SouthWest')
        legend boxoff
        ax = axis;
        ax(2) = 365;
        axis(ax)
        title(['Seasonal cycles ', subDirs(iDir).name], 'interpreter', 'none')
        save_current_figure(dirFileName)    
    end

    % Plot boxplots for every month for all stations in one (box)plot (seasonal cycle)
    dirFileName = fullfile(currentDirName, 'boxplots_monthly_network.png');
    if (exist(dirFileName, 'file') == 0 )    
        categories = repmat(date.month, 1, noStations);
        figure(5)    
        boxplot(data(:), categories(:))
        xlabel('Month')
        ylabel('Relative humidity [%]')
        title(['Monthly boxplots complete network ', subDirs(iDir).name], 'interpreter', 'none')
        save_current_figure(dirFileName)    
    end
    
    % Plot boxplots for every month (seasonal cycle), plot every station
    % separately.
    dirFileName = fullfile(currentDirName, 'boxplots_monthly_station.png');
    if (exist(dirFileName, 'file') == 0 )    
        categories = date.month;
        figure(6)    
        ax = get(gcf, 'position');
        ax(4) = 800;
        set(gcf, 'position', ax);
        for iStat=1:noStations
            subplot(3, 2, iStat)
            boxplot(data(:,iStat), categories)
            xlabel('Month')
            ylabel('Relative humidity [%]')
            title(['Monthly boxplots ', num2str(stationNo(iStat))], 'interpreter', 'none')
        end
        save_current_figure(dirFileName)    
    end
    a=0;
end
a=0;