
# Análise da Eficiência dos Gastos Públicos com Segurança nas Instituições Estaduais Brasileiras

Este projeto foi desenvolvido como meu Trabalho de Conclusão do Curso em 2019 para a minha obtenção do título de Bacharel em Ciências Econômicas pela Universidade Federal do Ceará, campus de Sobral. A pesquisa tem como foco a análise da eficiência dos gastos públicos em segurança nas instituições estaduais brasileiras, utilizando a Análise Envoltória de Dados (DEA) em Dois Estágios.

## Sumário

1. [Introdução](#introdução)
2. [Objetivo](#objetivo)
3. [Metodologia](#metodologia)
4. [Dados Utilizados](#dados-utilizados)
5. [Passo a Passo no RStudio](#passo-a-passo-no-rstudio)
6. [Exemplos de Resultados e Gráficos](#exemplos-de-resultados-e-gráficos)

## Introdução

A eficiência na alocação dos recursos públicos é um tema central no debate sobre a administração pública, especialmente em países em desenvolvimento como o Brasil. O aumento da criminalidade e a necessidade de otimizar recursos financeiros tornam a análise da eficiência dos gastos públicos em segurança um tema relevante e urgente. Este projeto oferece uma análise abrangente da eficiência dos estados brasileiros em seus gastos com segurança pública, usando a Análise Envoltória de Dados (DEA) em Dois Estágios. Este método permite não apenas identificar os estados mais eficientes, mas também investigar o impacto de variáveis como área geográfica, taxa de analfabetismo, e taxa de desemprego na eficiência.

## Objetivo

O objetivo deste projeto é analisar a eficiência técnica dos estados brasileiros em relação aos gastos com segurança pública no ano de 2017, utilizando a metodologia de Análise Envoltória de Dados (DEA). O projeto também visa verificar se variáveis não-discricionárias afetam o nível de eficiência, fornecendo insights valiosos para gestores públicos e formuladores de políticas.

## Metodologia

A metodologia usada no projeto é a Análise Envoltória de Dados (DEA) em Dois Estágios, conforme desenvolvido por Simar e Wilson (2007). O DEA é uma técnica não-paramétrica que mede a eficiência relativa de unidades de tomada de decisão (DMUs) — neste caso, os estados brasileiros.

## Dados Utilizados

- **Fonte dos Dados**: 12º Anuário Brasileiro de Segurança Pública (2018) e Instituto Brasileiro de Geografia e Estatística (IBGE).
- **Variáveis**:
  - **Input**: Despesa per capita realizada com a Função Segurança Pública (em reais constantes).
  - **Outputs**: Inverso das taxas de criminalidade (Mortes Violentas Intencionais,  Estupro, Tráfico de Entorpecentes e Roubo Total) por 100 mil habitantes e Inverso da taxa de Roubo e Furto de Veiculo por r 100 mil veículos.
  - **Variáveis Não-Discricionárias**: Área geográfica (Km²), densidade populacional (habitantes por km²), taxa de analfabetismo da população maior de 15 anos (% da população), taxa de desocupação (% da populaçã0) e renda domiciliar mensal (per capita)

Dados utilizados no Primeiro Estágio:

 **Quadro 1: Descrição das Variáveis Usadas no 1º Estágio**

| Variáveis | Descrição                                                                                   |
|-----------|---------------------------------------------------------------------------------------------|
| **Input** |                                                                                             |
| x         | Despesa per capita realizada com a Função Segurança Pública em 2017 - Em reais constantes.  |
| **Outputs**|                                                                                            |
| y₁        | Inverso da taxa² de Mortes Violentas Intencionais (MVI).                                    |
| y₂        | Inverso da taxa³ de roubo e furto de veículo.                                               |
| y₃        | Inverso da taxa² de estupro.                                                                |
| y₄        | Inverso da taxa² de tráfico de entorpecentes.                                               |
| y₅        | Inverso da taxa² de Roubo (total).                                                          |

Fonte: Elaboração própria

Dados utilizados no Segundo Estágio:

 **Quadro 2: Descrição das Variáveis Não-Discricionárias Usadas no 2º Estágio**

| Variáveis  | Descrição                                                                                           |
|------------|-----------------------------------------------------------------------------------------------------|
| 𝑧₁         | Proporção de jovens negros na faixa etária de 15-29 anos de idade - % da população                  |
| log(𝑧₂)    | Área Geográfica - km²                                                                               |
| 𝑧₃         | Densidade Populacional – habitantes por km²                                                         |
| 𝑧₄         | Taxa de Analfabetismo da população com 15 anos ou mais - % da população                             |
| 𝑧₅         | Média da Taxa de Desocupação - % da população                                                       |
| log(𝑧₆)    | Rendimento Mensal Domiciliar – per capita                                                           |

Fonte: Elaboração própria

### Etapas da Análise

1. **Análise Envoltória de Dados (DEA)**: Calcula a eficiência técnica dos estados usando os modelos DEA-CCR (Constant Returns to Scale) e DEA-BCC (Variable Returns to Scale).

2. **Regressão Truncada com Bootstrap**: Introduz variáveis não-discricionárias para modelar seu impacto na eficiência usando regressão truncada, complementada pela técnica bootstrap para obter intervalos de confiança mais robustos.

## Passo a Passo no RStudio

### 1. Carregamento dos Dados

Os dados são carregados a partir do arquivo `DADOS.xlsx` usando o pacote `readxl`. Esta etapa garante que todos os dados necessários para a análise estejam disponíveis no ambiente R.

```r
# Instalar os pacotes necessários:
install.packages("Benchmarking")
install.packages("frontier")
install.packages("readxl")
install.packages("truncnorm")
install.packages("AER")

# Ativando os pacotes:
library(Benchmarking)
library(frontier)
library(readxl)
library(truncnorm)
library(AER))

# Carregar os dados
dados <- read_excel("DADOS.xlsx")

# Ver os dados:
View(dados)
```

### 2. Limpeza e Preparação dos Dados

A limpeza de dados é essencial para garantir a precisão da análise. Aqui, todos os dados foram organizados e deixados no arquivo "DAODS.xlsx"


### 3. Implementação da Análise Envoltória de Dados (DEA)

 Os modelos DEA-CCR e DEA-BCC são aplicados para obter diferentes perspectivas da eficiência.

```r

# Modelo DEA-CCR (Constant Returns to Scale)
dea_ccr <- dea(X = dados$gastos_per_capita, Y = dados[,c("inverso_taxa_MVI", "inverso_taxa_roubo_furto_veiculo")], RTS = "crs")

# Modelo DEA-BCC (Variable Returns to Scale)
dea_bcc <- dea(X = dados$gastos_per_capita, Y = dados[,c("inverso_taxa_MVI", "inverso_taxa_roubo_furto_veiculo")], RTS = "vrs")

# Exibir resultados
summary(dea_ccr)
summary(dea_bcc)
```

### 4. Análise dos Resultados de Eficiência

A partir dos resultados obtidos com o DEA, calculamos o percentual de redução necessário nos gastos para que os estados ineficientes alcancem a eficiência máxima.

```r
# Percentual de redução de gastos para estados ineficientes
ineficiencia <- 1 - efficiency(dea_ccr)
reducoes <- ineficiencia * 100  # Converte para percentual

# Visualização dos resultados
barplot(reducoes, main = "Redução Necessária de Gastos por Estado", xlab = "Estados", ylab = "Percentual de Redução (%)")
```

### 5. Inclusão de Variáveis Não-Discricionárias: Regressão Truncada com Bootstrap

Realizamos uma regressão truncada para avaliar o impacto de variáveis não-discricionárias na eficiência. Utilizamos o pacote `truncreg` e aplicamos a técnica bootstrap para robustez dos resultados.

```r
library(truncreg)

# Regressão truncada com variáveis não-discricionárias
regressao <- truncreg(1 / efficiency(dea_ccr) ~ dados$area_geografica + dados$taxa_analfabetismo + dados$taxa_desemprego, data = dados)

# Estimativa Bootstrap
library(boot)

# Função para o bootstrap
bootstrap_function <- function(data, indices) {
  d <- data[indices, ]  # Amostra de dados
  fit <- truncreg(1 / efficiency(dea_ccr) ~ area_geografica + taxa_analfabetismo + taxa_desemprego, data = d)
  return(coef(fit))
}

# Executar o bootstrap
results <- boot(data = dados, statistic = bootstrap_function, R = 5000)
print(results)
```

### 6. Visualização e Interpretação dos Resultados

Utilizamos o `ggplot2` para criar gráficos que ilustram os resultados da regressão e a distribuição dos escores de eficiência.

```r
library(ggplot2)

# Gráfico dos resultados da regressão
ggplot(dados, aes(x = taxa_analfabetismo, y = efficiency(dea_ccr))) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(title = "Impacto da Taxa de Analfabetismo na Eficiência", x = "Taxa de Analfabetismo (%)", y = "Eficiência")
```

## Exemplos de Resultados e Gráficos

### Resultados de Eficiência Técnica

Os resultados mostram que apenas cinco estados (Paraíba, Maranhão, Rio Grande do Norte, Santa Catarina e São Paulo) atingiram a eficiência técnica máxima. Estados ineficientes, como o Rio de Janeiro, precisariam reduzir seus gastos com segurança em até 80% para atingir a fronteira de eficiência.

### Impacto das Variáveis Não-Discricionárias

Os gráficos gerados mostram que a área geográfica tem um impacto positivo na eficiência, enquanto a taxa de desemprego está associada à ineficiência. Estes insights são valiosos para formuladores de políticas que buscam alocar recursos de maneira mais eficaz.

   ```

## Referências

- Simar, L., & Wilson, P. W. (2007). "Estimation and inference in two-stage,
