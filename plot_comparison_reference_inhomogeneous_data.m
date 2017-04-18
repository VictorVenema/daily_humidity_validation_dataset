function plot_comparison_reference_inhomogeneous_data

plotAllNew = 0; 
plotDifferenceRefNew = 0;
plotDifferenceDetSto = 0;
plotDifferenceDetStoZoom = 0;

baseDirNameRef = {'/data/zamg_humidity/Reference/deterministic/', '/data/zamg_humidity/Reference/stochastic/', '/data/zamg_humidity/Reference/realistic/'};
baseDirNameSimul = {'/data/zamg_humidity/Inhomogeneous/deterministic/', '/data/zamg_humidity/Inhomogeneous/stochastic/', '/data/zamg_humidity/Inhomogeneous/realistic/'};

for iSimul =3 % 1:3
    baseDirNameData = baseDirNameRef{iSimul};
    baseDirNameSurr = baseDirNameSimul{iSimul};
    subDirsSurr = dir(baseDirNameSurr);
    subDirsSurr = remove_invisible_dirs(subDirsSurr);
    noDirsSurr = numel(subDirsSurr);

    for iDir = 1:noDirsSurr
        currentDirNameSurr = fullfile(baseDirNameSurr, subDirsSurr(iDir).name);
        fprintf(1, '%s\n', currentDirNameSurr)
        currentDirNameData = fullfile(baseDirNameData, subDirsSurr(iDir).name);  % (1:end-3)); 
        fprintf(1, '%s\n', currentDirNameData)
        temp = split_string(currentDirNameData, dirdelim);
        currentFileNameData = temp{end};

        completeData = 1;
        [stationNoData, dateData, data, metaData] = read_zamg(currentDirNameData, completeData);
        data(metaData==1) = NaN;

        noStations1 = numel(stationNoData);
        completeData = 1;
        [stationNoSurr, dateSurr, surr] = read_zamg(currentDirNameSurr, completeData);
        noStations2 = numel(stationNoSurr);
        if ( noStations1 == noStations2 )
            noStations = noStations1;
        else
            error('Number of stations is different in surrogate and observations.\n')
        end

        close all
        dirFileName = fullfile(currentDirNameSurr, 'reference_inhomogeneous_diff_image.png');
        if (exist(dirFileName, 'file') == 0 || plotAllNew == 1 || plotDifferenceRefNew == 1 )
            figure(1)    
            ax = [20   100  1250   800];
            set(gcf, 'position', ax); 
            maxVal = max([max(data(:)) max(surr(:)) ]);
            minVal  = min([min(data(:)) min(surr(:)) ]);

            subplot(1,3,1)
            imagesc(stationNoData, dateData.decYear, data, [minVal maxVal])
            set(gca,'XTick', 1:noStations)
            set(gca,'XTickLabel',stationNoData)
            xlabel('Station no.')
            ylabel('Year')
            title(['Reference ', currentFileNameData], 'interpreter', 'none')
            colorbar

            subplot(1,3,2)
            imagesc(stationNoSurr, dateSurr.decYear, surr, [minVal maxVal])
            set(gca,'XTick', 1:noStations)
            set(gca,'XTickLabel',stationNoSurr)
            xlabel('Station no.')
            ylabel('Year')
            title(['Inhomogeneous ', subDirsSurr(iDir).name], 'interpreter', 'none')
            colorbar                
            
            subplot(1,3,3)
            imagesc(stationNoData, dateSurr.decYear, data-surr)
            set(gca,'XTick', 1:noStations)
            set(gca,'XTickLabel',stationNoSurr)
            xlabel('Station no.')
            ylabel('Year')
            title(['Reference - inhomogeneous'], 'interpreter', 'none')
            colorbar                       
            save_current_figure(dirFileName)
        end % if overview image already exists
    end
end % for iSimulations

% Plot difference between deterministic data and stochastic data

baseDirNameData = baseDirNameSimul{1};
baseDirNameSurr = baseDirNameSimul{2};
subDirsSurr = dir(baseDirNameSurr);
subDirsSurr = remove_invisible_dirs(subDirsSurr);
noDirsSurr = numel(subDirsSurr);

for iDir = 1:noDirsSurr
    currentDirNameSurr = fullfile(baseDirNameSurr, subDirsSurr(iDir).name);
    fprintf(1, '%s\n', currentDirNameSurr)
    currentDirNameData = fullfile(baseDirNameData, subDirsSurr(iDir).name);  % (1:end-3)); 
    fprintf(1, '%s\n', currentDirNameData)
    temp = split_string(currentDirNameData, dirdelim);
    currentFileNameData = temp{end};

    completeData = 1;
    [stationNoData, dateData, data, metaData] = read_zamg(currentDirNameData, completeData);
    data(metaData==1) = NaN;

    noStations1 = numel(stationNoData);
    completeData = 1;
    [stationNoSurr, dateSurr, surr] = read_zamg(currentDirNameSurr, completeData);
    noStations2 = numel(stationNoSurr);
    if ( noStations1 == noStations2 )
        noStations = noStations1;
    else
        error('Number of stations is different in surrogate and observations.\n')
    end

    close all
    dirFileName = fullfile(currentDirNameSurr, 'deterministic_stochastic_inhomogeneous_diff_image.png');
    if (exist(dirFileName, 'file') == 0 || plotAllNew == 1 || plotDifferenceDetSto == 1)
        figure(1)    
        ax = [20   100  1250   800];
        set(gcf, 'position', ax); 
        maxVal = max([max(data(:)) max(surr(:)) ]);
        minVal  = min([min(data(:)) min(surr(:)) ]);

        subplot(1,3,1)
        imagesc(stationNoData, dateData.decYear, data, [minVal maxVal])
        set(gca,'XTick', 1:noStations)
        set(gca,'XTickLabel',stationNoData)
        xlabel('Station no.')
        ylabel('Year')
        title(['Deterministic inhomogeneous ', currentFileNameData], 'interpreter', 'none')
        colorbar

        subplot(1,3,2)
        imagesc(stationNoSurr, dateSurr.decYear, surr, [minVal maxVal])
        set(gca,'XTick', 1:noStations)
        set(gca,'XTickLabel',stationNoSurr)
        xlabel('Station no.')
        ylabel('Year')
        title(['Stochastic inhomogeneous ', subDirsSurr(iDir).name], 'interpreter', 'none')
        colorbar                

        subplot(1,3,3)
        imagesc(stationNoData, dateSurr.decYear, data-surr)
        set(gca,'XTick', 1:noStations)
        set(gca,'XTickLabel',stationNoSurr)
        xlabel('Station no.')
        ylabel('Year')
        title(['Deterministic - stochastic'], 'interpreter', 'none')
        colorbar                       
        save_current_figure(dirFileName)
    end % if overview image already exists
end

% Plot zoom of difference between deterministic data and stochastic data
baseDirNameData = baseDirNameSimul{1};
baseDirNameSurr = baseDirNameSimul{2};
subDirsSurr = dir(baseDirNameSurr);
subDirsSurr = remove_invisible_dirs(subDirsSurr);
noDirsSurr = numel(subDirsSurr);

for iDir = 1:noDirsSurr
    currentDirNameSurr = fullfile(baseDirNameSurr, subDirsSurr(iDir).name);
    fprintf(1, '%s\n', currentDirNameSurr)
    currentDirNameData = fullfile(baseDirNameData, subDirsSurr(iDir).name);  % (1:end-3)); 
    fprintf(1, '%s\n', currentDirNameData)
    temp = split_string(currentDirNameData, dirdelim);
    currentFileNameData = temp{end};

    completeData = 1;
    [stationNoData, dateData, data, metaData] = read_zamg(currentDirNameData, completeData);
    data(metaData==1) = NaN;

    dateData.decYear = dateData.decYear(1:365);
    data = data(1:365,:);
    
    noStations1 = numel(stationNoData);
    completeData = 1;
    [stationNoSurr, dateSurr, surr] = read_zamg(currentDirNameSurr, completeData);
    dateSurr.decYear = dateSurr.decYear(1:365);
    surr = surr(1:365,:);
    
    noStations2 = numel(stationNoSurr);
    if ( noStations1 == noStations2 )
        noStations = noStations1;
    else
        error('Number of stations is different in surrogate and observations.\n')
    end
    close all
    dirFileName = fullfile(currentDirNameSurr, 'deterministic_stochastic_inhomogeneous_diff_image_zoom.png');
    if (exist(dirFileName, 'file') == 0 || plotAllNew == 1 || plotDifferenceDetStoZoom == 1)
        figure(1)    
        ax = [20   100  1250   800];
        set(gcf, 'position', ax); 
        maxVal = max([max(data(:)) max(surr(:)) ]);
        minVal  = min([min(data(:)) min(surr(:)) ]);

        subplot(1,3,1)
        imagesc(stationNoData, dateData.decYear, data, [minVal maxVal])
        set(gca,'XTick', 1:noStations)
        set(gca,'XTickLabel',stationNoData)
        xlabel('Station no.')
        ylabel('Year')
        title(['Deterministic inhomogeneous ', currentFileNameData], 'interpreter', 'none')
        colorbar

        subplot(1,3,2)
        imagesc(stationNoSurr, dateSurr.decYear, surr, [minVal maxVal])
        set(gca,'XTick', 1:noStations)
        set(gca,'XTickLabel',stationNoSurr)
        xlabel('Station no.')
        ylabel('Year')
        title(['Stochastic inhomogeneous ', subDirsSurr(iDir).name], 'interpreter', 'none')
        colorbar                

        subplot(1,3,3)
        imagesc(stationNoData, dateSurr.decYear, data-surr)
        set(gca,'XTick', 1:noStations)
        set(gca,'XTickLabel',stationNoSurr)
        xlabel('Station no.')
        ylabel('Year')
        title(['Deterministic - stochastic'], 'interpreter', 'none')
        colorbar                       
        save_current_figure(dirFileName)
    end % if overview image already exists
end
a=0; %#ok<NASGU>
    