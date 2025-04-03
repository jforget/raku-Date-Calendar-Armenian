use v6.d;
unit module Date::Calendar::Armenian::Names:ver<0.1.0>:auth<zef:jforget>:api<1>;

my @month-names = < nawasard-i  hoṙ-i       sahm-i
                    trē         kʿało-cʿ    ara-cʿ
                    mehekan-i   areg        ahekan-i
                    marer-i     marga-cʿ    hroti-cʿ
                    aweleacʿ
                  >
;

my @month-abbr = < Naw Hor Sah Tre Kal Ara
                   Meh Are Ahe Mrr Mrg Hro Awe >;
;
my @day-names = < kiraki erkušabatʿi erekʿšabatʿi čʿorekʿšabatʿi hingšabatʿi urbatʿ šabatʿi >;
my @day-abbr  = < kir    erk         ere          cor            hin         urb    sab     >;

my @day-of-month = < areg     hrand   aram    margar   ahrankʿ
                     mazdeł   astłik  mihr    jopaber  murcʿ
                     erezkan  ani     parxar  vanat    aramazd
                     mani     asak    masis   anahit   aragac
                     gorgor   kordi   cmak    lusnak   cʿrōn
                     npat     vahagn  sēin    varag    gišeravar
                   >;

my @day-of-awe  = < pʿaylažu arusyak hrat lusntʿag erewak >;

our sub month-name(Int:D $month --> Str) {
  return @month-names[$month - 1];
}

our sub month-abbr(Int:D $month --> Str) {
  return @month-abbr[$month - 1];
}

our sub day-name(Int:D $day7 --> Str) {
  return @day-names[$day7];
}

our sub day-abbr(Int:D $day7 --> Str) {
  return @day-abbr[$day7];
}

our sub day-of-month(Int:D $month, Int:D $day --> Str) {
  if $month == 13 {
    return @day-of-month[$day - 1];
  }
  else {
    return @day-of-awe[$day - 1];
  }
}


=begin pod

=head1 NAME

Date::Calendar::Armenian::Names - string values for the Armenian calendar

=head1 SYNOPSIS

=begin code :lang<raku>

use Date::Calendar::Armenian;

=end code

=head1 DESCRIPTION

Date::Calendar::Armenian::Names is a utility module, providing
string values for the main module Date::Calendar::Armenian.

=head1 SOURCES

The day names and month names come from
L<http://www.epistemeacademy.org/calendars/yearly_calendar.html?cyear=2020&vADBC=AD&CCode=Armenian&day=1>

Other webpages have been used to cross-check these values:
L<https://en.wikipedia.org/wiki/Armenian_calendar>,
L<http://www.tacentral.com/astronomy.asp?story_no=3>,
L<https://icalendrier.fr/calendriers-saga/calendriers/armenien> (in French).

The abbreviations  have been chosen  by me, they  do not come  from an
authoritaive source. Patches welcome.

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2025 Jean Forget, all rights reserved

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
