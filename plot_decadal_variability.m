function plot_decadal_variability

baseDirNameInput = ['/data/zamg_humidity/Surrogate/'];

subDirs = dir(baseDirNameInput);
subDirs = remove_invisible_dirs(subDirs);

currentDirName = fullfile(baseDirNameInput, subDirs(1).name);

% Read humidity data
[stationNo, date, data] = read_zamg(currentDirName, 1); %#ok<NASGU>

for i=1:20
    % globalVariability is the variabilty in percent points
    globalVariability = fft_cloud(17, 4);
    globalVariability = globalVariability(1:36525);
    globalVariability = globalVariability - mean(globalVariability);
    globalVariability = globalVariability * 0.012 / std(globalVariability);

    figure(10)
    plot(date.decYear, globalVariability', 'color', (rand(3,1)))
    hold on
    axis tight
    xlabel('Year [a]')
    ylabel('Perturbation []')
end

save_current_figure('/data/zamg_humidity/decadal_variability.png')
a=0; %#ok<NASGU>