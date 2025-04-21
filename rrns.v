///////////////////////////////////////////////////////////////////////////////////////////////////////////////

module rrnsalu(input [31:0] in1,in2, input add_sub,input [48:0] in_err, output [31:0] out, output error);
wire [48:0] r1,r2,r3,r2_a, r2_b, r2_sub,r_err;
//wire [31:0] in2a;
wire sub;


bin2RRNS b1(.bin(in1), .residue(r1));
bin2RRNS b21(.bin(in2), .residue(r2_a));

//assign in2a= (~in2)+1;

//bin2RRNSn b22(.bin(in2), .residue(r2_b));
//assign r21 = in2[31] ? r2_b: r2_a; 
 
res_sub b5 (.res_in(r2_a), .res_out(r2_sub));// transferred these two lines from down to here-nagasai
assign r2 = add_sub ? r2_sub  : r2_a;
assign sub = (add_sub  && (in2 > in1)) ? 1 :0 ;
residue_adder b3(.residue1(r1), .residue2(r2), .res_out(r3));

assign r_err= in_err^r3;

//residue_adder b3(.residue1(r1), .residue2(r2), .res_out(r3));
residue_check b4(.in1(in1),.in2(in2),.res_in(r_err), .add_sub(sub), .bin_out(out), .error(error));


//assign error = error1 & err1;

endmodule


module bin2RRNS(input [31:0] bin, output [48:0] residue);

modulo101n m1(.bin(bin),.s(1'b0),.mod101(residue[48:42]));
modulo103n m2(.bin(bin),.s(1'b0),.mod103(residue[41:35]));
modulo107n m3(.bin(bin),.s(1'b0),.mod107(residue[34:28]));
modulo109n m4(.bin(bin),.s(1'b0),.mod109(residue[27:21]));
modulo113n m5(.bin(bin),.s(1'b0),.mod113(residue[20:14]));
modulo127n m6(.bin(bin),.s(1'b0),.mod127(residue[13:7]));
assign residue[6:0] = bin[6:0];

endmodule




module res_sub(input [48:0] res_in, output [48:0] res_out);

assign res_out[48:42] = (7'd101 - res_in[48:42]);
assign res_out[41:35] = (7'd103 - res_in[41:35]);
assign res_out[34:28] = (7'd107 - res_in[34:28]);
assign res_out[27:21] = (7'd109 - res_in[27:21]);
assign res_out[20:14] = (7'd113 - res_in[20:14]);
assign res_out[13:7] = (7'd127 - res_in[13:7]);
assign res_out[6:0] = (8'd128 - res_in[6:0]);
endmodule

module residue_adder(input [48:0] residue1, residue2, output [48:0] res_out);
wire [7:0] res101,res103,res107,res109,res113,res127;
assign res101 = residue1[48:42] + residue2[48:42];
assign res103 = residue1[41:35] + residue2[41:35];
assign res107 = residue1[34:28] + residue2[34:28];
assign res109 = residue1[27:21] + residue2[27:21];
assign res113 = residue1[20:14] + residue2[20:14];
assign res127 = residue1[13:7] + residue2[13:7];

assign res_out[48:42] = (res101<8'd101) ? res101[6:0] : (res101 - 8'd101);
assign res_out[41:35] = (res103<8'd103) ? res103[6:0] : (res103 - 8'd103);
assign res_out[34:28] = (res107<8'd107) ? res107[6:0] : (res107 - 8'd107);
assign res_out[27:21] = (res109<8'd109) ? res109[6:0] : (res109 - 8'd109);
assign res_out[20:14] = (res113<8'd113) ? res113[6:0] : (res113 - 8'd113);
assign res_out[13:7]  = (res127<8'd127) ? res127[6:0] : (res127 - 8'd127);
assign res_out[6:0]   = residue1[6:0] + residue2[6:0] ;
endmodule




module residue_check(input [31:0] in1, input [31:0] in2, input [48:0] res_in, input add_sub, output reg [31:0] bin_out, output reg error);
wire [31:0] b1,b2,b3,b4;
wire [6:0] res101,res103,res107,res109,res113,res127,res128;
wire [6:0] check101,check103_1,check103_2,check107,check109,check113,check127,check128;
wire s1,s2,s3,s4;

assign res101 = res_in[48:42];
assign res103 = res_in[41:35];
assign res107 = res_in[34:28];
assign res109 = res_in[27:21];
assign res113 = res_in[20:14];
assign res127 = res_in[13:7];
assign res128 = res_in[6:0];

mrc1 m1(.res101(res101),.res103(res103),.res107(res107),.res109(res109),.res113(res113),.add_sub(add_sub), .bin_out(b1));
modulo127n md1(.bin(b1),.s(1'b0),.mod127(check127));
assign check128 = b1[6:0];
assign s1 = (check127==res127)||(check128==res128);

mrc2 m2(.res101(res101),.res103(res103),.res107(res107),.res127(res127),.res128(res128),.add_sub(add_sub), .bin_out(b2));
modulo109n md2(.bin(b2),.s(1'b0),.mod109(check109));
modulo113n md3(.bin(b2),.s(1'b0),.mod113(check113));
assign s2 = (check109==res109)||(check113==res113);

mrc3 m3(.res101(res101),.res109(res109),.res113(res113),.res127(res127),.res128(res128),.add_sub(add_sub), .bin_out(b3));
modulo103n md4(.bin(b3),.s(1'b0),.mod103(check103_1));
modulo107n md5(.bin(b3),.s(1'b0),.mod107(check107));
assign s3 = (check103_1==res103)||(check107==res107);

mrc4 m4(.res107(res107),.res109(res109),.res113(res113),.res127(res127),.res128(res128),.add_sub(add_sub), .bin_out(b4));
modulo101n md6(.bin(b4),.s(1'b0),.mod101(check101));
modulo103n md7(.bin(b4),.s(1'b0),.mod103(check103_2));
assign s4 = (check101==res101)||(check103_2==res103);

always@(*)
begin
   
     if (s1)
        begin
        bin_out = b1;
        error = 1'b0;
        end
     else if(s2)
        begin
        bin_out = b2;
        error = 1'b0;
        end
     else if(s3)
        begin
        bin_out = b3;
        error = 1'b0;
        end
     else if(s4)
        begin
        bin_out = b4;
        error = 1'b0;
        end
    else if (in2 === 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) begin
    bin_out = b1;
    error = 1'b0;  // Set error to 0 if in_variable has unknown values
    
    end
    
     else if( (s1==0) && (s2==0) && (s3==0) && (s4==0))
        begin
        bin_out = b1;
        error = 1'b1;
        end     
 
end

endmodule




module modulo101n(input [31:0] bin, input s, output reg [6:0] mod101);
wire [6:0] s31,s30,s29,s28,s27,s26,s25,s24,s23,s22,s21,s20,s19,s18,s17,s16,s15,s14,s13,s12,s11,s10,s9,s8,s7;
wire [10:0] sum;

assign s31 = s ? (bin[31] ? 7'd67 : 7'd0) : (bin[31] ? 7'd34 : 7'd0 );
assign s30 = bin[30] ? 7'd17 : 7'd0;
assign s29 = bin[29] ? 7'd59 : 7'd0;
assign s28 = bin[28] ? 7'd80 : 7'd0;
assign s27 = bin[27] ? 7'd40 : 7'd0;
assign s26 = bin[26] ? 7'd20 : 7'd0;
assign s25 = bin[25] ? 7'd10 : 7'd0;
assign s24 = bin[24] ? 7'd5 : 7'd0;
assign s23 = bin[23] ? 6'd53 : 7'd0;
assign s22 = bin[22] ? 7'd77 : 7'd0;
assign s21 = bin[21] ? 7'd89 : 7'd0;
assign s20 = bin[20] ? 7'd95 : 7'd0;
assign s19 = bin[19] ? 7'd98 : 7'd0;
assign s18 = bin[18] ? 7'd49 : 7'd0;
assign s17 = bin[17] ? 7'd75 : 7'd0;
assign s16 = bin[16] ? 7'd88 : 7'd0;
assign s15 = bin[15] ? 7'd44 : 7'd0;
assign s14 = bin[14] ? 7'd22 : 7'd0;
assign s13 = bin[13] ? 7'd11 : 7'd0;
assign s12 = bin[12] ? 7'd56 : 7'd0;
assign s11 = bin[11] ? 7'd28 : 7'd0;
assign s10 = bin[10] ? 7'd14 : 7'd0;
assign s9 = bin[9] ? 7'd7 : 7'd0;
assign s8 = bin[8] ? 7'd54 : 7'd0;
assign s7 = bin[7] ? 7'd27 : 7'd0;

assign sum = bin[6:0]+s7+s8+s9+s10+s11+s12+s13+s14+s15+s16+s17+s18+s19+s20+s21+s22+s23+s24+s25+s26+s27+s28+s29+s30+s31;

always@(*)
begin
    if(sum < 12'd101)
        mod101 = sum;
    else if(sum < 12'd202)
        mod101 = sum - 12'd101;
    else if(sum < 12'd303)
        mod101 = sum - 12'd202;
    else if(sum < 12'd404)
        mod101 = sum - 12'd303;
    else if(sum < 12'd505)
        mod101 = sum - 12'd404;
    else if(sum < 12'd606)
        mod101 = sum - 12'd505;
    else if(sum < 12'd707)
        mod101 = sum - 12'd606;
    else if(sum < 12'd808)
        mod101 = sum - 12'd707;
    else if(sum < 12'd909)
        mod101 = sum - 12'd808;
    else if(sum < 12'd1010)
        mod101 = sum - 12'd909;
    else if(sum < 12'd1111)
        mod101 = sum - 12'd1010;
    else if(sum < 12'd1212)
        mod101 = sum - 12'd1111;
    else
        mod101 = sum - 12'd1212;    

end
endmodule


module modulo103n(input [31:0] bin, input s, output reg [6:0] mod103);
wire [6:0] s31,s30,s29,s28,s27,s26,s25,s24,s23,s22,s21,s20,s19,s18,s17,s16,s15,s14,s13,s12,s11,s10,s9,s8,s7;
wire [10:0] sum;

assign s31 = s ? (bin[31] ? 7'd20 : 7'd0) : (bin[31] ? 7'd83 : 7'd0);
assign s30 = bin[30] ? 7'd93 : 7'd0;
assign s29 = bin[29] ? 7'd98 : 7'd0;
assign s28 = bin[28] ? 7'd49 : 7'd0;
assign s27 = bin[27] ? 7'd76 : 7'd0;
assign s26 = bin[26] ? 7'd38 : 7'd0;
assign s25 = bin[25] ? 7'd19 : 7'd0;
assign s24 = bin[24] ? 7'd61 : 7'd0;
assign s23 = bin[23] ? 7'd82 : 7'd0;
assign s22 = bin[22] ? 7'd41 : 7'd0;
assign s21 = bin[21] ? 7'd72 : 7'd0;
assign s20 = bin[20] ? 7'd36 : 7'd0;
assign s19 = bin[19] ? 7'd18 : 7'd0;
assign s18 = bin[18] ? 7'd9 : 7'd0;
assign s17 = bin[17] ? 7'd56 : 7'd0;
assign s16 = bin[16] ? 7'd28 : 7'd0;
assign s15 = bin[15] ? 7'd14 : 7'd0;
assign s14 = bin[14] ? 7'd7 : 7'd0;
assign s13 = bin[13] ? 7'd55 : 7'd0;
assign s12 = bin[12] ? 7'd79 : 7'd0;
assign s11 = bin[11] ? 7'd91 : 7'd0;
assign s10 = bin[10] ? 7'd97 : 7'd0;
assign s9 = bin[9] ? 7'd100 : 7'd0;
assign s8 = bin[8] ? 7'd50 : 7'd0;
assign s7 = bin[7] ? 7'd25 : 7'd0;

assign sum = bin[6:0]+s7+s8+s9+s10+s11+s12+s13+s14+s15+s16+s17+s18+s19+s20+s21+s22+s23+s24+s25+s26+s27+s28+s29+s30+s31;

always@(*)
begin
    if(sum < 12'd103)
        mod103 = sum;
    else if(sum < 12'd206)
        mod103 = sum - 12'd103;
    else if(sum < 12'd309)
        mod103 = sum - 12'd206;
    else if(sum < 12'd412)
        mod103 = sum - 12'd309;
    else if(sum < 12'd515)
        mod103 = sum - 12'd412;
    else if(sum < 12'd618)
        mod103 = sum - 12'd515;
    else if(sum < 12'd721)
        mod103 = sum - 12'd618;
    else if(sum < 12'd824)
        mod103 = sum - 12'd721;
    else if(sum < 12'd927)
        mod103 = sum - 12'd824;
    else if(sum < 12'd1030)
        mod103 = sum - 12'd927;
    else if(sum < 12'd1133)
        mod103 = sum - 12'd1030;
    else if(sum < 12'd1236)
        mod103 = sum - 12'd1133;
    else if(sum < 12'd1339)
        mod103 = sum - 12'd1236;
   else if(sum < 12'd1442)
        mod103 = sum - 12'd1339;
    else
        mod103 = sum -12'd1442;  

end
endmodule





module modulo107n(input [31:0] bin, input s, output reg [6:0] mod107);
wire [6:0] s31,s30,s29,s28,s27,s26,s25,s24,s23,s22,s21,s20,s19,s18,s17,s16,s15,s14,s13,s12,s11,s10,s9,s8,s7;
wire [10:0] sum;

assign s31 = s ? (bin[31] ? 7'd39 : 7'd0) : (bin[31] ? 7'd68 : 7'd0);
assign s30 = bin[30] ? 7'd34 : 7'd0;
assign s29 = bin[29] ? 7'd17 : 7'd0;
assign s28 = bin[28] ? 7'd62 : 7'd0;
assign s27 = bin[27] ? 7'd31 : 7'd0;
assign s26 = bin[26] ? 7'd69 : 7'd0;
assign s25 = bin[25] ? 7'd88 : 7'd0;
assign s24 = bin[24] ? 7'd44 : 7'd0;
assign s23 = bin[23] ? 7'd22 : 7'd0;
assign s22 = bin[22] ? 7'd11 : 7'd0;
assign s21 = bin[21] ? 7'd59 : 7'd0;
assign s20 = bin[20] ? 7'd83 : 7'd0;
assign s19 = bin[19] ? 7'd95 : 7'd0;
assign s18 = bin[18] ? 7'd101 : 7'd0;
assign s17 = bin[17] ? 7'd104 : 7'd0;
assign s16 = bin[16] ? 7'd52 : 7'd0;
assign s15 = bin[15] ? 7'd26 : 7'd0;
assign s14 = bin[14] ? 7'd13 : 7'd0;
assign s13 = bin[13] ? 7'd60 : 7'd0;
assign s12 = bin[12] ? 7'd30 : 7'd0;
assign s11 = bin[11] ? 7'd15 : 7'd0;
assign s10 = bin[10] ? 7'd61 : 7'd0;
assign s9 = bin[9] ? 7'd84 : 7'd0;
assign s8 = bin[8] ? 7'd42 : 7'd0;
assign s7 = bin[7] ? 7'd21 : 7'd0;

assign sum = bin[6:0]+s7+s8+s9+s10+s11+s12+s13+s14+s15+s16+s17+s18+s19+s20+s21+s22+s23+s24+s25+s26+s27+s28+s29+s30+s31;

always@(*)
begin
    if(sum < 12'd107)
        mod107 = sum;
    else if(sum < 12'd214)
        mod107 = sum - 12'd107;
    else if(sum < 12'd321)
        mod107 = sum - 12'd214;
    else if(sum < 12'd428)
        mod107 = sum - 12'd321;
    else if(sum < 12'd535)
        mod107 = sum - 12'd428;
    else if(sum < 12'd642)
        mod107 = sum - 12'd535;
    else if(sum < 12'd749)
        mod107 = sum - 12'd642;
    else if(sum < 12'd856)
        mod107 = sum - 12'd749;
    else if(sum < 12'd963)
        mod107 = sum - 12'd856;
    else if(sum < 12'd1070)
        mod107 = sum - 12'd963;
    else if(sum < 12'd1177)
        mod107 = sum - 12'd1070;
    else if(sum < 12'd1284)
        mod107 = sum - 12'd1177;
     else if(sum < 12'd1391)
        mod107 = sum - 12'd1284;
    else
        mod107 = sum -12'd1391;     
     

end
endmodule


module modulo109n(input [31:0] bin, input s, output reg [6:0] mod109);
wire [6:0] s31,s30,s29,s28,s27,s26,s25,s24,s23,s22,s21,s20,s19,s18,s17,s16,s15,s14,s13,s12,s11,s10,s9,s8,s7;
wire [10:0] sum;

assign s31 = s ? (bin[31] ? 7'd17 : 7'd0) : (bin[31] ? 7'd92 : 7'd0);
assign s30 = bin[30] ? 7'd46 : 7'd0;
assign s29 = bin[29] ? 7'd23 : 7'd0;
assign s28 = bin[28] ? 7'd66 : 7'd0;
assign s27 = bin[27] ? 7'd33 : 7'd0;
assign s26 = bin[26] ? 7'd71 : 7'd0;
assign s25 = bin[25] ? 7'd90 : 7'd0;
assign s24 = bin[24] ? 7'd45 : 7'd0;
assign s23 = bin[23] ? 7'd77 : 7'd0;
assign s22 = bin[22] ? 7'd93 : 7'd0;
assign s21 = bin[21] ? 7'd101 : 7'd0;
assign s20 = bin[20] ? 7'd105 : 7'd0;
assign s19 = bin[19] ? 7'd107 : 7'd0;
assign s18 = bin[18] ? 7'd108 : 7'd0;
assign s17 = bin[17] ? 7'd54 : 7'd0;
assign s16 = bin[16] ? 7'd27 : 7'd0;
assign s15 = bin[15] ? 7'd68 : 7'd0;
assign s14 = bin[14] ? 7'd34 : 7'd0;
assign s13 = bin[13] ? 7'd17 : 7'd0;
assign s12 = bin[12] ? 7'd63 : 7'd0;
assign s11 = bin[11] ? 7'd86 : 7'd0;
assign s10 = bin[10] ? 7'd43 : 7'd0;
assign s9 = bin[9] ? 7'd76 : 7'd0;
assign s8 = bin[8] ? 7'd38 : 7'd0;
assign s7 = bin[7] ? 7'd19 : 7'd0;

assign sum = bin[6:0]+s7+s8+s9+s10+s11+s12+s13+s14+s15+s16+s17+s18+s19+s20+s21+s22+s23+s24+s25+s26+s27+s28+s29+s30+s31;

always@(*)
begin
    if(sum < 12'd109)
        mod109 = sum;
    else if(sum < 12'd218)
        mod109 = sum - 12'd109;
    else if(sum < 12'd327)
        mod109 = sum - 12'd218;
    else if(sum < 12'd436)
        mod109 = sum - 12'd327;
    else if(sum < 12'd545)
        mod109 = sum - 12'd436;
    else if(sum < 12'd654)
        mod109 = sum - 12'd545;
    else if(sum < 12'd763)
        mod109 = sum - 12'd654;
    else if(sum < 12'd872)
        mod109 = sum - 12'd763;
    else if(sum < 12'd981)
        mod109 = sum - 12'd872;
    else if(sum < 12'd1090)
        mod109 = sum - 12'd981;
    else if(sum < 12'd1199)
        mod109 = sum - 12'd1090;
    else if(sum < 12'd1308)
        mod109 = sum - 12'd1199;
    else if(sum < 12'd1417)
        mod109 = sum - 12'd1308;
    else if(sum < 12'd1526)
        mod109 = sum - 12'd1417;
   else if(sum < 12'd1635)
        mod109 = sum - 12'd1526;
    else
        mod109 = sum - 12'd1635;      

end
endmodule



module modulo113n(input [31:0] bin, input s, output reg [6:0] mod113);
wire [6:0] s31,s30,s29,s28,s27,s26,s25,s24,s23,s22,s21,s20,s19,s18,s17,s16,s15,s14,s13,s12,s11,s10,s9,s8,s7;
wire [10:0] sum;

assign s31 = s ? (bin[31] ? 7'd105 : 7'd0) : (bin[31] ? 7'd8 : 7'd0);
assign s30 = bin[30] ? 7'd4 : 7'd0;
assign s29 = bin[29] ? 7'd2 : 7'd0;
assign s28 = bin[28] ? 7'd1 : 7'd0;
assign s27 = bin[27] ? 7'd57 : 7'd0;
assign s26 = bin[26] ? 7'd85 : 7'd0;
assign s25 = bin[25] ? 7'd99 : 7'd0;
assign s24 = bin[24] ? 7'd106 : 7'd0;
assign s23 = bin[23] ? 7'd53 : 7'd0;
assign s22 = bin[22] ? 7'd83 : 7'd0;
assign s21 = bin[21] ? 7'd98 : 7'd0;
assign s20 = bin[20] ? 7'd49 : 7'd0;
assign s19 = bin[19] ? 7'd81 : 7'd0;
assign s18 = bin[18] ? 7'd97 : 7'd0;
assign s17 = bin[17] ? 7'd105 : 7'd0;
assign s16 = bin[16] ? 7'd109 : 7'd0;
assign s15 = bin[15] ? 7'd111 : 7'd0;
assign s14 = bin[14] ? 7'd112 : 7'd0;
assign s13 = bin[13] ? 7'd56 : 7'd0;
assign s12 = bin[12] ? 7'd28 : 7'd0;
assign s11 = bin[11] ? 7'd14 : 7'd0;
assign s10 = bin[10] ? 7'd7 : 7'd0;
assign s9 = bin[9] ? 7'd60 : 7'd0;
assign s8 = bin[8] ? 7'd30 : 7'd0;
assign s7 = bin[7] ? 7'd15 : 7'd0;

assign sum = bin[6:0]+s7+s8+s9+s10+s11+s12+s13+s14+s15+s16+s17+s18+s19+s20+s21+s22+s23+s24+s25+s26+s27+s28+s29+s30+s31;

always@(*)
begin
    if(sum < 12'd113)
        mod113 = sum;
    else if(sum < 12'd226)
        mod113 = sum - 12'd113;
    else if(sum < 12'd339)
        mod113 = sum - 12'd226;
    else if(sum < 12'd452)
        mod113 = sum - 12'd339;
    else if(sum < 12'd565)
        mod113 = sum - 12'd452;
    else if(sum < 12'd678)
        mod113 = sum - 12'd565;
    else if(sum < 12'd791)
        mod113 = sum - 12'd678;
    else if(sum < 12'd904)
        mod113 = sum - 12'd791;
    else if(sum < 12'd1017)
        mod113 = sum - 12'd904;
    else if(sum < 12'd1130)
        mod113 = sum - 12'd1017;
    else if(sum < 12'd1243)
        mod113 = sum - 12'd1130;
    else if(sum < 12'd1356)
        mod113 = sum - 12'd1243;
    else if(sum < 12'd1469)
        mod113 = sum - 12'd1356;
    else if(sum < 12'd1582)
        mod113 = sum - 12'd1469;
    else
        mod113 = sum - 12'd1582;
    
end
endmodule




module modulo127n(input [31:0] bin,input s, output reg [6:0] mod127);
wire [6:0] s31,s30,s29,s28,s27,s26,s25,s24,s23,s22,s21,s20,s19,s18,s17,s16,s15,s14,s13,s12,s11,s10,s9,s8,s7;
wire [10:0] sum;

assign s31 = s ? (bin[31] ? 7'd119 : 7'd0) : (bin[31] ? 7'd8 : 7'd0);
assign s30 = bin[30] ? 7'd4 : 7'd0;
assign s29 = bin[29] ? 7'd2 : 7'd0;
assign s28 = bin[28] ? 7'd1 : 7'd0;
assign s27 = bin[27] ? 7'd64 : 7'd0;
assign s26 = bin[26] ? 7'd32 : 7'd0;
assign s25 = bin[25] ? 7'd16 : 7'd0;
assign s24 = bin[24] ? 7'd8 : 7'd0;
assign s23 = bin[23] ? 7'd4 : 7'd0;
assign s22 = bin[22] ? 7'd2 : 7'd0;
assign s21 = bin[21] ? 7'd1 : 7'd0;
assign s20 = bin[20] ? 7'd64 : 7'd0;
assign s19 = bin[19] ? 7'd32 : 7'd0;
assign s18 = bin[18] ? 7'd16 : 7'd0;
assign s17 = bin[17] ? 7'd8 : 7'd0;
assign s16 = bin[16] ? 7'd4 : 7'd0;
assign s15 = bin[15] ? 7'd2 : 7'd0;
assign s14 = bin[14] ? 7'd1 : 7'd0;
assign s13 = bin[13] ? 7'd64 : 7'd0;
assign s12 = bin[12] ? 7'd32 : 7'd0;
assign s11 = bin[11] ? 7'd16 : 7'd0;
assign s10 = bin[10] ? 7'd8 : 7'd0;
assign s9 = bin[9] ? 7'd4 : 7'd0;
assign s8 = bin[8] ? 7'd2 : 7'd0;
assign s7 = bin[7] ? 7'd1 : 7'd0;

assign sum = bin[6:0]+s7+s8+s9+s10+s11+s12+s13+s14+s15+s16+s17+s18+s19+s20+s21+s22+s23+s24+s25+s26+s27+s28+s29+s30+s31;

always@(*)
begin
    if(sum < 12'd127)
        mod127 = sum;
    else if(sum < 12'd254)
        mod127 = sum - 12'd127;
    else if(sum < 12'd381)
        mod127 = sum - 12'd254;
    else if(sum < 12'd508)
        mod127 = sum - 12'd381;
    else 
        mod127 = sum - 12'd508;
        
end
endmodule


module mrc1(input [6:0] res101,res103,res107,res109,res113, input add_sub, output [31:0] bin_out);
wire [6:0] v1,v2,v3,v4,v5;
wire [31:0] v2n,v3n,v4n,v5n,b1;

localparam c12 =8'd51; localparam c13 =8'd89; localparam c14 =8'd68; localparam c15 =8'd47;
localparam c23 =8'd80; localparam c24 =8'd18; localparam c25 =8'd79;
localparam c34 =8'd54; localparam c35 =8'd94;
localparam c45 =8'd28;

assign v1 = res101;

assign v2n = (res103 - v1)*c12;
modulo103n m1(.bin(v2n),.s(1'b1),.mod103(v2));

assign v3n = ((res107 - v1)*c13 - v2)*c23;
modulo107n m2(.bin(v3n),.s(1'b1),.mod107(v3));

assign v4n = (((res109 - v1)*c14 - v2)*c24 - v3)*c34;
modulo109n m3(.bin(v4n),.s(1'b1),.mod109(v4));

assign v5n = ((((res113 - v1)*c15 - v2)*c25 - v3)*c35 - v4)*c45;
modulo113n m4(.bin(v5n),.s(1'b1),.mod113(v5));

assign b1 = v1 + v2*101 + v3*101*103 + v4*101*103*107 + v5*101*103*107*109;
assign bin_out = add_sub ? b1 -101*103*107*109*113 : b1;
//assign bin_out = b1;
endmodule

module mrc2(input [6:0] res101,res103,res107,res127,res128, input add_sub, output [31:0] bin_out);
wire [6:0] v1,v2,v3,v4,v5;
wire [31:0] v2n,v3n,v4n,v5n,b1;

localparam c12 =8'd51; localparam c13 =8'd89; localparam c14 =8'd83; localparam c15 =8'd109;
localparam c23 =8'd80; localparam c24 =8'd37; localparam c25 =8'd87;
localparam c34 =8'd19; localparam c35 =8'd67;
localparam c45 =8'd127;

assign v1 = res101;

assign v2n = (res103 - v1)*c12;
modulo103n m1(.bin(v2n),.s(1'b1),.mod103(v2));

assign v3n = ((res107 - v1)*c13 - v2)*c23;
modulo107n m2(.bin(v3n),.s(1'b1),.mod107(v3));

assign v4n = (((res127 - v1)*c14 - v2)*c24 - v3)*c34;
modulo127n m3(.bin(v4n),.s(1'b1),.mod127(v4));

assign v5n = ((((res128 - v1)*c15 - v2)*c25 - v3)*c35 - v4)*c45;
assign v5 = v5n[6:0];

assign b1 = v1 + v2*101 + v3*101*103 + v4*101*103*107 + v5*101*103*107*127;
assign bin_out = add_sub ? b1 -101*103*107*127*128 : b1;
//assign bin_out = b1;
endmodule


module mrc3(input [6:0] res101,res109,res113,res127,res128, input add_sub, output [31:0] bin_out);
wire [6:0] v1,v2,v3,v4,v5;
wire [31:0] v2n,v3n,v4n,v5n,b1;

localparam c12 =8'd68; localparam c13 =8'd47; localparam c14 =8'd83; localparam c15 =8'd109;
localparam c23 =8'd28; localparam c24 =8'd7; localparam c25 =8'd101;
localparam c34 =8'd9; localparam c35 =8'd17;
localparam c45 =8'd127;

assign v1 = res101;

assign v2n = (res109 - v1)*c12;
modulo109n m1(.bin(v2n),.s(1'b1),.mod109(v2));

assign v3n = ((res113 - v1)*c13 - v2)*c23;
modulo113n m2(.bin(v3n),.s(1'b1),.mod113(v3));

assign v4n = (((res127 - v1)*c14 - v2)*c24 - v3)*c34;
modulo127n m3(.bin(v4n),.s(1'b1),.mod127(v4));

assign v5n = ((((res128 - v1)*c15 - v2)*c25 - v3)*c35 - v4)*c45;
assign v5 = v5n[6:0];

assign b1 = v1 + v2*101 + v3*101*109 + v4*101*109*113 + v5*101*109*113*127;
assign bin_out = add_sub ? b1 -101*109*113*127*128 : b1;
//assign bin_out = b1;

endmodule


module mrc4(input [6:0] res107,res109,res113,res127,res128, input add_sub, output [31:0] bin_out);
wire [6:0] v1,v2,v3,v4,v5;
wire [31:0] v2n,v3n,v4n,v5n,b1;

localparam c12 =8'd54; localparam c13 =8'd94; localparam c14 =8'd19; localparam c15 =8'd67;
localparam c23 =8'd28; localparam c24 =8'd7; localparam c25 =8'd101;
localparam c34 =8'd9; localparam c35 =8'd17;
localparam c45 =8'd127;

assign v1 = res107;

assign v2n = (res109 - v1)*c12;
modulo109n m1(.bin(v2n),.s(1'b1),.mod109(v2));

assign v3n = ((res113 - v1)*c13 - v2)*c23;
modulo113n m2(.bin(v3n),.s(1'b1),.mod113(v3));

assign v4n = (((res127 - v1)*c14 - v2)*c24 - v3)*c34;
modulo127n m3(.bin(v4n),.s(1'b1),.mod127(v4));

assign v5n = ((((res128 - v1)*c15 - v2)*c25 - v3)*c35 - v4)*c45;
assign v5 = v5n[6:0];

assign b1 = v1 + v2*107 + v3*107*109 + v4*107*109*113 + v5*107*109*113*127;
assign bin_out = add_sub ? b1 -107*109*113*127*128 : b1;
//assign bin_out = b1;
endmodule

