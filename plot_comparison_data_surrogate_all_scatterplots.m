function plot_comparison_data_surrogate_all_scatterplots

plotAllNew = 1; 
baseDirNameData = ['/data/zamg_humidity/Netzwerke_Metainformation/'];
baseDirNameSurr = ['/data/zamg_humidity/Surrogate/'];

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
    [stationNoSurr, dateSurr, surr] = read_zamg(currentDirNameSurr);
    noStations2 = numel(stationNoSurr);
    if ( noStations1 == noStations2 )
        noStations = noStations1;
    else
        error('Number of stations is different in surrogate and observations.\n')
    end
    
    surrPart   = surr(1:noValuesData,:);
    dateSurrPart.decYear   = dateSurr.decYear(1:noValuesData,:);
  
    % Scatterplots of the all station with the others and for the real data
    close all
    for iStation = 1:noStations          
        dirFileName = fullfile(currentDirNameSurr, ['comparison_all_scatterplots_', num2str(iStation), '.png']);
        if (exist(dirFileName, 'file') == 0 || plotAllNew == 1)
            figure(iStation)    
%             ax = get(gcf, 'position');
%             ax(4) = 500;
%             ax(3) = 1300;
            ax = [1 100 1300 500];
            set(gcf, 'position', ax);
            maxVal = max(data(:));
            minVal = min(data(:));
            iStat1 = iStation;
            noPlots = noStations-1; % Number of scatterplot of one kind (surrogate or observations), total number of plots is double
            iPlotStat = 0; % counter for the subplot function
            for iStat2 = 1:noStations                
                if ( iStat1 ~= iStat2 )
                    iPlotStat = iPlotStat + 1;
                    subplot(2, noStations-1, iPlotStat)
                    plot(data(:,iStat1), data(:,iStat2), 'r.', 'markerSize', 0.01)
                    axis([minVal maxVal minVal maxVal])
                    axis square
                    if ( iPlotStat == 1 )
                        title(['Scatterplots network ', currentFileNameData], 'interpreter', 'none')
                    else
                         title('Scatterplot observations')
                    end
                    ylabel(['Obs. station ' num2str(iStat2)])
                    xlabel(['Obs. station ' num2str(iStat1)])

                    subplot(2, noStations-1, iPlotStat+noPlots)
                    plot(surrPart(:,iStat1), surrPart(:,iStat2), 'b.', 'markerSize', 0.01)
                    axis([minVal maxVal minVal maxVal])
                    axis square            
                    title('Scatterplot surrogates')
                    ylabel(['Surr. station ' num2str(iStat2)])
                    xlabel(['Surr. station ' num2str(iStat1)])     
                end % if iStat1 not iStat2
            end % for iStat2
            save_current_figure(dirFileName)
        end
    end % For iStation
    a=0;
end
a=0;