class peripheral_uvm_sequencer extends uvm_sequencer #(peripheral_uvm_transaction);
  // Declaration of Sequence utils
  `uvm_component_utils(peripheral_uvm_sequencer)

  // constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass
