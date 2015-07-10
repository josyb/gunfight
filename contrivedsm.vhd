-- contrived state-machine example 


library	ieee;
	use	ieee.std_logic_1164.all ;
	use	ieee.numeric_std.all ;

	
	
	
entity contrivedsm is
	generic (
		STATE_MACHINE_STYLE		:	string	:= "HYBRIDJOSYB" 	--	"TWOPROCESS" or "SYNCHRONOUS" or "HYBRID" or "HYBRIDJOSYB"
		) ;
	port (
		Clk		:	in	std_logic ;
		Reset	:	in	std_logic ;
		
		A		:	in	std_logic ;
		B		:	in	std_logic ;
		C		:	in	std_logic ;
		
		Stage	:	out	natural range 0 to 3 ;
		
		DoneP	:	out std_logic
		) ;
	end contrivedsm ;

	
architecture arch of contrivedsm is

	constant	RANGE_COUNTER	:	natural		:=	1000 ;
	
	type contrivedsm_states is ( S0 , S1 , S2 , S3 ) ;
	
	
	
	

	component downcounter
		generic (
			COUNT_MAX : natural := 2 ** 30 - 1
			) ;
		port (
			Clk    : in  std_logic;
			Reset  : in  std_logic                    := '0';
			SLoad  : in  std_logic;
			Data   : in  natural range 0 to COUNT_MAX := COUNT_MAX;
			CntEn  : in  std_logic                    := '1';
			Q      : out natural range 0 to COUNT_MAX;
			IsOne  : out std_logic;
			IsZero : out std_logic
			);
		end component downcounter;
		

begin

	gentwoprocess : if STATE_MACHINE_STYLE = "TWOPROCESS" generate
		signal	smn , smp						:	contrivedsm_states ;
		signal	countern , counterp				:	natural	range 0 to RANGE_COUNTER ;
		signal	stagen , stagep					:	natural range 0 to 3 ;
		signal 	donen							:	std_logic ;
	
		begin
			process( smp , A , B , C , counterp , stagep)
				begin
					donen <= '0' ;
					stagen <= stagep ;
					
					
					case smp is
						when S0 =>
							if (A = '1') then
								smn <= S1 ;
								countern <= 25 ;
								stagen <= 1 ;
							elsif (B = '1') then
								smn <= S2 ;
								countern <= 50 ;
								stagen <= 2 ;
							elsif (C = '1') then
								smn <= S3 ;
								countern <= 75 ;
								stagen <= 3 ;
							else
								smn <= S0 ;
								countern <= 0 ;
							end if ;
							
						when S1 =>
							if (counterp = 0) then
								smn <= S2 ;
								countern <= 100 ;
								stagen <= 2 ;
							else
								smn <= S1 ;
								countern <= counterp - 1 ;
							end if ;
							
						when S2 =>
							stagen <= 2 ;
							if (counterp = 0) then
								smn <= S3 ;
								countern <= 200 ;
								stagen <= 3 ;
							else
								smn <= S2 ;
								countern <= counterp - 1 ;
							end if ;
	
						when S3 =>
							stagen <= 3 ;
							if (counterp = 0) then
								smn <= S0 ;
								countern <= 0 ;
								donen <= '1' ;
								stagen <= 0 ;
							else
								smn <= S3 ;
								countern <= counterp - 1 ;
							end if ;
							
					end case ;
					
				end process ;
		
			process (Clk, Reset) is
				begin
					if (Reset = '1') then
						smp <= S0 ;	
						counterp <= 0 ;
						DoneP <= '0' ;
						stagep <= 0 ;
						
					elsif rising_edge(Clk) then
						smp <= smn ;
						counterp <= countern ;
						DoneP <= donen ;
						stagep <= stagen ;
					end if;
				end process ;
			
			Stage <= stagep ;
	end generate ;
	
	
	
	gensynchronous: if STATE_MACHINE_STYLE = "SYNCHRONOUS" generate
		signal	sm 								:	contrivedsm_states ;
		signal	counter							:	natural	range 0 to RANGE_COUNTER ;
		
		begin
			process (Clk, Reset) is
				begin
					if (Reset = '1') then
						sm <= S0 ;	
						counter <= 0 ;
						DoneP <= '0' ;
						Stage <= 0 ;
						
					elsif rising_edge(Clk) then
						DoneP <= '0' ;
						
						case sm is
							when S0 =>
								if (A = '1') then
									sm <= S1 ;
									counter <= 25 ;
									Stage <= 1 ;
								elsif (B = '1') then
									sm <= S2 ;
									counter <= 50 ;
									Stage <= 2 ;
								elsif (C = '1') then
									sm <= S3 ;
									counter <= 75 ;
									Stage <= 3 ;
								end if ;
								
							when S1 =>
								if (counter = 0) then
									sm <= S2 ;
									counter <= 100 ;
									Stage <= 2 ;
								end if ;
								
							when S2 =>
								if (counter = 0) then
									sm <= S3 ;
									counter <= 200 ;
									Stage <= 3 ;
								end if ;
		
							when S3 =>
								if (counter = 0) then
									sm <= S0 ;
									DoneP <= '1' ;
									Stage <= 0 ;
								end if ;
								
						end case ;
						
						if ( counter /= 0) then
							counter <= counter - 1 ;
						end if ;
						
					end if;
				end process ;
		
	end generate ;
	
	
	
	genhybrid : if (STATE_MACHINE_STYLE = "HYBRID") or (STATE_MACHINE_STYLE = "HYBRIDJOSYB") generate
		signal	smhn , smhp						:	contrivedsm_states ;
		signal	counterh						:	natural	range 0 to RANGE_COUNTER ;
		signal	counterhdata 					:	natural range 0 to RANGE_COUNTER;
		signal	counterh_IsZero					:	std_logic ;
		signal	counterhsload					:	std_logic;
		signal 	donen							:	std_logic ;
	
		begin
			process( smhp , A , B , C , counterh_IsZero)
				begin
					donen <= '0' ;
					counterhdata <= 200 ;
					counterhsload <= '0' ;
					Stage <= 0 ;
								
					case smhp is
						when S0 =>
							if (A = '1') then
								smhn <= S1 ;
								counterhdata <= 25 ;
								counterhsload <= '1' ;
							elsif (B = '1') then
								smhn <= S2 ;
								counterhdata <= 50 ;
								counterhsload <= '1' ;
							elsif (C = '1') then
								smhn <= S3 ;
								counterhdata <= 75 ;
								counterhsload <= '1' ;
							else
								smhn <= S0 ;
							end if ;
							
						when S1 =>
							Stage <= 1 ;
							if (counterh_IsZero = '1') then
								smhn <= S2 ;
								counterhdata <= 100 ;
								counterhsload <= '1' ;
							else
								smhn <= S1 ;
							end if ;
							
						when S2 =>
							Stage <= 2 ;
							if (counterh_IsZero = '1') then
								smhn <= S3 ;
								counterhsload <= '1' ;
							else
								smhn <= S2 ;
							end if ;
	
						when S3 =>
							Stage <= 3 ;
							if (counterh_IsZero = '1') then
								smhn <= S0 ;
								donen <= '1' ;
							else
								smhn <= S3 ;
							end if ;
							
					end case ;
					
				end process ;
		
			genclockedhybrid : if STATE_MACHINE_STYLE = "HYBRID" generate
				process (Clk, Reset) is
					begin
						if (Reset = '1') then
							smhp <= S0 ;	
							counterh <= 0 ;
							counterh_IsZero <= '0' ;
							DoneP <= '0' ;
							
						elsif rising_edge(Clk) then
						
							smhp <= smhn ;
							DoneP <= donen ;
							
							if (counterhsload = '1') or (counterh /= 0) then
								if (counterhsload = '1') then
									counterh <= counterhdata ;
									counterh_IsZero <= '0' ;
								else
									counterh <= counterh - 1 ;
									if (counterh = 1) then
										counterh_IsZero <= '1' ;
									end if ;
								end if ;
							end if ;
						end if;
					end process ;
			end generate ;
				
			genclockedhybridjosyb : if STATE_MACHINE_STYLE = "HYBRIDJOSYB" generate	
				process (Clk, Reset) is
					begin
						if (Reset = '1') then
							smhp <= S0 ;	
							DoneP <= '0' ;
							
						elsif rising_edge(Clk) then
							smhp <= smhn ;
							DoneP <= donen ;
							
						end if;
					end process ;
				
				counterh : downcounter
					generic map(
						COUNT_MAX => RANGE_COUNTER
						)
					port map(
						Clk    => Clk,
						Reset  => Reset,
						SLoad  => counterhsload ,
						Data   => counterhdata ,
						CntEn  => '1' ,
						Q      => open ,
						IsOne  => open ,
						IsZero => counterh_IsZero
						);
			end generate ;
		
	end generate ;
	
	
	

end arch ;
