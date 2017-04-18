function [stationNo, dateAll, dataAll, varargout] = read_zamg_complete(dirName)
% DecimalDate is given in year and is not exact, should only be used for plotting.

if  ( ( nargin < 1 ) || isempty(dirName) )
    number = [1, 2, 3, 4, 5, 7];
    number = number(6);
    dirName = ['/data/zamg_humidity/Netzwerke/Netzwerk', num2str(number), '_voll_hom_vv/'];
end
if ( isnumeric(dirName) )
    number = [1, 2, 3, 4, 5, 7];
    number = number(dirName);
    dirName = ['/data/zamg_humidity/Netzwerke/Netzwerk', num2str(number), '_voll_hom_vv/'];
end       

matlabDataFileDirName = fullfile(dirName, 'data.mat');
readAnew = 0;
if ( (exist(matlabDataFileDirName, 'file') > 0 ) && (readAnew == 0) ) 
    load(matlabDataFileDirName)
else
    files = dir(fullfile(dirName, 'Complete_Rel_Feuchte_*.txt'));
    noFiles = numel(files);

    stationNo = zeros(1,noFiles);
%     fileContainsMetaData = 0;
    for iFile = 1:noFiles
        fileName  = fullfile(dirName, files(iFile).name);
        fid = fopen(fileName);
        data = textscan(fid, '%d %s %f', 'HeaderLines', 1);
        fclose(fid);
        if ( iFile == 1 )
            noValuesAll = numel(data{1}); % 36525;
            dataAll = NaN*zeros(noValuesAll, noFiles);
            metaAll= NaN*zeros(noValuesAll, noFiles);
        end
        stationNoFile = data{1}(1);
        stationNo(iFile) = stationNoFile;

        datetmp=data{2};
        dataFile=data{3};
%         if ( numel(data) > 3 )
%             fileContainsMetaData = 1;
%             dataFile(data{4}==1) = NaN;
%         end        
        if ( numel(data) > 3 )
            metaFile=data{4};
        end
        % In network4 there are some values with NA at the end, which are not
        % read by Matlab, which is okay as they are the last values. However
        % because of this the stationno and date columns are one element longer
%         if (numel(datetmp) == numel(dataFile)+1 )
%             datetmp = datetmp(1:numel(dataFile));
%         end        

        if ( sum(isfinite(dataFile)) <= 365+365+365+366 )
            warning('Station no. %d contains less than 4 years of data.\n', iFile);
        end        
        if ( iFile == 1 )
            % Convert date to usefull 3 column values
            year    = zeros(size(datetmp));
            month = zeros(size(datetmp));
            day     = zeros(size(datetmp));
            julianDay = zeros(size(datetmp));
            decYearFile = zeros(size(datetmp));
            noValues = numel(year);
            for iDate = 1:noValues
                temp = datetmp{iDate};
                tempstr = temp(1:4);
                year(iDate) = str2num(tempstr); %#ok<*ST2NM>
                tempstr = temp(5:6);
                month(iDate) = str2num(tempstr); %#ok<*ST2NM>
                tempstr = temp(7:8);
                day(iDate) = str2num(tempstr); %#ok<*ST2NM>        
                julianDay(iDate) = date2julian(day(iDate), month(iDate), year(iDate));
                decYearFile(iDate) = calcDecYear(year(iDate), julianDay(iDate));
            end % for iDate  
            dateAll.day = day;
            dateAll.month = month;
            dateAll.year = year;
            dateAll.julianDay = julianDay;
            dateAll.decYear = decYearFile;            
        end
        dataAll(:,iFile) = dataFile;
        if ( exist('metaFile', 'var') > 0 )
            metaAll(:,iFile) = metaFile;
        end
        if 0
            figure(1)
            imagesc(1:noFiles, decYearAll, dataAll), 
            colorbar
        end
        a=0; %#ok<NASGU>
    end % for iFile
    sumData = sum(dataAll, 2);
    if ( sum(isfinite(sumData)) <= 365 )
        error('There is no period of longer than one year where all stations have data. There may not be overlapping data for every pair. Implement check for that.\n')
    end
    save(matlabDataFileDirName, 'stationNo', 'dateAll', 'dataAll');
end % if exists matlabDataFileDirName

if ( nargout > 3 ) 
    if ( exist('metaFile', 'var') > 0 )
%     if ( fileContainsMetaData )
        varargout{1} = metaAll;
    else
        varargout{1} = NaN;
    end
end

dataAll(dataAll<-999) = NaN;


a=0; %#ok<NASGU>


