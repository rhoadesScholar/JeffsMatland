function [pointerShape, pointerHotSpot] = createPointer
%CREATEPOINTER fucntion creates a shape for the pointer.
    pointerHotSpot = [8 8];
    pointerShape = NaN(16,16);
    pointerShape(:,8) = 1;
    pointerShape(8,:) = 1;
end

