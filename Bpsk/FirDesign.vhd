------------------       ROOT RAISED COSINE FIR FILTER       ------------------------------------------
---- Filtro Raiz de Cosseno Levantado de 41 coeficientes com resposta ao impulso limitada em faixa ----
---- que entrega um pulso conformado de 8 coeficientes para um trem de 4 pulsos.                   ----
-------------------------------------------------------------------------------------------------------
---- ntaps = N * sps = N coeficientes (Duração de N/2 - 1 pulsos )                                 ----
-------------------------------------------------------------------------------------------------------
---- Fs = 16000 (taxa de amostragem) Rs = 4000(taxa de símbolos) sps = Fs/Rs (amostras por símbolo)----
-------------------------------------------------------------------------------------------------------
---- Coeficientes do filtro obtids à partir do arquivo coefs.dat gerado pelo código genCoefs.m  ------- 
-------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;   -- TRABALHA VALORES LÓGICOS.
USE IEEE.std_logic_arith.ALL;  -- TRABALHA COM ARITMÉTICA.
USE IEEE.std_logic_signed.ALL; -- TRABALHA COM COMPLEMENTO DE 2.

ENTITY FirDesign IS
	PORT(
		clock 		: IN  STD_LOGIC; 			-- SIMULA RELÓGIO DE 50MHZ VINDO DO EVALUATION BOARD.
	   	reset 		: IN  STD_LOGIC;
	   	clock_ad   	: OUT STD_LOGIC; 			-- SINAL DE ENTRADA DE CLOCK DO A/D (41* TAXA DE AMOSTRAGEM - ESPECIFICAÇÕES DO CONVERSOR A/D A ESCOLHER)
	   	sinal_in_rrc 	: IN  STD_LOGIC_VECTOR(7 DOWNTO 0); 	-- BARRAMENTO DO SINAL DE ENTRADA DE 8 BITS VINDOS DO A/D PARA O RRC FIR.
	   	int_ad 		: IN  STD_LOGIC; 			-- SINAL DE INTERRUPÇÃO FORNECIDO PELO A/D NA MESMA TAXA DOS DADOS DE ENTRADA.
	   	sinal_out_rrc 	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)	-- SINAL DE SAÍDA DO RRC FIR PARA O D/A. 
	);
END FirDesign;

ARCHITECTURE rtl OF FirDesign IS

-- CONSTANTES GLOBAIS
CONSTANT number_of_coefs : INTEGER := 41;
CONSTANT MULT_FACTOR     : REAL    := 2.0**11; 				      -- FATOR DE NORMALIZAÇÃO PARA TRABALHAR COM PONTO FIXO (COMPLEMENTO DE 2) UTILIZANDO 12 BITS  
                                               				      -- (2^11-1 = 2047) MAX POS.011111111111 -- MIN NEG. 100000000000 (-2^12 = -2048)--RAY.



-- SINAIS GLOBAIS
SIGNAL clock_ad_int  : STD_LOGIC;
SIGNAL clock_ad_int1 : STD_LOGIC;
SIGNAL int_ad_reg    : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL enable_ad     : STD_LOGIC;
SIGNAL result_sum    : STD_LOGIC_VECTOR(21 DOWNTO 0); 					-- ARMAZENA O RESULTADO DAS SOMAS
SIGNAL sinal_ad_reg  : STD_LOGIC_VECTOR(7 DOWNTO 0); 					-- SINAL PARA REGISTRAR A ENTRADA DE SINAL VINDA DO A/D.
SIGNAL counter1      : INTEGER RANGE 0 TO 16 := 0; 				        -- freq_AD = 1.472 kHz -> F_intr = Fs = 23 kHz	

-- DECLARAÇÃO DE UMA MEMÓRIA RAM COM 41 BYTES PARA ARMAZENAR AS CADEIAS DE ATRASO.
TYPE   vector_delay_chain IS ARRAY (INTEGER RANGE <>) OF STD_LOGIC_VECTOR(7 DOWNTO 0); -- DECLARAÇÃO DE UM VETOR LÓGICO EM UM TIPO ARRAY.
SIGNAL delay_chain : vector_delay_chain(number_of_coefs-1 DOWNTO 0);                   -- CADEIAS DE ATRASOS DO FILTRO FIR.
	
-- DECLARAÇÃO DE UMA MEMÓRIA ROM COM 41 COEFICIENTES DO FILTRO RAIZ DE COSSENO LEVANTADO.
-- COEFICIENTES DO FILTRO RRC ALTERADOS MANUALMENTE NO FILTRO FIR.
-- CONFIGURAÇÃO DE UM FILTRO FIR RAIZ DE COSSENO LEVANTADO.
TYPE coefs_type IS ARRAY (NATURAL RANGE <>) OF STD_LOGIC_VECTOR(11 DOWNTO 0); -- DECLARAÇÃO DE ARRAY PARA PERCORRER A MEMÓRIA ROM.
CONSTANT coefs : coefs_type(number_of_coefs - 1 DOWNTO 0) := 		      -- DECLARAÇÃO DE UMA MEMÓRIA CONSTANTE PERCORRIDA PELO AR 
(
-- FILTRO PASSA BAIXA UTILIZANDO JANELA DE KAISER WS = 0.26*PI (0 - 250Hz) BANDA DE PASSAGEM;  (WP = 0.0875*PI(1000HZ), pi) ;SIGMA= 0.015 (36dB REJEIÇÃO)=> PARA FS=23KHZ.
-- COEFICIENTES DO FILTRO OBTIDOS A PARTIR DO ARQUIVO coefs.dat GERADOS PELO CÓDIGO genCoefs.m.
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.0033681 ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.0025928 ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.0013571  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.0057259  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.0063752  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.001155   ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.0074855 ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.013118  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.0095692 ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.0037318  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.019357   ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.025178   ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.012408   ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.016358  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.044928  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.050074  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.014367  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.061807   ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.15667    ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.23524    ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.26569    ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.23524    ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.15667    ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.061807   ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.014367  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.050074  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.044928  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.016358  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.012408   ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.025178   ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.019357   ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.0037318  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.0095692 ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.013118  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.0074855 ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.001155   ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.0063752  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.0057259  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( 0.0013571  ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.0025928 ) ) , 12),	
CONV_STD_LOGIC_VECTOR( INTEGER( MULT_FACTOR *  ( -0.0033681 ) ) , 12)
);	

-- DECLARAÇÃO DE UMA MEMÓRIA RAM PARA ARMAZENAR AS CADEIAS DE ATRASO CONVOLUCIONADAS.
TYPE result_mult_type IS ARRAY (NATURAL RANGE <>) OF STD_LOGIC_VECTOR(19 DOWNTO 0); 
SIGNAL result_mult  : result_mult_type(number_of_coefs - 1 DOWNTO 0);			-- ARMAZENA O RESULTADO DAS MULTIPLICAÇÕES NO TEMPO

BEGIN
        
	clock_ad <= clock_ad_int1;
	
	-- PROCESSO PARA AMOSTRAGEM DO SINAL DE INTERRUPÇÃO VINDO DO A/D. (CHAVEAMENTO)
	PROCESS(clock)
		BEGIN
		IF(rising_edge(clock)) THEN
			IF(reset = '1') THEN

				int_ad_reg <= (OTHERS => '0');
				enable_ad <= '0';

			ELSE
				int_ad_reg(0) <= int_ad;
				int_ad_reg(2 DOWNTO 1) <= int_ad_reg(1 DOWNTO 0);
			
				IF(int_ad_reg(2 DOWNTO 1) = "10") THEN 
			
					enable_ad <= '1';

				ELSE
					enable_ad <= '0';

				END IF;
			
			END IF;
		END IF;
	END PROCESS;
	
	-- REGISTRAR BARRAMENTO DE 8 BITS DO SINAL DE ENTRADA VINDO DO AD.
	PROCESS(clock)
		VARIABLE sum_int : STD_LOGIC_VECTOR(21 DOWNTO 0);
		VARIABLE temp    : STD_LOGIC_VECTOR(21 DOWNTO 0);
	BEGIN
		IF(rising_edge(clock)) THEN
			IF(reset = '1') THEN

				sinal_ad_reg  <= (OTHERS => '0');
				delay_chain  <= (OTHERS => (OTHERS => '0'));
				result_mult <= (OTHERS => (OTHERS => '0'));
				result_sum <= (OTHERS => '0');
				sinal_out_rrc <= (OTHERS => '0');

			ELSIF(enable_ad = '1') THEN

			    	sinal_ad_reg(7 DOWNTO 0) <= sinal_in_rrc(7 DOWNTO 0);
				delay_chain(0) <= sinal_ad_reg;
				delay_chain(number_of_coefs-1 DOWNTO 1) <= delay_chain(number_of_coefs-2 DOWNTO 0);
				
				sum_int := (OTHERS => '0');
				
				LOOP1 : FOR i IN 0 TO number_of_coefs-1 LOOP
					result_mult(i) <= delay_chain(i) * coefs(i); -- REALIZAÇÃO DAS MULTIPLICAÇÕES.
					
					temp(19 DOWNTO 0) := result_mult(i);
					temp(21 DOWNTO 20) := (OTHERS => result_mult(i)(19));
					
					sum_int := sum_int + temp;-- REALIZAÇÃO DAS SOMAS.
					
					
				END LOOP;
				
				result_sum <= sum_int;
	
				-- sinal_out_rrc(7)<= NOT result_sum(18);                  -- SAÍDA PARA SÍNTESE
                                -- sinal_ou(6 downto 0) <= result_sum(17 downto 11);  -- O CONVERSOR D/A POSSUI O BIT MAIS SIGNIFICATIVO INVERTIDO.				
				sinal_out_rrc(7 DOWNTO 0) <= result_sum(18 DOWNTO 11);     -- SAÍDA PARA SIMULAÇÃO 
				
			END IF;
		END IF;
	END PROCESS;
	
END rtl;