function julianDay = date2julian(day, month, year)
% Author: Victor Venema, victor.venema@uni-bonn.de 

indexLeap    = find( mod(year, 4) == 0 & (mod(year,100) ~= 0 | mod(year,400) == 0) );
indexNonLeap = find( mod(year, 4) ~= 0 | (mod(year,100) == 0 & mod(year,400) ~= 0) );

lastDayOfMonthLeap = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366]; % Leap year
maxDayOfMonthLeap  = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

lastDayOfMonthNonLeap = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]; % Normal year
maxDayOfMonthNonLeap  = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];    

if (day(indexNonLeap) > maxDayOfMonthNonLeap(month(indexNonLeap)))
    error('Too high data number. Day, month, year: %d, %d, %d', day, month, year)
end
if (day(indexLeap) > maxDayOfMonthLeap(month(indexLeap)) )
    error('Too high data number. Day, month, year: %d, %d, %d', day, month, year)
end

julianDay = zeros(size(day));

julianDay(indexLeap)    = lastDayOfMonthLeap   (month(indexLeap))    + day(indexLeap);
julianDay(indexNonLeap) = lastDayOfMonthNonLeap(month(indexNonLeap)) + day(indexNonLeap);

% if ( mod(year, 4) == 0)
%     lastDayOfMonth = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366]; % Leap year
%     maxDayOfMonth  = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
% else
%     lastDayOfMonth = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]; % Normal year
%     maxDayOfMonth  = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];    
% end
