classdef KalmanFilter < handle
    
    properties
        x = [];
        P = [];
        Q = [];
        R = [];
        F = [];
        H = [];
    end
    
    methods
        function obj = KalmanFilter(x0, P0)
            obj.x = x0;
            obj.P = P0;
        end
        function Predict(obj)
            obj.x = obj.F*obj.x;
            obj.P = obj.F*obj.P*obj.F' + obj.Q;
        end
        function Update(obj, z)
            v = z - obj.H*obj.x;
            S = obj.H*obj.P*obj.H' + obj.R;
            K = obj.P*obj.H'/S;
            obj.x = obj.x + K*v;
            obj.P = obj.P - K*obj.H*obj.P;
        end
        
    end
    
end
