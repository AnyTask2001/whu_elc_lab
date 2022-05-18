module trigger8D_module(
	CLK,Setn,Clrn,D,Q,led
);

input CLK,Setn,Clrn;
input [7:0] D;
output [7:0] Q;
output [7:0] led;
reg [7:0] t;

always @(posedge CLK or negedge Setn or negedge Clrn)
begin
	t[0] <= (D[0]&Setn&Clrn)|~Setn;
   t[1] <= (D[1]&Setn&Clrn)|~Setn;
   t[2] <= (D[2]&Setn&Clrn)|~Setn;
	t[3] <= (D[3]&Setn&Clrn)|~Setn;
	t[4] <= (D[4]&Setn&Clrn)|~Setn;
	t[5] <= (D[5]&Setn&Clrn)|~Setn;
	t[6] <= (D[6]&Setn&Clrn)|~Setn;
	t[7] <= (D[7]&Setn&Clrn)|~Setn;
end
 
assign Q=t;
assign led=D;
endmodule