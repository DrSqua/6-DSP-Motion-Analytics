function [axialRot,abduction,flexion] = Euler_Cardan_angles(rel_rotation_matrix)
% rot2CardanXYZ  Extract ISB‐style Cardan (X–Y–Z) angles from a 3×3 R
%
%   [axialRot, abduction, flexion] = rot2CardanXYZ(R)
%
% Input:
%   R           3×3 rotation matrix (child‐local → parent‐local)
%
% Outputs (in degrees):
%   flexion     rotation about the local X‐axis (e.g. flexion/extension)
%   abduction   rotation about the new Y‐axis     (e.g. ab/adduction)
%   axialRot    rotation about the final Z‐axis   (e.g. int./ext. rotation)
%
% Uses the sequence:
%   R = Rz(axialRot) * Ry(abduction) * Rx(flexion)
% which is equivalent to first rotate about X, then Y′, then Z″.

  % guard against numerical roundoff pushing asin input slightly >1
  sy = -rel_rotation_matrix(3,1);
  sy = max(min(sy,1),-1);

  % Cardan angles
  flexion   = atan2d( rel_rotation_matrix(3,2),  rel_rotation_matrix(3,3) );    % θx = atan2(r32, r33)
  abduction = asind ( sy             );    % θy =  asin(−r31)
  axialRot  = atan2d( rel_rotation_matrix(2,1),  rel_rotation_matrix(1,1) );    % θz = atan2(r21, r11)
end