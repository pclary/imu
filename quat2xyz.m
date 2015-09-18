function r = quat2xyz(q)
%#codegen

r = threeaxisrot( -2.*(q(3).*q(4) - q(1).*q(2)), ...
    q(1).^2 - q(2).^2 - q(3).^2 + q(4).^2, ...
    2.*(q(2).*q(4) + q(1).*q(3)), ...
   -2.*(q(2).*q(3) - q(1).*q(4)), ...
    q(1).^2 + q(2).^2 - q(3).^2 - q(4).^2);

end

function r = threeaxisrot(r11, r12, r21, r31, r32)
    % find angles for rotations about X, Y, and Z axes
    r1 = atan2( r11, r12 );
    r2 = asin( r21 );
    r3 = atan2( r31, r32 );
    r = [r1, r2, r3];
end
