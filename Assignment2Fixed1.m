%% Assignment 2 Fixed
%  Konrad Socha 101037642


L = 120;
W = 80;

F = zeros(L*W,1);
G = sparse(L*W, L*W);

for i = 1:1:L
    for j = 1:1:W
        N = (i-1) * W + j;
        NXM = (i-2) * W + j;
        NXP = i * W + j;
        NYM = (i-1) * W + j-1;
        NYP = (i-1) * W + j+1;
        if i == 1 %     LEFT
        F(N,1) = 1;
        G(N,N) = 1;
        elseif i == L % RIGHT
        F(N,1) = 1;
        G(N,N) = 1;
        elseif j == 1 % BOTTOM
        F(N,1) = 0;
        G(N,N) = 1;
        elseif j == W % TOP
        F(N,1) = 0;
        G(N,N) = 1;
        else %          MID
        G(N,N)   = -4;
        G(N,NXM) = 1;
        G(N,NXP) = 1;
        G(N,NYM) = 1;
        G(N,NYP) = 1;
        end

    end

end


%Mesh Solution
VMatrix = reshape(G\F , [W,L]);

figure(1);
spy(G);
title("G Matrix") ;
figure(2);
surf(VMatrix')
title('Mesh Solution')
view(90,0);
xlabel("Distance (m)")
ylabel("Distance (m)")
zlabel("Voltage (V)")

x = linspace(-W/2, W/2, L); 
y = linspace(0, L, W);
Vana = zeros(W, L);
[X,Y] = meshgrid(x,y);

for n = 1:2:99 
    Vana = Vana +  1/n * cosh((n*pi*X)/L) / cosh((n*pi*W/2)/L).*...
        sin((n*pi*Y)/L) ;
end

figure(3);
VanaSurf = 4/pi * Vana;
surf(VanaSurf')
title('Analytical Solution')
view(90,0);
xlabel("Distance (m)")
ylabel("Distance (m)")
zlabel("Voltage (V)")
