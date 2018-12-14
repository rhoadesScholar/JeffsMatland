function procFrame = body_contour_from_procFrame(procFrame)

for(i=1:length(procFrame))
    for(j=1:length(procFrame(i).worm))
        procFrame(i).worm(j).body_contour = body_contour_from_image( procFrame(i).worm(j).image,  procFrame(i).worm(j).bound_box_corner);
    end
end

return;
end
