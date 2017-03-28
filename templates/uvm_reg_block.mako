<%
import utils.naming as naming
addressBusByteWidth = addressBlock.width / 8
addressBusBitWidth  = addressBlock.width
%>\
class reg_block extends uvm_reg_block;
% for reg in addressBlock.register:
  rand ${naming.get_register_class(reg)} ${naming.get_register_inst(reg)};
% endfor


  virtual function void build();
    default_map = create_map("default_map", \
${addressBusBitWidth}${"'h{:08X}".format(addressBlock.baseAddress)}, ${addressBusByteWidth}, UVM_LITTLE_ENDIAN);

% for reg in addressBlock.register:
<%
reg_class = naming.get_register_class(reg)
reg_inst = naming.get_register_inst(reg)
%>\
    // ${reg.name}: ${reg.description}
    reg_inst = reg_class::type_id::create("reg_inst", null, this);
    reg_inst.configure(this);
    reg_inst.build();
    default_map.add_reg(${reg_inst}, ${addressBusBitWidth}${"'h{:08X}".format(reg.addressOffset)});
%   if not loop.last:

%   endif
% endfor
  endfunction


  function new(string name = "reg_block";
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  `uvm_object_utils(reg_block)
endclass
