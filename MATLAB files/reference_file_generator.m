%Reference File Generator
%Sine-Cosine
%-90 to 90
%-180 to 180
%16 bits each

x = -180:1:180;%0.0039
l = length(x);
cosine_array = cosd(x);
sine_array = sind(x);
fileID = fopen('D:\Fall 2017\6276\Project\output_reference180.txt','w');
fprintf(fileID,'%6s %6s\r\n','sine','cosine');
for i = 1:l
fprintf(fileID,'%6.4f %6.4f\r\n',sine_array(i),cosine_array(i));
end
fclose(fileID);