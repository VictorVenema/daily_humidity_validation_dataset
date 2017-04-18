function [stationNo, dateAll, dataAll, varargout] = read_zamg(dirName, completeData)
% This function reads observational or simulated data in the format used by
% ZAMG.
% The simulated data is complete data (completeData==1), the observational
% data is not complete. To speed up reading, the function creates a matlab
% datafile with the data (matlabDataFileDirName) at the end and if this file is present at the
% beginning, it will read this matlab file. To override this, delete the
% matlab datafile or set readAnew = 1.
% Note that DecimalDate is given in years and is not exact, should only be used for plotting.

if  ( ( nargin < 1 ) || isempty(dirName) )
    number = [1, 2, 3, 4, 5, 7];
    number = number(6);
    dirName = ['/data/zamg_humidity/Netzwerke/Netzwerk', num2str(number), '_voll_hom_vv/'];
end
if isnumeric(dirName)    
    number = [1, 2, 3, 4, 5, 7];
    number = number(dirName);
    dirName = ['/data/zamg_humidity/Netzwerke/Netzwerk', num2str(number), '_voll_hom_vv/'];
end       
if  ( ( nargin < 2 ) || isempty(completeData) )
    completeData = 0;
end

if ( completeData )
    [stationNo, dateAll, dataAll] = read_zamg_complete(dirName);    
else
    matlabDataFileDirName = fullfile(dirName, 'data.mat');
    readAnew = 0;
    if ( (exist(matlabDataFileDirName, 'file') > 0 ) && (readAnew == 0) ) 
        load(matlabDataFileDirName)
    else
        files = dir(fullfile(dirName, 'Complete_Rel_Feuchte_*.txt'));
        noFiles = numel(files);
        fileContainsMetaData = 0;
        
        % First make vectors containing dates running for the full period of the network
        % Read files to determine begin and end year (only full years are used)
        beginDate = +inf;
        endDate = -inf;
        for iFile = 1:noFiles
            fileName  = fullfile(dirName, files(iFile).name);
            fid = fopen(fileName);
            tline = fgetl(fid); %#ok<NASGU>
            tline = fgetl(fid);
            delimiters = [9:13 32]; % White space characters
            string_vector=split_string(tline, delimiters);
            frewind(fid);
            if ( numel(string_vector) > 3 )
                if ( iFile == 1 )
                    fileContainsMetaData =1;
                else
                    if ( fileContainsMetaData == 0 )
                        error('Not all files seems to have meta data, reading routine not written for that.\n')
                    end
                end
            end            
            if ( fileContainsMetaData )
                data = textscan(fid, '%d %d %f %d', 'HeaderLines', 1);
            else
                data = textscan(fid, '%d %d %f', 'HeaderLines', 1);
            end            
            fclose(fid);
                        
            datetmp=data{2};
            if ( datetmp(1) < beginDate )
                beginDate = datetmp(1);
            end
            if ( datetmp(end) > endDate )
                endDate = datetmp(end);
            end
        end
        % a=0;
        % Compute vector with the years, taking leap years into account
        beginYearAll = floor(beginDate/1e4);
        endYearAll = floor(endDate/1e4);
        noValuesYear = [365 366];
        noValuesAll = 0;
        for iYear = beginYearAll:endYearAll
            noValuesAll = noValuesAll + noValuesYear(is_leap(iYear)+1);
        %     fprintf(1, '%d, %d\n', iYear, noValuesAll)
        end

        % Compute the dates within the year
        [yearAll, julianAll] = generateYearDay(noValuesAll, beginYearAll);
        monthAll = zeros(noValuesAll, 1);
        dayAll = zeros(noValuesAll, 1);
        decYearAll = zeros(noValuesAll, 1);
        for iDay = 1:noValuesAll
             [day, month] = julian2date(julianAll(iDay), yearAll(iDay));
            monthAll(iDay) = month;
            dayAll(iDay) = day;
            decYearAll(iDay) = calcDecYear(yearAll(iDay), julianAll(iDay));
        end
        dateAll.day = dayAll;
        dateAll.month = monthAll;
        dateAll.year = yearAll;
        dateAll.julianDay = julianAll;
        dateAll.decYear = decYearAll;
        % Now the vectors with the years should be ready

        % Read data again and insert the data at the right position of the full vector
        dataAll = NaN*zeros(noValuesAll, noFiles);
        if ( fileContainsMetaData )
            metaAll = NaN*zeros(noValuesAll, noFiles);
        end
        halfADay = 0.5/365.24;
        stationNo = zeros(1,noFiles);
        for iFile = 1:noFiles
            fileName  = fullfile(dirName, files(iFile).name);
            fid = fopen(fileName);            
            if ( fileContainsMetaData )
                data = textscan(fid, '%d %s %f %d', 'HeaderLines', 1);
            else
                data = textscan(fid, '%d %s %f', 'HeaderLines', 1);
            end
            fclose(fid);

            stationNoFile = data{1}(1);
            stationNo(iFile) = stationNoFile;

            datetmp=data{2};
            dataFile=data{3};
             if ( fileContainsMetaData )
                metaFile=data{4};
            end
            % In network4 there are some values with NA at the end, which are not
            % read by Matlab, which is okay as they are the last values. However
            % because of this the stationno and date columns are one element longer
            if (numel(datetmp) == numel(dataFile)+1 )
                datetmp = datetmp(1:numel(dataFile));
            end        

            if (sum(isfinite(dataFile)) <= 365+365+365+366 )
                warning('Station no. %d contains less than 4 years of data.\n', iFile);
            end        
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

            % Cut away the last part of the data to make the dataset contain only full years of data.
            dayCounter = noValues;
            lastDay = julianDay(1)-1;
            if ( lastDay == 0 )
                lastDay = noValuesYear(is_leap(iYear)+1);            
            end
            while ( julianDay(dayCounter) ~=  lastDay )
                dayCounter = dayCounter - 1;
            end
            dataFile = dataFile(1:dayCounter);
            if ( fileContainsMetaData )
                metaFile = metaFile(1:dayCounter);
            end
            noValues = dayCounter;

            % Check if the dates match
            index = find(decYearAll-decYearFile(1)+halfADay>0);
            index = index(1);
    %         noValues = numel(datetmp);
            for iDate = 1:noValues
                if ( (decYearAll(index+iDate-1)-decYearFile(iDate)) ~= 0 )
                    fprintf(1, '%d, %d\n', decYearAll(index+iDate-1), decYearFile(iDate) )
                    fprintf(1, '%d\n', iDate)
                end
            end   

            dataAll(index:index+noValues-1,iFile) = dataFile;            
            if ( fileContainsMetaData )
                metaAll(index:index+noValues-1,iFile) = metaFile;  
            end
            if 0
                figure(1)
                imagesc(1:noFiles, decYearAll, dataAll), 
                colorbar
            end
            a=0; %#ok<NASGU>
        end % for iFile
        sumData = sum(dataAll, 2);
        if (sum(isfinite(sumData)) <= 365 )
            error('There is no period of longer than one year where all stations have data. There may not be overlapping data for every pair. Implement check for that.\n')
        end
        if ( exist(matlabDataFileDirName, 'file') == 0 )
            if ( exist('metaAll', 'var') > 0 )
                save(matlabDataFileDirName, 'stationNo', 'dateAll', 'dataAll', 'metaAll');
            else
                save(matlabDataFileDirName, 'stationNo', 'dateAll', 'dataAll');
            end
        end
    end % if exists matlabDataFileDirName
end % if complete data
a=0; %#ok<NASGU>

dataAll(dataAll<-999) = NaN;

if ( nargout > 3 ) 
    if ( exist('metaAll', 'var') > 0 )
        varargout{1} = metaAll;
    else
        varargout{1} = NaN;
    end
end
