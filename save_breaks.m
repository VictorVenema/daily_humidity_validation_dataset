function save_breaks(saveDirNameInhom, breaks, stationNo, perturbations) %#ok<INUSD>

dirFileName = fullfile(saveDirNameInhom, 'breaks.txt');
fid = fopen(dirFileName, 'wt');

fprintf(fid, 'StatNo\tYear\tMonth\tDay\tJulianDay\tindex\n');

noStations = numel(stationNo);
for iStat = 1:noStations
    iStat2 = 0;
    indexStat = [];
    for iAll = 1:numel(breaks)
        if ( breaks(iAll).stationNo == stationNo(iStat) )
            iStat2 = iStat2 + 1;
            indexStat(iStat2) = iAll;         %#ok<AGROW>
        end
    end
    breaksStat = breaks(indexStat); 
    [dummy, indexBreaks] = sort([breaksStat.iPos], 'ascend');    
    noBreaks = numel(indexBreaks);
    for iBreak = 1:noBreaks
        fprintf(fid, '%d\t%d\t%d\t%d\t%d\t%d\n', breaksStat(iBreak).stationNo,        breaksStat(iBreak).time.year, ...
                                                                          breaksStat(iBreak).time.month,      breaksStat(iBreak).time.day, ...
                                                                          breaksStat(iBreak).time.julianDay, breaksStat(iBreak).iPos);
    end
end

fclose(fid);


dirFileName = fullfile(saveDirNameInhom, 'perturbations.txt');
save(dirFileName, '-ascii', 'perturbations')


a=0;



%                 breaks(iBreak).stationNo = stationNo(iStation); %#ok<*AGROW>
%                 breaks(iBreak).iStation = iStation; %#ok<*AGROW>
%                 breaks(iBreak).time.year = date.year(iPos);
%                 breaks(iBreak).time.month = date.month(iPos);
%                 breaks(iBreak).time.day = date.day(iPos);
%                 breaks(iBreak).time.julianDay = date.julianDay(iPos);
%                 breaks(iBreak).time.decYear = date.decYear(iPos);
%                 breaks(iBreak).iPos = iPos;
%                 breaks(iBreak).type = 1; % 1 is random break, 2 is correlated break