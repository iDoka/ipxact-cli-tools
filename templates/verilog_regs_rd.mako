# -*- coding: utf-8 -*-

%for reg in register:
<%
addr_msb = addr_width - 1
reg_address = ("'h%0"+str(addr_width/4)+"X") % reg.addressOffset
reg_name    = "%-12s" % reg.name
%>\
`define  ${reg_name}  ${addr_width}${reg_address}
%endfor


// Reading data from registers
reg [:0] data_out;

always @ (*) begin
  case(addr[${addr_msb}:0])  /* synthesis parallel_case */
%for reg in register: #.sort(key=lambda i: i.addressOffset):
<%
AssemblyReg = ['RSVD' for i in range(data_width)]
#reg_address = "'h{:08X}".format(reg.addressOffset)
reg_address =  ("'h%0"+str(addr_width/4)+"X") % reg.addressOffset

for field in reg.field:
  name = field.name.lower() + "_reg"
  size = field.bitWidth - 1
  lsb = field.bitOffset
  msb = field.bitOffset + field.bitWidth - 1

  dim = '['+str(size)+':0]' if field.bitWidth > 1 else ''
  for i in range(lsb, msb+1):
    AssemblyReg[i] = field.name + dim


total = ''
tmp_name = 'null'
rsvd_count = 0
comma = ','

for i in reversed(range(0, data_width)):
  rsvd_count += 1 if AssemblyReg[i] == 'RSVD' else 0
  if AssemblyReg[i] != tmp_name:
    tmp_name = AssemblyReg[i]
    if AssemblyReg[i] != 'RSVD':
      if rsvd_count>0:
        total += str(rsvd_count) + '\'h0' + comma
        rsvd_count = 0
      total += AssemblyReg[i] + comma
  if AssemblyReg[i] == 'RSVD' and i == 0:
    total += str(rsvd_count) + '\'h0' + comma

total = total[:-1]
reg_name    = "%-12s" % reg.name
%>\
    `${reg_name}: data_out = {${total}}; // ${reg.name}: ${reg.description}
%endfor
    default:      data_out = ${data_width}'h00000000; // the rest is read as 0
  endcase
end
