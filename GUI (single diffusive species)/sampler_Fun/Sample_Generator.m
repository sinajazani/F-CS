function [ X,Y,Z,single_photon_arrivals ] = Sample_Generator( ...
...
...
Lxy                , Lz                   , Length_signal  , Number_molecules , ...
wxy                , wz                   , D              , tau              , ...
Molecule_emission  , Background_emission  , PSF            , handles          , ...
GUI                )
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % Lxy                     :  Periodic boundary in  x and y coordinates
     % Lz                      :  Periodic boundary in  z coordinate
     % Length_signal           :  Length of the time trace
     % Number_molecules        :  Number of molecules for each species
     % wxy                     :  Minor Semi-axis of the confocal volume
     % wz                      :  Major Semi-axis of the confocal volume
     % D                       :  Diffusion coeffcient
     % tau                     :  Data acquisition time
     % Molecule_emission       :  Molecular brightness
     % Background_emission     :  Background photon emission rate
     % PSF_func                :  Point spread function type (3DG = 1 , 2DGL =2 and 2DGC = 3)
     % handles                 :  GUI information
     % GUI                     :  A control for GUI 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % X                     :  Location molecuules in x coordinate
     % Y                     :  Location molecuules in y coordinate
     % Z                     :  Location molecuules in z coordinate
     % single_photon_arrivals  :  Single photon arrival time trace
    

% Measure the kinetic step size
k=sqrt(2*D*tau);

% consider the space size for locations
X = zeros ( Number_molecules , Length_signal ) ;
Y = zeros ( Number_molecules , Length_signal ) ;
Z = zeros ( Number_molecules , Length_signal ) ;

if GUI==1
% Initialize the time bar
   cla(handles.axes23)
   set(handles.axes23,'Units','pixels','XLim',[0 1],'YLim',[0 1],...
           'XTick',[],'YTick',[],'Color','w','XColor','w','YColor','w');
    
   patch(handles.axes23,[0 0 0 0],[0 1 1 0],'b');
   handles.text80.String='Initializing ...';
   drawnow
   time_loop =0 ;
   save_bar=1;
   tic
end
    
    

% Randomly sample the location of the molecules from the uniform probability
for jk1=1:Number_molecules
    
    X(jk1,1) = Lxy*(1-2*rand());
    Y(jk1,1) = Lxy*(1-2*rand());
    Z(jk1,1) = Lz *(1-2*rand());

end
  

for i=2:Length_signal+1  
    for j1  = 1:Number_molecules
        
        % Sample the locations baswed on brownian motion
        X(j1,i) = X(j1,i-1)+(k*randn());
        Y(j1,i) = Y(j1,i-1)+(k*randn());
        Z(j1,i) = Z(j1,i-1)+(k*randn());
       
        % Periodoc boundaries
        if  X(j1,i) >= Lxy
            X(j1,i)  = X(j1,i)-2*Lxy;
        end  
        if  X(j1,i) <= -Lxy
            X(j1,i)  = X(j1,i)+2*Lxy;
        end 
        if  Y(j1,i) >= Lxy
            Y(j1,i)  = Y(j1,i)-2*Lxy;
        end  
        if  Y(j1,i) <= -Lxy
            Y(j1,i)  = Y(j1,i)+2*Lxy;
        end 
        if PSF~=3
            if  Z(j1,i) >= Lz
                Z(j1,i)  = Z(j1,i)-2*Lz;
            end  
            if  Z(j1,i) <= -Lz
                Z(j1,i)  = Z(j1,i)+2*Lz;
            end 
        end
        
    end
    
    
    if GUI==1
       if find((floor((1:1:10).*(Length_signal+1)./10))==i)>=1
          time_loop=time_loop+toc;
          remaining_time=floor((time_loop/(save_bar.*(Length_signal+1)./10))*((10-save_bar).*...
                                                     (Length_signal+1)./10)*10)/10;
          handles.text80.String=['Remaining time = ', num2str(remaining_time),' s'];
          patch(handles.axes23,[0  0  save_bar/10  save_bar/10],[0 1 1 0],'b');
          save_bar=save_bar+1;
          drawnow
          tic
       end
    end
    
                     
end % end of time loop


% Choose a PSF
switch PSF
    
    case 1        % 3D Gaussian PSF
              Emit_rate_pos = sum(exp(-2*( (X./wxy).^2 + (Y./wxy).^2 + (Z./wz).^2 )),1);
    case 2        % 2D Gaussian-Lorentzian PSF
              Emit_rate_pos = sum(exp(-2*( (X./wxy).^2 + (Y./wxy).^2)./(1+(Z./wz).^2))./(1+(Z./wz).^2),1) ;
    otherwise     % 2D Gaussian-Cylindrical PSF
              Emit_rate_pos = sum(exp(-2*( (X./wxy).^2 + (Y./wxy).^2  )),1);
end




if GUI==1
   handles.text80.String='Done!';
   
   
   % sample the photons from a bernoulli distribution
   photons= poissrnd(tau*(Background_emission+(Molecule_emission.*Emit_rate_pos))) ;
   
   % Find the arrival times of observed photons
   single_photon_arrivals=find(photons>0)*tau;
   
   X=[];
   Y=[];
   Z=[];
else

% sample the photons from a bernoulli distribution
   photons= poissrnd(tau*(Background_emission+(Molecule_emission'.*Emit_rate_pos))) ;

% Find the arrival times of observed photons
   max_emission=find(Molecule_emission==max(Molecule_emission));
   photon_loc =find(photons(max_emission,:)>0);
   
   for num_sig=1:length(Molecule_emission)
       single_photon_arrivals{num_sig}=find(photons(num_sig,:)>0)*tau;
   end
   
   X          = X(:,photon_loc)    ;
   Y          = Y(:,photon_loc)    ;
   Z          = Z(:,photon_loc)    ;
end

end