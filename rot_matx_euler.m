 function eul = rot_matx_euler(R)
    % Input: R = 3x3 rotatiematrix
    % Output: eul = [alpha beta gamma] in radians

    beta = acos(R(2,2));    
    
    if abs(sin(beta)) < 1e-6
        % Gimbal lock geval (beta ~ 0 of pi)
        alpha = 0;
        gamma = atan2(-R(1,3), R(1,1));
    else
        alpha = atan2(R(1,2), -R(3,2));
        gamma = atan2(R(2,1), R(2,3));
    end
    
    eul = [alpha, beta, gamma]; % in radialen
end
