function mplot(t, data, varargin)

if (nargin < 2 )
    data = t;
    t = 1:size(t,1);
%     data = t;
end

noVariables = size(data,2);
% noValues    = size(data,1);

if ( noVariables <= 20 )
    for iVar = 1:noVariables
        subplot(noVariables, 1, iVar)
        plot(t, data(:,iVar), varargin{:})
        axis tight
    end
else
    plot(data, varargin{:})
    axis tight    
end