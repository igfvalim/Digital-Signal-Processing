%%L� os dados do arquivo ouputSignal.dat que foram armazenados no formato de 8 bits.

%gera o vetor 'c' a partir da leitura(fscanf) do arquivo fid,
%%dados lidos do formato 'string", e convertido em um vetor de 8 colunas
%% e comprimento at� o final do arquivo (inf). count retorna o comprimento do vetor.

fid = fopen('pulse.dat','r');
c = fscanf(fid, '%d ', [1 inf]);

fid1 = fopen('rrc.dat','r');
c1 = fscanf(fid1, '%d ', [1 inf]);

fid2 = fopen('nco.dat','r');
c2 = fscanf(fid2, '%d ', [1 inf]);

fid3 = fopen('bpsk.dat','r');
c3 = fscanf(fid3, '%d ', [1 inf]);

%Plota os graficos do sinal de entrada fornecido para a simula��o
%e do sinal de saida obtido ap�s a simula��o
figure(1);

subplot(4,1,1)
stem(c/70);
grid on
ylabel('pulso');

subplot(4,1,2)
stem(c1/70);
grid on
ylabel('rrc');

subplot(4,1,3)
stem(c2/70);
grid on
ylabel('nco');

subplot(4,1,4)
stem(c3/70);
grid on
ylabel('bpsk');
