function [X] = Backward_Sampling( x  , vt  , sign_siz , vdif   )


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % x                        :  Mean value of the previous filter
     % vt                       :  Variance of the previous filter
     % sign_siz                 :  Length f the time trace
     % vdif                     :  varinace of the dynamical probability
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % XX                       :  Sampled trajectory
     
     
% Prelocate the vector of the trajectory
     X=nan(1,sign_siz);
     
%Sample the last point directly from the filter
     if  rand()>0.5
         X(1,sign_siz)  =  x(sign_siz+1) + sqrt(vt(sign_siz+1))*randn()   ;
     else
         X(1,sign_siz)  = -x(sign_siz+1) + sqrt(vt(sign_siz+1))*randn()   ;
     end

     vtt   = vt(1:sign_siz)+vdif(1,:)                                     ;
     vvt   = sqrt(vt(1:sign_siz).*vdif(1,:)./vtt)                         ;
     
     for i = sign_siz:-1:2
         if  rand() < 1/(1+exp(-2*X(1,i)*x(i)/vtt(i)))
             X(1,i-1) = ( X(1,i)*vt(i)+vdif(1,i)*x(i) )/vtt(i) + vvt(i)*randn()  ;
         else         
             X(1,i-1) = ( X(1,i)*vt(i)-vdif(1,i)*x(i) )/vtt(i) + vvt(i)*randn()  ;
         end
     end

end