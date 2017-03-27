<%!
import utils.naming as naming

def get_access(field):
    switcher = {
        'read-write'    : '"RW"',
        'read-only'     : '"RO"',
        'write-only'    : '"WO"',
        'read-writeOnce': '"W1"',
        'writeOnce'     : '"WO1"',
    }
    return switcher.get(field.access, "RW")

def get_volatile(field):
    switcher = {
        'true'  : '1',
        'false' : '0',
    }
    return switcher.get(field.volatile, '0')

%>\
<%
reg_class = naming.get_register_class(reg)
%>\
class ${reg_class} extends uvm_reg;
% for field in reg.field:
  rand uvm_reg_field ${field.name};
% endfor


  virtual function build();
% for field in reg.field:
<%
field_inst = naming.get_field_inst(field)
%>\
    ${field_inst} = uvm_reg_field::type_id::create("${field_inst}", null, \
get_full_name());
    ${field_inst}.configure(this, ${field.bitWidth}, ${field.bitOffset}, \
${get_access(field)}, ${get_volatile(field)});
%   if not loop.last:

%   endif
% endfor
  endfunction


  function new(string name = "${reg_class}");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  `uvm_object_utils(${reg_class})
endclass
