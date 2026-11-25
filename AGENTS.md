# Repository Notes

- Enter the Nix dev environment with `nix develop` (or use the existing direnv integration). It provides Icarus Verilog, Verilator, Verible, and GTKWave.
- RTL is under `src/`: `timer_top.v` wires the clock, button/controller, timer, and six-digit display; implementation is grouped in `clock/`, `timer/`, and `ui/`.
- Run one testbench by compiling all RTL with its test top, then run the simulation:
  ```sh
  iverilog -g2012 -s tb_controller -o /tmp/timer-test src/clock/*.v src/timer/*.v src/ui/*.v src/timer_top.v test/tb_controller.v
  vvp /tmp/timer-test
  ```
  Replace `tb_controller` and its test file to focus another bench. The testbenches use reduced clock parameters for simulation.
- There is no checked-in test runner. Current baseline: `tb_button`, `tb_controller`, `tb_full_timer`, and `tb_tick_generator` pass; `tb_timer_display` and `tb_timer_top` fail at initial display assertions. Verible lint currently reports a constant-name issue in `tick_generator.v` and two overlong lines in `tb_timer_display.v`.
- `.verible.style` sets four-space indentation; `.vscode/settings.json` selects `verible-verilog-format` as the editor formatter.
