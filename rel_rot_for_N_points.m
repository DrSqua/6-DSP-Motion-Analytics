function R = rel_rot_for_N_points(P_curr, P_ref)
% Inputs:
%   P_ref  = 3×N matrix of reference marker positions (each column is a marker)
%   P_curr = 3×N matrix of current marker positions
% Output:
%   R      = 3×3 rotation matrix (attitude matrix)

  % Center the markers
  mu_ref = mean(P_ref, 2);
  mu_curr = mean(P_curr, 2);
  Q_ref = P_ref - mu_ref;
  Q_curr = P_curr - mu_curr;

  % Compute rotation using SVD
  H = Q_ref * Q_curr';
  [U, ~, V] = svd(H);
  R = V * U';

  % Ensure a right-handed coordinate system
  if det(R) < 0
      V(:,end) = -V(:,end);
      R = V * U';
  end
end