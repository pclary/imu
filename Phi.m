function out = Phi(wb, dt)

if ~all(size(wb) == [3, 1])
    error('Body angular acceleration wb must be a 3x1 vector');
end

w = norm(wb);
if w ~= 0
    n = wb/w;
else
    n = [1; 0; 0];
end
    
theta = w*dt/2;
c = cos(theta);
s = sin(theta);

out = [c      -s*n(1) -s*n(2) -s*n(3);
       s*n(1)  c      -s*n(3)  s*n(2);
       s*n(2)  s*n(3)  c      -s*n(1);
       s*n(3)  s*n(2)  s*n(1)  c     ];
