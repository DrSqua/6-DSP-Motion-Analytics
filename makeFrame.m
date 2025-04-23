function R = makeFrame(P1, P2, P3)
    % Bouw een lokaal assenstelsel:
    % P1 = origine, P2 bepaalt x, P3 bepaalt xy-vlak
    x = normalize(P2 - P1, 2);              % x-as
    z = normalize(cross(x, P3 - P1, 2), 2); % z-as
    y = normalize(cross(z, x, 2), 2);       % y-as
    R = zeros(3,3,size(P1,1));              % Nx3x3

    for i = 1:size(P1,1)
        R(:,:,i) = [x(i,:); y(i,:); z(i,:)]';
    end
end
