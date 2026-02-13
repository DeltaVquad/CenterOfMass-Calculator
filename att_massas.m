function att_massas()
    clc;
    filePos = 'componentes_posicao.csv'; 
    fileMass = 'banco_de_massas.xlsx';
    rho_PLA = 0.00124; 

    if ~exist(filePos, 'file'), error('Arquivo %s não encontrado.', filePos); end

    optsP = detectImportOptions(filePos); optsP.VariableNamingRule = 'preserve';
    T_pos = readtable(filePos, optsP);
    T_pos.Properties.VariableNames = lower(T_pos.Properties.VariableNames);

    if exist(fileMass, 'file')
        optsM = detectImportOptions(fileMass); optsM.VariableNamingRule = 'preserve';
        T_mass = readtable(fileMass, optsM);
        T_mass.Properties.VariableNames = {'nome', 'massa'};
        nomes_cadastrados = lower(string(T_mass.nome));
    else
        T_mass = table({}, [], 'VariableNames', {'nome', 'massa'});
        nomes_cadastrados = [];
    end

    [~, idx_novos] = setdiff(lower(string(T_pos.nome)), nomes_cadastrados, 'stable');
    nomes_novos = T_pos.nome(idx_novos); 

    if isempty(nomes_novos), return; end

    novas_massas = zeros(length(nomes_novos), 1);
    for i = 1:length(nomes_novos)
        valido = false;
        while ~valido
            entrada = input(sprintf('Massa para "%s": ', nomes_novos{i}), 's');
            if strcmpi(entrada, 'PLA')
                idx = find(strcmpi(string(T_pos.nome), string(nomes_novos{i})), 1);
                if ~isempty(idx) && ismember('vol_mm3', T_pos.Properties.VariableNames)
                    novas_massas(i) = T_pos.vol_mm3(idx) * rho_PLA;
                    fprintf('   -> %.2f g\n', novas_massas(i));
                    valido = true;
                end
            else
                val = str2double(entrada);
                if ~isnan(val), novas_massas(i) = val; valido = true; end
            end
        end
    end

    T_final = [T_mass; table(nomes_novos, novas_massas, 'VariableNames', {'nome', 'massa'})];
    writetable(T_final, fileMass);
    if exist('*.asv', 'file'), delete('*.asv'); end
end