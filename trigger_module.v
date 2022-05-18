module trigger_module(
	CLK,Setn,Clrn,D,Q,D_out
);

input CLK,Setn,Clrn,D;
output Q,D_out;

wire f1,f2,f3,f4,f5,f6,f7;

nand 	U1(f1,Setn,f4,f2),
		U2(f2,f1,f5,Clrn),
		U3(f3,Setn,f6,f4),
		U4(f4,f3,CLK,Clrn),
		U5(f5,f4,Setn,CLK,f6),
		U6(f6,f5,D,Clrn),
		U7(f7,Setn,Clrn);
		
//*********************************		
/*always @(posedge CLK) begin
if(Setn==1'b1 && Clrn==1'b1)begin
nand	U7(f1,Setn,Clrn),
		U2(f2,f1,f5,Clrn),
		U3(f3,Setn,f6,f4),
		U4(f4,f3,CLK,Clrn),
		U5(f5,f4,Setn,CLK,f6),
		U6(f6,f5,D,Clrn);
end
else begin
nand 	U1(f1,Setn,f4,f2),
		U2(f2,f1,f5,Clrn),
		U3(f3,Setn,f6,f4),
		U4(f4,f3,CLK,Clrn),
		U5(f5,f4,Setn,CLK,f6),
		U6(f6,f5,D,Clrn);
end
end*/
assign D_out=~D;
assign Q=~f1;

endmodule