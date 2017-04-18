function generate_homogeneous_data_zamg_additive
% This fuction read the surrogate data and adds long-term variability to
% generate the homogeneous data for the validation dataset.
% A signal with a power law power spectrum is added to the surrogate data.
% To avoid boundary effects this signal is windowed and tapered to zero at
% the boundaries.
% After this step the (missing data and) inhomogeneities need to be added.
% There are two version for this. Please call the functions: 
% generate_realistic_error_reference
% generate_idealised_error_reference

computeNew = 1;
baseDirNameInput = ['/data/zamg_humidity/Surrogate/'];
baseDirNameOutput = ['/data/zamg_humidity/Homogeneous/'];

subDirs = dir(baseDirNameInput);
subDirs = remove_invisible_dirs(subDirs);
noDirs = numel(subDirs);

% Compute window
halfSize = 10;
hanningWindow = hanning(2*halfSize);

figure(3)
humidity = 0:100;
window = ones(1, 101);
window(1) = 0;
window(end) = 0;
window(2:halfSize+1) = hanningWindow(1:halfSize);
window(end-halfSize:end-1) = hanningWindow(halfSize+1:end);
plot(0:100, window)
xlabel('Humidity [%]')
ylabel('Multiplication factor []')
% save_current_figure('/data/zamg_humidity/multiplication_factor.png')

% For every directory/network compute a signal and add the same signal to all
% stations in a network.
for iDir = 1:noDirs
        currentDirName = fullfile(baseDirNameInput, subDirs(iDir).name);
        fprintf(1, '%s\n', currentDirName)
        saveDirName = fullfile(baseDirNameOutput, subDirs(iDir).name);
        if ( exist(saveDirName, 'file') == 0 || computeNew == 1 )
            % Read humidity data
             [stationNo, date, data] = read_zamg(currentDirName, 1);
            [noValues, noStations] = size(data);
            
            % Generate network wide decadal variability.
            if 1
                % globalVariability is the variabilty in percent points
                globalVariability = fft_cloud(17, 4);                                                      % Generate a signal with a power law power spectrum with an exponent of -4
                globalVariability = globalVariability(1:36525);                                    % Crop
                globalVariability = globalVariability - mean(globalVariability);           % Normalize
                globalVariability = globalVariability * 0.012 / std(globalVariability);   % Set standard deviation of the long-term variability signal
            end   
            figure(10)
            plot(date.decYear, globalVariability', 'color', (rand(3,1)))
            hold on
            axis tight
                     
            % Implement decadal variability. For every station in the network.
            for iStat =1:noStations
                for iVal = 1:noValues
                    val = data(iVal,iStat);
                    factor = interp1(humidity, window, val);
                    data(iVal, iStat) = data(iVal, iStat) +  globalVariability(iVal) .* factor;
                end
            end
            
            % Check for violations of the limits
            index = find(data(:) < 0 | data(:) > 100, 1);
            if ( ~isempty(index) )
                error('Perturbation has caused unphysical values\n')
            end
            
            % Save perturbed data.
            save_zamg(saveDirName, stationNo, date, data, [], 0)
        end
end
