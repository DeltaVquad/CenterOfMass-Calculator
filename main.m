function main()
    clc;

    %% ===== Configuração de Densidades (g/mm^3) =====
    densidades = containers.Map();
    densidades('PLA')  = 0.00124; % 1.24 g/cm3

    %% ===== Ler CSV do Fusion =====
    pastaDesktop = fullfile(getenv('USERPROFILE'), 'Desktop');
    arquivoCSV = fullfile(pastaDesktop, 'componentes_posicao.csv');
    
    if ~exist(arquivoCSV, 'file')
        disp('Erro: Arquivo de posições (CSV) não encontrado.');
        return;
    end

    opts = detectImportOptions(arquivoCSV);
    opts.VariableNamingRule = 'preserve'; 
    T = readtable(arquivoCSV, opts);

    % Padroniza nomes das colunas
    T.Properties.VariableNames = lower(T.Properties.VariableNames);

    % Verifica coluna de volume
    temVolume = ismember('vol_mm3', T.Properties.VariableNames);
    if ~temVolume
        warning('A coluna "vol_mm3" não foi encontrada. O cálculo por material não funcionará.');
    end

    % --- Remove linhas vazias ---
    if iscell(T.nome)
        idxVazios = cellfun(@isempty, T.nome);
    else
        idxVazios = (T.nome == "") | ismissing(T.nome);
    end

    if any(idxVazios)
        T(idxVazios, :) = [];
    end

    nomes = T.nome;
    x = T.x_mm;
    y = T.y_mm; % Ajuste de eixos (Y global é Z no plot)
    z = T.z_mm;

    if temVolume
        volumes = T.vol_mm3;
    else
        volumes = zeros(height(T), 1);
    end

    n = height(T);

    %% ===== BANCO DE MASSAS (EXCEL) =====
    % Usamos .xlsx para facilitar a edição no Excel.
    % Se preferir CSV mesmo assim, mude a extensão para .csv
    arquivoMassas = 'banco_de_massas.xlsx'; 
    
    massaMap = containers.Map();

    % --- Carregar Massas Existentes ---
    if exist(arquivoMassas, 'file')
        try
            % Lê a tabela do Excel/CSV
            optsM = detectImportOptions(arquivoMassas);
            optsM.VariableNamingRule = 'preserve';
            T_massas = readtable(arquivoMassas, optsM);
            
            % Verifica se as colunas esperadas existem
            colunasMassas = lower(T_massas.Properties.VariableNames);
            if ismember('nome', colunasMassas) && ismember('massa', colunasMassas)
                % Popula o mapa com os dados do arquivo
                for k = 1:height(T_massas)
                    % Garante que o nome seja string/char e massa double
                    nKey = char(string(T_massas.Nome{k})); 
                    mVal = double(T_massas.Massa(k));
                    massaMap(nKey) = mVal;
                end
                fprintf('Carregadas %d massas do arquivo "%s".\n', height(T_massas), arquivoMassas);
            end
        catch ME
            wwarning(ME.identifier, 'Não foi possível ler o arquivo de massas: %s', ME.message);
        end
    else
        fprintf('Arquivo "%s" não encontrado. Será criado um novo.\n', arquivoMassas);
    end

    %% ===== Perguntar massas que faltam =====
    alterouMassas = false;
    
    for i = 1:n
        nome = nomes{i};
        % Se não existe no Map (ou seja, não estava no Excel), pergunta
        if ~isKey(massaMap, nome)
            fprintf('\n--- Novo componente encontrado: "%s" ---\n', nome);
            novaMassa = solicitarMassa(nome, volumes(i), densidades, temVolume);
            massaMap(nome) = novaMassa;
            alterouMassas = true;
        end
    end

    %% ===== Editar massas (Opcional) =====
    resp = input('\nDeseja editar alguma massa manualmente agora? (s/n): ', 's');

    while lower(resp) == 's'
        fprintf('\nComponentes carregados:\n');
        for i = 1:n
            if isKey(massaMap, nomes{i})
                fprintf('  %d - %s (%.1f g)\n', i, nomes{i}, massaMap(nomes{i}));
            else
                fprintf('  %d - %s (SEM MASSA)\n', i, nomes{i});
            end
        end

        idxInput = input('Digite o número do componente para editar: ', 's');
        idx = str2double(idxInput);

        if ~isnan(idx) && idx >= 1 && idx <= n
            nome = nomes{idx};
            fprintf('Massa atual de "%s": %.1f g\n', nome, massaMap(nome));
            massaMap(nome) = solicitarMassa(nome, volumes(idx), densidades, temVolume);
            alterouMassas = true;
        else
            disp('Índice inválido.');
        end

        resp = input('Deseja editar outro? (s/n): ', 's');
    end

    %% ===== Salvar Massas Atualizadas no Arquivo =====
    if alterouMassas || ~exist(arquivoMassas, 'file')
        % Converte o Map para Tabela
        chaves = keys(massaMap);
        valores = values(massaMap);
        
        % Prepara vetores coluna
        colNomes = chaves(:);
        colMassas = cell2mat(valores(:));
        
        T_export = table(colNomes, colMassas, 'VariableNames', {'Nome', 'Massa'});
        
        try
            writetable(T_export, arquivoMassas);
            fprintf('\nBanco de massas atualizado e salvo em: %s\n', arquivoMassas);
        catch
            fprintf('\n[ERRO] Não foi possível salvar "%s".\n', arquivoMassas);
            fprintf('Verifique se o arquivo está ABERTO no Excel e feche-o.\n');
            input('Pressione Enter após fechar o arquivo para tentar salvar novamente...');
            try
                writetable(T_export, arquivoMassas);
                fprintf('Salvo com sucesso!\n');
            catch
                fprintf('Falha ao salvar. Os dados novos serão perdidos ao fechar.\n');
            end
        end
    end

    %% ===== Construir vetor de massas final =====
    m = zeros(n,1);
    for i = 1:n
        if isKey(massaMap, nomes{i})
            m(i) = massaMap(nomes{i});
        else
            m(i) = 0; % Segurança
        end
    end

    %% ===== Calcular CM =====
    CM_xyz = CM(x, y, z, m, nomes);

    fprintf('\nCentro de Massa Final:\n');
    fprintf('X = %.4f\n', CM_xyz(1));
    fprintf('Y = %.4f\n', -CM_xyz(2));
    fprintf('Z = %.4f\n', CM_xyz(3));
end

%% ===== Função Auxiliar para Input Inteligente =====
function massa = solicitarMassa(nomeComp, volumeComp, mapDensidades, temVolume)
    valido = false;
    while ~valido
        if temVolume && volumeComp > 0
            prompt = sprintf('Digite a massa (g) OU material (PLA, ABS...) para "%s": ', nomeComp);
        else
            prompt = sprintf('Digite a massa (g) para "%s": ', nomeComp);
        end
        
        entrada = input(prompt, 's');
        
        % Tenta converter para número
        numVal = str2double(entrada);
        
        if ~isnan(numVal)
            massa = numVal;
            valido = true;
        else
            % É um texto (possível material)
            material = upper(entrada); 
            
            if isKey(mapDensidades, material)
                if temVolume
                    densidade = mapDensidades(material);
                    massa = volumeComp * densidade;
                    fprintf('   -> Mat: %s | Vol: %.1f | Dens: %.5f | Massa: %.2f g\n', ...
                        material, volumeComp, densidade, massa);
                    valido = true;
                else
                    fprintf('   Erro: Sem volume para calcular %s.\n', material);
                end
            else
                fprintf('   Entrada inválida. Digite número ou material (PLA, ABS, ALUMINIO...)\n');
            end
        end
    end
end