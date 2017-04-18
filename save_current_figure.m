function save_current_figure(output_filename)
% You can use this small function to save the currently active window
% in a file. Matlab knows which file format you want to use, by the 
% extention of the output_filename.
%
% Author: Victor Venema, victor.venema@uni-bonn.de 

I = getframe(gcf);
imwrite(I.cdata, output_filename);
