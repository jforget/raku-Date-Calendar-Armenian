#!/usr/bin/env python
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Constitution des tests pour les conversions
# Building tests for the date conversions
#
# Copyright (c) 2025 Jean Forget, all rights reserved
#
# This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
#

import re
import sys
import fileinput
from convertdate import armenian

p = re.compile(r'\s+\S+\s+(\d+),\s+(\d+),\s+(\d+)\],?')

for line in fileinput.input():
    m = p.search(line)
    ya, ma, da = m.groups()
    yg, mg, dg = armenian.to_gregorian(int(ya), int(ma), int(da))
    print(', ( %4d, %2d, %2d, %4s, %2s, %2s )' % (yg, mg, dg, ya, ma, da))
