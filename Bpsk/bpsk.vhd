---- ################################################################################################################## ----
---- ###########################     BPSK - BINARY PHASE SHIFT KEYING      ############################################ ----
---- ################################################################################################################## ----
----------------------------------------------------------------------------------------------------------------------------
---- BPSK acionado por um enable, entrega um sinal BPSK de 10 coeficientes sincronizados em 20 ciclos de clock.       ------
----------------------------------------------------------------------------------------------------------------------------
---- coeficientes senóide (Ciclo de senóide) / 2 = comprimento pulso BPSK modulado   (frequência de Nyquist)          ------
----------------------------------------------------------------------------------------------------------------------------
---- codificador de pulsos sigma delta RZ {+1,-1} com sps = Fs/Rs = 4 (amostras por símbolo)                           -----
----------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;   -- TRABALHA VALORES LÓGICOS.
USE IEEE.std_logic_arith.ALL;  -- TRABALHA COM ARITMÉTICA.
USE IEEE.std_logic_signed.ALL; -- TRABALHA COM COMPLEMENTO DE 2.

ENTITY bpsk IS

	PORT (

		clock     : IN  STD_LOGIC;
		enable    : IN  STD_LOGIC;
		reset     : IN  STD_LOGIC;
		contador  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		int_ad    : IN  STD_LOGIC;
		sinal_in  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		sinal_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		pulso	  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		rrc	  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		osc       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)		
		
	     );

END bpsk;

ARCHITECTURE rtl OF bpsk IS

------------------         DECLARAÇÃO DE COMPONENTES        -------------------------------------------------------------
---- Componentes: Multiplexador de 8-bits , Codificador de pulsos de 8-bits, Filtro RRC FIR, NCO                     ----
-------------------------------------------------------------------------------------------------------------------------

COMPONENT mux8        PORT(

      			  clock          : IN STD_LOGIC;
      	      		  enable_mux8    : IN  STD_LOGIC_VECTOR(0 DOWNTO 0); -- ACIONAMENTO DO CODIFICADOR DE 8-BITS
      			  address_mux8   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); -- SELETOR DO CODIFICADOR DE 8-BITS
      			  sinal_in_mux8  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); -- SINAL DE ENTRADA "PALAVRA DE 8-BITS"
      			  sinal_out_mux8 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)  -- SINAL DE SAÍDA "BITSTREAM"
   
    			  );
END COMPONENT;

COMPONENT pulseCodec PORT (
        
      			  clock         : IN  STD_LOGIC;		     -- SIMULA RELÓGIO DE 50MHZ VINDO DO EVALUATION BOARD
        		  enable_pulse  : IN  STD_LOGIC; 		     -- SELEÇÃO DE CODIFICAÇÃO DE PULSOS
        		  address_pulse : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);  -- ENDEREÇAMENTO DE CODIFICAÇÃO DE PULSOS
        		  pulse         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)   -- SINAL DE SAÍDA "TREM DE PULSOS"
                     
		          );
END COMPONENT;

COMPONENT FirDesign  PORT(
		
			 clock 		: IN  STD_LOGIC; 		     -- SIMULA REL?GIO DE 50MHZ VINDO DO EVALUATION BOARD.
	   		 reset 		: IN  STD_LOGIC;
	   		 clock_ad   	: OUT STD_LOGIC; 		     -- SINAL DE ENTRADA DE CLOCK DO A/D (41* TAXA DE AMOSTRAGEM - ESPECIFICA??ES DO CONVERSOR A/D A ESCOLHER)
	   		 sinal_in_rrc 	: IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  -- BARRAMENTO DO SINAL DE ENTRADA DE 8 BITS VINDOS DO A/D PARA O RRC FIR.
	   		 int_ad 	: IN  STD_LOGIC; 		     -- SINAL DE INTERRUP??O FORNECIDO PELO A/D NA MESMA TAXA DOS DADOS DE ENTRADA.
	   		 sinal_out_rrc 	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)   -- SINAL DE SA?DA DO RRC FIR PARA O D/A. 
	
			 );
END COMPONENT;

COMPONENT nco       PORT (
        
		        clock        : IN  STD_LOGIC;			     -- SIMULA RELÓGIO DE 50MHZ VINDO DO EVALUATION BOARD
		        enable_nco   : IN  STD_LOGIC; 			     -- ACIONAMENTO DO OSCILADOR.
		        address_nco  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);     -- ENDEREÇAMENTO DO SENÓIDE EM MEMÓRIA.
 		        nco          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)      -- SINAL DE SAÍDA "SENO".
                  
  		         );
END COMPONENT;

-- CONSTANTES GLOBAIS
CONSTANT pulse_lenght  : INTEGER := 4;
CONSTANT nco_lenght : INTEGER := 20;
CONSTANT symbol_lenght : INTEGER := 30;

-- SINAIS DO MULTIPLEXADOR
SIGNAL enable_mux8    : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL address_mux8   : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL sinal_in_mux8  : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL sinal_out_mux8 : STD_LOGIC_VECTOR(0 DOWNTO 0);

-- SINAIS DO CODIFICADOR DE PULSOS
SIGNAL enable_pulse   : STD_LOGIC;
SIGNAL address_pulse  : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL pulse	      : STD_LOGIC_VECTOR(7 DOWNTO 0);

-- SINAIS DO RRC FIR FILTER
SIGNAL clock_ad      : STD_LOGIC;
SIGNAL sinal_in_rrc  : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL sinal_out_rrc : STD_LOGIC_VECTOR(7 DOWNTO 0);

-- SINAIS DO NCO
SIGNAL enable_nco   : STD_LOGIC;
SIGNAL address_nco  : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL nco1         : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

------------------        INSTÂNCIAS  DE COMPONENTES        -------------------------------------------------------------
---- Componentes: Multiplexador de 8-bits , Codificador de pulsos de 8-bits, Filtro RRC FIR, NCO                     ----
-------------------------------------------------------------------------------------------------------------------------

MULTIPLEXADOR: mux8 PORT MAP(

    			clock      	=> clock,
			enable_mux8     => enable_mux8,
    			address_mux8    => address_mux8,
    			sinal_in_mux8   => sinal_in_mux8,
    			sinal_out_mux8  => sinal_out_mux8
   
		    );

CODIFICADOR: pulseCodec PORT MAP (
        
     			 clock        	=> clock,
        		 enable_pulse   => enable_pulse,
        		 address_pulse  => address_pulse,
        		 pulse		=> pulse
                     
       			  );

RRCFIR: FirDesign PORT MAP(
		
			 clock 		=> clock,
	   		 reset 		=> reset,
	   		 clock_ad   	=> clock_ad,
	   		 sinal_in_rrc 	=> sinal_in_rrc,
	   		 int_ad 	=> int_ad,
	   		 sinal_out_rrc 	=> sinal_out_rrc
	
			 );

OSCILADOR: nco PORT MAP (
        
       			 clock        => clock,
      			 enable_nco   => enable_nco,
       			 address_nco  => address_nco,
       			 nco          => nco1
                  
     		    );

		enable_mux8 <= CONV_STD_LOGIC_VECTOR(enable,1);
		sinal_in_mux8 <= sinal_in;
---- ################################################################################################################## ----
---- ###########################     BPSK - BINARY PHASE SHIFT KEYING      ############################################ ----
---- #####    Controles de acionamento, casamento de timing e entrega da saída do modulador de sinais BPSK        ##### ----
---- ################################################################################################################## ----


-------------------     CONTROLE MULTIPLEXADOR DE 8-BITS      --------------------------------------------------------------
----- multiplexador acionado por um enable que converte um um barramento serial de 8-bits em um bitstream sincronizado -----
----- com o comprimento de símbolo "symbol_length" em 30 ciclos de clock.                                              -----
----------------------------------------------------------------------------------------------------------------------------
----- O BITSTREAM ENTREGUE PELO MULTIPLEXADOR ALIMENTA SICRONIZADAMENTE O CODIFICADOR DE PULSOS SIGMA DELTA RZ         -----
----------------------------------------------------------------------------------------------------------------------------
	PROCESS(clock)
		VARIABLE seletor_temp : INTEGER := 0;
		VARIABLE contador_int : INTEGER := 0;
		BEGIN

		IF rising_edge(clock) AND reset = '0' AND enable = '1' THEN

			address_mux8    <= conv_std_logic_vector(seletor_temp,3);

			IF contador_int = symbol_lenght THEN

				seletor_temp	:= seletor_temp + 1;
					
			END IF;

			IF sinal_out_mux8 = "1" AND contador_int = symbol_lenght THEN
					
				enable_pulse <= enable;
				contador_int := 0;
					
			ELSE IF sinal_out_mux8 = "0" AND contador_int = symbol_lenght THEN
				
				enable_pulse <= NOT enable;
				contador_int := 0;
			END IF;
			END IF;

			contador_int := contador_int + 1;		
		END IF;

	END PROCESS;

------------------     CONTROLE CODIFICADOR DE PULSOS      ----------------------------------------------------------------
---- codificador de pulsos sigma delta RZ {+1,-1} que atende aos critérios de Nyquist, selecionado por um enable,     -----
----   entrega um trem de 4 pulsos ( sps = 4) sincronizados em 30 ciclos de clock. (Comprimento de um símbolo)        -----
---------------------------------------------------------------------------------------------------------------------------
----- O TREM DE PULSOS ENTREGUE PELO CODIFICADOR SIGMA DELTA RZ ALIMENTA SICRONIZADAMENTE O FILTRO RRC FIR            -----
---------------------------------------------------------------------------------------------------------------------------
	PROCESS(clock)
		VARIABLE address_pulse_temp : INTEGER := 0;
		VARIABLE contador_int       : INTEGER := 0;
		VARIABLE pulse_conv         : STD_LOGIC_VECTOR(7 DOWNTO 0);
		VARIABLE contador_global    : INTEGER := 0;
		BEGIN

		IF rising_edge(clock) AND reset = '0' AND enable = '1' THEN

			contador_int := contador_int+1;
			IF contador_int > 2 THEN
				
				address_pulse <= CONV_STD_LOGIC_VECTOR(address_pulse_temp,2);


				IF address_pulse_temp < pulse_lenght THEN
					address_pulse_temp := address_pulse_temp + 1;
				END IF;
				
				IF address_pulse_temp <= pulse_lenght AND address_pulse_temp >= 0 THEN
				
					pulse_conv(7) 	:= NOT pulse(7);
					pulse_conv(6 DOWNTO 0):= pulse(6 DOWNTO 0);
					sinal_in_rrc <= (OTHERS => '0');
					sinal_in_rrc <= pulse_conv;

				ELSE 
					
					sinal_in_rrc <= "10000001";
					
				END IF;

				
				IF contador_int = symbol_lenght THEN
					
					address_pulse_temp := 0;
					contador_int       := 0;
					contador_global    := contador_global + 1;
					contador           <= conv_std_logic_vector((contador_global),8); -- CONTADOR DE PULSOS TRANSMITIDOS
					
				END IF;
			
			END IF;
			pulso <= pulse;
			rrc   <= sinal_out_rrc;
		END IF;

	END PROCESS;

------------------     CONTROLE NCO (NUMERICALLY CONTROLLED OSCILLATOR)    -----------------------------------------------
---- Oscilador controlado numericamente que atende aos critérios de Nyquist, acionado por um enable e  sincronizado   ----
---- com a saída conformada do pulso no filtro RRC FIR.                                                               ----
--------------------------------------------------------------------------------------------------------------------------
	PROCESS(clock)
		VARIABLE address_nco_temp : INTEGER := 0;
		VARIABLE contador : INTEGER := 0;
		BEGIN

		contador := contador + 1;
		IF contador = 75 THEN
			enable_nco <= '1';
		END IF;

		IF enable_nco = '1' THEN
			address_nco     <= conv_std_logic_vector(address_nco_temp, 8);
			address_nco_temp := address_nco_temp + 1;
			
			IF address_nco_temp = nco_lenght THEN 
				address_nco_temp := 0;
			END IF; 
			osc <= nco1;
		END IF;

	END PROCESS;


------------------     CONTROLE MULTIPLICAÇÃO NO TEMPO (MODULAÇÃO)      --------------------------------------------------
---- multiplicação no domínio do tempo para modular o pulso conformado em BPSK.                                       ----
---- OBS: O Oscilador e o pulso conformado precisam estar sincronizados !                                             ----
--------------------------------------------------------------------------------------------------------------------------
	PROCESS(clock)
		VARIABLE nco_conv : STD_LOGIC_VECTOR(7 DOWNTO 0);
		BEGIN

		nco_conv(7) := NOT nco1(7);
		nco_conv(6 DOWNTO 0) := nco1(6 DOWNTO 0);	
		sinal_out <= sinal_out_rrc * nco_conv; 
		
	END PROCESS;

END rtl;