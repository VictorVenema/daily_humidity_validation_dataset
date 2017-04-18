function generate_realistic_error_reference
% This function reads the homogeneous data and missing data nad
% adds inhomogeneities. These inhomogeneities can either be "deterministic"
% (not used in article) or have both a deterministic and stochastic
% component (called "stochastic"). See article for background of how the
% stochastic data is generated.

computeNew = 0;
baseDirNameInput         = '/data/zamg_humidity/Homogeneous/';
baseDirNameRefRel      = '/data/zamg_humidity/Reference/realistic/';
baseDirNameInhomRel = '/data/zamg_humidity/Inhomogeneous/realistic/';

subDirs = [];
for i =6:10
    subDirs = [subDirs; dir([baseDirNameInput, '*', num2str(i)])]; %#ok<AGROW>
end
subDirs = remove_invisible_dirs(subDirs);
noDirs = numel(subDirs);

for iDir = 1:noDirs
        currentDirName = fullfile(baseDirNameInput, subDirs(iDir).name);
        fprintf(1, '%s\n', currentDirName)
        saveDirNameRefRel = fullfile(baseDirNameRefRel, subDirs(iDir).name);
        saveDirNameInhomRel = fullfile(baseDirNameInhomRel, subDirs(iDir).name);        
        if ( exist(saveDirNameRefRel, 'file') == 0 || exist(saveDirNameInhomRel, 'file') == 0 || computeNew == 1 )
            % Read humidity data
             [stationNo, date, data] = read_zamg(currentDirName, 1);
             data(data<0) = 0;
             data(data>100) = 100;

            % Save the homogeneous reference data
            reference = data;
            
            reference = insert_missing_data(reference, date); % Difference to other datasets
            
            spectralDiff = [];
            dataComplete = 1;
            save_zamg(saveDirNameRefRel, stationNo, date, reference, spectralDiff, dataComplete)      
            
            % Compute the inhomogeneous data and save it
            taperBreakFreqBegin = 1; % Difference to other datasets
            [inhomogeneousDummy, breaksDummy, inhomogeneousRel, breaksRel, perturbations2DDummy, perturbations2DRel] = insert_breaks_humidity(reference, date, stationNo, taperBreakFreqBegin);
                        
            spectralDiff = [];
            dataComplete = 1;
            save_zamg(saveDirNameInhomRel, stationNo, date, inhomogeneousRel, spectralDiff, dataComplete)
            save_breaks(saveDirNameInhomRel, breaksRel, stationNo, perturbations2DRel)
        end
end
a=0; %#ok<NASGU>
