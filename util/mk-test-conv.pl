#!/usr/bin/env perl
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Constitution des tests pour les conversions
# Building tests for the date conversions
#

use v5.10;
use strict;
use warnings;
use Date::Converter;

my $cnv = Date::Converter->new('armenian', 'gregorian');

while (my $line = <>) {
  my ($ya, $ma, $da) = $line =~ /^ \s+ \[ [0-9.,]+ \s+ (\d+) , \s+ (\d+) , \s+ (\d+) \] ,? \s* $/x;
  my ($yg, $mg, $dg) = $cnv->convert($ya, $ma, $da);
  printf(", ( %4d, %2d, %2d, %4d, %2d, %2d )\n", $yg, $mg, $dg, $ya, $ma, $da);
}


__END__

=encoding utf8

=head1 NAME

mk-tests-week.pl - generate test data for the Raku module on Armenian calendar

=head1 SYNOPSIS

  perl   mk-tests-conv.pl < test-converter > t1
  python mk-tests-conv.py < test-converter > t2
  diff t1 t2

=head1 DESCRIPTION

This program generates test data for the Armenian calendar, especially
for conversions with the core class Date.

For cross-check purposes, another program, written in Python, uses the
same input to generate test data and both generated datasets should be
equal.

The generated test data are then copied-pasted into
F<xt/06-conversions.rakutest>. Do not forget to check the commas at
the beginning and end of the list.

=head1 PARAMETERS

None.

=head1 PREREQUISITE

The Perl program requires module C<Date::Converter>

The Python program requires module C<convertdate>

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2025 Jean Forget, all rights reserved

This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
