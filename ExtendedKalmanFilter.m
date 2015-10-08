classdef ExtendedKalmanFilter < handle
    
    properties
        x = [];
        P = [];
        Q = [];
        R = [];
        f = @(x, u) [];
        h = @(x) [];
        Ffun = @(x) [];
        Hfun = @(x) [];
    end
    
    methods
        function obj = ExtendedKalmanFilter(x0, P0)
            obj.x = x0;
            obj.P = P0;
        end
        function Predict(obj, u)
            obj.x = obj.f(obj.x, u);
            F = obj.Ffun(obj.x);
            obj.P = F*obj.P*F' + obj.Q;
        end
        function Update(obj, z)
            v = z - obj.h(obj.x);
            H = obj.Hfun(obj.x);
            S = H*obj.P*H' + obj.R;
            K = obj.P*H'/S;
            obj.x = obj.x + K*v;
            obj.P = obj.P - K*H*obj.P;
        end
    end
    
end
