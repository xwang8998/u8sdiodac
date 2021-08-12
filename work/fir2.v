
// 8x filter, turn 352.8K to 2.8224MHz

module fir_stage_2(
input pclk,      //45.1584MHz clock
input preset_n,
input start,
input signed [31:0]x_0,             //input sample
input signed [31:0]x_1,             //input sample
output started,
output reg signed [31:0] fir_out_0,
output reg signed [31:0] fir_out_1
);

parameter FIR1_000 = 1'b0,
          FIR1_100 = 1'b1;

reg reset_n;
always @* if (start == 0) reset_n = 0; else reset_n = preset_n;

reg state, n_state;
reg [3:0] j, n_j;
reg [2:0] k, n_k;
reg work, n_work;
assign started = work;

wire [6:0] tap_addr;
assign tap_addr = {j[3:0], k[2:0]};

wire [2:0] last_k;
assign last_k = 7;

reg signed [31:0] n_fir_out_0;
reg signed [31:0] n_fir_out_1;
reg signed [59:0] sum_0, n_sum_0;
reg signed [59:0] sum_1, n_sum_1;

wire signed [59:0] mul_fir0_tap;
wire signed [59:0] mul_fir1_tap;

wire signed [31:0] TAP_AT_tap_pos;
tap_rom2 U1 ( .output_tap(TAP_AT_tap_pos), .address(tap_addr));

reg signed [27:0] fir_0 [0:15];
reg signed [27:0] n_fir_0 [0:15];
reg signed [27:0] fir_1 [0:15];
reg signed [27:0] n_fir_1 [0:15];

mult28x32 UM1 (.pclk(pclk), .reset_n(preset_n), .a(fir_0[j]), .b(TAP_AT_tap_pos), .y(mul_fir0_tap));
mult28x32 UM2 (.pclk(pclk), .reset_n(preset_n), .a(fir_1[j]), .b(TAP_AT_tap_pos), .y(mul_fir1_tap));

integer n;
always @(posedge pclk or negedge reset_n)
    if (reset_n == 0) begin
        j <= 0;
        k <= 0;
        sum_0 <= 0;
        fir_out_0 <= 0;
        for (n = 0; n < 16; n = n +1)   fir_0[n] <= 0;
        sum_1 <= 0;
        fir_out_1 <= 0;
        for (n = 0; n < 16; n = n +1)   fir_1[n] <= 0;
        state <= 0;
        work <= 0;
        end
    else begin
        j <= n_j;
        k <= n_k;
        sum_0 <= n_sum_0;
        fir_out_0 <= n_fir_out_0;
        for (n = 0; n < 16; n = n +1)   fir_0[n] <= n_fir_0[n];
        sum_1 <= n_sum_1;
        fir_out_1 <= n_fir_out_1;
        for (n = 0; n < 16; n = n +1)   fir_1[n] <= n_fir_1[n];
        state <= n_state;
        work <= n_work;
        end

//FSM body
always @* begin
    n_j = j;
    n_k = k;
    n_sum_0 = sum_0;
    n_fir_out_0 = fir_out_0;
    for (n = 0; n < 16; n = n +1)   n_fir_0[n] = fir_0[n];
    n_sum_1 = sum_1;
    n_fir_out_1 = fir_out_1;
    for (n = 0; n < 16; n = n +1)   n_fir_1[n] = fir_1[n];
    n_state = state;
    n_work = work;

    case(state)

FIR1_000: begin
    n_work = 0;
    n_sum_0 = 0;
    n_sum_1 = 0;
    n_k = 0;
    n_j = 0;
    if (start == 0) n_state = FIR1_000;
    else begin
         n_state = FIR1_100;
         end
    end

FIR1_100: begin     
#1       n_state = FIR1_100; 

#1       if (j==15) begin   //end of inner loop (polyphase) 
             #1 if (k==last_k) begin  //end of big loop!
             // load new and shift fir[]
             for (n = 1; n < 16; n = n +1)  #1 n_fir_0[n] = fir_0[n-1];
             #1 n_fir_0[0] = x_0[31:4];
             for (n = 1; n < 16; n = n +1)  #1  n_fir_1[n] = fir_1[n-1];
             #1 n_fir_1[0] = x_1[31:4];

             n_k = 0;
             end
          else begin
             n_k = k+1;
             end

          n_j = 0;
          n_sum_0 = 0;
          n_sum_1 = 0;
          n_state = FIR1_100;
//          #10 if (work) $display("@@@@=%d", fir_out_1);   //must delay to allow logic settle
          end

       else begin
           #1 n_sum_0 = sum_0 + mul_fir0_tap;
           #1 n_sum_1 = sum_1 + mul_fir1_tap;
           #1 n_j = j+1;
           end

       //output result
       if (j==15) begin
            #1 n_fir_out_0 = sum_0[57:26];
            #1 n_fir_out_1 = sum_1[57:26];
            n_work = 1;
            end

       end
   endcase
   end
endmodule

