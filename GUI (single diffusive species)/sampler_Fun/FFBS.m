%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Extended Kalman Filter %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[positions]  =  FFBS( ...
    ...
    ...
observation   , I         , I_b       , vdif         , ...
positions     , num_par   , mu_prior  , var_prior    , ...
b             , sign_siz  , PSF_func  , Filter_typ   , ...
yy            , p         , f_3DG     , f_2DGL_D1_2  , ...
f_2DGL_D3     , f_2DGC    , AAA       ) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % observation              :  Anscombe transformed trace
     % I                        :  Vector of molecle photon emission rates at any time step
     % I_b                      :  Vector of background photon emission rates at any time step
     % vdif                     :  Vector of the kinetic variances at each time step and coordinates
     % positions                :  Locations of all molecules
     % num_par                  :  The tag for targeted molecule
     % mu_prior                 :  Mean value for prior of X0 in normalized scale for x, y and z coordintes
     % var_prior                :  Variance for prior of X0 in normalized scale for x, y and z coordintes
     % b                        :  Loads
     % sign_siz                 :  length of the trace
     % PSF_func                 :  Point Spread Function type ( 'Gaussian' or 'Lorentzian Gaussian')
     % Filter_typ               :  Filter Type ('EKF' or 'UKF')
     % yy                       :  Location of the sigma points used in UKF
     % p                        :  Weight of the sigma points used in UKF
     % f_3DG                    :  3DG PSF function
     % f_2DGL_D1_2              :  2DG-Lorentzian PSF, x and y demensions function
     % f_2DGL_D3                :  2DG-Lorentzian PSF, z demensions function
     % f_2DGC                   :  2DG-cylindrica PSF function
     % AAA                      :  Pre-calculations to be used in likelihood calculations
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % positions                :  Updated position of targeted molecules


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%  Precalculations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vt              =  nan(1,sign_siz+1)   ;  % Forward Filter Varinace
x               =  nan(1,sign_siz+1)   ;  % Mean value of the Forward Filter

% Pre-calculations 
nump=(num_par-1)*3;

AA=[ 1 , 2 , 3 ; ...
     2 , 1 , 3 ; ...
     3 , 1 , 2];
 
% Calculate the effect of the other molecule on the likelihood
b(num_par)=0;

% Choose the function for PSF
switch  PSF_func
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%  3D Gaussian PSF  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 1   
          constant1 = I_b+(I.*(b*exp(-2*((positions(AAA(1,:),:).^2) ...
                                        +(positions(AAA(2,:),:).^2) ...
                                        +(positions(AAA(3,:),:).^2)))));                         

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  nn=1,2,3 as X, Y , Z  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for nn = 1:3  
    
x(1)    =  mu_prior(AA(nn,1))       ;  % Set the initial Mean value of the Forward Filter
vt(1)   =  var_prior(AA(nn,1))      ;  % Set the initial Variance of the Forward Filter

%%%%%%%%%%%%%%%%%%%%%%%%%%% Forward Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose the filter type
switch Filter_typ
    case 1    % EKF
         for t=1:sign_siz  
             [x(t+1),vt(t+1)] = EKF( x(t)                          , ...
                                     vt(t)                         , ...
                                     constant1(t)                  , ...
                                     I(t)                          , ...
                                     positions(nump+AA(nn,2) ,t)   , ...
                                     positions(nump+AA(nn,3) ,t)   , ...
                                     observation(t)                , ...
                                     vdif(AA(nn,1),t)              , ...
                                     f_3DG                        );
         end
    case 2    % UKF
         for t=1:sign_siz  
             [x(t+1),vt(t+1)] = UKF( x(t)                          , ...
                                     vt(t)                         , ...
                                     constant1(t)                  , ...
                                     I(t)                          , ...
                                     positions(nump+AA(nn,2) ,t)   , ...
                                     positions(nump+AA(nn,3) ,t)   , ...
                                     observation(t)                , ...
                                     vdif(AA(nn,1),t)              , ...
                                     yy                            , ...
                                     p                             , ...
                                     f_3DG                        );
         end
end
        
%%%%%%%%%%%%%%%%%%%%%%%%% Backward sampling %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
positions(nump+AA(nn,1),:) = Backward_Sampling( x , vt , sign_siz , vdif(AA(nn,1),:));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Lorentzian-Gaussian PSF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 2     
              constant1 = I_b+(I.*(b*(exp(-2*((positions(AAA(1,:),:).^2) ...
                                             +(positions(AAA(2,:),:).^2))./...
                                           (1+(positions(AAA(3,:),:).^2)))./...
                                           (1+(positions(AAA(3,:),:).^2)))));
               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  nn=1,2,3 as X, Y , Z  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for nn=1:3
    
x(1)    =  mu_prior(AA(nn,1))       ;  % Set the initial Mean value of the Forward Filter
vt(1)   =  var_prior(AA(nn,1))      ;  % Set the initial Variance of the Forward Filter

%%%%%%%%%%%%%%%%%%%%%%%%%%% Forward Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose the filter type
switch AA(nn,1)
       case 3
            switch Filter_typ
                   case 1    % EKF
                        for t=1:sign_siz  
                            [x(t+1),vt(t+1)] = EKF_2DGL_3( x(t)                   , ...
                                                           vt(t)                  , ...
                                                           constant1(t)           , ...
                                                           I(t)                   , ...
                                                           positions(nump+1 ,t)   , ...
                                                           positions(nump+2 ,t)   , ...
                                                           observation(t)         , ...
                                                           vdif(3,t)              , ...
                                                           f_2DGL_D3             );
                        end
                   case 2    % UKF
                        for t=1:sign_siz  
                            [x(t+1),vt(t+1)] = UKF( x(t)                   , ...
                                                    vt(t)                  , ...
                                                    constant1(t)           , ...
                                                    I(t)                   , ...
                                                    positions(nump+1 ,t)   , ...
                                                    positions(nump+2 ,t)   , ...
                                                    observation(t)         , ...
                                                    vdif(3,t)              , ...
                                                    yy                     , ...
                                                    p                      , ...
                                                    f_2DGL_D3             );
                        end
            end
    otherwise 
            switch Filter_typ
                   case 1   % EKF
                        for t=1:sign_siz  
                            [x(t+1),vt(t+1)] = EKF_2DGL_12( x(t)                          , ...
                                                            vt(t)                         , ...
                                                            constant1(t)                  , ...
                                                            I(t)                          , ...
                                                            positions(nump+AA(nn,2) ,t)   , ...
                                                            positions(nump+3        ,t)   , ...
                                                            observation(t)                , ...
                                                            vdif(AA(nn,1),t)              , ...
                                                            f_2DGL_D1_2                  );
                        end
                       
                   case 2   % UKF
                        for t=1:sign_siz  
                            [x(t+1),vt(t+1)] = UKF( x(t)                          , ...
                                                    vt(t)                         , ...
                                                    constant1(t)                  , ...
                                                    I(t)                          , ...
                                                    positions(nump+AA(nn,2) ,t)   , ...
                                                    positions(nump+3        ,t)   , ...
                                                    observation(t)                , ...
                                                    vdif(AA(nn,1),t)              , ...
                                                    yy                            , ...
                                                    p                             , ...
                                                    f_2DGL_D1_2                  );
                        end
            end
end
        

%%%%%%%%%%%%%%%%%%%%%%%%% Backward sampling %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
positions(nump+AA(nn,1),:) = Backward_Sampling( x  , vt  , sign_siz , vdif(AA(nn,1),:) );

end
                                           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Cylindrical PSF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    otherwise
              constant1 = I_b+(I.*(b*exp(-2*(positions(AAA(1,:),:).^2 ...
                                            +positions(AAA(2,:),:).^2))));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%  nn=1,2  as X, Y   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for nn=1:2  
    
    
x(1)    =  mu_prior(AA(nn,1))   ;  % Set the initial Mean value of the Forward Filter
vt(1)   =  var_prior(AA(nn,1))  ;  % Set the initial Variance of the Forward Filter


%%%%%%%%%%%%%%%%%%%%%%%%%%% Forward Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose the filter type
switch Filter_typ
    
    case 1    % EKF
         for t=1:sign_siz  
             [x(t+1),vt(t+1)] = EKF( x(t)                          , ...
                                     vt(t)                         , ...
                                     constant1(t)                  , ...
                                     I(t)                          , ...
                                     positions(nump+AA(nn,2) ,t)   , ...
                                     positions(nump+3        ,t)   , ...
                                     observation(t)                , ...
                                     vdif(AA(nn,1),t)              , ...
                                     f_2DGC                       );
         end
    case 2    % UKF
         for t=1:sign_siz  
             [x(t+1),vt(t+1)] = UKF( x(t)                          , ...
                                     vt(t)                         , ...
                                     constant1(t)                  , ...
                                     I(t)                          , ...
                                     positions(nump+AA(nn,2) ,t)   , ...
                                     positions(nump+3        ,t)   , ...
                                     observation(t)                , ...
                                     vdif(AA(nn,1),t)              , ...
                                     yy                            , ...
                                     p                             , ...
                                     f_2DGC                       );
         end
end
        

%%%%%%%%%%%%%%%%%%%%%%%%% Backward sampling %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
positions(nump+AA(nn,1),:) = Backward_Sampling( x  , vt  , sign_siz , vdif(AA(nn,1),:));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%  Z coordinate from random walk  %%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
positions(nump+3,:) =  cumsum([((-1)^(floor(2*rand())))*mu_prior(3) + sqrt(var_prior(3))*randn(),...
                                              sqrt(vdif(3,2:end)).*randn(1,sign_siz-1)],2) ;
end




end