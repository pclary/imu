function drawframe(q)

xaxis = [0 1; 0 0; 0 0];
yaxis = [0 0; 0 1; 0 0];
zaxis = [0 0; 0 0; 0 1];

A = quat2mat(q);

clf;
hold on;

plotline3(xaxis, 'r:');
plotline3(yaxis, 'g:');
plotline3(zaxis, 'b:');

plotline3(A*xaxis, 'r');
plotline3(A*yaxis, 'g');
plotline3(A*zaxis, 'b');

hold off;
axis equal;
axis([-1, 1, -1, 1, -1, 1]);
view(37.5+90, 30);
grid on;


function plotline3(p, color)

plot3(p(1,:), p(2,:), p(3,:), color, 'LineWidth', 2);
