function att_massas()
    clc;
    filePos = 'componentes_posicao.csv'; 
    fileMass = 'banco_de_massas.xlsx';

    if ~exist(filePos, 'file'), error('Arquivo %s não encontrado.', filePos); end

    optsP = detectImportOptions(filePos); optsP.VariableNamingRule = 'preserve';
    T_pos = readtable(filePos, optsP);
    T_pos.Properties.VariableNames = lower(T_pos.Properties.VariableNames);
    
    if ~ismember('nome', T_pos.Properties.VariableNames)
        error('Coluna "nome" não encontrada no CSV.');
    end
    nomes_projeto = lower(string(T_pos.nome)); 

    if exist(fileMass, 'file')
        optsM = detectImportOptions(fileMass); optsM.VariableNamingRule = 'preserve';
        T_mass = readtable(fileMass, optsM);
        T_mass.Properties.VariableNames = {'nome', 'massa'};
        nomes_cadastrados = lower(string(T_mass.nome));
    else
        T_mass = table({}, [], 'VariableNames', {'nome', 'massa'});
        nomes_cadastrados = [];
    end

    [~, idx_novos] = setdiff(nomes_projeto, nomes_cadastrados, 'stable');
    nomes_novos = T_pos.nome(idx_novos); 

    if isempty(nomes_novos)
        fprintf('Todos os componentes já possuem massa.\n');
        delete('*.asv');
        return;
    end

    novas_massas = zeros(length(nomes_novos), 1);
    for i = 1:length(nomes_novos)
        valido = false;
        while ~valido
            entrada = input(sprintf('Massa (g) para "%s": ', nomes_novos{i}), 's');
            valor = str2double(entrada);
            if ~isnan(valor), novas_massas(i) = valor; valido = true; end
        end
    end

    T_novos = table(nomes_novos, novas_massas, 'VariableNames', {'nome', 'massa'});
    T_final = [T_mass; T_novos];
    [~, idx_unico] = unique(lower(string(T_final.nome)), 'stable');
    T_final = T_final(idx_unico, :);
    T_final.Properties.VariableNames = {'Nome', 'Massa'};

    writetable(T_final, fileMass);
    fprintf('Banco atualizado: %s\n', fileMass);
    delete('*.asv');
end