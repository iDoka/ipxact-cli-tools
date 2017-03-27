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

def get_random(field):
    switcher = {
        'read-write'    : '1',
        'read-only'     : '0',
        'write-only'    : '0',
        'read-writeOnce': '1',
        'writeOnce'     : '0',
    }
    return switcher.get(field.access, '1')

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
    ${field_inst}.configure(
        this, // parent
        ${field.bitWidth}, // size in bits
        ${field.bitOffset}, // offset in bits
        ${get_access(field)}, // access type
        ${get_volatile(field)}, // is volatile?
        0, // value by reset
        0, // has reset?
        ${get_random(field)}, // is randomize?
        0); // individually accessible?
%   if not loop.last:

%   endif
% endfor
  endfunction


  function new(string name = "${reg_class}");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  `uvm_object_utils(${reg_class})
endclass
