module top_DedicatedProcessor (
    input logic clk,
    input logic reset,
    output logic [7:0] outPort
    );
    
    logic sumSrcMuxSel;
    logic iSrcMuxSel;
    logic sumEn;
    logic iEn;
    logic adderSrcMuxSel;
    logic outBuf;
    logic iLe10;

    Datapath u_datapath(
        .*
    );

    ControlUnit u_controlunit(
        .*
    );
endmodule