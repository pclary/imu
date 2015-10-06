%%
data = csvread('data2.csv');
gyro = data(:, 1:3)*(1000/2^15);
dt = 1/8000;
t = dt*(1:length(data))';

bias = mean(gyro(1:1e5, :));
gyro = bsxfun(@minus, gyro, bias);

plot(t, gyro);

%%
data = csvread('mpu-100hz-250dps-2g.csv');
gyro = data(:, 1:3);
accel = data(:, 4:6);
dt = 1/100;
t = dt*(1:length(data));

bias = mean(gyro(3e4:6e4, :));
gyro = bsxfun(@minus, gyro, bias);

n = 64;
fgyro = filtfilt(ones(n, 1), n, gyro);
plot(t, fgyro);

%%

downsample = 8;
gyro2 = conv2(gyro, ones(downsample, 1)/downsample, 'valid');
gyro2 = gyro2(1:downsample:end, :);
t2 = t(1:downsample:end);
t2 = t2(1:length(gyro2));

q = [1; 0; 0; 0];
yaw = zeros(size(t2));
pitch = zeros(size(t2));
roll = zeros(size(t2));

for i = 1:length(gyro2)
    F = Phi(gyro2(i, :)'*pi/180, dt*downsample);
    q = F*q;
    r = quat2zyx(q);
    yaw(i) = r(1);
    pitch(i) = r(2);
    roll(i) = r(3);
end

%%
plot(t2, yaw*180/pi);
