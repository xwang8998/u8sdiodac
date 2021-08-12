//
// pipe line output x+1, x-1, (x+1)*b1, (x-1)*b1
// this is the input stage for pipeline sdm512 engine
//
// input is -6dB of original PCM
//
// output data will have a sample rate of 2822400, which is 1/16 of the 45.1584MHz clock
//

`define  B1  36'h4F00000

module pipe_pcm(
input pclk,      //45.1584MHz clock
input preset_n,
input start,
output started,  //only active when the outputs are valid, otherwise SDM unstable!!!!!!!!!!
input signed [31:0] pcm,
output signed [27:0]x0,
output signed [27:0]x1,
output signed [35:0]y0,
output signed [35:0]y1
);

parameter IDLE = 1'b0;
parameter WORK = 1'b1;
reg state, n_state;
reg [3:0] i, n_i;
reg [5:0] j, n_j;
reg work, n_work;

reg reset_n;
always @* if (start == 0) reset_n = 0; else reset_n = preset_n;

wire signed [32:0] pcmx; 
wire signed [32:0] one, minus_one;
wire signed [32:0] xp1, xm1; 

assign pcmx = pcm[31]? {1'b1, pcm} : {1'b0, pcm};
assign one = 33'h7fffffff + 33'h1;
assign minus_one = 33'h0 - one;
assign xp1 = one + pcmx;         // no rounding
assign xm1 = minus_one + pcmx;   // no roundin

reg signed [27:0] plus, minus, n_plus, n_minus;
reg signed [27:0] xx0, xx1, n_xx0, n_xx1;
reg signed [35:0] b1xplus, b1xminus, n_b1xplus, n_b1xminus;

//multipliers:
wire signed [35:0] mul_plus_b1, mul_minus_b1;
mulb1 U100(.i1_0(plus[27:12]), .i1_1(minus[27:12]), .o1(mul_plus_b1), .o2(mul_minus_b1));

assign x0 = xx0;
assign x1 = xx1;
assign y0 = b1xplus;
assign y1 = b1xminus;
assign started = work;

always @(posedge pclk or negedge reset_n)
    if (0 == reset_n) begin
        state <= 0;
        i  <= 0; j <= 0;
        plus <= 0;
        minus <= 0;
        b1xplus <= 0;
        b1xminus <= 0;
        xx0 <= 0; xx1 <= 0;    
        work <= 0;
        end
    else begin
        state <= n_state;
        i <= n_i; j <= n_j;
        plus <= n_plus;
        minus <= n_minus;
        b1xplus <= n_b1xplus;
        b1xminus <= n_b1xminus;
        xx0 <= n_xx0; xx1 <= n_xx1;
        work <= n_work;
        end

always @* begin
    n_state = state;
    n_i = i; n_j = j;
    n_plus = plus;
    n_minus = minus;
    n_b1xplus = b1xplus;
    n_b1xminus = b1xminus;
    n_xx0 = xx0; n_xx1 = xx1;
    n_work = work;
    case(state)

IDLE: begin
    n_i = 0;
    n_j = 0;
    n_xx0 = 0;
    n_xx1 = 0;
    n_b1xplus  = 0;
    n_b1xminus  = 0;
    if (start) n_state = WORK;
    end

WORK: begin
    n_i = i+1;
    if (i == 0) begin
        n_plus  = {2'b00, xp1[31:6]};
        n_minus = {2'b11, xm1[31:6]} + 28'h1;
        end

    if (i == 7) begin
        n_xx0 = plus;
        n_xx1 = minus;
        n_b1xplus = mul_plus_b1;
        n_b1xminus = mul_minus_b1;
        if (j<63) n_j = n_j+1;
        if (j==62) n_work = 1;

        //#10 if (work) $display("@@@@=%d %d %d %d %d", pcm, plus, minus, b1xplus, b1xminus);  
        end

    end

    endcase    
    end

endmodule


//calc (x+1)*b1, (x-1)*b1
module mulb1(
input signed[27:12] i1_0,
input signed[27:12] i1_1,
output signed [35:0] o1,
output signed [35:0] o2
);

reg signed [35:0]  mul_i1_0_b1; /* synthesis syn_multstyle="logic" */
reg signed [35:0]  mul_i1_1_b1; /* synthesis syn_multstyle="logic" */
reg signed [35:0] b1;
reg signed [15:0] t100, t101;
reg signed [19:0] tb1;
always @* begin
    b1 = `B1;
    tb1 =  {b1[31:12]};
    t100 = {i1_0[27:12]};
    t101 = {i1_1[27:12]};
    mul_i1_0_b1 = t100 * tb1;
    mul_i1_1_b1 = t101 * tb1;
    end

assign o1 = mul_i1_0_b1;
assign o2 = mul_i1_1_b1;
endmodule


