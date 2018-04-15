%Theta Generator for particular frequencies
%0 to 360
%16 bit representation
f = 50*1000;
T = 20*(10^-9);%20 ns
theta_step = 360*10^-3;
angle=0;
one_space = '1 ';
fileID = fopen('D:\Fall 2017\6276\Project\theta_generated50.txt','w');
fprintf(fileID,'%18s\r\n','Angle');
while angle<360
    angle
    angle_by_360 = angle/360;
    angle_raised_by_16 = angle_by_360*(2^16 - 1);
    angle_bin = dec2bin(angle_raised_by_16,16);
    fprintf(fileID,'%2s %16s\r\n',one_space, angle_bin);
    angle = angle + theta_step;
end
fclose(fileID);