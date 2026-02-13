function main()
    clc; close all;
    caminhoPosicao = 'componentes_posicao.csv';
    caminhoMassas  = 'banco_de_massas.xlsx'; 

    opts = detectImportOptions(caminhoPosicao); opts.VariableNamingRule = 'preserve';
    T_pos = readtable(caminhoPosicao, opts);
    T_pos.Properties.VariableNames = lower(T_pos.Properties.VariableNames);

    optsM = detectImportOptions(caminhoMassas); optsM.VariableNamingRule = 'preserve';
    T_mass = readtable(caminhoMassas, optsM);
    T_mass.Properties.VariableNames = {'nome', 'massa'}; 

    T = innerjoin(T_pos, T_mass, 'Keys', 'nome');
    if isempty(T), error('Nenhum componente correspondente encontrado.'); end

    M_total = sum(T.massa);
    T.y_mm = -T.y_mm;
    CM = sum([T.x_mm, T.y_mm, T.z_mm] .* T.massa) / M_total;

    fprintf('Massa Total: %.2f g\nCM Final:\nX: %.4f\nY: %.4f\nZ: %.4f\n', ...
        M_total, CM(1), CM(2), CM(3));

    figure('Color', 'w'); hold on; grid on; axis equal; view(3); rotate3d on;
    scatter3(T.x_mm, T.y_mm, T.z_mm, 50, 'b', 'filled', 'MarkerFaceAlpha', 0.6);
    scatter3(CM(1), CM(2), CM(3), 100, [0.5 0.5 0.5], 'filled'); 
    text(CM(1), CM(2), CM(3), '  CM', 'FontWeight', 'bold');
    scatter3(0, 0, 0, 80, 'r', 'filled'); 
    text(0, 0, 0, '  Origem', 'Color', 'r');

    xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Z (mm)');
    title('Distribuição de Massas e CM');
    set(gca, 'YDir', 'reverse');

    dcm = datacursormode(gcf);
    set(dcm, 'Enable', 'on', 'UpdateFcn', @(obj, ev) tooltipCallback(obj, ev, T));
    delete('*.asv');
end

function txt = tooltipCallback(~, event, T)
    idx = event.DataIndex;
    if idx <= height(T)
        txt = sprintf('Comp: %s\nMassa: %.2f g\nPos: [%.1f, %.1f, %.1f]', ...
            T.nome{idx}, T.massa(idx), event.Position);
    else
        txt = 'Referência (CM ou Origem)';
    end
end