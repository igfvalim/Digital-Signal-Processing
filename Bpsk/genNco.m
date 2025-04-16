clear all;

w= 1/20;               % quantidade de amostras
cont = 1;               % contador de amostras


fid = fopen('nco.dat', 'w'); %cria o arquivo inputSignal.m

for i = 0:20     % Gerar 32 amostras de 8-bits e printar c�digo VHDL da ROM

  temp = round((2^7*0.5*(0.8*sin(2*pi*i*w)+0.25*sin(2*pi*i*w)))+2^7+1);   % cria um sen�ide
                                                                % normalizado entre 0 at� 255 correspondendo aos niveis do conversor AD de 8 bits
 %% address = dec2bin(i,8);
  saida = dec2bin(temp,8);                                      % converte para uma palavra binaria de 8 bits
  fprintf(fid,'\r\n  "%s", ',saida);      % escreve no arquivo rom.dat
  x(cont) = temp/256;
  cont = cont + 1;
endfor;

fclose(fid);                                                    % fecha o arquivo inputSignal.m

%gera o grafico da entrada para visualiza��o de dados da ROM no Octave
figure 1;
stem(x);
ylabel('Seno');
grid on




