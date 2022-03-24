
%% Assignment 1 Fixed
%  Konrad Socha 101037642

%% Initialize Function and Declare Variables and Constants 

function [] = MainAssignment3B(nElec)

    %FLAGS

    ScatterFlag = 1;
    BoxFlag = 0;
    ReflectFlag = 0;
    InjectFlag = 0;



    q_0 = 1.60217653e-19;             % electron charge
    %hb = 1.054571596e-34;             % Dirac constant
    %h = C.hb * 2 * pi;                % Planck constant
    m_0 = 9.10938215e-31;             % electron mass
    kb = 1.3806504e-23;               % Boltzmann constant
    %eps_0 = 8.854187817e-12;          % vacuum permittivity
    %mu_0 = 1.2566370614e-6;           % vacuum permeability
    %c = 299792458;                    % speed of light
    %g = 9.80665;                      % metres (32.1740 ft) per s²
    Ne = 2.7182818;                    % eulers number
    tm = 0.2e-12;                       % Mean Collision time
    
    %CONSTANTS
    Vth = sqrt(2 * kb * 300/ (0.26 * m_0));

    %TIME
    t = 0;
    dt = 1e-13;
    TStop = 100*dt; % shortened to 100 from 1000 for testing

    %COUNT
    count = 1;
    nElecCount = 0;

    %BOUNDARIES
    xMax = 200e-9;
    yMax = 100e-9;
    Limits = [-xMax +xMax -yMax +yMax];
    LimitsTemp = [0 TStop 0 600];
    LimitsScatter = [0 TStop 0 1];
    LimitsMFP = [0 TStop 0 3e-09];

    %Scattering probability
    pScat = 1 - Ne^(-(dt/(0.2e-12)));
    scattercount = 0;

    %Drawing of boxes
    Box1 = [-xMax/5 -yMax/4; xMax/5 -yMax/4; xMax/5 -yMax; -xMax/5 -yMax;-xMax/5 -yMax/4;];
    Box2 = [-xMax/5 yMax/4; xMax/5 yMax/4; xMax/5 yMax; -xMax/5 yMax;-xMax/5 yMax/4;];

    %Old position values
    xOld = zeros(1,nElec);
    yOld = zeros(1,nElec);
    
    % Randomly place electrons
    x(1, :) = zeros(1,nElec)-xMax; % injection from left side
    y(1, :) = ((rand(1,nElec)*2) - 1) * yMax; % spread evenly
    
    
    % give each particle Vth but with a random direction
    Vx(1:nElec) = Vth/sqrt(2) * randn(1,nElec);
    Vy(1:nElec) = Vth/sqrt(2) * randn(1,nElec);
    
    %set scatter Avg to zero to start
    ScatterAvg = 0;

    %Initialize V field
    VoltX = 0.1;
    EfieldX = VoltX/xMax;
    AccelX = (EfieldX * q_0) / (0.26 * m_0);

    if InjectFlag == 0
        x(1, :) = ((rand(1,nElec)*2) - 1) * xMax; % spread evenly
        nElecCount = nElec;
    end

%% Assignment 2
L = xMax * 1e9;
W = yMax * 1e9;
F = zeros(L*W,1);
G = sparse(L*W, L*W);
Box = 40;
sigma = 0.01;
ConMatrix = ones(L,W);
ConMatrix(L/2 - Box/2:L/2 + Box/2,1:Box) = sigma;
ConMatrix(L/2 - Box/2:L/2 + Box/2,W-Box:W) = sigma;


for i = 1:1:L
    for j = 1:1:W
        N = (i-1) * W + j;
        NXM = (i-2) * W + j;
        NXP = i * W + j;
        NYM = (i-1) * W + j-1;
        NYP = (i-1) * W + j+1;

        %MXM = (ConMatrix(i,j) + ConMatrix(i-1,j));
        %MXP = (ConMatrix(i,j) + ConMatrix(i+1,j));
        %MYM = (ConMatrix(i,j) + ConMatrix(i,j-1));
        %MYP = (ConMatrix(i,j) + ConMatrix(i,j+1));

        if i == 1 %     LEFT
            F(N,1) = VoltX;
            G(N,N) = 1;
        elseif i == L % RIGHT
            F(N,1) = 0;
            G(N,N) = 1;
        elseif j == 1 % BOTTOM
            MXM = (ConMatrix(i,j) + ConMatrix(i-1,j));
            MXP = (ConMatrix(i,j) + ConMatrix(i+1,j));
            %MYM = (ConMatrix(i,j) + ConMatrix(i,j-1));
            MYP = (ConMatrix(i,j) + ConMatrix(i,j+1));

            G(N,N)   = -(MXM + MXP + MYP);
            G(N,NXM)   = MXM;
            G(N,NXP)   = MXP;
            G(N,NYP)   = MYP;
        elseif j == W % TOP
            MXM = (ConMatrix(i,j) + ConMatrix(i-1,j));
            MXP = (ConMatrix(i,j) + ConMatrix(i+1,j));
            MYM = (ConMatrix(i,j) + ConMatrix(i,j-1));
            %MYP = (ConMatrix(i,j) + ConMatrix(i,j+1));

            G(N,N)   = -(MXM + MXP + MYP);
            G(N,NXM)   = MXM;
            G(N,NXP)   = MXP;
            G(N,NYP)   = MYM;
        else %           MID
            MXM = (ConMatrix(i,j) + ConMatrix(i-1,j));
            MXP = (ConMatrix(i,j) + ConMatrix(i+1,j));
            MYM = (ConMatrix(i,j) + ConMatrix(i,j-1));
            MYP = (ConMatrix(i,j) + ConMatrix(i,j+1));

            G(N,N)   = -(MXM + MXP + MYM + MYP);
            G(N,NXM) = MXM;
            G(N,NXP) = MXP;
            G(N,NYM) = MYM;
            G(N,NYP) = MYP;
        end

    end

end

VMatrix = reshape(G\F , [W,L]);
[Ex,Ey] = gradient(-VMatrix);


figure(1)
title("Voltage Plot")
surf(VMatrix')
xlabel("Distance (m)")
ylabel("Distance (m)")
zlabel("V Plot")

figure(2);
quiver(Ex,Ey);
title('E field') ;
xlabel("Distance (m)")
ylabel("Distance (m)")
zlabel("E field")

   %% Main Loop

    while t < TStop


            % Iterate time
            t  = t + dt;  

            % Get old positions
            xOld(1:nElecCount) = x(1:nElecCount);
            yOld(1:nElecCount) = y(1:nElecCount);
            VxOld(1:nElecCount) = Vx(1:nElecCount);
            VyOld(1:nElecCount) = Vy(1:nElecCount);

            % Update Velocity
            Vx(1:nElecCount) = Vx(1:nElecCount) + (AccelX * dt);
            

            % Get new Positions
            x(1:nElecCount) = x(1:nElecCount) + (Vx(1:nElecCount) .* dt);
            y(1:nElecCount) = y(1:nElecCount) + (Vy(1:nElecCount) .* dt);


            

            %% Testing "for" loops
            for i=1:1:nElecCount

                if ScatterFlag == 1
                %Scatter Test
                rScat = rand(1,nElecCount);
                if rScat(i) <= pScat
                scattercount = scattercount+1;
                Vx(i) = Vth/sqrt(2) * randn();
                Vy(i) = Vth/sqrt(2) * randn();
                end
                end

if ReflectFlag == 1
                %reflect on X
                if x(i) <= -xMax  %check if out of bounds 
                  Vx(i) = Vx(i) * -1; 
                  x(i) = -xMax;
                elseif  x(i) >= xMax  %check if out of bounds
                  Vx(i) = Vx(i) * -1;
                  x(i) = xMax;
                end
else
                %transparent x
                if x(i) <= -xMax  %check if out of bounds 
                  x(i) = xMax;
                  xOld(i) = xOld(i) + 2*xMax;
                elseif  x(i) >= xMax  %check if out of bounds
                  x(i) = -xMax;
                  xOld(i) = xOld(i) - 2*xMax;
                end
end
                %reflect on Y
                if y(i) <= -yMax %check if out of bounds
                  Vy(i) = Vy(i) * -1; 
                  y(i) = -yMax;
                elseif  y(i) >= yMax  %check if out of bounds 
                  Vy(i) = Vy(i) * -1;
                  y(i) = yMax;
                end

%% Box Boundaries code

%Box 1 & 2
if BoxFlag == 1
                if (y(i) <= -yMax/4 || y(i) >= yMax/4) && x(i) >= -xMax/5 && x(i) <= xMax/5 % check if inside a bottom box
                    if y(i) <= -yMax/4 && yOld(i) >= -yMax/4 %check if electron came from above
                        Vy(i) = Vy(i) * -1;
                        y(i) = -yMax/4;
                    elseif y(i) >= yMax/4 && yOld(i) <= yMax/4 %check if electron came from below
                        Vy(i) = Vy(i) * -1;
                        y(i) = yMax/4;
                    elseif x(i) >= -xMax/5 && xOld(i) <= -xMax/5 %check if electron came from left side
                        Vx(i) = Vx(i) * -1;
                        x(i) = -xMax/5;
                    else
                        Vx(i) = Vx(i) * -1;
                        x(i) = xMax/5;
                    end
                end
end

            end


            %Get plot arrays using new - old
            xPlot = [xOld(:) x(:)];
            yPlot = [yOld(:) y(:)];
            %vOldx = Vx;
            %vOldy = Vy;
            
                        
            
            %% Calculations

            VAvg = (sqrt((abs(Vx)).^2 + (abs(Vy)).^2)); % get current average Velocity
            TAvg = mean((VAvg.^2 .* (0.26*m_0))/ (2 * kb));
            MFPcurrent = mean(VAvg) * dt / scattercount;
            TempPlot(count,:) = TAvg;  
            scatterPlot(count,:) = ScatterAvg; % store array of times
            timePlot(count,:) = [t]; % store array of times
            MFP(count,:) =  MFPcurrent; % length of paths / number of scatters

            %% Plots

            subplot(2,2,1);
            hold on
            %subplot(2,1,1),plot(x, y, 'bo', 'markers',4,'MarkerFaceColor', 'b');
            if BoxFlag == 1
            subplot(2,2,1),plot(Box1(1:5,1),Box1(1:5,2),'k');
            subplot(2,2,1),plot(Box2(1:5,1),Box2(1:5,2),'k');
            end
            if(nElecCount >= 1)
            subplot(2,2,1),plot(xPlot(1,1:2), yPlot(1,1:2),'b');
            end
            if(nElecCount >= 14)
            subplot(2,2,1),plot(xPlot(11,1:2), yPlot(11,1:2),'r');
            end
            if(nElecCount >= 24)
            subplot(2,2,1),plot(xPlot(21,1:2), yPlot(21,1:2),'g');
            end
            if(nElecCount >= 34)
            subplot(2,2,1),plot(xPlot(31,1:2), yPlot(31,1:2),'c');
            end
            if(nElecCount >= 44)
            subplot(2,2,1),plot(xPlot(41,1:2), yPlot(41,1:2),'y');
            end
            if(nElecCount >= 54)
            subplot(2,2,1),plot(xPlot(51,1:2), yPlot(51,1:2),'m');
            end

            %quiver(x,y,Vx,Vy);
            hold off
            axis(Limits);
            xlabel('x');
            ylabel('y');
            grid on
            
            subplot(2,2,2); %plot Avg Velocity
            plot(t,TAvg,'v','linewidth', 2);
            hold on
            subplot(2,2,2), plot(timePlot,TempPlot,'linewidth', 2);
            hold off
            axis(LimitsTemp);
            xlabel('Time');
            ylabel('Temperature in K');
            grid on

            subplot(2,2,4); %plot Avg Velocity
            plot(t,MFPcurrent,'v','linewidth', 2);
            hold on
            subplot(2,2,4), plot(timePlot,MFP,'linewidth', 2);
            hold off
            axis(LimitsMFP);
            xlabel('Time');
            ylabel('Mean Free Path');
            grid on
            
            subplot(2,2,3); %plot Avg Velocity
            plot(t,ScatterAvg,'v','linewidth', 2);
            hold on
            subplot(2,2,3), plot(timePlot,scatterPlot,'linewidth', 2);
            hold off
            axis(LimitsScatter);
            xlabel('Time');
            ylabel('scattering probability');
            grid on



            count = count + 1;
            pause(0.0001)

            % iterate number of electrons

            if nElecCount < nElec
                nElecCount = nElecCount+10;
            end


            ScatterAvg = scattercount/nElecCount; % get current chance to scatter
            scattercount = 0;
%     end
%     figure(2)
%     xlin = linspace(-xMax,xMax,200);
%     ylin = linspace(-yMax,yMax,100);
%     [meshx,meshy] = meshgrid(xlin,ylin);
%     Temps = (sqrt((Vx(1:nElec).^2)+(Vy(1:nElec).^2)).^2 .* 0.26 .* m_0)./(2*kb);
%     TempMap = griddata(x,y,Temps,meshx,meshy);
%     surf(meshx,meshy,TempMap)
%     title("Temperature Map")
% 
%     figure(3)
%     Exlin = linspace(0,xMax,101);
%     Eylin = linspace(0,yMax,51);
%     ExlinMesh = linspace(0,xMax,100);
%     EylinMesh = linspace(0,yMax,50);
%     [Emeshx,Emeshy] = meshgrid(ExlinMesh,EylinMesh);
%     Emap = histcounts2(y,x,Eylin,Exlin);
%     surf(Emeshx,Emeshy,Emap)
%     title("Density Map")

end



