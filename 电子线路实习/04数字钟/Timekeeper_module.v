module Timekeeper_module(
	Clk,
	Rst,
	DispWeek_n,
	AdjtWeek,
	AdjtHour,
	AdjtMin,
	Buzzer_Out,
	Digitron_Out,
	DigitronCS_Out
	);

input Clk,Rst,DispWeek_n,AdjtWeek,AdjtHour,AdjtMin;
output Buzzer_Out;
output [7:0] Digitron_Out;
output [5:0] DigitronCS_Out;
//*********************************************************
//Display
parameter Num0=8'b0011_1111;//Display number with 7 led
parameter Num1=8'b0000_0110;
parameter Num2=8'b0101_1011;
parameter Num3=8'b0100_1111;
parameter Num4=8'b0110_0110;
parameter Num5=8'b0110_1101;
parameter Num6=8'b0111_1101;
parameter Num7=8'b0000_0111;
parameter Num8=8'b0111_1111;
parameter Num9=8'b0110_1111;
parameter Null=8'b0;
parameter Num0p=8'b1011_1111;//Display number with point by 7 led
parameter Num1p=8'b1000_0110;
parameter Num2p=8'b1101_1011;
parameter Num3p=8'b1100_1111;
parameter Num4p=8'b1110_0110;
parameter Num5p=8'b1110_1101;
parameter Num6p=8'b1111_1101;
parameter Num7p=8'b1000_0111;
parameter Num8p=8'b1111_1111;
parameter Num9p=8'b1110_1111;
parameter Nullp=8'b1000_0000;
//********************************************************
//Status
parameter Led1=6'b01_1111;
parameter Led2=6'b10_1111;
parameter Led3=6'b11_0111;
parameter Led4=6'b11_1011;
parameter Led5=6'b11_1101;
parameter Led6=6'b11_1110;
//********************************************************
//User
reg [31:0] Counter=32'b0,TCW=32'b0,TCH=32'b0,TCM=32'b0;
reg Buzzer_tmp;
reg [7:0] Digitron_tmp;
reg [5:0] DigitronCS_tmp;
reg [9:0] Hour=10'b0,Min=10'b0,Sec=10'b0,Week=10'b1;
reg [9:0] Rest;
reg [3:0] HNumH,HNumL,MNumH,MNumL,SNumH,SNumL,WeekL;
parameter T1s=50000000;
parameter T0_5s=25000000;
parameter T0_1s=5000000;
//********************************************************
//********************************************************
//Main Code
always @(posedge Clk) begin
	Counter <= Counter+1'b1;
	if (!Rst) begin
		// reset
		Hour <= 23;
		Min <= 59;
		Sec <= 30;
		Week <= 7;
		Counter <= 32'b0;
	end
	else if (Counter==T1s) begin
		if (Sec+1<60) begin
			Sec <= Sec+1;
		end
		else begin
			if (Min+1<60) begin
				Min <= Min+1;
			end
			else begin
				if (Hour+1<24) begin
					Hour <= Hour+1;
				end
				else begin
					if (Week+1<=7) begin
						Week <= Week+1;
					end
					else begin
						Week <= 1;
						
					end
					Hour <= 0;
				end
				Min <= 0;
			end	
			Sec <= 0;
		end
		Counter <= 32'b0;
	end
//*********************************
//Add Week
	if (!AdjtWeek) begin
		TCW <= TCW+1'b1;
		if (TCW==1) begin
			if (Week+1<=7) begin
				Week <= Week+1;
			end
			else begin
				Week <= 1;
			end
		end
		else begin
			if (TCW>=T1s && TCW%T0_1s==0) begin
				if (Week+1<=7) begin
					Week <= Week+1;
				end
				else begin
					Week <= 1;
				end
			end
		end
		if (TCW>12*T1s) begin
				TCW <= 32'b0;
		end
	end
	else begin
		TCW <= 32'b0;
	end
//**********************************
//Add hour
	if (!AdjtHour) begin
		TCH <= TCH+1'b1;
		if (TCH==1) begin
			if (Hour+1<24) begin
				Hour <= Hour+1;
			end
			else begin
				Hour <= 0;
			end
		end
		else begin
			if (TCH>=T1s && TCH%T0_1s==0) begin
				if (Hour+1<24) begin
					Hour <= Hour+1;
				end
				else begin
					Hour <= 0;
				end
			end
		end
		if (TCH>12*T1s) begin
			TCH <= 32'b0;
		end
	end
	else begin
		TCH <= 32'b0;
	end
//**********************************
//Add minute
	if (!AdjtMin) begin
		TCM <= TCM+1'b1;
		if (TCM==1) begin
			if (Min+1<60) begin
				Min <= Min+1;
			end
			else begin
				Min <= 0;
			end
		end
		else begin
			if (TCM>=T1s && TCM%T0_1s==0) begin
				if (Min+1<60) begin
					Min <= Min+1;
				end
				else begin
					Min <= 0;
				end
			end
		end
		if (TCM>12*T1s) begin
			TCM <= 32'b0;
		end
	end
	else begin
		TCM <= 32'b0;
	end
end
//********************************************************
//********************************************************
always @(posedge Clk) begin
	HNumL <= Hour%10;
	HNumH <= (Hour-HNumL)/10;
	MNumL <= Min%10;
	MNumH <= (Min-MNumL)/10;
	SNumL <= Sec%10;
	SNumH <= (Sec-SNumL)/10;
	WeekL <= Week;
	Rest <= Counter%300;
	if (DispWeek_n) begin
		if (Rest<50) begin
			DigitronCS_tmp <= Led1;
			case(HNumH)
				4'b0000:begin
					Digitron_tmp <= Num0;
				end
				4'b0001:begin
					Digitron_tmp <= Num1;
				end
				4'b0010:begin
					Digitron_tmp <= Num2;
				end
				default:begin
					Digitron_tmp <= Nullp;
				end
			endcase
		end
		else if (Rest<100 && Rest>=50) begin
			DigitronCS_tmp <= Led2;
			case(HNumL)
				4'b0000:begin
					Digitron_tmp <= Num0p;
				end
				4'b0001:begin
					Digitron_tmp <= Num1p;
				end
				4'b0010:begin
					Digitron_tmp <= Num2p;
				end
				4'b0011:begin
					Digitron_tmp <= Num3p;
				end
				4'b0100:begin
					Digitron_tmp <= Num4p;
				end
				4'b0101:begin
					Digitron_tmp <= Num5p;
				end
				4'b0110:begin
					Digitron_tmp <= Num6p;
				end
				4'b0111:begin
					Digitron_tmp <= Num7p;
				end
				4'b1000:begin
					Digitron_tmp <= Num8p;
				end
				4'b1001:begin
					Digitron_tmp <= Num9p;
				end
				default:begin 
					Digitron_tmp <= Num8p;
				end
			endcase
		end
		else if (Rest<150 && Rest>=100) begin
			DigitronCS_tmp <= Led3;
			case(MNumH)
				4'b0101:begin
					Digitron_tmp <= Num5;
				end
				4'b0100:begin
					Digitron_tmp <= Num4;
				end
				4'b0011:begin
					Digitron_tmp <= Num3;
				end
				4'b0010:begin
					Digitron_tmp <= Num2;
				end
				4'b0001:begin
					Digitron_tmp <= Num1;
				end
				4'b0000:begin
					Digitron_tmp <= Num0;
				end
				default:begin 
					Digitron_tmp <= Nullp;
				end
			endcase
		end
		else if (Rest<200 && Rest>=150) begin
			DigitronCS_tmp <= Led4;
			case(MNumL)
				4'b1001:begin
					Digitron_tmp <= Num9p;
				end
				4'b1000:begin
					Digitron_tmp <= Num8p;
				end
				4'b0111:begin
					Digitron_tmp <= Num7p;
				end
				4'b0110:begin
					Digitron_tmp <= Num6p;
				end
				4'b0101:begin
					Digitron_tmp <= Num5p;
				end
				4'b0100:begin
					Digitron_tmp <= Num4p;
				end
				4'b0011:begin
					Digitron_tmp <= Num3p;
				end
				4'b0010:begin
					Digitron_tmp <= Num2p;
				end
				4'b0001:begin
					Digitron_tmp <= Num1p;
				end
				4'b0000:begin
					Digitron_tmp <= Num0p;
				end
				default:begin 
					Digitron_tmp <= Nullp;
				end
			endcase
		end
		else if (Rest<250 && Rest>=200) begin
			DigitronCS_tmp <= Led5;
			case(SNumH)
				4'b0101:begin
					Digitron_tmp <= Num5;
				end
				4'b0100:begin
					Digitron_tmp <= Num4;
				end
				4'b0011:begin
					Digitron_tmp <= Num3;
				end
				4'b0010:begin
					Digitron_tmp <= Num2;
				end
				4'b0001:begin
					Digitron_tmp <= Num1;
				end
				4'b0000:begin
					Digitron_tmp <= Num0;
				end
				default:begin 
					Digitron_tmp <= Nullp;
				end
			endcase
		end
		else if (Rest<300 && Rest>=250) begin
			DigitronCS_tmp <= Led6;
			case(SNumL)
				4'b1001:begin
					Digitron_tmp <= Num9;
				end
				4'b1000:begin
					Digitron_tmp <= Num8;
				end
				4'b0111:begin
					Digitron_tmp <= Num7;
				end
				4'b0110:begin
					Digitron_tmp <= Num6;
				end
				4'b0101:begin
					Digitron_tmp <= Num5;
				end
				4'b0100:begin
					Digitron_tmp <= Num4;
				end
				4'b0011:begin
					Digitron_tmp <= Num3;
				end
				4'b0010:begin
					Digitron_tmp <= Num2;
				end
				4'b0001:begin
					Digitron_tmp <= Num1;
				end
				4'b0000:begin
					Digitron_tmp <= Num0;
				end
				default:begin 
					Digitron_tmp <= Nullp;
				end
			endcase
		end
	end
	else begin//Display week number
		DigitronCS_tmp <= Led6;
		case(WeekL)
			4'b0111:begin
				Digitron_tmp <= Num8;
			end
			4'b0110:begin
				Digitron_tmp <= Num6;
			end
			4'b0101:begin
				Digitron_tmp <= Num5;
			end
			4'b0100:begin
				Digitron_tmp <= Num4;
			end
			4'b0011:begin
				Digitron_tmp <= Num3;
			end
			4'b0010:begin
				Digitron_tmp <= Num2;
			end
			4'b0001:begin
				Digitron_tmp <= Num1;
			end
			default:begin 
				Digitron_tmp <= Nullp;
			end
		endcase
	end
end
//********************************************************
//********************************************************
//Warning

always @(posedge Clk) begin
	if(Min==59)begin
		if (Sec==50 || Sec==52 || Sec==54 || Sec==56 || Sec==58)begin
			if(Counter%47800==0)begin
				Buzzer_tmp <= ~Buzzer_tmp;
			end
		end
	end
	else 
	if (Sec==0 && Min==0) begin
	    if (Counter%25300==0) begin
	    	Buzzer_tmp <= ~Buzzer_tmp;
	    end
	end
	else begin
		Buzzer_tmp <= 1'b1;
	end
end

assign Buzzer_Out = Buzzer_tmp;
assign Digitron_Out = Digitron_tmp;
assign DigitronCS_Out = DigitronCS_tmp;

endmodule