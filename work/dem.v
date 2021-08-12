

wire [7:0] dem_lp, dem_ln;
dem UDEM10(.dem_clk(dem_clk), .reset_n(reset_n), .x(dsd_lpr), .xbar(dsd_lnr), .y(dem_lp), .ybar(dem_ln));


// a0.....a7
// .
// h0 
// each row has 1 "1" each colume has 1 "1"
//
// the trick is to generate random "n" below

module dem(
input dem_clk,
input reset_n,
input [7:0] x,
input [7:0] xbar,
output reg [7:0] ybar,
output reg [7:0] y);

wire x0,x1,x2,x3,x4,x5,x6,x7;
assign {x7,x6,x5,x4,x3,x2,x1,x0} = x;

wire a0,a1,a2,a3,a4,a5,a6,a7;
wire b0,b1,b2,b3,b4,b5,b6,b7;
wire c0,c1,c2,c3,c4,c5,c6,c7;
wire d0,d1,d2,d3,d4,d5,d6,d7;
wire e0,e1,e2,e3,e4,e5,e6,e7;
wire f0,f1,f2,f3,f4,f5,f6,f7;
wire g0,g1,g2,g3,g4,g5,g6,g7;
wire h0,h1,h2,h3,h4,h5,h6,h7;

wire [7:0] A,B,C,D,E,F,G,H;

assign {a7,a6,a5,a4,a3,a2,a1,a0} = A;
assign {b7,b6,b5,b4,b3,b2,b1,b0} = B;
assign {c7,c6,c5,c4,c3,c2,c1,c0} = C;
assign {d7,d6,d5,d4,d3,d2,d1,d0} = D;
assign {e7,e6,e5,e4,e3,e2,e1,e0} = E;
assign {f7,f6,f5,f4,f3,f2,f1,f0} = F;
assign {g7,g6,g5,g4,g3,g2,g1,g0} = G;
assign {h7,h6,h5,h4,h3,h2,h1,h0} = H;

reg [1:0] p0,p1,p2,p3;

assign A = (p0==2'b00) ? 8'h80 : (p0==2'b01) ? 8'h20: (p0==2'b10) ? 8'h08 : 8'h02;
assign B = (p0==2'b00) ? 8'h40 : (p0==2'b01) ? 8'h10: (p0==2'b10) ? 8'h04 : 8'h01;
assign C = (p1==2'b00) ? 8'h80 : (p1==2'b01) ? 8'h20: (p1==2'b10) ? 8'h08 : 8'h02;
assign D = (p1==2'b00) ? 8'h40 : (p1==2'b01) ? 8'h10: (p1==2'b10) ? 8'h04 : 8'h01;
assign E = (p2==2'b00) ? 8'h80 : (p2==2'b01) ? 8'h20: (p2==2'b10) ? 8'h08 : 8'h02;
assign F = (p2==2'b00) ? 8'h40 : (p2==2'b01) ? 8'h10: (p2==2'b10) ? 8'h04 : 8'h01;
assign G = (p3==2'b00) ? 8'h80 : (p3==2'b01) ? 8'h20: (p3==2'b10) ? 8'h08 : 8'h02;
assign H = (p3==2'b00) ? 8'h40 : (p3==2'b01) ? 8'h10: (p3==2'b10) ? 8'h04 : 8'h01;

reg [4:0] n;
always @(n) begin
    case(n)
5'd0:  begin  p0 = 0; p1 = 1; p2 = 2; p3 = 3; end
5'd1:  begin  p0 = 0; p1 = 1; p2 = 3; p3 = 2; end
5'd2:  begin  p0 = 0; p1 = 2; p2 = 1; p3 = 3; end
5'd3:  begin  p0 = 0; p1 = 2; p2 = 3; p3 = 1; end
5'd4:  begin  p0 = 0; p1 = 3; p2 = 1; p3 = 2; end
5'd5:  begin  p0 = 0; p1 = 3; p2 = 2; p3 = 1; end

5'd6:  begin  p0 = 1; p1 = 0; p2 = 2; p3 = 3; end
5'd7:  begin  p0 = 1; p1 = 0; p2 = 3; p3 = 2; end
5'd8:  begin  p0 = 1; p1 = 2; p2 = 3; p3 = 0; end
5'd9:  begin  p0 = 1; p1 = 2; p2 = 0; p3 = 3; end
5'd10:  begin  p0 = 1; p1 = 3; p2 = 0; p3 = 2; end
5'd11:  begin  p0 = 1; p1 = 3; p2 = 2; p3 = 0; end

5'd12:  begin  p0 = 2; p1 = 3; p2 = 0; p3 = 1; end
5'd13:  begin  p0 = 2; p1 = 3; p2 = 1; p3 = 0; end
5'd14:  begin  p0 = 2; p1 = 1; p2 = 3; p3 = 0; end
5'd15:  begin  p0 = 2; p1 = 1; p2 = 0; p3 = 3; end
5'd16:  begin  p0 = 2; p1 = 0; p2 = 1; p3 = 3; end
5'd17:  begin  p0 = 2; p1 = 0; p2 = 3; p3 = 1; end

5'd18:  begin  p0 = 3; p1 = 0; p2 = 2; p3 = 1; end
5'd19:  begin  p0 = 3; p1 = 0; p2 = 1; p3 = 2; end
5'd20:  begin  p0 = 3; p1 = 1; p2 = 0; p3 = 2; end
5'd21:  begin  p0 = 3; p1 = 1; p2 = 2; p3 = 0; end
5'd22:  begin  p0 = 3; p1 = 2; p2 = 0; p3 = 1; end
5'd23:  begin  p0 = 3; p1 = 2; p2 = 1; p3 = 0; end

//more
5'd24:  begin  p0 = 3; p1 = 2; p2 = 1; p3 = 0; end
5'd25:  begin  p0 = 2; p1 = 1; p2 = 3; p3 = 0; end
5'd26:  begin  p0 = 0; p1 = 2; p2 = 3; p3 = 1; end
5'd27:  begin  p0 = 1; p1 = 0; p2 = 2; p3 = 3; end

5'd28:  begin  p0 = 1; p1 = 3; p2 = 2; p3 = 0; end
5'd29:  begin  p0 = 0; p1 = 1; p2 = 2; p3 = 3; end
5'd30:  begin  p0 = 3; p1 = 0; p2 = 1; p3 = 2; end
5'd31:  begin  p0 = 2; p1 = 3; p2 = 1; p3 = 0; end
    endcase
    end


always @(posedge dem_clk or negedge reset_n)
    if (1'b0 == reset_n) begin
        y <= 8'd0;
        ybar <= 8'd255;
        n <= 0;
        end
    else begin
        n <= n+1;
        ybar <= xbar;
        y[0] <= (x0 & a0) | (x1 & a1) | (x2 & a2) | (x3 & a3) | (x4 & a4) | (x5 & a5) | (x6 & a6) | (x7 & a7);
        y[1] <= (x0 & b0) | (x1 & b1) | (x2 & b2) | (x3 & b3) | (x4 & b4) | (x5 & b5) | (x6 & b6) | (x7 & b7);
        y[2] <= (x0 & c0) | (x1 & c1) | (x2 & c2) | (x3 & c3) | (x4 & c4) | (x5 & c5) | (x6 & c6) | (x7 & c7);
        y[3] <= (x0 & d0) | (x1 & d1) | (x2 & d2) | (x3 & d3) | (x4 & d4) | (x5 & d5) | (x6 & d6) | (x7 & d7);
        y[4] <= (x0 & e0) | (x1 & e1) | (x2 & e2) | (x3 & e3) | (x4 & e4) | (x5 & e5) | (x6 & e6) | (x7 & e7);
        y[5] <= (x0 & f0) | (x1 & f1) | (x2 & f2) | (x3 & f3) | (x4 & f4) | (x5 & f5) | (x6 & f6) | (x7 & f7);
        y[6] <= (x0 & g0) | (x1 & g1) | (x2 & g2) | (x3 & g3) | (x4 & g4) | (x5 & g5) | (x6 & g6) | (x7 & g7);
        y[7] <= (x0 & h0) | (x1 & h1) | (x2 & h2) | (x3 & h3) | (x4 & h4) | (x5 & h5) | (x6 & h6) | (x7 & h7);
        end

endmodule


