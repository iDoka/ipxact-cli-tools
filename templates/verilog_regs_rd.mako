<%
reg_class = reg.name.lower() + "_reg"
AssemblyReg = ['RSVD' for i in range(data_width)]

reg_address = "'h{:08X}".format(reg.addressOffset)
hex_addr = '0x%02X' % reg.addressOffset

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

%>\
ADDRESS   ${addr_width}${reg_address}: ${reg.name} = {${total}}; // ${reg.description}
