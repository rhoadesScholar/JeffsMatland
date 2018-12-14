function mvt_init_vector = compress_mvt_init_vectors(sRev, lRev, omega, upsilon)

mvt_init_vector=[];

mvt_init_vector = sRev.*num_state_convert('sRev');
mvt_init_vector = mvt_init_vector + lRev.*num_state_convert('lRev');
mvt_init_vector = mvt_init_vector + omega.*num_state_convert('omega');
mvt_init_vector = mvt_init_vector + upsilon.*num_state_convert('upsilon');

return;
end
