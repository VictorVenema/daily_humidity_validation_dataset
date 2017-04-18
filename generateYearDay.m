function [year, julianDay] = generateYearDay(noValues, beginYear)

if ( nargin < 2 )
    beginYear = 1900;
end

year      = zeros(noValues, 1);
julianDay = zeros(noValues, 1);

noDaysYear = [365 366];

yearCounter = beginYear;
bi = 1;
currentNoDaysYear = noDaysYear(1+is_leap(beginYear));  
ei = currentNoDaysYear;

while ( ei <= noValues )      
    year     (bi:ei) = yearCounter;
    julianDay(bi:ei) = 1:currentNoDaysYear;
    % update counters
    bi = bi + currentNoDaysYear;
    yearCounter = yearCounter + 1;
    currentNoDaysYear = noDaysYear(1+is_leap(yearCounter)); 
    ei = ei + currentNoDaysYear;    
end

year      = year     (1:ei-currentNoDaysYear);
julianDay = julianDay(1:ei-currentNoDaysYear);