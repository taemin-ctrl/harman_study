`timescale 1ns/1ps

module I2C_Master_tb;

  // DUT 신호 정의
  logic clk;
  logic reset;
  logic start;
  logic i2c_en;
  logic stop;
  logic [7:0] tx_data;
  wire [7:0] rx_data;
  wire tx_done;
  wire ready;
  wire [3:0] lstate;
  wire SCL;
  tri  SDA;
  logic rw;

  // SDA 내부 드라이버 시뮬레이션을 위한 변수
  logic sda_out;
  logic sda_in; 
  assign SDA = sda_in ? sda_out: 1'bz;  // Testbench가 SDA를 구동할 경우
                   // DUT가 SDA를 읽는 경우

  // DUT 인스턴스
  I2C_Master dut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .i2c_en(i2c_en),
    .rw(rw),
    .stop(stop),
    .tx_data(tx_data),
    .rx_data(rx_data),
    .tx_done(tx_done),
    .ready(ready),
    .lstate(lstate),
    .SCL(SCL),
    .SDA(SDA)
  );

  // 클럭 생성
  always #5 clk = ~clk; // 50 MHz

  // 초기화 및 테스트 시나리오
  initial begin
    $display("Starting I2C_Master Testbench");
    clk = 0;
    reset = 1;
    start = 0;
    i2c_en = 0;
    stop = 0;
    tx_data = 8'ha0;
    rw = 0;
    sda_in = 0;
    sda_out =1'bz;

    #100;
    reset = 0;

    wait(ready == 1);  // IDLE 상태 대기

    // Write 시퀀스 시작
    tx_data = 8'hA0;  // 임의의 데이터 전송
    start = 1;
    #20;
    start = 0;

    wait(lstate == 4'h6); // WAIT 상태 진입 대기
    i2c_en = 1;
    #20;
    i2c_en = 0;
    #10
    wait(tx_done == 1);
    #100;
    wait(lstate == 4'h6);
    tx_data =1;

    i2c_en = 1;
    wait(lstate != 6);
    i2c_en = 0;
    wait(tx_done == 1);
    
    #10;
    wait(lstate == 6);

    // Read 시퀀스 (기본 구현에서 ACK에 따라 분기됨)
    tx_data = 8'hA1; // READ 모드로 진입할 가짜 주소
    rw = 1;
    sda_in = 1;

    i2c_en = 1;
    
    i2c_en = 0;

    wait(lstate == 6); // HOLD 상태 진입 대기

    i2c_en = 1;
    #20;
    i2c_en = 0;
    rw = 1;
    wait(lstate == 10); // READ0 상태

    sda_out = 0;
    wait(tx_done == 1);

    stop = 1;
    #20;
    stop = 0;

    wait(ready == 1);
    $display("Read Transaction Complete, RX Data = %h", rx_data);

    #100;
    $finish;
  end

endmodule
