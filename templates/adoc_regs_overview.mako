<%
reg_name = reg.name.upper()
AssemblyReg = ['RSVD' for i in range(data_width)]

hex_addr = '0x%02X' % reg.addressOffset
#hex_addr = "0x{:02X}".format(reg.addressOffset)

for field in reg.field:
  name = field.name.upper()
  size = field.bitWidth - 1
  lsb  = field.bitOffset
  msb  = field.bitOffset + field.bitWidth - 1

  dim = '['+str(size)+':0]' if field.bitWidth > 1 else ''
  for i in range(lsb, msb+1):
    AssemblyReg[i] = str(field.bitWidth) + '+^| ' + field.name + dim + ' '

#  try:
#    reset_value = 0x'%08X' % (field.resets.reset.value)
#  except AttributeError:
#    reset_value = 0xUUUUUUUU

%>\
<%
total = ''
tmp_name = 'null'
rsvd_count = 0

for i in reversed(range(0, data_width)):
  rsvd_count += 1 if AssemblyReg[i] == 'RSVD' else 0
  if AssemblyReg[i] != tmp_name:
    tmp_name = AssemblyReg[i]
    if AssemblyReg[i] != 'RSVD':
      if rsvd_count>0:
        total += str(rsvd_count) + '+^| '
        rsvd_count = 0
      total += AssemblyReg[i]
  if AssemblyReg[i] == 'RSVD' and i == 0:
    total += str(rsvd_count) + '+^| '

total = total[:-1]

%>\

| ${hex_addr} | ${reg.name}  ${total} | {reset_value}