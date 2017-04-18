function [breaks, noRandomBreaksNetwork] = compute_positions_breaks_network(data, date, noValues, stationNo, taperBreakFreqBegin)
% This function computes the positions of the breaks at random positions
% for an entire network by calling the function to compute the positions
% for a single station.

noStations = size(data,2);
iBreak = 0;
for iStation=1:noStations
    iPosStation = compute_break_positions(data, date, noValues, taperBreakFreqBegin);
    noBreaksStat = numel(iPosStation);
    if ( numel(iPosStation) > 0 )
        % Compute the dates to the positions
        for iBreakStation = 1:noBreaksStat
            iPos = iPosStation(iBreakStation);
            index1 = isfinite(data(1:iPos, iStation));
            index2 = isfinite(data(iPos+1:end, iStation));
            if (  ( sum(index1) > 0 ) && ( sum(index2) > 0 )  )
                iBreak = iBreak + 1;
                
                breaks(iBreak).stationNo = stationNo(iStation); %#ok<*AGROW>
                breaks(iBreak).iStation = iStation; %#ok<*AGROW>
                breaks(iBreak).time.year = date.year(iPos);
                breaks(iBreak).time.month = date.month(iPos);
                breaks(iBreak).time.day = date.day(iPos);
                breaks(iBreak).time.julianDay = date.julianDay(iPos);
                breaks(iBreak).time.decYear = date.decYear(iPos);
                breaks(iBreak).iPos = iPos;
                breaks(iBreak).type = 1; % 1 is random break, 2 is correlated break
            end % if data before and after break
        end % for iBreakStation
    end % if breaks in this station
end % for all stastions
noRandomBreaksNetwork = iBreak;