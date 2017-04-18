function y = fft_cloud(order, beta)
% This function makes a time spectrum with -1*beta noise. As it is mostly used
% by me to generate cloud time series with a red power spectrum it is
% called fft_cloud. The parameter n determines the number of values of the
% time series (N), using the equation N = 2^order.
% If no beta is specified, a -5/3 power spectrum is produced, as it typical
% for fully developped homogeneous isotropic turbulence.

% Written by Victor Venema, Victor.Venema@uni-bonn.de in 2003.
% Modified by Victor Venema in August 2003
% - Negative and positive frequencies get the same phase, which makes the
%   time series real.

% Input checking
if (order < 2), perror('Number of points should be at least 4, i.e. the order should be at least 2.'); end
if (nargin < 2)
    beta = 5/3;
end
if (beta < 0)
    warning('Did you realy want to make an anti-correlated time series? The slope of the power spectrum is -1*Beta.')
end

% Initialisation
noValues = 2^order;
halfNoValues = floor(noValues/2);
x = zeros(1,noValues);

% fill the Power spectrum with values
% x(1) is the mean of the time series (DC-component) and stays zero.
x(2:halfNoValues+1)      = (1:halfNoValues).^(-beta);

x = sqrt(x); % calculate the (magnitude of the) Fourier coefficients
phase = rand(1,halfNoValues)*2*pi-pi; % calculate random phases for the complex Fourier coefficients
x(1:halfNoValues) = x(1:halfNoValues) .* exp(i * phase(1:halfNoValues)); % Multiply with random phases.
x(end:-1:halfNoValues+2) = conj(x(2:halfNoValues)); % fold the postive frequencies to the negative frequencies.

y = fft(x);
y = real(y);
% y = y - mean(y);
