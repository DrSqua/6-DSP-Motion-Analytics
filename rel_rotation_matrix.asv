function [rotation_matrix] = rel_rotation_matrix(attitude_parent,attitude_child)
% relRot  Compute child‐relative‐to‐parent rotation matrix
%
%   R_rel = relRot(R_parent, R_child)
%
% Inputs:
%   R_parent   3×3 attitude matrix of the parent segment (local→global)
%   R_child    3×3 attitude matrix of the child  segment (local→global)
%
% Output:
%   R_rel      3×3 rotation matrix: transforms child‐local coordinates
%              into parent‐local coordinates

  % undo the parent’s orientation, then apply the child’s
  rotation_matrix = attitude_parent' * attitude_child;
end