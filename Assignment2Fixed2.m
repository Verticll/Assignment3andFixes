%% Assignment 2 Fixed
%  Konrad Socha 101037642

L = 120;
W = 80;

F = zeros(L*W,1);
G = sparse(L*W, L*W);
sigma = 0.01;
Box = 30;
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
            F(N,1) = 1;
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
CurrentX = ConMatrix' .* Ex;
CurrentY = ConMatrix' .* Ey;

% figure(1);
% spy(G);
% title("G Matrix") ;
figure(1);
surf(VMatrix')
title('Voltage') ;
xlabel("Distance (m)")
ylabel("Distance (m)")
zlabel("Voltage (V)")

figure(2)
surf(ConMatrix);
title('Conductivity') ;
xlabel("Distance (m)")
ylabel("Distance (m)")
zlabel("Conductivity (ohm/m)")

figure(3);
quiver(Ex,Ey);
title('E field') ;
xlabel("Distance (m)")
ylabel("Distance (m)")
zlabel("E field")

figure(4);
quiver(CurrentX,CurrentY);
title('Curent') ;
xlabel("Distance (m)")
ylabel("Distance (m)")
zlabel("Current (A)")

