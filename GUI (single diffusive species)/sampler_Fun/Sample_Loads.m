function[ b , acceptance_rate_b ]    =  Sample_Loads( ...
...
...
b_old    , I                 , observation  , acceptance_rate_b , ...
Time     , Number_moleclues  , I_back       , q                 , ...
Constant )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % b_old                         :  Old sampled load 
     % I                             :  Moelcule photon emission rate
     % observation                   :  Anscombe transformed time trace
     % acceptance_rate_b             :  Previous acceptance rate 
     % Time                          :  Data acquisition time
     % Number_molecules              :  Number of defined molecules
     % I_back                        :  Background photon emission rate
     % q                             :  Weight of loads
     % Constant                      :  Precalculated likelihood
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % b                             :  Updated load b
     % acceptance_rate_b             :  Updated acceptance rate
   
     
   % Propose the new loads
   b_new = rand(1,Number_moleclues)<q;
    
   neww  =((I_back + I.*(b_new*Constant)).*Time);
   oldd  =((I_back + I.*(b_old*Constant)).*Time);

   moldd = sqrt((4*oldd)+1.5)-(0.25./sqrt(oldd))+(0.03125./(oldd.^1.5)) ;
   mneww = sqrt((4*neww)+1.5)-(0.25./sqrt(neww))+(0.03125./(neww.^1.5)) ;
             
   logr =  0.5*sum(log((1+0.0625./(oldd.^2))./(1+0.0625./(neww.^2)))+...
       ((observation-moldd).^2)./(1+0.0625./(oldd.^2)) -((observation-mneww).^2)./(1+0.0625./(neww.^2)))    ;
   
   % Check the acceptance
   if  logr>log(rand())
       b = b_new ;   %% Accept %%
       acceptance_rate_b = acceptance_rate_b + 1 ;
   else
       b = b_old ;   %% Reject %%
   end
   
end