#!/usr/bin/env perl
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Constitution des tests pour le numéro de semaine
# Building tests for the week number
#

use v5.10;
use strict;
use warnings;
use Date::Converter;
use DateTime;

my $cnv = Date::Converter->new('armenian', 'gregorian');

my @day_names = qw< kiraki erkušabatʿi erekʿšabatʿi čʿorekʿšabatʿi hingšabatʿi urbatʿ šabatʿi >;

my @years = @ARGV;

foreach my $year (@years) {
  build_tests($year);
}

sub build_tests {
  my ($year) = @_;
  my ($yg, $mg, $dg) = $cnv->convert($year, 1, 1);
  my $date_g = DateTime->new(year => $yg, month => $mg, day => $dg);
  my $begin  = $date_g->dow % 7;
  printf("  # Year $year begins on %s (%s)\n", $day_names[$begin], $date_g->strftime("%A %Y-%m-%d"));
  for my $d (1..5) {
    prt_line($year - 1, 13, $d, 360, $begin + 1, 'aweleacʿ');
  }
  for my $d (1..6) {
    prt_line($year, 1, $d, 0, $begin - 1, 'nawasard-i');
  }
}

sub prt_line {
  my ($year, $month, $day, $shift_doy, $shift_dow, $month_name) = @_;
  my $dow = ($day + $shift_dow) % 7;
  my $tag = '   ';
  if ($dow == 0) {
    $tag = 'vvv';
  }
  elsif ($dow == 3) {
    $tag = '...';
  }
  elsif ($dow == 6) {
    $tag = '^^^';
  }
  my $wednesday = $shift_doy + $day + 3 - $dow;
  my $week = week_number($wednesday);
  my $week_year = $year;
  if ($wednesday > 365) {
    $week_year ++;
    $week = week_number($wednesday - 365);
  }
  elsif ($wednesday < 1) {
    $week_year --;
    $week = week_number($wednesday + 365);
  }
  printf(", (%d, %2d, %d, %3d, '%d-W%02d-%d') # %s %s %d %s %d\n", $year, $month, $day, $day + $shift_doy, $week_year, $week, $dow + 1, $tag, $day_names[$dow], $day, $month_name, $year);
}

sub week_number {
  my ($doy) = @_;
  return int(($doy + 6) / 7);
}

__END__

=encoding utf8

=head1 NAME

mk-tests-week.pl - generate test data for the Raku module on Armenian calendar

=head1 SYNOPSIS

  perl mk-tests-week.pl 1474

=head1 DESCRIPTION

This program generates test data for the Armenian calendar, especially
for the week-related attributes.

=head1 PARAMETERS

The program receives one or more year numbers. For example:

  perl mk-tests-week.pl 1474 1477

will generate data spanning the last 5  days of 1473, the first 6 days
of  1474, the  last  5 days  of  1476 and  the first  6  days of  1747
(Gregorian 2025-07-16 to 2025-07-26 and 2028-07-15 to 2028-07-25)

=head1 PREREQUISITE

The proram requires modules C<Date::Converter> and C<DateTime>.

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2025 Jean Forget, all rights reserved

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
