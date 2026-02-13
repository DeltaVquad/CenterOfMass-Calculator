# CM-Calc: Calculadora de Centro de Massa (Fusion 360 + MATLAB)

Ferramenta para calcular e visualizar o Centro de Massa (CM) de montagens complexas projetadas no Autodesk Fusion 360. O sistema utiliza um script em Python para extrair a geometria e um ambiente MATLAB para gerenciar densidades e plotar o resultado final.

## 🚀 Funcionalidades

* **Exportação Automática:** Script para Fusion 360 que exporta coordenadas e volumes de componentes selecionados.
* **Banco de Dados de Massas:** Script MATLAB (`att_massas.m`) que cruza os dados exportados com uma planilha Excel (`banco_de_massas.xlsx`).
* **Cálculo Inteligente para PLA:** Se o componente for impresso em 3D (PLA), o sistema calcula a massa automaticamente baseada no volume e na densidade configurada.
* **Visualização 3D:** O `main.m` gera um gráfico 3D mostrando a distribuição dos componentes e a posição exata do CM final.

## 🛠️ Estrutura do Projeto

* **`CM-Calc/`**: Pasta raiz do projeto MATLAB.
    * `att_massas.m`: Gerencia e atualiza o banco de dados de massas.
    * `main.m`: Script principal que calcula o CM e gera o gráfico.
    * `banco_de_massas.xlsx`: (Gerado/Lido) Planilha que armazena as massas conhecidas.
    * `componentes_posicao.csv`: (Gerado pelo Fusion) Arquivo intermediário com posições e volumes.
* **`CM-Calc/CM2CSV/`**: Pasta do Script para o Fusion 360.
    * `CM2CSV.py`: O código Python que roda dentro do Fusion.
    * `CM2CSV.manifest`: Arquivo de metadados do script.

## 📋 Pré-requisitos

* Autodesk Fusion 360
* MATLAB (Recomendado R2020b ou superior)
* Microsoft Excel (para leitura/escrita do `.xlsx`)

## ⚙️ Instalação

1.  Baixe ou clone este repositório em seu computador.
2.  Abra o seu projeto no **Fusion 360**.
3.  Pressione `Shift + S` para abrir a janela **Scripts and Add-ins**.
5.  Clique no ícone **+** na parte superior.
6.  Navegue até a pasta deste repositório e selecione a subpasta **`CM2CSV`**.
7.  Clique em **Select Folder**.
8.  O script `CM2CSV` aparecerá na sua lista de "My Scripts" pronto para uso.

## 📖 Como Usar

### Passo 1: No Fusion 360
1.  Abra sua montagem.
2.  **Selecione** os componentes ou corpos que deseja incluir no cálculo (na árvore de projeto ou na viewport).
3.  Vá em **Scripts and Add-ins** (`Shift + S`), selecione `CM2CSV` na lista e clique em **Run**.
4.  O arquivo `componentes_posicao.csv` será gerado ou atualizado automaticamente dentro da pasta do projeto (`CM-Calc/`).

### Passo 2: No MATLAB (Atualizar Massas)
1.  Abra o MATLAB e navegue até a pasta `CM-Calc`.
2.  Execute o script `att_massas.m`.
3.  O script verificará se há novos componentes no CSV que ainda não têm massa cadastrada no Excel.
4.  Para cada item novo, o terminal pedirá a massa:
    * Digite o valor numérico (em gramas).
    * OU digite **`PLA`** para que o script calcule automaticamente a massa usando o volume exportado e a densidade do PLA (padrão: `0.00124 g/mm³`).

### Passo 3: No MATLAB (Visualizar CM)
1.  Execute o script `main.m`.
2.  O console exibirá a **Massa Total** e as coordenadas **X, Y, Z** do Centro de Massa.
3.  Uma figura 3D será aberta mostrando a nuvem de pontos dos componentes (azul) e o CM final (cinza).

## 📝 Notas Técnicas
* **Densidade do PLA:** Definida como `0.00124` no arquivo `att_massas.m`. Altere este valor se estiver usando outro material.
* **Sistema de Coordenadas:** O script exporta as coordenadas do Fusion relativas à origem da montagem.