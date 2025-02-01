class alu_scoreboard extends uvm_scoreboard;
    // Packets received from monitor
    alu_seq_item pkt_qu[$];
    // Stored accumulator value - the only stored value that affects ALU results
    bit [7:0] accumulator;

    // This receives packets from monitor
    uvm_analysis_imp #(alu_seq_item, alu_scoreboard) item_collected_export;
    `uvm_component_utils(alu_scoreboard)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_collected_export = new("item_collected_export", this);
        accumulator = 8'b10010110;
    endfunction

    // Log and save packets from monitor
    virtual function void write(alu_seq_item pkt);
        pkt.print();
        pkt_qu.push_back(pkt);
    endfunction

    virtual task run_phase(uvm_phase phase);
        alu_seq_item alu_pkt;
        bit expected_cy;
        bit [7:0] expected_acc;
        bit should_jump;

        forever begin
            // Process incoming packet as soon as they arrive in queue
            wait(pkt_qu.size() > 0);
            alu_pkt = pkt_qu.pop_front();

            // TODO: Proces packets and check them. Use `uvm_error on errors.
            expected_cy = 0; // Everything (even NOP) should clear cy (per req 3)
            case (alu_pkt.opcode)
                `ADD: {expected_cy, expected_acc} = accumulator + alu_pkt.register;
                `SUB: {expected_cy, expected_acc} = accumulator - alu_pkt.register;
                `LD: expected_acc = alu_pkt.register;
                `AND: expected_acc = accumulator & alu_pkt.register;
                `OR: expected_acc = accumulator | alu_pkt.register;
                `XOR: expected_acc = accumulator ^ alu_pkt.register;
                `NOT: expected_acc = ~alu_pkt.register;
                `ST, `NOP, `JMP, `JZ: expected_acc = accumulator;
                default: `uvm_fatal(get_type_name(), $sformatf("Simulated incorrect opcode %0d", alu_pkt.opcode))
            endcase
            should_jump = alu_pkt.opcode == `JMP || (alu_pkt.opcode == `JZ && accumulator == 0);

            if (alu_pkt.acc != expected_acc)
                `uvm_error(
                    get_type_name(),
                    $sformatf(
                        "Operation %0d on acc %0d with val %0d gave %0d, but %0d was expected",
                        alu_pkt.opcode, accumulator, alu_pkt.register, alu_pkt.acc, expected_acc
                ))
            if (alu_pkt.cy != expected_cy) begin
                if (expected_cy) begin
                    `uvm_error(
                        get_type_name(),
                        $sformatf(
                            "Operation %0d on acc %0d with val %0d did not produce carry",
                            alu_pkt.opcode, accumulator, alu_pkt.register
                    ))
                end else begin
                    `uvm_error(
                        get_type_name(),
                        $sformatf(
                            "Operation %0d on acc %0d with val %0d produced unexpected carry",
                            alu_pkt.opcode, accumulator, alu_pkt.register
                    ))
                end
            end
            if (should_jump && !alu_pkt.jmp_ce_temp)
                `uvm_error(
                    get_type_name(),
                    $sformatf(
                        "Operation %0d on acc %0d with val %0d did not result in expected jump",
                        alu_pkt.opcode, accumulator, alu_pkt.register
                ))
            if (!should_jump && alu_pkt.jmp_ce_temp)
                `uvm_error(
                    get_type_name(),
                    $sformatf(
                        "Operation %0d on acc %0d with val %0d caused unexpected jump",
                        alu_pkt.opcode, accumulator, alu_pkt.register
                ))
            if (should_jump && alu_pkt.jmp_addr_temp != alu_pkt.argument)
                `uvm_error(
                    get_type_name(),
                    $sformatf(
                        "Expected jump to %0h, but got addr %0h",
                        alu_pkt.argument, alu_pkt.jmp_addr_temp
                ))

            accumulator = expected_acc;
        end
    endtask
endclass
