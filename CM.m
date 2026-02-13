function CM_out = CM(x, y, z, m, nomes)
% CM
% Calcula e plota o centro de massa 3D
% Mostra recomendações para mover o CG para a origem

    % ===== Verificações =====
    if length(x) ~= length(y) || length(x) ~= length(z) || ...
       length(x) ~= length(m) || length(x) ~= length(nomes)
        error('x, y, z, m e nomes devem ter o mesmo tamanho');
    end

    % ===== Centro de Massa =====
    M = sum(m);

    x_cm = sum(m .* x) / M;
    y_cm = sum(m .* y) / M;
    z_cm = sum(m .* z) / M;

    CM_out = [x_cm, y_cm, z_cm];

    % ===== Recomendações de Ajuste (CG -> Origem) =====
    fprintf('\n========== Recomendações de Ajuste ==========\n');
    
    % Ajuste em X (Assumindo +X Frente, precisamos mover para Trás)
    if x_cm > 0
        fprintf('Mover o CG %.3f para trás\n', abs(x_cm));
    elseif x_cm < 0
        fprintf('Mover o CG %.3f para frente\n', abs(x_cm));
    else
        fprintf('CG alinhado em X\n');
    end

    % Ajuste em Y (Assumindo que se Y está positivo, movemos para o oposto)
    % Nota: Ajuste a direção "Esquerda/Direita" conforme seu referencial.
    % Aqui assume-se que para corrigir um Y negativo, move-se para a Esquerda (+).
    if y_cm > 0
        fprintf('Mover o CG %.3f para a direita\n', abs(y_cm)); 
    elseif y_cm < 0
        fprintf('Mover o CG %.3f para a esquerda\n', abs(y_cm));
    else
        fprintf('CG alinhado em Y\n');
    end

    % Ajuste em Z (Assumindo +Z Cima, precisamos mover para Baixo)
    if z_cm > 0
        fprintf('Mover o CG %.3f para baixo\n', abs(z_cm));
    elseif z_cm < 0
        fprintf('Mover o CG %.3f para cima\n', abs(z_cm));
    else
        fprintf('CG alinhado em Z\n');
    end
    fprintf('=============================================\n\n');

    % ===== Plot =====
    figure
    hold on
    grid on
    axis equal
    view(3)
    rotate3d on

    % Pontos
    scatter3(x, y, z, 60, 'filled')

    % Centro de massa (cinza)
    scatter3(x_cm, y_cm, z_cm, 120, [0.5 0.5 0.5], 'filled')
    text(x_cm, y_cm, z_cm, '  CM', 'FontWeight','bold')

    % Origem (vermelho)
    scatter3(0, 0, 0, 120, 'r', 'filled')
    text(0, 0, 0, '  (0,0,0)', 'Color','r')

    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    title('Centro de Massa 3D')

    % ===== Data Cursor (clique nos pontos) =====
    dcm = datacursormode(gcf);
    set(dcm, 'Enable', 'on');
    set(dcm, 'UpdateFcn', @(obj,event) ...
        sprintf('%s\n%.2f g', nomes{event.DataIndex}, m(event.DataIndex)));

    hold off
end