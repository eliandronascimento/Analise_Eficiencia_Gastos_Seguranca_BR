
# Análise da Eficiência dos Gastos Públicos com Segurança nas Instituições Estaduais Brasileiras

Este projeto foi desenvolvido como meu Trabalho de Conclusão do Curso em 2019 para a minha obtenção do título de Bacharel em Ciências Econômicas pela Universidade Federal do Ceará, campus de Sobral. A pesquisa tem como foco a análise da eficiência dos gastos públicos em segurança nas instituições estaduais brasileiras, utilizando a Análise Envoltória de Dados (DEA) em Dois Estágios.

## Sumário

1. [Introdução](#introdução)
2. [Objetivo](#objetivo)
3. [Metodologia](#metodologia)
4. [Dados Utilizados](#dados-utilizados)
5. [Passo a Passo no RStudio](#passo-a-passo-no-rstudio)
6. [Análise dos Resultados](#análise-dos-resultados)

## 1. Introdução

A eficiência na alocação dos recursos públicos é um tema central no debate sobre a administração pública, especialmente em países em desenvolvimento como o Brasil. O aumento da criminalidade e a necessidade de otimizar recursos financeiros tornam a análise da eficiência dos gastos públicos em segurança um tema relevante e urgente. Este projeto oferece uma análise abrangente da eficiência dos estados brasileiros em seus gastos com segurança pública, usando a Análise Envoltória de Dados (DEA) em Dois Estágios. Este método permite não apenas identificar os estados mais eficientes, mas também investigar o impacto de variáveis como área geográfica, taxa de analfabetismo, e taxa de desemprego na eficiência.

## 2. Objetivo

O objetivo deste projeto é analisar a eficiência técnica dos estados brasileiros em relação aos gastos com segurança pública no ano de 2017, utilizando a metodologia de Análise Envoltória de Dados (DEA). O projeto também visa verificar se variáveis não-discricionárias afetam o nível de eficiência, fornecendo insights valiosos para gestores públicos e formuladores de políticas.

## 3. Metodologia

A metodologia usada no projeto é a Análise Envoltória de Dados (DEA) em Dois Estágios, conforme desenvolvido por Simar e Wilson (2007). O DEA é uma técnica não-paramétrica que mede a eficiência relativa de unidades de tomada de decisão (DMUs) — neste caso, os estados brasileiros.

## 4. Dados Utilizados

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

## 5. Passo a Passo no RStudio

### 1. Carregamento dos Dados

Os dados são carregados a partir do arquivo `DADOS.xlsx` usando o pacote `readxl`. Esta etapa garante que todos os dados necessários para a análise estejam disponíveis no ambiente R.P ara realizar a análise, é necessário instalar os pacotes R que serão utilizados ao longo do projeto. Isso pode ser feito com os seguintes comandos:

```r
# Instalação dos Pacotes Necessários:
install.packages("Benchmarking")
install.packages("frontier")
install.packages("readxl")
install.packages("truncnorm")
install.packages("AER")

# Ativação dos Pacotes:
library(Benchmarking)
library(frontier)
library(readxl)
library(truncnorm)
library(AER))

# Importação da Base de Dados
dados <- read_excel("DADOS.xlsx")

# Ver os dados:
View(dados)
```

Fixar a Base de Dados

Fixamos a base de dados no ambiente de trabalho para facilitar a manipulação das variáveis:

```{r}
attach(DADOS)
```

Modelo DEA de Dois Estágios

1° Estágio: Análise Envoltória de Dados (DEA)

Neste estágio, calculamos o inverso das taxas de criminalidade (pois desejamos reduzi-las) e definimos as variáveis de insumo e produto.

Cálculo dos Inversos das Taxas de Criminalidade:
```{r}
DADOS$ay1=1/(DADOS$y1)
DADOS$ay2=1/(DADOS$y2)
DADOS$ay3=1/(DADOS$y3)
DADOS$ay4=1/(DADOS$y4)
DADOS$ay5=1/(DADOS$y5)

#Fixar a base de dados atualizada
attach(DADOS)
```
Definição de Insumos e Produtos

Aqui, agrupamos as variáveis de insumo e produto:
```{r}
produtos<-cbind(ay1,ay2,ay3,ay4,ay5)
insumos<- cbind(x)

```
**1) CALCULANDO O DEA**

DEA-CCR ORIENTADO AOS INSUMOS: calcula a eficiência técnica orientada a insumos com a hipótese de retornos constantes de escala (“CRS”) e amazenar os dados obtidos no CCR:

```{r}
CCR <- dea(insumos,produtos, RTS="crs", ORIENTATION = "in", SLACK=TRUE)

```

Mostrar Eficiências Obtidas no Modelo DEA-CCR:
```{r}
eff(CCR)
```
Análise Adicional do DEA-CCR:
```{r}
CCR$slack
peers(CCR)
lambda(CCR)
```

DEA-BCC ORIENTADO AOS INSUMOS: calcula a eficiência técnica orientada a insumos  (“in”) com a hipótese de retornos variáveis de escala (“vrs”) e amazena os dados obtidos no objeto BCC: :

```{r}
BCC <-dea(insumos,produtos, RTS="vrs", ORIENTATION = "in", SLACK=TRUE)
```

Mostrar Eficiências do Modelo DEA-BCC: 
```{r}
eff(BCC)
```
Análise Adicional do DEA-BCC:
```{r}
BCC$slack
peers(BCC)
lambda(BCC)
```

Cálculo das Eficiências de Escala:
```{r}
Escala <- eff(CCR)/eff(BCC)
Escala
```

Resultados Finais: Tabela com DEA-BCC, DEA-CCR e Eficiência de Escala

Mostrar tabela com os resultados de DEA-BBC, DEA-CCR e Escala:
```{r}
cbind(eff(CCR), eff(BCC),Escala)
```

Ajuste de Variáveis para o 2º Estágio

Calcula os logarítimos das variáveis z2(Área Geografica - km²) e z6( Renda Domiciliar média - Mensal:
```{r}
DADOS$logz2=log(DADOS$z2)
DADOS$logz6=log(DADOS$z6)
```

2° ESTÁGIO: Regressão Tobit para Análise das Variáveis Ambientais

Adição dos Escores de Eficiência DEA-BCC

Os escores de eficiência do DEA-BCC são adicionados à base de dados:
```{r}
DADOS$theta<-eff(BCC)
```

**2)RETIRAR DMU’s EFICIENTES NO PASSO 1**

Removemos as DMUs que foram eficientes no primeiro estágio para focar na análise das DMUs ineficientes:

```{r}
DADOS<-subset(DADOS,theta!=1)

```

**3) OBTÉM O INVERSO DOS ESCORES**

Calcula o inverso dos escores de eficiência:
```{r}
DADOS$eta=1/DADOS$theta
```

**4) MODELO TOBIT**

Utiliza o modelo Tobit (ou outro modelo equivalente) para regredir os escores de eficiência obtidos contra as variáveis ambientais, mas utilizando somente os registros das DMUs não eficientes, de acordo com a seguinte equação: , onde é o vetor de variáveis ambientais associado a DMU i, é o vetor de coeficientes a ser estimado e é o erro aleatório também associado a DMU i. Obtenha estimativas para , e para o desvio padrão de ;

```{r}

etobit<-tobit(eta~z1+logz2+z3+z4+z5+logz6, left=1, right=Inf,
data=DADOS)
DADOS$e<-residuals(etobit)
s_e<-sqrt(var(DADOS$e))
DADOS$predito<-fitted(etobit)
summary(etobit)


```
**5) GERAÇÃO DE RESÍDUOS ARTIFICIAIS**

Produza resíduos artificiais gerados a partir de uma distribuição normal truncada, com truncamento à esquerda8 em e com desvio padrão igual a , que foi estimado no passo 4:
```{r}
library(truncnorm)
DADOS$e_artif<-rtruncnorm(1, a=1-DADOS$predito, b=Inf, mean = 0, sd = s_e)
```

**6) CÁLCULO DA VARIÁVEL ESTIMADA**

Computa a variável segundo a equação, onde é o estimador para o parâmetro:
```{r}
DADOS$eta_est<-DADOS$predito+DADOS$e_artif

```

**7) NOVA REGRESSÃO TOBIT**

Estime mais uma vez utilizando o modelo Tobit e as DMUs acima não eficientes, só que agora utilizando os valores obtidos da equação 8.24 como variável endógena, e as variáveis exógenas como variáveis explicativas , onde agora é o erro aleatório.:
```{r}
etobit_novo<-tobit(eta_est~z1+logz2+z3+z4+z5+logz6, left=1, right=Inf, data=DADOS)
summary(etobit_novo)
```
**8) ESTIMATIVAS FINAIS**

Obtenha as estimativas finais para os coeficientes e o desvio padrão do erro:
```{r}
gamma_est<-coef(etobit_novo)
s_w<-sqrt(var(residuals(etobit_novo)))
```

**9) BOOTSTRAP PARA OBTENÇÃO DE INTERVALOS DE CONFIANÇA**

Repita os passos 5, 6, 7 e 8 L9 vezes, de modo a obter a matriz. Inicialmente vamos definir a matriz G e atribuir os valores dos coeficientes e do desvio padrão a ela:
```{r}
L=5000
set.seed(254487)
#G<-cbind(rep(0,L),rep(0,L),rep(0,L),rep(0,L),rep(0,L),rep(0,L),rep(0,L))
#G[1,L]<-cbind(t(gamma_est), s_w)

G<-cbind(rep(0,L),rep(0,L),rep(0,L),rep(0,L),rep(0,L), rep(0,L),rep(0,L),
rep(0,L))
for (i in 1:L){
 DADOS$e_artif<-rtruncnorm(1, a=1-DADOS$predito, b=Inf,
mean = 0, sd = s_e)
 DADOS$eta_est<-DADOS$predito+DADOS$e_artif
 etobit_novo<-tobit(eta_est~z1+logz2+z3+z4+z5+logz6, left=1, right=Inf,
data=DADOS)
 gamma_est<-coef(etobit_novo)
 s_w<-sqrt(var(residuals(etobit_novo)))
 G[1,]<-cbind(t(gamma_est), s_w)
}
summary(etobit_novo)
```
**10) CÁLCULO DAS MÉDIAS E VARIÂNCIAS**

 Calculea as médias e variâncias de cada coluna G para construir intervalos de confiança para os parâmetros:
```{r}
medias<-rep(0,8)
desvios<-rep(0,8)
intervalo<-data.frame(cbind(rep(0,8),rep(0,8)))
names(intervalo)<-cbind("Inferior", "Superior")
rownames(intervalo)<-rbind("Intercepto", "z1","logz2","z3","z4","z5","logz6","Desvio do Erro")
#rownames(intervalo)<-rbind("Intercepto", "az2", "az3","az4", "az7","az8","Desvio do Erro")

for(i in 1:8){
 medias[i]<-mean(G[,i])
 desvios[i]<-sqrt(var(G[,i]))
erro<- qnorm(0.95)*desvios[i]/sqrt(L)
 intervalo[i,1]<- medias[i]-erro
 intervalo[i,2]<- medias[i] + erro
 }
intervalo
```

**11) EFEITOS DAS VARIÁVEIS AMBIENTAIS**

Calcula a média de cada coluna para obter a estimativa dos efeitos das variáveis ambientais sobre a eficiência das DMUs:
```{r}
names(medias)<-cbind("Intercepto", "z1","logz2","z3", "z4","z5","logz6", "Desvio do Erro")
medias

```
Mostra eficiências obtidas:
```{r}
eff(BCC)
```
## 6. Análise dos Resultados

Esta seção apresenta a análise das eficiências técnica (ET), técnica pura (ETP) e de escala (EE) das 26 Unidades Federativas (UFs) analisadas, excluindo Roraima por falta de dados. Utilizamos a metodologia DEA-BCC e DEA-CCR orientadas a insumos no primeiro estágio, e o método de Simar e Wilson (2007) no segundo estágio.

**Resultados do Primeiro Estágio**

Os resultados dos modelos DEA-BCC e DEA-CCR para as 26 UFs, incluindo a eficiência de escala e a estatística descritiva, são apresentados na tabela abaixo:


**Estatísticas Descritivas:**
- Média: ET = 0,6195, ETP = 0,7198, EE = 0,8485
- Desvio Padrão: ET = 0,2429, ETP = 0,2158, EE = 0,1536
- Coeficiente de Variação: ET = 39,22%, ETP = 29,98%, EE = 18,10%

**Quartis:**
 - 1º Quartil: ET = 0,4485, ETP = 0,5757, EE = 0,7609
 - 2º Quartil (Mediana): ET = 0,5717, ETP = 0,6921, EE = 0,8908 
 - 3º Quartil: ET = 0,7284, ETP = 0,9641, EE = 0,9861


**Observações:**
- 5 UFs estão na fronteira de eficiência: Paraíba, Maranhão, Rio Grande do Norte, Santa Catarina e São Paulo.
- Rio de Janeiro apresentou o menor nível de ET (0,2177).
- Mato Grosso foi ineficiente com retornos constantes de escala, mas eficiente com retornos variáveis.
- Minas Gerais, Paraná, Rondônia e Tocantins apresentaram escores de ET e ETP muito próximos, indicando ineficiências técnicas na gestão dos serviços.


## Referências

- Simar, L., & Wilson, P. W. (2007). "Estimation and inference in two-stage,
