function uniqueFilename = unique_filename(filenameBegin, filenameEnd, startNumber, formatStr)

if ( nargin < 2 )
    filenameEnd = '';
end
if ( nargin < 3 )
    number = 1;
else
    number = startNumber;
end
if ( nargin < 4 )
    formatStr = []; %02.f
end

if isempty(formatStr)
    uniqueFilename = strcat( filenameBegin, num2str(number), filenameEnd);
else
    uniqueFilename = strcat( filenameBegin, num2str(number, formatStr), filenameEnd);
end
% uniqueFilename = strcat( filenameBegin, num2str(number), filenameEnd);
while ( exist(uniqueFilename, 'file') > 0 )
    number = number + 1;
    if isempty(formatStr)
        uniqueFilename = strcat( filenameBegin, num2str(number), filenameEnd);
    else
        uniqueFilename = strcat( filenameBegin, num2str(number, formatStr), filenameEnd);
    end
end