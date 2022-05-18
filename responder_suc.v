module responder_suc(
	Reset,
	Clk,
	Start,
	Key_In,
	Led_Out,
	Buzzer_Out,
	Led_Overtime,
	Digitron_Out,
	DigitronCS_Out
);

input Reset,Start,Clk;
input [3:0] Key_In;
output Buzzer_Out,Led_Overtime;
output [3:0] Led_Out;
output [5:0] DigitronCS_Out;
output [7:0] Digitron_Out;
//*********************************************************
//Time control
//parameter T0_1s=5000000;
//parameter T0_2s=10000000;
//parameter T0_5s=25000000;//fosc=50MHz,o.5s->25MHz
parameter T1s=50000000;//1s->50MHz
parameter T30s=1500000000;//30s->1.5GHz
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
//*********************************************************
//Status
reg [2:0] Flag = 3'b000;
reg Block;
reg Over;
parameter Clr =3'b000;
parameter Wait=3'b001;
parameter Spon=3'b010;
parameter Flow=3'b011;
//*********************************************************
//User
reg [3:0] Key_tmp;
reg [3:0] Led_tmp;
reg Buzzer_tmp,Led_Overtime_tmp;
reg [31:0] Counter,Re;
reg [5:0] DigitronCS_tmp;
reg [7:0] Digitron_tmp;

integer Rest;
reg [3:0] NumH,NumL;
reg [7:0] NO;
parameter Dig0=6'b11_1110;//00_0001;
parameter Dig1=6'b11_1101;//00_0010;
parameter Dig5=6'b01_1111;//10_0000;
//*********************************************************
//Status
always @(posedge Clk) begin
	if (!Reset) begin
		// reset
		Flag <= Clr;//Status=0xxx
	end
	else begin
		if (Start) begin
			if (!Block) begin
			Flag <= Wait;//Status=110x
			end
			else begin
				if (!Over) begin
					Flag <= Spon;//Status=1110
				end
				else begin
					Flag <= Flow;//Status=1111
				end
			end
		end
		else begin
			Flag <= Clr;//Status=10xx
		end
	end
end
//*********************************************************
//Main function
always @(posedge Clk) begin
	//************************************
	//While someone responder, keep the data in unchanged
	if (!Block) begin
		if (!(Key_In[0] && Key_In[1] && Key_In[2] && Key_In[3])) begin
			Block <= 1'b1;
			Key_tmp <= ~Key_In;
			case(Key_In)
				4'b1110:begin
					NO <= Num1;
				end
				4'b1101:begin
					NO <= Num2;
				end
				4'b1011:begin
					NO <= Num3;
				end
				4'b0111:begin
					NO <= Num4;
				end
				default: NO <= Null;
			endcase
		end		
	end
	//************************************
	//Overtime sign
	if(Counter>=T30s) begin
		Over <= 1'b1;
	end
	//************************************
	//Clear all
	if (Flag==Clr) begin
		Block <= 1'b0;
		Over <= 1'b0;
		Counter <= 32'b0;
		Key_tmp <= 4'b0;
		Led_tmp <= 4'b0;
		Buzzer_tmp <= 1'b1;
		Digitron_tmp <= 8'b0;
		DigitronCS_tmp <= 6'b11_1111;
		Led_Overtime_tmp <= 1'b0;
	end
	//************************************
	//Wait for one of Key_In's bit transfer to '0'
	else if (Flag==Wait) begin
	end
	//***********************************
	//Responder and not overtime
	if (Flag==Spon) begin
		Counter <= Counter+1'b1;
		if (Counter<T0_5s) begin
			if(Counter%47800==0)begin
				Buzzer_tmp <= ~Buzzer_tmp;
			end
		end
		else begin
			Buzzer_tmp <= 1'b1;
		end
		Rest <= Counter%300;
		Re <= 30-Counter/T1s;
		NumL <= Re%10;
		NumH <= (Re-NumL)/10;
		//{NumH[3:0],NumL[3:0]} <= Re[7:0];
		if (Rest<100) begin
			Digitron_tmp <= NO;
			DigitronCS_tmp <= Dig5;
		end
		else 
		if(Rest<200 && Rest>=100) begin
			
			case(NumH)
				4'b0011:begin
					DigitronCS_tmp <= Dig1;
					Digitron_tmp <= Num3;
				end
				4'b0010:begin
					DigitronCS_tmp <= Dig1;
					Digitron_tmp <= Num2;
				end
				4'b0001:begin
					DigitronCS_tmp <= Dig1;
					Digitron_tmp <= Num1;
				end
				4'b0000:begin
					DigitronCS_tmp <= Dig1;
					Digitron_tmp <= Num0;
				end
				default:begin 
					DigitronCS_tmp <= Dig1;
					Digitron_tmp <= Null;
				end
			endcase
		end
		else begin
			DigitronCS_tmp <= Dig0;
			case(NumL)
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
				default: Digitron_tmp <= Null;
				endcase
		end
	end
	//***********************************
	//Overtime
	if (Flag==Flow) begin
		if (Counter<=(T1s+T30s)) begin
			Counter <= Counter+1'b1;
			if (Counter%25300==0) begin
				Buzzer_tmp <= ~Buzzer_tmp;
			end
			Led_Overtime_tmp <= 1'b1;
		end
		else begin
			Led_Overtime_tmp <= 1'b0;
			Buzzer_tmp <= 1'b1;
		end
	end
end

assign Buzzer_Out = Buzzer_tmp;
assign Led_Overtime = Led_Overtime_tmp;
assign Led_Out = Key_tmp;
assign Digitron_Out = Digitron_tmp;
assign DigitronCS_Out = DigitronCS_tmp;

endmodule