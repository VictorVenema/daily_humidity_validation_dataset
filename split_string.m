function string_vector=split_string(string, delim)
% This functin splits the string string into the part before and 
% the part after the delimiter delim.
%
% Author: Victor Venema, victor.venema@uni-bonn.de 

if ( iscell(string) ) 
    if ( numel(string) == 1 )
        string = string{:};
    else
        error('This function does not accept multi-entry cells. Please use a string as input.')
    end    
end

string_vector = cellstr(' ');
i=1;
[token,remainder]=strtok(string,delim);
while ( isempty(token) ~= 1 )
    string_vector{i}=token;
    string = remainder;
    i=i+1;
    [token,remainder]=strtok(string,delim);
%     token = token{1};
end 
