# -*- coding: utf-8 -*-
<%!
#import utils.naming as naming

#addressBusByteWidth = addressBlock.width / 8
#addressBusBitWidth  = addressBlock.width

#${addressBusBitWidth}${"'h{:08X}".format(addressBlock.baseAddress)}, ${addressBusByteWidth}, UVM_LITTLE_ENDIAN;
#reg(${reg_class}, ${addressBusBitWidth}${"'h{:08X}".format(reg.addressOffset)});

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
reg_name = reg.name.lower() + "_reg"
AssemblyReg = ['RSVD' for i in range(data_width)]

reg_address = "'h{:08X}".format(reg.addressOffset)
hex_addr = ('0x%0'+str(addr_width/4)+'X') % reg.addressOffset

%>\
// *********************************************************************
//     ${reg.name}: ${reg.description} (Address: ${hex_addr})
// *********************************************************************
// ${reg_name}: ${addr_width}${"'h{:08X}".format(reg.addressOffset)};

% for field in reg.field:
<%
name = field.name.lower() + "_reg"
size = field.bitWidth - 1
lsb = field.bitOffset
msb = field.bitOffset + field.bitWidth - 1

dim = '['+str(size)+':0]' if field.bitWidth > 1 else ''
for i in range(lsb, msb+1):
  AssemblyReg[i] = field.name + dim

#  ${get_access(field)}, // access type
#  ${get_volatile(field)}, // is volatile?

clk = str(cfg['General']['Clock'])
rst = str(cfg['General']['Reset'])
rst_level   = int(cfg['General']['ResetActiveLevel'])
rst_is_sync = int(cfg['General']['ResetIsSync'])

try:
  reset_value = '%X' % (field.resets.reset.value)
  has_reset = 1
except AttributeError:
  reset_value = 0
  has_reset = 0
%>\

  %if msb == lsb:
    reg ${field.name}; // ${field.description}
  %else:
    reg [${size}:0] ${field.name}; // ${field.description}
  %endif

  %if has_reset:
    %if rst_is_sync:
    always @(posedge ${clk})
      %if rst_level:
      if (${rst})
      %else:
      if (!${rst})
      %endif
    %else:
      %if rst_level:
    always @(posedge ${clk} or posedge ${rst})
      if (${rst})
      %else:
    always @(posedge ${clk} or negedge ${rst})
      if (!${rst})
      %endif
    %endif
        ${field.name} <= ${field.bitWidth}'h${reset_value};
      else
      %if msb == lsb:
        ${field.name} <= data_in[${lsb}];
      %else:
        ${field.name} <= data_in[${msb}:${lsb}];
      %endif
  %else:
    always @(posedge ${clk})
  %endif

%   if not loop.last:

%   endif
% endfor

