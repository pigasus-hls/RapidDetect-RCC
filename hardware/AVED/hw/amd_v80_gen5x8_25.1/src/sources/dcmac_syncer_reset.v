// Copyright (C) 2025 Advanced Micro Devices, Inc. All rights reserved.
// SPDX-License-Identifier: MIT

`timescale 1ps/1ps

module dcmac_syncer_reset #(
    parameter RESET_PIPE_LEN = 3
)
(
    input  wire clk,
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input  wire reset_async,
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    output wire resetn,
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    output wire reset
);

    (* ASYNC_REG = "TRUE" *) reg  [RESET_PIPE_LEN-1:0] reset_pipe_retime;
    reg  reset_pipe_out = 1'b0;

    always @(posedge clk or negedge reset_async) begin
        if (reset_async == 1'b0) begin
            reset_pipe_retime <= {RESET_PIPE_LEN{1'b0}};
            reset_pipe_out    <= 1'b0;
        end
        else begin
            reset_pipe_retime <= {reset_pipe_retime[RESET_PIPE_LEN-2:0], 1'b1};
            reset_pipe_out    <= reset_pipe_retime[RESET_PIPE_LEN-1];
        end
    end

    assign resetn = ~reset_pipe_out;
    assign reset = reset_pipe_out;

endmodule
