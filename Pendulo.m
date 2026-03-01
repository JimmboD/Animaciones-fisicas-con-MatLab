%% 1. PARÁMETROS FÍSICOS
clear; clc; close all;
g = 9.81;
L = 4;
theta0 = pi/2;
c = 0;       % Agregamos un poco de fricción para que el video tenga fin
t_max = 10;     % Reducido a 10 segundos para mayor rapidez

%% 2. RESOLVER LA FÍSICA
f = @(t, y) [y(2); -(g/L)*sin(y(1)) - c*y(2)];
% 300 puntos para 10 segundos a 30fps exactos
t_span = linspace(0, t_max, 300); 
[t, sol] = ode45(f, t_span, [theta0; 0]); 
theta = sol(:, 1);
omega = sol(:, 2);

%% 3. CONFIGURAR EL LIENZO
fig = figure('Color', 'w', 'Position', [100, 100, 800, 600]); 
hold on; axis equal; grid off;
axis([-5 5 -5 2]);        
set(gca, 'Visible', 'off'); 

% --- ENTORNO ESTÁTICO ---
plot([-3, 3], [0.4, 0.4], 'k', 'LineWidth', 2); 
for i = -2.9:0.3:2.9
    plot([i, i+0.15], [0.4, 0.6], 'k'); 
end
plot([-0.3, 0.3, 0, -0.3], [0.4, 0.4, 0, 0.4], 'k', 'LineWidth', 1.5); 
plot(0, 0, 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 8); 

%% 4. CONFIGURAR ESTELA Y OBJETOS
N_cola = 20; 
cola_handles = gobjects(1, N_cola); 
fade_map = repmat(linspace(1, 0, N_cola)', 1, 3);

cuerda = plot([0 0], [0 0], 'k', 'LineWidth', 1.5);
masa = plot(0, 0, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 12);
escala_v = 0.1; 
flecha_vx = quiver(0, 0, 0, 0, 0, 'k', 'LineWidth', 1.8, 'MaxHeadSize', 1.5);
texto_vx = text(0, 0, '$v_x$', 'FontSize', 14, 'Color','k', 'Interpreter','latex');

% --- CONFIGURACIÓN DE VIDEO ---
nombre_archivo = 'Simulacion_Pendulo_Corta.mp4';
v = VideoWriter(nombre_archivo, 'MPEG-4');
v.FrameRate = 30;
v.Quality = 95; 
open(v);

%% 5. BUCLE DE ANIMACIÓN Y GRABACIÓN
x_prev = L * sin(theta(1));
y_prev = -L * cos(theta(1));

% Usamos un try-catch para forzar el cierre del video si algo falla
try
    for i = 2:length(t)
        % Si la ventana se cierra, salimos del bucle
        if ~ishandle(fig), break; end
        
        x = L * sin(theta(i));
        y = -L * cos(theta(i));
        
        % Lógica de la estela
        new_seg = plot([x_prev, x], [y_prev, y], 'k--', 'LineWidth', 1);
        cola_handles = [cola_handles, new_seg];
        if length(cola_handles) > N_cola
            if ishandle(cola_handles(1)), delete(cola_handles(1)); end
            cola_handles = cola_handles(2:end);
        end
        for k = 1:length(cola_handles)
            if ishandle(cola_handles(k)), set(cola_handles(k), 'Color', fade_map(k, :)); end
        end
        
        % Actualizar péndulo
        vx = L * cos(theta(i)) * omega(i);
        u = vx * escala_v;
        set(cuerda, 'XData', [0, x], 'YData', [0, y]);
        set(masa, 'XData', x, 'YData', y);
        set(flecha_vx, 'XData', x, 'YData', y, 'UData', u, 'VData', 0);
        set(texto_vx, 'Position', [x + u, y + 0.25]);
        
        x_prev = x; y_prev = y;
        
        % Captura de cuadro
        drawnow; 
        frame = getframe(fig); % Captura específicamente la figura creada
        writeVideo(v, frame);
    end
catch
    disp('Grabación interrumpida.');
end

% Cerrar el video pase lo que pase
close(v); 
fprintf('Proceso terminado. Video guardado como: %s\n', nombre_archivo);