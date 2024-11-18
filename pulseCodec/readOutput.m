fid = fopen('outputSignal.dat','r');
a = fscanf(fid, '%d ', [1 inf]);


%%L� os dados do arquivo ouputSignal.dat que foram armazenados no formato de 8 bits.


%Plota os graficos do sinal de entrada fornecido para a simula��o
%e do sinal de saida obtido ap�s a simula��o

figure(1);
subplot(2,1,1);
stem(a/50);
subplot(2,1,2);
plot(a/50+0.5);
grid on

