function[ x ] = Inactive_molecules( ...
...
...
x         , sign_siz   , Time               , b    , ...
mu_prior  , var_prior  , wxy                ,wz     , ...
D         , Num_part   , Species_to_learnD  )   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % x                             :  Positions of the molecules (Normalized)
     % sign_siz                      :  Length of the observation trace
     % Time                          :  Data acquisition time
     % b                             :  Loads for active molecules
     % mu_prior                      :  Mean value of initial positions prior  ( Normal distribution)
     % var_prior                     :  Variance of initial positions prior    ( Normal distribution)
     % wxy                           :  Radius of the confocal in xy plane
     % wz                            :  Radius of the confocal in z axis
     % D                             :  Old sampled diffusion coefficent
     % Num_part                      :  Maximum number of molecules of each species
     % Species_to_learnD             %  Number of species
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % x                             :  sampled inactive particle trajectories


     for mm=1:Species_to_learnD
% Calculate the kinetics
         kxy              = sqrt(2*D(mm)*Time(2:end))./wxy  ;
         kz               = kxy.*(wxy/wz)                   ;
         for nn=1:Num_part
             if b((mm-1)*Num_part+nn)==0
% Sample the locations of molecules through brownian motion
              x(3*((mm-1)*Num_part+nn)-2,:) = cumsum([((-1)^(floor(2*rand())))*mu_prior(1) + sqrt(var_prior(1))*randn(),...
                                             kxy.*randn(1,sign_siz-1)],2)                            ;
              x(3*((mm-1)*Num_part+nn)-1,:) = cumsum([((-1)^(floor(2*rand())))*mu_prior(1) + sqrt(var_prior(1))*randn(),...
                                             kxy.*randn(1,sign_siz-1)],2)                            ;
              x(3*((mm-1)*Num_part+nn)  ,:) = cumsum([((-1)^(floor(2*rand())))*mu_prior(2) + sqrt(var_prior(2))*randn(),...
                                              kz.*randn(1,sign_siz-1)],2)                            ;
             end
         end
     end
     
end