% dec2twos
function twos_complement = dec2twos_mod(z)
z_binary_inv = char(zeros(1,16));
if z<0
    z_binary = dec2bin(abs(z/180)*(2^15),16);
    for i = 1:16
        if z_binary(i)=='0'
            z_binary_inv(i) = '1';
        else
            z_binary_inv(i) = '0';
        end
    end
    z_inv_plus_1 = dec2bin((bin2dec(z_binary_inv) + 1),16);
    twos_complement = z_inv_plus_1(1:16);
else
    twos_complement = dec2bin(abs(z/180)*(2^15),16);
end
end