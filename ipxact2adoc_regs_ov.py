#!/usr/bin/env python
# -*- coding:utf-8 -*-

import os
import sys
sys.path.append('ipyxact')

from ipyxact.ipyxact import Component

from mako.lookup import TemplateLookup
from mako.template import Template
from mako.runtime import Context

import argparse

import yaml




parser = argparse.ArgumentParser(description='Generate Verilog RTL for Config/Status-Register')
parser.add_argument('xml_path', metavar='<ipcore.xml>', type=file, nargs=1,
                    help='path to IP-XACT xml-file to be parse')
args = parser.parse_args()
inputname = os.path.splitext(args.xml_path[0].name)[0] + ".yml"

try:
  with open(inputname, 'r') as configfile:
    cfg = yaml.load(configfile)
except IOError:
  with open("config.yml", 'r') as configfile:
    cfg = yaml.load(configfile)

'''debug print of config sections
for section in cfg:
    print(section)
'''
clk = str(cfg['General']['Clock'])
rst = str(cfg['General']['Reset'])
rst_level   = int(cfg['General']['ResetActiveLevel'])
rst_is_sync = int(cfg['General']['ResetIsSync'])




component = Component()
component.load(args.xml_path[0].name)

addressBlock = component.memoryMaps.memoryMap[0].addressBlock[0]
busByteWidth = component.memoryMaps.memoryMap[0].addressBlock[0].width / 8
busBitWidth  = component.memoryMaps.memoryMap[0].addressBlock[0].width

addr_width = component.memoryMaps.memoryMap[0].addressBlock[0].width
data_width = component.memoryMaps.memoryMap[0].addressBlock[0].register[0].size

fileName = component.name.lower() + '_table_regs_ov.adoc'



lookup = TemplateLookup(directories=['templates'],
                        input_encoding='utf-8',
                        output_encoding='utf-8',
                        default_filters=['decode.utf8'],
                        encoding_errors='replace')

buffer = open(fileName, 'w')

z=''
for i in reversed(range(0, data_width)):
  z += str(i) + '|'

buffer.write('.Register Overview\n')
buffer.write('[cols="^3e,^3s,'+ str(data_width) +'*^1,^5",options="header"]\n')
buffer.write('|===================================================\n')
buffer.write('| ADDR | REG |' + z + ' RST\n')

for reg in addressBlock.register:
    template = lookup.get_template('adoc_regs_overview.mako')
    ctx = Context(buffer,
    	          reg = reg,
    	          cfg = cfg,
    	          addr_width = addr_width,
    	          data_width = data_width)
    template.render_context(ctx)

buffer.write("\n|===================================================\n")
