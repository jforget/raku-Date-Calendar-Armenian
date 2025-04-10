#!/usr/bin/env -S raku -I../lib -I../../version-new/lib
# -*- encoding: utf-8; indent-tabs-mode: nil -*-
#
# Générer les données de test pour 07-conv-old.rakutest et 08-conv-new.rakutest
# Generate test data for 07-conv-old.rakutest and 08-conv-new.rakutest
#

use v6.d;
use Date::Calendar::Strftime:api<1>;
use Date::Calendar::Armenian;
use Date::Calendar::Aztec;
use Date::Calendar::Aztec::Cortes;
use Date::Calendar::Bahai;
use Date::Calendar::Bahai::Astronomical;
use Date::Calendar::Coptic;
use Date::Calendar::Ethiopic;
use Date::Calendar::Hebrew;
use Date::Calendar::Hijri;
use Date::Calendar::Gregorian;
use Date::Calendar::FrenchRevolutionary;
use Date::Calendar::FrenchRevolutionary::Arithmetic;
use Date::Calendar::FrenchRevolutionary::Astronomical;
use Date::Calendar::Julian;
use Date::Calendar::Julian::AUC;
use Date::Calendar::Maya;
use Date::Calendar::Maya::Astronomical;
use Date::Calendar::Maya::Spinden;
use Date::Calendar::Persian;
use Date::Calendar::Persian::Astronomical;

my %class =   a0 => 'Date::Calendar::Aztec'
            , a1 => 'Date::Calendar::Aztec::Cortes'
            , ba => 'Date::Calendar::Bahai'
            , be => 'Date::Calendar::Bahai::Astronomical'
            , gr => 'Date::Calendar::Gregorian'
            , co => 'Date::Calendar::Coptic'
            , et => 'Date::Calendar::Ethiopic'
            , fr => 'Date::Calendar::FrenchRevolutionary'
            , fa => 'Date::Calendar::FrenchRevolutionary::Arithmetic'
            , fe => 'Date::Calendar::FrenchRevolutionary::Astronomical'
            , he => 'Date::Calendar::Hebrew'
            , hi => 'Date::Calendar::Hijri'
            , jl => 'Date::Calendar::Julian'
            , jc => 'Date::Calendar::Julian::AUC'
            , m0 => 'Date::Calendar::Maya'
            , m1 => 'Date::Calendar::Maya::Astronomical'
            , m2 => 'Date::Calendar::Maya::Spinden'
            , pe => 'Date::Calendar::Persian'
            , pa => 'Date::Calendar::Persian::Astronomical'
            ;

my %midnight = ba => False
             , be => False
             , co => False
             , et => False
             , fr => True
             , fa => True
             , fe => True
             , gr => True
             , he => False
             , hi => False
             , jl => True
             , jc => True
             , pe => True
             , pa => True
             ;

my @new-maya;
my @new-others;

say '07-conv-old.rakutest variables @data and then @data-greg';
gener-others('ba', 1470,  7,  4);
gener-others('be', 1473, 10, 16);
gener-others('co', 1472,  2, 27);
gener-others('et', 1471,  4,  6);
gener-others('fr', 1473,  9, 12);
gener-others('fa', 1471,  8, 10);
gener-others('fe', 1472,  6, 21);
gener-others('gr', 1470, 12,  5);
gener-others('he', 1472, 11,  6);
gener-others('hi', 1470,  3, 14);
gener-others('jl', 1473,  9, 29);
gener-others('jc', 1473,  8,  2);
gener-others('pe', 1471, 11, 27);
gener-others('pa', 1470, 10,  2);
say '-' x 50;
say '07-conv-old.rakutest variable @data-maya';
gener-maya('m0', 1473,  7, 11);
gener-maya('m1', 1471,  9,  7);
gener-maya('m2', 1473,  1, 20);
gener-maya('a0', 1473, 10,  3);
gener-maya('a1', 1472,  6, 10);
say '-' x 50;
say '08-conv-new.rakutest variables @data';
say @new-others.join("");
say '-' x 50;
say '08-conv-new.rakutest variable @data-maya';
say @new-maya.join("");

sub gener-others($key, $year, $month, $day) {
  my Date::Calendar::Armenian $da1 .= new(year => $year, month => $month, day => $day);
  my Date::Calendar::Armenian $da2 .= new-from-daycount($da1.daycount + 1);
  my     $d1  = $da1.to-date(%class{$key});
  my     $d2  = $da2.to-date(%class{$key});
  my Str $s1  = $d1 .strftime('"%A %d %b %Y"');
  my Str $sa1 = $da1.strftime('"%a %d %b %Y ☼"');
  my Str $gr1 = $da1.to-date.gist;
  my Str $gr2 = $da2.to-date.gist;
  my Str $s2  = $d2 .strftime('"%A %d %b %Y"');
  my Str $sa2 = $da2.strftime('"%a %d %b %Y ☼"');
  my Int $lg-s1 = 26;
  my Int $lg-sa = 19;
  if $s1 .chars < $lg-s1 { $s1  ~= ' ' x ($lg-s1 - $s1 .chars); }
  if $sa1.chars < $lg-sa { $sa1 ~= ' ' x ($lg-sa - $sa1.chars); }
  if $s2 .chars < $lg-s1 { $s2  ~= ' ' x ($lg-s1 - $s2 .chars); }
  if $sa2.chars < $lg-sa { $sa2 ~= ' ' x ($lg-sa - $sa2.chars); }
  my Str $day-x   = sprintf("%2d", $day);
  my Str $month-x = sprintf("%2d", $month);
  print qq:to<EOF>;
       , ($year, $month-x, $day-x, daylight,       '$key', $s1, $sa1, "$gr1 no problem")
       , ($year, $month-x, $day-x, after-sunset,   '$key', $s1, $sa1, "$gr1 shift to daylight")
       , ($year, $month-x, $day-x, before-sunrise, '$key', $s2, $sa2, "$gr2 shift to next day")
  EOF

  $s1  = $d1 .strftime("%A %d %b %Y");
  $s2  = $d2 .strftime("%A %d %b %Y");
  $sa1 = $da1.strftime("%a %d %b %Y");
  $sa2 = $da2.strftime("%a %d %b %Y");
  my Int $lg = 24;
  my Str $w1 = ''; if $s1.chars < $lg { $w1 = ' ' x ($lg - $s1.chars); }
  my Str $w2 = ''; if $s1.chars < $lg { $w2 = ' ' x ($lg - $s2.chars); }
  if %midnight{$key} {
    push @new-others, qq:to<EOF>;
         , ($year, $month-x, $day-x, daylight,       '$key', "$s1 ☼"$w1, "$sa1 ☼", "Gregorian: $gr1")
         , ($year, $month-x, $day-x, after-sunset,   '$key', "$s1 ☽"$w1, "$sa1 ☽", "Gregorian: $gr1")
         , ($year, $month-x, $day-x, before-sunrise, '$key', "$s2 ☾"$w2, "$sa1 ☾", "Gregorian: $gr2")
    EOF
  }
  else {
    push @new-others, qq:to<EOF>;
         , ($year, $month-x, $day-x, daylight,       '$key', "$s1 ☼"$w1, "$sa1 ☼", "Gregorian: $gr1")
         , ($year, $month-x, $day-x, after-sunset,   '$key', "$s2 ☽"$w2, "$sa1 ☽", "Gregorian: $gr1")
         , ($year, $month-x, $day-x, before-sunrise, '$key', "$s2 ☾"$w2, "$sa1 ☾", "Gregorian: $gr2")
    EOF
  }
}

sub gener-maya($key, $year, $month, $day) {
  my Date::Calendar::Armenian $da1 .= new(year => $year, month => $month, day => $day);
  my Date::Calendar::Armenian $da0 .= new-from-daycount($da1.daycount - 1);
  my Date::Calendar::Armenian $da2 .= new-from-daycount($da1.daycount + 1);
  my Str $sa0;
  my Str $sa1 = $da1.strftime('"%a %d %b %Y ☼"');
  my Str $sa2 = $da2.strftime('"%a %d %b %Y ☼"');
  my Str $sa3;
  my     $d0  = $da0.to-date(%class{$key});
  my     $d1  = $da1.to-date(%class{$key});
  my     $d2  = $da2.to-date(%class{$key});
  my Str $s0;
  my Str $s1  = $d1 .strftime('"%e %B %V %A"');
  my Str $s2  = $d2 .strftime('"%e %B %V %A"');;
  my Str $l0  = $d0 .strftime( '%e %B ') ~ $d1.strftime( '%V %A');
  my Str $l2  = $d1 .strftime( '%e %B ') ~ $d2.strftime( '%V %A');
  my Str $gr1 = $da1.to-date.gist;
  my Str $gr2 = $da2.to-date.gist;
  my Int $lg-s1 = 29;
  my Int $lg-sa = 19;
  if $s1 .chars < $lg-s1 { $s1  ~= ' ' x ($lg-s1 - $s1 .chars); }
  if $sa1.chars < $lg-sa { $sa1 ~= ' ' x ($lg-sa - $sa1.chars); }
  if $s2 .chars < $lg-s1 { $s2  ~= ' ' x ($lg-s1 - $s2 .chars); }
  if $sa2.chars < $lg-sa { $sa2 ~= ' ' x ($lg-sa - $sa2.chars); }
  my Str $day-x   = sprintf("%2d", $day);
  my Str $month-x = sprintf("%2d", $month);
  print qq:to<EOF>;
       , ($year, $month-x, $day-x, daylight,       '$key', $s1, $sa1, "$gr1 no problem")
       , ($year, $month-x, $day-x, after-sunset,   '$key', $s1, $sa1, "$gr1 wrong intermediate date, should be $l2")
       , ($year, $month-x, $day-x, before-sunrise, '$key', $s2, $sa2, "$gr2 shift to next day")
  EOF

  $sa0 = $da1.strftime('"%a %d %b %Y ☾"');
  $sa1 = $da1.strftime('"%a %d %b %Y ☼"');
  $sa2 = $da1.strftime('"%a %d %b %Y ☽"');
  $sa3 = $da1.strftime('"%a %d %b %Y ☾"');
  $s1  = $d1 .strftime('"%e %B %V %A"');
  $s0  = $d0 .strftime('"%e %B ') ~ $d1.strftime('%V %A"');
  $s2  = $d1 .strftime('"%e %B ') ~ $d2.strftime('%V %A"');
  $lg-s1 = 29;
  $lg-sa = 19;
  if $s0 .chars < $lg-s1 { $s0  ~= ' ' x ($lg-s1 - $s0 .chars); }
  if $s1 .chars < $lg-s1 { $s1  ~= ' ' x ($lg-s1 - $s1 .chars); }
  if $s2 .chars < $lg-s1 { $s2  ~= ' ' x ($lg-s1 - $s2 .chars); }
  if $sa0.chars < $lg-sa { $sa0 ~= ' ' x ($lg-sa - $sa0.chars); }
  if $sa1.chars < $lg-sa { $sa1 ~= ' ' x ($lg-sa - $sa1.chars); }
  if $sa2.chars < $lg-sa { $sa2 ~= ' ' x ($lg-sa - $sa2.chars); }
  if $sa3.chars < $lg-sa { $sa3 ~= ' ' x ($lg-sa - $sa3.chars); }
  push @new-maya, qq:to<EOF>;
       , ($year, $month-x, $day-x, daylight,       '$key', $s1, $sa1, "Gregorian: $gr1")
       , ($year, $month-x, $day-x, after-sunset,   '$key', $s2, $sa2, "Gregorian: $gr1")
       , ($year, $month-x, $day-x, before-sunrise, '$key', $s2, $sa3, "Gregorian: $gr2")
  EOF
}

=begin pod

=head1 NAME

gener-test-0.1.0.raku -- Generation of test data

=head1 SYNOPSIS

  raku gener-test-0.1.0.raku > /tmp/test-data

Copy-paste from /tmp/test-data to the tests scripts.

=head1 DESCRIPTION

This program  uses the  various C<Date::Calendar::>R<xxx>  classes, to
generate test  data for version 0.1.0  and API 1. After  the test data
are generated, check them with  another source (the calendar functions
in Emacs, some websites, some  Android apps). Please remember that the
other sources do not care about sunset (and sunrise for the civil Maya
and Aztec calendars  and for the Armenian calendar) and  that you will
have to mentally shift the results before the comparison.

And after  the data are  checked, copy-paste  the lines into  the test
scripts C<xt/07-conv-old.rakutest> and C<xt/08-conv-new.rakutest>.

In C<xt/07-conv-old.rakutest>,  fill the C<@data-maya> array  with the
lines listing Maya and Aztec  dates and fill the C<@data-others> array
with the lines listing other dates. Then cut the lines listing C<'gr'>
dates  and  paste  them  into  the C<@data-greg>  array  and  add  the
Gregorian date with  the 'YYYY-MM-AA' format at the end  of each array
line.

Note:  the  C<07-conv-old.rakutest>  data  is meant  to  check,  among
others, the C<Date::Calendar::Ethiopian>  module, version C<0.0.3>, in
which there was an off-by-one error on the weekday names. On the other
hand,  in this  program, the  Ethiopian  data was  generated with  the
C<Date::Calendar::Ethiopian>   module,  version   C<0.1.1>,  with   no
off-by-one    error.    So     when    copying-pasting    data    into
C<07-conv-old.rakutest>, you should  reintroduce the off-by-one errors
with:

  s/Sanyo/Maksegno/
  s/Maksanyo/Rob/

In C<xt/08-conv-new.rakutest>,  fill the C<@data-maya> array  with the
lines listing  Maya and Aztec dates  and fill the C<@data>  array with
the lines listing other dates. No special processing for the Gregorian
dates and the Ethiopian dates.

Remember  that you  need to  erase the  first comma  in each  chunk of
copied-pasted code.

All computed  dates are daylight  dates. So  it does not  matter which
version  and API  are  such  and such  classes.  Daylight dates  gives
exactly the  same results with version  0.1.x / API 1  as with version
0.0.y / API 0.

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2025 Jean Forget, all rights reserved

This program is  free software; you can redistribute  it and/or modify
it under the Artistic License 2.0.

=end pod
