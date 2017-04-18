function generate_idealised_error_reference
% This function reads the homogeneous data and
% adds inhomogeneities. These inhomogeneities can either be "deterministic"
% (not used in article) or have both a deterministic and stochastic
% component (called "stochastic"). See article for background of how the
% stochastic data is generated.
% This idealised version does not inserts missing data, but does have a
% section for that and saves such data for symetry with
% generate_realistic_error_reference.m

computeNew = 0;
baseDirNameInput         = '/data/zamg_humidity/Homogeneous/';
baseDirNameRefDet      = '/data/zamg_humidity/Reference/deterministic/';
baseDirNameInhomDet = '/data/zamg_humidity/Inhomogeneous/deterministic/';
baseDirNameRefSto      = '/data/zamg_humidity/Reference/stochastic/';
baseDirNameInhomSto = '/data/zamg_humidity/Inhomogeneous/stochastic/';

noRep = 5;
subDirs = [];
for i =1:noRep
    subDirs = [subDirs; dir([baseDirNameInput, '*', num2str(i)])]; %#ok<AGROW>
end
subDirs = remove_invisible_dirs(subDirs);
noDirs = numel(subDirs);

% Loop over directories/networks
for iDir = 1:noDirs
        currentDirName = fullfile(baseDirNameInput, subDirs(iDir).name);
        fprintf(1, '%s\n', currentDirName)
        saveDirNameRefDet = fullfile(baseDirNameRefDet, subDirs(iDir).name);
        saveDirNameInhomDet = fullfile(baseDirNameInhomDet, subDirs(iDir).name);        
        saveDirNameRefSto = fullfile(baseDirNameRefSto, subDirs(iDir).name);
        saveDirNameInhomSto = fullfile(baseDirNameInhomSto, subDirs(iDir).name);
        
        % If this dataset has not been generated yet or computeNew set to 1
        % compute a new dataset
        if ( exist(saveDirNameRefDet, 'file') == 0 || exist(saveDirNameInhomDet, 'file') == 0 || ...
              exist(saveDirNameRefSto, 'file') == 0 || exist(saveDirNameInhomSto, 'file') == 0 || computeNew == 1 )
            % Read humidity data
             [stationNo, date, data] = read_zamg(currentDirName, 1);
             data(data<0) = 0;
             data(data>100) = 100;

            % Save the homogeneous reference data
            reference = data;
            spectralDiff = [];
            dataComplete = 1;
            save_zamg(saveDirNameRefDet, stationNo, date, reference, spectralDiff, dataComplete)            
            save_zamg(saveDirNameRefSto, stationNo, date, reference, spectralDiff, dataComplete)
            
            % Compute the inhomogeneous data and save it
            taperBreakFreqBegin = 0;
            [inhomogeneousDet, breaksDet, inhomogeneousSto, breaksSto, perturbations2DDet, perturbations2DSto] = insert_breaks_humidity(data, date, stationNo, taperBreakFreqBegin);
            
            spectralDiff = [];
            dataComplete = 1;
            save_zamg(saveDirNameInhomDet, stationNo, date, inhomogeneousDet, spectralDiff, dataComplete)
            save_breaks(saveDirNameInhomDet, breaksDet, stationNo, perturbations2DDet)                 
            save_zamg(saveDirNameInhomSto, stationNo, date, inhomogeneousSto, spectralDiff, dataComplete)
            save_breaks(saveDirNameInhomSto, breaksSto, stationNo, perturbations2DSto)
        end
end

a=0; %#ok<NASGU>
