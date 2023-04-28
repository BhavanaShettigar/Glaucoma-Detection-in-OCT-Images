function diff_im = anisotropicdiffusion(image, iteration, delta_t, kappa)
%% Convert input image to double.
image = double(image);

%% PDE (partial differential equation) initial condition.
diff_im = image;

%% Center pixel distances.
dx = 1;
dy = 1;
dd = sqrt(2);

%% 2D convolution masks 
hN = [0 1 0; 0 -1 0; 0 0 0];
hS = [0 0 0; 0 -1 0; 0 1 0];
hE = [0 0 0; 0 -1 1; 0 0 0];
hW = [0 0 0; 1 -1 0; 0 0 0];
hNE = [0 0 1; 0 -1 0; 0 0 0];
hSE = [0 0 0; 0 -1 0; 0 0 1];
hSW = [0 0 0; 0 -1 0; 1 0 0];
hNW = [1 0 0; 0 -1 0; 0 0 0];

%% Anisotropic diffusion.
for t = 1:iteration

        % Finite differences.
        nablaN = conv2(diff_im,hN,'same');
        nablaS = conv2(diff_im,hS,'same');   
        nablaW = conv2(diff_im,hW,'same');
        nablaE = conv2(diff_im,hE,'same');   
        nablaNE = conv2(diff_im,hNE,'same');
        nablaSE = conv2(diff_im,hSE,'same');   
        nablaSW = conv2(diff_im,hSW,'same');
        nablaNW = conv2(diff_im,hNW,'same'); 
        
            % Diffusion function.
            cN = exp(-(nablaN/kappa).^2);
            cS = exp(-(nablaS/kappa).^2);
            cW = exp(-(nablaW/kappa).^2);
            cE = exp(-(nablaE/kappa).^2);
            cNE = exp(-(nablaNE/kappa).^2);
            cSE = exp(-(nablaSE/kappa).^2);
            cSW = exp(-(nablaSW/kappa).^2);
            cNW = exp(-(nablaNW/kappa).^2);

                 % Discrete PDE solution.
                 diff_im = diff_im + ...
                     delta_t*(...
                     (1/(dy^2))*cN.*nablaN + (1/(dy^2))*cS.*nablaS + ...
                     (1/(dx^2))*cW.*nablaW + (1/(dx^2))*cE.*nablaE + ...
                     (1/(dd^2))*cNE.*nablaNE + (1/(dd^2))*cSE.*nablaSE + ...
                     (1/(dd^2))*cSW.*nablaSW + (1/(dd^2))*cNW.*nablaNW );
                 
 %% Iteration
 fprintf('\rIteration %d\n',t);
end


