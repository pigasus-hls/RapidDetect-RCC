// Copyright (C) 2025 Advanced Micro Devices, Inc. All rights reserved.
// SPDX-License-Identifier: MIT

`timescale 1ps/1ps

module reset_registers #(
    parameter RESET_PIPE_LEN = 3
)
(
    input  wire clk,
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input  wire reset_sync,
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    output wire resetn,
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    output wire reset
);

    reg  [RESET_PIPE_LEN-1:0] reset_pipe_retime;
    reg  reset_pipe_out = 1'b0;

    always @(posedge clk) begin
        reset_pipe_retime <= {reset_pipe_retime[RESET_PIPE_LEN-2:0], reset_sync};
        reset_pipe_out    <= reset_pipe_retime[RESET_PIPE_LEN-1];
    end

    assign resetn = ~reset_pipe_out;
    assign reset = reset_pipe_out;

endmodule
