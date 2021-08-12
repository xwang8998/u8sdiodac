//
// filter that turn 352.8KHz to 2.8224MHz
//
module tap_rom2(
input [6:0] address,
output signed [31:0] output_tap);

//assign ntap = 7'd115;

reg signed [31:0] output_tapx;
assign output_tap = output_tapx[31:0];

always @* begin
    case(address)
    7'd0: output_tapx = -156;
    7'd1: output_tapx = -663;
    7'd2: output_tapx = -1808;
    7'd3: output_tapx = -3728;
    7'd4: output_tapx = -6054;
    7'd5: output_tapx = -7443;
    7'd6: output_tapx = -5219;
    7'd7: output_tapx = 4498;
    7'd8: output_tapx = 25784;
    7'd9: output_tapx = 60729;
    7'd10: output_tapx = 106266;
    7'd11: output_tapx = 150807;
    7'd12: output_tapx = 172231;
    7'd13: output_tapx = 139281;
    7'd14: output_tapx = 18222;
    7'd15: output_tapx = -214463;
    7'd16: output_tapx = -554768;
    7'd17: output_tapx = -953535;
    7'd18: output_tapx = -1305508;
    7'd19: output_tapx = -1453421;
    7'd20: output_tapx = -1214197;
    7'd21: output_tapx = -429598;
    7'd22: output_tapx = 964303;
    7'd23: output_tapx = 2864197;
    7'd24: output_tapx = 4947133;
    7'd25: output_tapx = 6666484;
    7'd26: output_tapx = 7319840;
    7'd27: output_tapx = 6198201;
    7'd28: output_tapx = 2802705;
    7'd29: output_tapx = -2912452;
    7'd30: output_tapx = -10336678;
    7'd31: output_tapx = -18117180;
    7'd32: output_tapx = -24260548;
    7'd33: output_tapx = -26458948;
    7'd34: output_tapx = -22623579;
    7'd35: output_tapx = -11541481;
    7'd36: output_tapx = 6490264;
    7'd37: output_tapx = 29236738;
    7'd38: output_tapx = 52483674;
    7'd39: output_tapx = 70507029;
    7'd40: output_tapx = 77074826;
    7'd41: output_tapx = 66868143;
    7'd42: output_tapx = 37072619;
    7'd43: output_tapx = -11208419;
    7'd44: output_tapx = -72099700;
    7'd45: output_tapx = -134980862;
    7'd46: output_tapx = -185567852;
    7'd47: output_tapx = -208005731;
    7'd48: output_tapx = -187689361;
    7'd49: output_tapx = -114320221;
    7'd50: output_tapx = 15413476;
    7'd51: output_tapx = 196140607;
    7'd52: output_tapx = 413557573;
    7'd53: output_tapx = 645825257;
    7'd54: output_tapx = 866482560;
    7'd55: output_tapx = 1048420928;
    7'd56: output_tapx = 1168217620;
    7'd57: output_tapx = 1210017861;
    7'd58: output_tapx = 1168217620;
    7'd59: output_tapx = 1048420928;
    7'd60: output_tapx = 866482560;
    7'd61: output_tapx = 645825257;
    7'd62: output_tapx = 413557573;
    7'd63: output_tapx = 196140607;
    7'd64: output_tapx = 15413476;
    7'd65: output_tapx = -114320221;
    7'd66: output_tapx = -187689361;
    7'd67: output_tapx = -208005731;
    7'd68: output_tapx = -185567852;
    7'd69: output_tapx = -134980862;
    7'd70: output_tapx = -72099700;
    7'd71: output_tapx = -11208419;
    7'd72: output_tapx = 37072619;
    7'd73: output_tapx = 66868143;
    7'd74: output_tapx = 77074826;
    7'd75: output_tapx = 70507029;
    7'd76: output_tapx = 52483674;
    7'd77: output_tapx = 29236738;
    7'd78: output_tapx = 6490264;
    7'd79: output_tapx = -11541481;
    7'd80: output_tapx = -22623579;
    7'd81: output_tapx = -26458948;
    7'd82: output_tapx = -24260548;
    7'd83: output_tapx = -18117180;
    7'd84: output_tapx = -10336678;
    7'd85: output_tapx = -2912452;
    7'd86: output_tapx = 2802705;
    7'd87: output_tapx = 6198201;
    7'd88: output_tapx = 7319840;
    7'd89: output_tapx = 6666484;
    7'd90: output_tapx = 4947133;
    7'd91: output_tapx = 2864197;
    7'd92: output_tapx = 964303;
    7'd93: output_tapx = -429598;
    7'd94: output_tapx = -1214197;
    7'd95: output_tapx = -1453421;
    7'd96: output_tapx = -1305508;
    7'd97: output_tapx = -953535;
    7'd98: output_tapx = -554768;
    7'd99: output_tapx = -214463;
    7'd100: output_tapx = 18222;
    7'd101: output_tapx = 139281;
    7'd102: output_tapx = 172231;
    7'd103: output_tapx = 150807;
    7'd104: output_tapx = 106266;
    7'd105: output_tapx = 60729;
    7'd106: output_tapx = 25784;
    7'd107: output_tapx = 4498;
    7'd108: output_tapx = -5219;
    7'd109: output_tapx = -7443;
    7'd110: output_tapx = -6054;
    7'd111: output_tapx = -3728;
    7'd112: output_tapx = -1808;
    7'd113: output_tapx = -663;
    7'd114: output_tapx = -156;
    default: output_tapx = 0;
    endcase
    end

endmodule

