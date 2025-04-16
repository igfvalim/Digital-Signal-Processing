---- ################################################################################################################## ----
---- #####                               TESTBENCH MODULADOR BPSK                                                 ##### ----
---- ################################################################################################################## ----
----------------------------------------------------------------------------------------------------------------------------
---- BPSK acionado por um enable, entrega um sinal BPSK de 10 coeficientes sincronizados em 20 ciclos de clock.       ------
----------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;   -- TRABALHA VALORES LÓGICOS.
USE IEEE.std_logic_arith.ALL;  -- TRABALHA COM ARITMÉTICA.
USE IEEE.std_logic_signed.ALL; -- TRABALHA COM COMPLEMENTO DE 2.
USE IEEE.std_logic_textio.ALL; -- TRABALHA COM VALORES LÓGICOS EM ARQUIVOS TEXTO.
USE std.textio.ALL;            -- TRABALHAR COM ARQUIVOS TEXTO.

ENTITY TBbpsk IS
END TBbpsk;

ARCHITECTURE rtl OF TBbpsk IS
-------------------------------------------------------------------------------------------------------------------------
----                                    DECLARAÇÃO DO COMPONENTE BPSK                                                ----
-------------------------------------------------------------------------------------------------------------------------
COMPONENT bpsk PORT (

			clock     : IN  STD_LOGIC;                        -- SIMULA RELÓGIO DE 50MHZ VINDO DO EVALUATION BOARD
			enable    : IN  STD_LOGIC;                        -- RESET BPSK
			reset     : IN  STD_LOGIC;                        -- ENABLE BPSK
			contador  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);     -- CONTADOR DE SÍMBOLOS TRANSMITIDOS
			int_ad    : IN  STD_LOGIC;                        -- SINAL DE INTERRUPÇÃO FORNECIDO PELO A/D NA MESMA TAXA DOS DADOS DE ENTRADA DO FILTRO RRC FIR.
			sinal_in  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);     -- ENTRADA BARRAMENTO SERIAL DE 8-BITS 
			sinal_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);    -- SINAL MODULADO BPSK
			pulso	  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			rrc	  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			osc       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)			
	            );
END COMPONENT;

-- CONSTANTES GLOBAIS
CONSTANT clock_period : TIME := 20 ns;	

-- SINAIS GLOBAIS
SIGNAL clock     : STD_LOGIC := '0'; 		  -- SIMULA RELÓGIO DE 50MHZ VINDO DO EVALUATION BOARD
SIGNAL reset     : STD_LOGIC := '1'; 		  -- RESET BPSK
SIGNAL enable    : STD_LOGIC := '0'; 		  -- ENABLE BPSK
SIGNAL contador  : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- CONTADOR DE SÍMBOLOS TRANSMITIDOS
SIGNAL int_ad    : STD_LOGIC := '0';              -- SINAL DE INTERRUPÇÃO FORNECIDO PELO A/D NA MESMA TAXA DOS DADOS DE ENTRADA DO FILTRO RRC FIR.
SIGNAL sinal_in  : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- ENTRADA BARRAMENTO SERIAL DE 8-BITS 
SIGNAL sinal_out : STD_LOGIC_VECTOR(15 DOWNTO 0); -- SINAL MODULADO BPSK
SIGNAL pulso	 : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- SINAL PULSO SIGMA DELTA RZ
SIGNAL rrc	 : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- SINAL CONFORMADO PELO FILTRO RRC
SIGNAL osc       : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- SINAL OSCILADOR CONTROLADO NUMERICAMENTE		

BEGIN
-------------------------------------------------------------------------------------------------------------------------
------------------                 INSTÂNCIA DO MODULADOR BPSK               --------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
MODULADOR: bpsk PORT MAP(

    			clock => clock,
			enable => enable,
    			reset   => reset,
    		 	contador => contador,
			int_ad    => int_ad,
    			sinal_in   => sinal_in,
			sinal_out   => sinal_out,
			pulso         => pulso, 
   			rrc		=> rrc,
			osc		  => osc
		        );

-- RELÓGIOS E RESETS
clock    <= NOT clock  AFTER clock_period/2;
int_ad   <= NOT int_ad AFTER clock_period;
enable   <= '1' ; -- AFTER 20*60 ns;
reset    <= '0' AFTER 60 ns;

-- PALAVRA TESTE
sinal_in <= "10101010";


----------------------------------------------------------------
-- CRIAÇÃO DO ARQUIVO pulse.dat COM OS VALORES DE SAÍDA       --
-- PÓS SIMULAÇÃO,FORNECIDOS PELO MODELSIM                     --
----------------------------------------------------------------
----            ESCREVE EM ARQUIVO TEXT                  -------
----------------------------------------------------------------
	PROCESS
		FILE     fid  : TEXT;
		VARIABLE line : LINE;
		BEGIN
      		file_open(fid, "pulse.dat", WRITE_MODE);
		WHILE TRUE LOOP

			wait until rising_edge(clock) AND enable='1';
			write(line,  conv_integer(pulso),RIGHT, 10);
			writeline(fid, line);
      
		END LOOP;

	END PROCESS;


----------------------------------------------------------------
-- CRIAÇÃO DO ARQUIVO rrc.dat COM OS VALORES DE SAÍDA       --
-- PÓS SIMULAÇÃO,FORNECIDOS PELO MODELSIM                     --
----------------------------------------------------------------
----            ESCREVE EM ARQUIVO TEXT                  -------
----------------------------------------------------------------
	PROCESS
		FILE     fid1  : TEXT;
		VARIABLE line1 : LINE;
		BEGIN
      		file_open(fid1, "rrc.dat", WRITE_MODE);
		WHILE TRUE LOOP

			wait until rising_edge(clock) AND enable='1';
			write(line1,  conv_integer(rrc),RIGHT, 10);
			writeline(fid1, line1);
      
		END LOOP;

	END PROCESS;


----------------------------------------------------------------
-- CRIAÇÃO DO ARQUIVO nco.dat COM OS VALORES DE SAÍDA       --
-- PÓS SIMULAÇÃO,FORNECIDOS PELO MODELSIM                     --
----------------------------------------------------------------
----            ESCREVE EM ARQUIVO TEXT                  -------
----------------------------------------------------------------
	PROCESS
		FILE     fid2  : TEXT;
		VARIABLE line2 : LINE;
		VARIABLE temp  : STD_LOGIC_VECTOR(7 DOWNTO 0);
		BEGIN
      		file_open(fid2, "nco.dat", WRITE_MODE);
		WHILE TRUE LOOP
			temp(7) := NOT osc(7);
			temp(6 DOWNTO 0) := osc(6 DOWNTO 0);

			wait until rising_edge(clock) AND enable='1';
			write(line2,  conv_integer(temp),RIGHT, 10);
			writeline(fid2, line2);
      
		END LOOP;

	END PROCESS;


----------------------------------------------------------------
-- CRIAÇÃO DO ARQUIVO bpsk.dat COM OS VALORES DE SAÍDA       --
-- PÓS SIMULAÇÃO,FORNECIDOS PELO MODELSIM                     --
----------------------------------------------------------------
----            ESCREVE EM ARQUIVO TEXT                  -------
----------------------------------------------------------------
	PROCESS
		FILE     fid3  : TEXT;
		VARIABLE line3 : LINE;
		BEGIN
      		file_open(fid3, "bpsk.dat", WRITE_MODE);
		WHILE TRUE LOOP

			wait until rising_edge(clock) AND enable='1';
			write(line3,  conv_integer(sinal_out),RIGHT, 10);
			writeline(fid3, line3);
      
		END LOOP;

	END PROCESS;

END rtl;