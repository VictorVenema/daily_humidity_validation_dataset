function save_zamg(dirName, stationNo, date, data, spectralDiff, dataComplete)
% Save simulated data in the ZAMG format. And if spectralDiff exists save
% this in separate file.

if ( (nargin < 5 ) || (isempty(spectralDiff)) )
    spectralDiff = [];
end

if ( (nargin < 6) || (isempty(dataComplete)) )
    dataComplete = 0;
end

noFiles = numel(stationNo);

data(~isfinite(data)) = -999.99;

if ( dataComplete )
    noValues = numel(date.year);
    datestr = blanks(8*noValues);
    datestr = reshape(datestr, 8, noValues);
    for iVal = 1:noValues
        datestr(:, iVal) = sprintf('%4.f%02.f%02.f', date.year(iVal), date.month(iVal), date.day(iVal));  
    end
end

% Every series has its own file.
for iFile = 1:noFiles
        if ( exist(dirName, 'dir') == 0 )
            mkdir(dirName)
        end
        
        % Save data in ZAMG format
        fileName  = fullfile(dirName, ['Complete_Rel_Feuchte_', num2str(stationNo(iFile)), '.txt']);
        fid = fopen(fileName, 'w');
        fprintf(fid, 'statnr datum rel.hum\n');

        if ( dataComplete )
            stationData = data(:,iFile);
            for iVal = 1:noValues
                fprintf(fid, '%.0f %s %.2f\n', stationNo(iFile), datestr(:,iVal), stationData(iVal));
            end
        else
            stationData = data(:,iFile);
            stationDate = date;
            index = find(isfinite(stationData));
            firstIndex = index(1);
            lastIndex  = index(end);
            stationData = stationData(firstIndex:lastIndex);
            stationDate.year    = stationDate.year(firstIndex:lastIndex);
            stationDate.month = stationDate.month(firstIndex:lastIndex);
            stationDate.day     = stationDate.day(firstIndex:lastIndex);
            noValues = numel(stationData);            
            for iVal = 1:noValues
                datestr = sprintf('%4.f%02.f%02.f', stationDate.year(iVal), stationDate.month(iVal), stationDate.day(iVal));
                fprintf(fid, '%.0f %s %.2f\n', stationNo(iFile), datestr, stationData(iVal));
            end            
        end
        fclose(fid);
end

if ( ~isempty(spectralDiff) )
    % Save spectral difference
    fileName  = fullfile(dirName, 'spectralDiff.txt');
    fid = fopen(fileName, 'w');
    fprintf(fid, '%d', spectralDiff);
    fclose(fid);
end
