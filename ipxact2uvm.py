#!/bin/env python2.7

import sys
sys.path.append('ipyxact')

import argparse
from ipyxact.ipyxact import Component

from mako.lookup import TemplateLookup
from mako.template import Template
from mako.runtime import Context


parser = argparse.ArgumentParser(description='Generate registers for UVM')
parser.add_argument('xml_path', metavar='<xml>', type=file, nargs=1,
                    help='path to IP-XACT XML file to be read')
args = parser.parse_args()


component = Component()
component.load(args.xml_path[0].name)
addressBlock = component.memoryMaps.memoryMap[0].addressBlock[0]
#busByteWidth = component.memoryMaps.memoryMap[0].addressBlock[0].width / 8
fileName = component.name.lower() + '_regs.svh'

lookup = TemplateLookup('templates')
buffer = open(fileName, 'w')

for reg in addressBlock.register:
    template = lookup.get_template('uvm_reg.mako')
    ctx = Context(buffer, reg=reg)
    template.render_context(ctx)
    buffer.write('\n\n\n\n')

template = lookup.get_template('uvm_reg_block.mako')
ctx = Context(buffer, addressBlock=addressBlock)
template.render_context(ctx)
