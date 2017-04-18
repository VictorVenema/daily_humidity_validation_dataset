function decYear = calcDecYear(year, julianDate)
    
uniqueYears = unique(year);
noUniqueYears = numel(uniqueYears);

decYear = zeros(size(year));

noDaysYear = [365 366];

for i=1:noUniqueYears
    currentYear = uniqueYears(i);
    index = find(year == currentYear);
    decYear(index) = year(index) + (julianDate(index)-0.5)/noDaysYear(1+is_leap(currentYear));
end

