% 1. LIMPIEZA INICIAL
clear; clc; close all;

% 2. PARÁMETROS FÍSICOS
g = 9.81;                 
v0 = 20;                  
angulo = 60 * (pi/180);   
y0 = 0;
c_aire=0.5;

% 3. RESOLVER EL FUTURO (Cálculo de posiciones y velocidades)
t_vuelo = (v0*sin(angulo) + sqrt((v0*sin(angulo))^2 + 2*g*y0)) / g;
t = linspace(0, t_vuelo, 100);

% Posiciones ideales
x = v0 * cos(angulo) * t;
y = y0 + v0 * sin(angulo) * t - 0.5 * g * t.^2; 

% Velocidades instantáneas ideales
vx = v0 * cos(angulo) * ones(size(t)); % Velocidad en X es constante
vy = v0 * sin(angulo) - g * t;         % Velocidad en Y cambia por la gravedad

% 4. CONFIGURAR EL LIENZO ESTILO "LIBRO DE TEXTO"
figure('Color', 'w', 'Position', [100, 100, 800, 450]); 
hold on; axis equal; grid off;
set(gca, 'Visible', 'off'); 
axis([-3, max(x)+3, -2, max(y)+4]); 

% --- ENTORNO ESTÁTICO ---
plot([-2, max(x)+2], [0, 0], 'k', 'LineWidth', 1.5); % Suelo
for i = -1.5:0.5:max(x)+1.5
    plot([i, i-0.3], [0, -0.4], 'k', 'LineWidth', 0.8); % Achurado
end
plot([0, 0], [0, y0], 'k', 'LineWidth', 2); % Soporte
%plot(x, y, 'k--', 'LineWidth', 1.2); % Trayectoria teórica

% --- PREPARAR OBJETOS MÓVILES (Handles) ---

% La roca
roca = plot(x(1), y(1), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8);

% El vector de velocidad (Usamos quiver para la flecha móvil)
% 'LineWidth', 2 para que sea más grueso. 'AutoScale', 'off' para controlar el tamaño real.
escala_flecha = 0.2; % Ajusta este número para que la flecha no sea gigante

flecha_v = quiver(x(1), y(1), vx(1)*escala_flecha, vy(1)*escala_flecha, 0, ...
                  'k', 'LineWidth', 2.5, 'MaxHeadSize', 0.8);

% Vector de velocidad x
flecha_x=quiver(x(1), 0, vx(1)*escala_flecha, vy(1), 0, ...
                  'k', 'LineWidth', 2.5, 'MaxHeadSize', 0.8);

% Vector de velocidad y
flecha_y=quiver(0, y(1), x(1), vy(1), 0, ...
                  'k', 'LineWidth', 2.5, 'MaxHeadSize', 0.8);

% Cota de altura
cota_altura=plot([x(1) ,x(1)] ,[0 ,y(1)] , ...
    'k' , 'LineWidth' , 2 , Marker='^');

% Label h
label_altura=text(-1,0,'$h$', ...
    'Interpreter','latex', ...
    'HorizontalAlignment', 'right', ...
    'FontSize',14, ...
    'Color','k' ...
    )

% Label theta
label_theta=text(2,0.5,'$\theta$', ...
    'Interpreter','latex', ...
    'HorizontalAlignment', 'right', ...
    'FontSize',10, ...
    'Color','k' ...
    )

% Label velocidad
label_velocidad=text(2,0.5,'$v$', ...
    'Interpreter','latex', ...
    'HorizontalAlignment', 'right', ...
    'FontSize',14, ...
    'Color','k' ...
    )

% Label velocidad x
label_vx=text(2,0,'$v_x$', ...
    'Interpreter','latex', ...
    'HorizontalAlignment', 'right', ...
    'FontSize',14, ...
    'Color','k' ...
    )

% Label velocidad y
label_vy=text(0,2,'$v_y$', ...
    'Interpreter','latex', ...
    'HorizontalAlignment', 'right', ...
    'FontSize',14, ...
    'Color','k' ...
    )

% Linea horizontal punteada
cota_distancia=plot([x(1) ,x(1)] ,[y(1) ,y(1)] , ...
    'k--' , 'LineWidth' , 1);

% Trayectoria
trayectoria=plot(x(1), y(1), 'k', 'LineWidth', 2);

% Angulo director
h_arco=plot(NaN,NaN,'k','LineWidth',2);
r=1

% --- CONFIGURACIÓN DE VIDEO ---
nombre_archivo = 'Simulacion_Tiro_Parabolico.mp4';
v = VideoWriter(nombre_archivo, 'MPEG-4'); % Formato compatible con YouTube/Social Media
v.FrameRate = 30; % 30 cuadros por segundo para buena fluidez
open(v); % "Abrimos el obturador" para empezar a recibir datos

% 5. EL BUCLE DE ANIMACIÓN
for i = 1:length(t)
    % Actualizamos la posición de la roca
    set(roca, 'XData', x(i), 'YData', y(i));
    
    % Actualizamos el vector: posición inicial (X,Y) y componentes (U,V)
    set(flecha_v, 'XData', x(i), 'YData', y(i), ...
                  'UData', vx(i)*escala_flecha, 'VData', vy(i)*escala_flecha);

    % Actualizacion de la componente x
    set(flecha_x, 'XData', x(i), 'YData', y(i), ...
                  'UData', vx(i)*escala_flecha, 'VData', 0);

    % Actualizacion de la componente y
    set(flecha_y, 'XData', x(i), 'YData', y(i), ...
                  'UData', 0,'VData', vy(i)*escala_flecha);

    % Actualizacion de la cota de altura
    set(cota_altura, 'XData',[x(1),x(1)],'YData',[0,y(i)])

    % Actualizacion del label altura
    set(label_altura,'Position',[-1,y(i)/2,0])

    % Actualizacion de la cota de distancia
    set(cota_distancia, 'XData',[x(1),x(i)],'YData',[y(i),y(i)]);

    % Actualizacion de la trayectoria
    set(trayectoria, 'XData',x(1:i),'YData',y(1:i));

    % Actualizacion del angulo
    theta_i = atan2(vy(i), vx(i));

    angulos_arco = linspace(0, theta_i, 20);

    arco_x = x(i) + r * cos(angulos_arco);
    arco_y = y(i) + r * sin(angulos_arco);
    set(h_arco, 'XData', arco_x, 'YData', arco_y);

    % Actualizacion del label theta
    set(label_theta,'Position',[x(i)+2,y(i)+vy(i)*escala_flecha/2,0])

    % Actualizacion de los label velocidad
    set(label_velocidad,'Position',[x(i)+vx(i)*escala_flecha+1,y(i)+vy(i)*escala_flecha*(6/5),0])
    set(label_vx,'Position',[x(i)+vx(i)*escala_flecha*1.6,y(i),0])
    set(label_vy,'Position',[x(i),y(i)+vy(i)*escala_flecha*(6/5),0])

    
    drawnow;

    % Al final del loop, después de drawnow:
    frame = getframe(gcf); % Captura lo que se ve en la ventana
    writeVideo(v, frame);  % Escribe ese cuadro en el video

    pause(0.02); 
end

% Después del end del bucle:
close(v); % Cerramos y guardamos el archivo
fprintf('Video guardado exitosamente como: %s\n', nombre_archivo);