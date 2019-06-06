function[ MU , MU_BACK ,mu_acceptance_rate ] = Sample_emission_rates( ...
...
...
mu_proposal   ,  mu_alpha            , mu_beta           ,  MU_OLD          , ...
sign_siz      ,  mu_acceptance_rate  , observation       ,  MU_BACK_OLD     , ...
Time          ,  b                   , mu_back_proposal  ,  mu_back_alpha   , ...
mu_back_beta  ,  Constant            , Species_to_learn  ,  Num_part) 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % mu_proposal                   :  Proposal parameter for MU           ( Gamma distribution)
     % mu_alpha                      :  Alpha parameter of MU prior         ( Gamma distribution)
     % mu_beta                       :  Beta parameter of MU prior          ( Gamma distribution)
     % MU_OLD                        :  Previous sampled molecule photon emission rate
     % sign_siz                      :  Length of the observation signal
     % mu_acceptance_rate            :  Previous acceptance rate 
     % observation                   :  Anscombe transformed time trace
     % MU_BACK_OLD                   :  Previous background emission rate
     % Time                          :  Data acqisition time
     % b                             :  Loads for active molecules
     % mu_back_proposal              :  Proposal parameter for MU_back       ( Gamma distribution)
     % mu_back_alpha                 :  Alpha parameter of MU_back prior     ( Gamma distribution)
     % mu_back_beta                  :  Beta parameter of MU_back prior      ( Gamma distribution)
     % Constant                      :  Precalculated likelihood
     % Species_to_learn              :  Number of species
     % Num_part                      :  Number of molecules of each species
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % MU                            :  Updated MU
     % MU_BACK                       :  Updated MU Background
     % mu_acceptance_rate            :  Updated acceptance rate


% Propose MU from a gamma distribution
         MU_NEW      = (MU_OLD./mu_proposal).*randg(mu_proposal,Species_to_learn,1)  ;
         MU_BACK_NEW = (MU_BACK_OLD/mu_back_proposal)*randg(mu_back_proposal)  ;
bbnew=[];
bbold=[];
         for mm=1:Species_to_learn
             bbnew=[bbnew,b(1,(mm-1)*Num_part+1:mm*Num_part)*MU_NEW(mm)];
             bbold=[bbold,b(1,(mm-1)*Num_part+1:mm*Num_part)*MU_OLD(mm)];
         end
       
% Calculate the likelihood
             neww      = ((MU_BACK_NEW+(bbnew*Constant{1})).*Time{1}) ;
             oldd      = ((MU_BACK_OLD+(bbold*Constant{1})).*Time{1}) ;
             
             moldd     = sqrt((4*oldd)+1.5)-(0.25./sqrt(oldd))+(0.03125./(oldd.^1.5)) ;
             mneww     = sqrt((4*neww)+1.5)-(0.25./sqrt(neww))+(0.03125./(neww.^1.5)) ;
             
             constant1 = 0.5*sum(log((1+0.0625./(oldd.^2))./(1+0.0625./(neww.^2)))+...
        ((observation{1}-moldd).^2)./(1+0.0625./(oldd.^2))-((observation{1}-mneww).^2)./(1+0.0625./(neww.^2)));
             


% Calculate the logarithm of posterior ratio                           
         logr = constant1 +...
                sum(((2*mu_proposal-mu_alpha)*log(MU_OLD./MU_NEW))+...
                ((MU_OLD-MU_NEW)/mu_beta)+...
                (mu_proposal*((MU_NEW./MU_OLD)-(MU_OLD./MU_NEW))))+...
                ((2*mu_back_proposal-mu_back_alpha)*log(MU_BACK_OLD/MU_BACK_NEW))+...   
                ((MU_BACK_OLD-MU_BACK_NEW)/mu_back_beta)+...
                (mu_back_proposal*((MU_BACK_NEW/MU_BACK_OLD)-(MU_BACK_OLD/MU_BACK_NEW)));

% Accept or reject the proposals
         if  logr>log(rand())
             MU                 = MU_NEW                ;
             MU_BACK            = MU_BACK_NEW           ;
             mu_acceptance_rate = mu_acceptance_rate+1  ;
         else
             MU                 = MU_OLD                ;
             MU_BACK            = MU_BACK_OLD           ;
         end
         
end