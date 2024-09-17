
---
#  INSTALAR OS PACOTES:

install.packages("Benchmarking")
install.packages("frontier")
install.packages("readxl")
install.packages("truncnorm")
install.packages("AER")

# ATIVAR OS PACOTES:

library(Benchmarking)
library(frontier)
library(readxl)
library(truncnorm)
library(AER)


# IMPORTAR BASE DE DADOS: importa a base de dados e a nomeia como "DADOS".

DADOS <- read_excel("~.../DADOS.xlsx")
View(DADOS)
```
#VARIÁVEIS

#Insumo/Produto	Descrição para o ano de 2017:
  
#x = Despesa per capita realizada com a Função Segurança Pública - Em reais constantes de 2017
#y1 = Mortes Violentas Intencionais-MVI (Homicídio Doloso; Latrocínio; Lesão Corporal seguida de Morte.)-Taxa por 100 mil habitantes
#y2 = Roubo e Furto de Veículo - Taxa por 100 mil veículos (SEM DADOS PARA RORAIMA)
#y3 = Estupro - taxa por 100 mil habitantes
#y4 = Tráfico de Entorpecentes - taxa por 100 mil habitantes (SEM DADOS PARA  RORAIMA)
#y5 = Roubo (total) - taxa por 100 mil habitantes (SEM DADOS PARA RORAIMA)
#z1 = Proporção de jovens negros na faixa etária de 15-29 anos de idade - % da população
#z2 = Área Geografica - km²
#z3 = Densidade Populacional
#z4 = Taxa de Alfabetização da população com 15 ou mais - % da população
#z5 = Média da Taxa de Desocupação - % da população
#z6 = Renda Domiciliar média - Mensal


# Fixar a base de Dados

attach(DADOS)


#MODELO DEA DE DOIS ESTÁGIOS

#1° ESTÁGIO
#Calcula o inverso dos ìndices de criminalidade devido a querer reduzir-las e calcula a variável x3(número de policiais):

DADOS$ay1=1/(DADOS$y1)
DADOS$ay2=1/(DADOS$y2)
DADOS$ay3=1/(DADOS$y3)
DADOS$ay4=1/(DADOS$y4)
DADOS$ay5=1/(DADOS$y5)

#Fixar a base de Dados
attach(DADOS)

#Define as variáveis que são insumos e as que são produtos:

produtos<-cbind(ay1,ay2,ay3,ay4,ay5)
insumos<- cbind(x)

#PASSO 1
#DEA-CCR ORIENTADO AOS INSUMOS: calcula a eficiência técnica orientada a insumos com a hipótese de retornos constantes de escala (“CRS”) e amazenar os dados obtidos no CCR:
  
CCR <- dea(insumos,produtos, RTS="crs", ORIENTATION = "in", SLACK=TRUE)


#Mostrar eficiências obtidas no modelo DEA-CCR:

eff(CCR)

#outros cáculos sobre DEA-CCR:

CCR$slack
peers(CCR)
lambda(CCR)


#DEA-BCC ORIENTADO AOS INSUMOS: calcula a eficiência técnica orientada a insumos  (“in”) com a hipótese de retornos variáveis de escala (“vrs”) e amazena os dados obtidos no objeto BCC: :
  
BCC <-dea(insumos,produtos, RTS="vrs", ORIENTATION = "in", SLACK=TRUE)

#Mostrar eficiências do modelo DEA-BCC:: 

eff(BCC)

#Outros cáculos sobre DEA-BCC:

BCC$slack
peers(BCC)
lambda(BCC)


#Calcular eficiências de escala:

Escala <- eff(CCR)/eff(BCC)
Escala


#tabela com os resultados de DEA-BBC, DEA-CCR e Escala:

cbind(eff(CCR), eff(BCC),Escala)


#ARRUMANDO VARIÁVEIS: calculando os logarítimos das variáveis z2(Área Geografica - km²) e z6( Renda Domiciliar média - Mensal:
                                                                                            
DADOS$logz2=log(DADOS$z2)
DADOS$logz6=log(DADOS$z6)

                                                                                             
# 2° ESTÁGIO
                                                                                             
#Utilizando DEA-BCC no segundo estágio:

DADOS$theta<-eff(BCC)

                                                                                             
#2)RETIRAR DMU’s EFICIENTES NO PASSO 1


DADOS<-subset(DADOS,theta!=1)


#3) Obtenha os escores inversos


DADOS$eta=1/DADOS$theta
```

#4) Utilize o modelo Tobit (ou outro modelo equivalente) para regredir os escores de eficiência obtidos contra as variáveis ambientais, mas utilizando somente os registros das DMUs não eficientes, de acordo com a seguinte equação: , onde é o vetor de variáveis ambientais associado a DMU i, é o vetor de coeficientes a ser estimado e é o erro aleatório também associado a DMU i. Obtenha estimativas para , e para o desvio padrão de ;



#library("AER")

etobit<-tobit(eta~z1+logz2+z3+z4+z5+logz6, left=1, right=Inf, data=DADOS)
DADOS$e<-residuals(etobit)
s_e<-sqrt(var(DADOS$e))
DADOS$predito<-fitted(etobit)
summary(etobit)


#5) Produza resíduos artificiais gerados a partir de uma distribuição normal truncada, com truncamento à esquerda8 em e com desvio padrão igual a , que foi estimado no passo 4:
  
  
library(truncnorm)
DADOS$e_artif<-rtruncnorm(1, a=1-DADOS$predito, b=Inf,mean = 0, sd = s_e)



#6) Compute a variável segundo a equação: ,onde é o estimador para o parâmetro :
  
DADOS$eta_est<-DADOS$predito+DADOS$e_artif


#7) Estime mais uma vez utilizando o modelo Tobit e as DMUs acima não eficientes, só que agora utilizando os valores obtidos da equação 8.24 como variável endógena, e as variáveis exógenas como variáveis explicativas , onde agora é o erro aleatório.

etobit_novo<-tobit(eta_est~z1+logz2+z3+z4+z5+logz6, left=1, right=Inf, data=DADOS)
summary(etobit_novo)


#8) Obtenha as estimativas para e para o desvio padrão do erro, ( e ).

gamma_est<-coef(etobit_novo)
s_w<-sqrt(var(residuals(etobit_novo)))


#9) Repita os passos 5, 6, 7 e 8 L9 vezes, de modo a obter a matriz Inicialmente vamos definir a matriz G e atribuir os valores dos coeficientes e do desvio padrão a ela:
  
L=5000
set.seed(254487)
#G<-cbind(rep(0,L),rep(0,L),rep(0,L),rep(0,L),rep(0,L),rep(0,L),rep(0,L))
#G[1,L]<-cbind(t(gamma_est), s_w)
G<-cbind(rep(0,L),rep(0,L),rep(0,L),rep(0,L),rep(0,L), rep(0,L),rep(0,L),
         rep(0,L))
for (i in 1:L){DADOS$e_artif<-rtruncnorm(1, a=1-DADOS$predito, b=Inf, mean = 0, sd = s_e)
  DADOS$eta_est<-DADOS$predito+DADOS$e_artif
  etobit_novo<-tobit(eta_est~z1+logz2+z3+z4+z5+logz6, left=1, right=Inf,data=DADOS)
  gamma_est<-coef(etobit_novo)
  s_w<-sqrt(var(residuals(etobit_novo)))
  G[1,]<-cbind(t(gamma_est), s_w)
}
summary(etobit_novo)


#10) Calcule as médias e variâncias de cada coluna G para construir intervalos de confiança para os parâmetros.

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


#11) Calcule a média de cada coluna para obter a estimativa dos efeitos das variáveis ambientais sobre a eficiência das DMUs.


names(medias)<-cbind("Intercepto", "z1","logz2","z3", "z4","z5","logz6", "Desvio do Erro")
medias


#Mostrar eficiências obtidas:

eff(BCC)
