%Input Reference File Generator
%Angle
%-90 to 90
%-180 to 180
%16 bits each

x = -90:1:90;%0.0039
l = length(x);
fileID = fopen('D:\Fall 2017\6276\Project\input_reference.txt','w');
% fprintf(fileID,'%16s\r\n','angle');
for i = 1:l
% fprintf(fileID,'%16s\r\n',dec2twos_mod(x(i)*180*(2^-15)));
fprintf(fileID,'%16s\r\n',dec2twos(x(i)));
end
fclose(fileID);