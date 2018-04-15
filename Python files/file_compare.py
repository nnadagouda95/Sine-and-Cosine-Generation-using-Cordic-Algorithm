
import numpy as np

ref_op = open('D:/Fall 2017/6276/Project/output_reference180.txt','r')
lines_ref_op = ref_op.read().split()
lines_ref_op = lines_ref_op[2:]
l1 = len(lines_ref_op)
sample_op = open('D:/Fall 2017/6276/Project/sample_output_cordic_top.txt','r' )
lines_sample_op = sample_op.read().split()
lines_sample_op = lines_sample_op[4:]
l2 = len(lines_sample_op)

sine_values_dec = ['0']*(l1/2)
cos_values_dec = ['0']*(l1/2)
sine_values_bin = ['0']*(l2/3)
cos_values_bin = ['0']*(l2/3)

for i in range(0,l1,2):
    sine_values_dec[i/2] = lines_ref_op[i]
    cos_values_dec[i/2] = lines_ref_op[i+1]
    
for i in range(0,l2,3):
    sine_values_bin[i/3] = lines_sample_op[i]
    cos_values_bin[i/3] = lines_sample_op[i+1]
    
l = len(sine_values_dec)

float_sine_ref = [float(val) for val in sine_values_dec]
float_cos_ref = [float(val) for val in cos_values_dec]

def str2dec(x):
    x_dec = 0
    for i in range(0,15):
        x_dec += (int(x[15-i])*(2**(i)))
    x_dec += int(x[0])*(-2**(15))
    x_dec /= 32768.0
    return x_dec

float_sine_sample = [str2dec(line) for line in sine_values_bin]
float_cos_sample = [str2dec(line) for line in cos_values_bin]

np_sine_ref = np.array(float_sine_ref)
np_cos_ref = np.array(float_cos_ref)
np_sine_sample = np.array(float_sine_sample)
np_cos_sample = np.array(float_cos_sample)


mse_sin = (sum(abs(np_sine_ref-np_sine_sample))/l)
mse_cos = (sum(abs(np_cos_ref-np_cos_sample))/l)
avg_mse = 0.5*(mse_sin + mse_cos)