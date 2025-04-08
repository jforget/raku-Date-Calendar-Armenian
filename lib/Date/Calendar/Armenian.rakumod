use v6.d;
use Date::Calendar::Strftime;
use Date::Calendar::Armenian::Names;

unit class Date::Calendar::Armenian:ver<0.1.0>:auth<zef:jforget>:api<1>
      does Date::Calendar::Strftime;

has Int $.daycount;
has Int $.daypart where { before-sunrise() ≤ $_ ≤ after-sunset() };
has Int $.year    where { $_ ≥ 1 };
has Int $.month   where { 1 ≤ $_ ≤ 13 };
has Int $.day     where { 1 ≤ $_ ≤ 30 };
has Int $.day-of-year;
has Int $.day-of-week;
has Int $.week-number;
has Int $.week-year;

method BUILD(Int:D :$year, Int:D :$month, Int:D :$day, Int :$daypart = daylight()) {
  $._chek-build-args($year, $month, $day);
  $._build-from-args($year, $month, $day, $daypart);
}

method _chek-build-args(Int $year, Int $month, Int $day) {
  if $month == 13 && $day > 5 {
    X::OutOfRange.new(:what<Day>, :got($day), :range<1..5 for additional days (aveliats)>).throw;
  }
}

method _build-from-args(Int $year, Int $month, Int $day, Int $daypart) {
  $!year    = $year;
  $!month   = $month;
  $!day     = $day;
  $!daypart = $daypart;

  # computing derived attributes
  my $doy      =  30 × ($month - 1) + $day;
  my $daycount = 365 × $year + $doy - 477499;
  my $dow      = ($daycount + 3) % 7 + 1;
  if $daypart == before-sunrise() {
    # after computing $dow, not before!
    ++$daycount;
  }

  # storing derived attributes
  $!day-of-year = $doy;
  $!day-of-week = $dow;
  $!daycount    = $daycount;

  # computing week-related derived attributes
  my Int $doy-wed   = $doy - $dow + 4; # day-of-year value for the nearest čʿorekʿšabatʿi / Wednesday
  my Int $week-year = $year;
  if $doy-wed ≤ 0 {
    -- $week-year;
    $doy    += 365;
    $doy-wed = $doy - $dow + 4;
  }
  elsif $doy-wed > 365 {
    ++ $week-year;
    $doy    -= 365;
    $doy-wed = $doy - $dow + 4;
  }
  my Int $week-number = ($doy-wed / 7).ceiling;

  # storing week-related derived attributes
  $!week-number = $week-number;
  $!week-year   = $week-year;
}

method gist {
  sprintf("%04d-%02d-%02d", $.year, $.month, $.day);
}

method month-name {
  Date::Calendar::Armenian::Names::month-name($.month);
}

method month-abbr {
  Date::Calendar::Armenian::Names::month-abbr($.month);
}

method day-name {
  Date::Calendar::Armenian::Names::day-name($.day-of-week);
}

method day-abbr {
  Date::Calendar::Armenian::Names::day-abbr($.day-of-week);
}

method month-day-name {
  Date::Calendar::Armenian::Names::day-of-month($.month, $.day);
}

method specific-format { %( Ed => { $.month-day-name }
                          ) }

method new-from-date($date) {
  $.new-from-daycount($date.daycount, daypart => $date.?daypart // daylight());
}

method new-from-daycount(Int $count is copy, Int :$daypart = daylight()) {
  if $daypart == before-sunrise() {
    --$count;
  }
  $count += 477498;
  my Int $y = ($count / 365).Int; $count -= $y × 365;
  my Int $m = ($count /  30).Int; $count -= $m ×  30;
  $.new(year => $y, month => $m + 1, day => $count + 1, daypart => $daypart);
}

method to-date($class = 'Date') {
  # See "Learning Perl 6" page 177
  my $d = ::($class).new-from-daycount($.daycount, daypart => $.daypart);
  return $d;
}

=begin pod

=head1 NAME

Date::Calendar::Armenian - Conversions from / to the Armenian calendar

=head1 SYNOPSIS

Converting a Gregorian date (e.g. 13th November 2024) into Armenian

=begin code :lang<raku>

use Date::Calendar::Armenian;
my  Date                     $d-grg
my  Date::Calendar::Armenian $d-arm;

$d-grg .= new(2024, 11, 13);
$d-arm .= new-from-date($d-grg);

say $d-arm;
# --> 1474-04-26
say "{.day-name} {.day} {.month-name} {.year}" with $d-arm;
# --> čʿorekʿšabatʿi 26 trē 1474
say $d-arm.strftime("%A %d %B %Y");
# --> čʿorekʿšabatʿi 26 trē 1474

=end code

Converting a Armenian date (e.g. 16 ahekan 1474) into Gregorian

=begin code :lang<raku>

use Date::Calendar::Armenian;
my  Date::Calendar::Armenian $d-arm;
my  Date                     $d-grg;

$d-arm .= new(year  => 1474
            , month =>    9
            , day   =>   16);
$d-grg = $d-arm.to-date;

say $d-grg;
# ---> 2025-04-02

=end code

Converting a Armenian date to Gregorian, while paying attention to sunset.

=begin code :lang<raku>

use Date::Calendar::Armenian;
use Date::Calendar::Strftime;
my  Date::Calendar::Armenian $d-arm;
my  Date                     $d-grg;

$d-arm .= new(year    => 1474
            , month   =>    9
            , day     =>   16
            , daypart => before-sunrise());
$d-grg = $d-arm.to-date;

say $d-grg;
# ---> 2025-04-03 instead of 2025-04-02

# on the other hand:
$d-arm .= new(year => 1474, month => 9, day => 16, daypart => after-sunset());
$d-grg  = $d-arm.to-date;
say $d-grg;
# --> '2025-04-02'

$d-arm .= new(year => 1474, month => 9, day => 16, daypart => daylight());
$d-grg  = $d-arm.to-date;
say $d-grg;
# --> '2025-04-02' also

=end code

=head1 DESCRIPTION

Date::Calendar::Armenian is a class representing dates in the Armenian
calendar. It allows you to convert an Armenian date into Gregorian (or
possibly other) calendar and the other way.

The Armenian calendar uses a vague year, that is, a year with 365 days
and no leap adjustment. A year is  divided into 12 months with 30 days
each, plus  5 additional days  which appear in  this class as  a short
13th month.

According to L<http://www.tacentral.com/astronomy.asp?story_no=3>,
The switch from  a date to the  next occurs at sunrise.

=head1 METHODS

=head2 Constructors

=head3 new

Create an  Armenian date by  giving the  year, month and  day numbers,
plus the day part (C<before-sunrise>, C<daylight> or C<after-sunset>).

=head3 new-from-date

Build an Armenian  date by cloning an object from  another class. This
other   class    can   be    the   core    class   C<Date>    or   any
C<Date::Calendar::>R<xxx>  class   with  a  C<daycount>   method  and,
hopefully, a C<daypart> method.

=head3 new-from-daycount

Build  an Armenian  date from  the Modified  Julian Day  number and  the
C<daypart> value.

=head2 Accessors

=head3 gist

Gives a short string representing the date, in C<YYYY-MM-DD> format.

=head3 year, month, day

The numbers defining the date.

=head3 daycount

The MJD (Modified Julian Date) number for the date.

=head3 daypart

A  number indicating  which part  of the  day. This  number should  be
filled   and   compared   with   the   following   subroutines,   with
self-documenting names:

=item before-sunrise()
=item daylight()
=item after-sunset()

=head3 month-name

The month of the date, as a string.

=head3 month-abbr

The month of the  date, as a 3-char string.

=head3 day-name

The name of the day within  the week.

=head3 day-of-week

The number of  the day within the  week (1 for Sunday / kiraki, 7
for Saturday / šabatʿi).

=head3 week-number

The number  of the  week within the  year, 1  to 52 or  1 to  53. Week
number  1 is  the Sun→Sat  span that  contains the  first Wednesday  /
čʿorekʿšabatʿi of  the year, week  number 2  is the Sun→Sat  span that
contains the second Wednesday / čʿorekʿšabatʿi of the year and so on.

The week number and the week year (see below) are not a feature of the
Armenian  calendar.  They are  a  feature  of the  Gregorian  calendar
(so-called "ISO date") ported to the Armenian calendar.

=head3 week-year

Mostly similar  to the C<year>  attribute. Yet,  the last days  of the
year  and  the  first  days  of the  following  year  can  be  sort-of
transferred  to the  other year.  The C<week-year>  attribute reflects
this transfer. While  the real year always begins on  1st Navasard and
ends  on 5th  Aveliats, the  C<week-year>  always begins  on Sunday  /
kiraki and it always ends on Saturday / šabatʿi.

=head3 day-of-year

How many days since the beginning of the year. 1 to 365.

=head3 month-day-name

In addition to its name representing  its position within a week, each
days  has  a  name  representing  its position  within  a  month.  The
C<month-day-name> method gives this second name.

=head2 Other Methods

=head3 to-date

Clones  the   date  into   a  core  class   C<Date>  object   or  some
C<Date::Calendar::>R<xxx> compatible calendar  class. The target class
name is given  as a positional parameter. This  parameter is optional,
the default value is C<"Date"> for the Gregorian calendar.

To convert a date from a  calendar to another, you have two conversion
styles,  a "push"  conversion and  a "pull"  conversion. For  example,
while converting "26 Tre 1474" to the Julian calendar, you can code:

=begin code :lang<raku>

use Date::Calendar::Armenian;
use Date::Calendar::Julian;

my  Date::Calendar::Armenian $d-orig;
my  Date::Calendar::Julian   $d-dest-push;
my  Date::Calendar::Julian   $d-dest-pull;

$d-orig .= new(year  => 1474
             , month =>    9
             , day   =>   26);
$d-dest-push  = $d-orig.to-date("Date::Calendar::Julian");
$d-dest-pull .= new-from-date($d-orig);
say $d-orig, ' ', $d-dest-push, ' ', $d-dest-pull;
# --> "1474-09-26 2024-10-31 2024-10-31"

=end code

When converting  I<from> the core  class C<Date>, use the  pull style.
When converting I<to> the core class C<Date>, use the push style. When
converting from  any class other  than the  core class C<Date>  to any
other  class other  than the  core class  C<Date>, use  the style  you
prefer. For the Gregorian calendar, instead of the core class C<Date>,
you can use the  child class C<Date::Calendar::Gregorian> which allows
both push and pull styles.

=head3 strftime

The C<strftime> method is similar  to the C<strftime> functions you in
several  languages (C,  shell, etc)  and to  the C<strftime>  function
described below. Please refer to this function. The only difference is
the call syntax:

=begin code :lang<raku>

say $df.strftime("%04d blah blah blah %-25B"); # using the method
say strftime($df,"%04d blah blah blah %-25B"); # using the function

=end code

=head1 FUNCTIONS

The class exports only one function.

=head3 strftime

This function is very similar to the homonymous functions you can find
in several  languages (C, shell, etc).  It also takes some  ideas from
C<printf>-similar functions. For example

=begin code :lang<raku>

strftime($d, "%04d blah blah blah %-25B")

=end code

will give  the day number  padded on  the left with  2 or 3  zeroes to
produce a 4-digit substring, plus the substring C<" blah blah blah ">,
plus the month name, padded on the right with enough spaces to produce
a 25-char substring. Thus, the whole  string will be at least 42 chars
long. By  the way, you  can drop the  "at least" mention,  because the
longest month  name is 7-char long,  so the padding will  always occur
and will always include at least 18 spaces.

A C<strftime> specifier consists of:

=item A percent sign,

=item An  optional minus sign, to  indicate on which side  the padding
occurs. If the minus sign is present, the value is aligned to the left
and the padding spaces are added to the right. If it is not there, the
value is aligned to the right and the padding chars (spaces or zeroes)
are added to the left.

=item  An  optional  zero  digit,  to  choose  the  padding  char  for
right-aligned values.  If the  zero char is  present, padding  is done
with zeroes. Else, it is done wih spaces.

=item An  optional length, which  specifies the minimum length  of the
result substring.

=item  An optional  C<"E">  or  C<"O"> modifier.  On  some older  UNIX
system,  these  were used  to  give  the I<extended>  or  I<localized>
version  of  the date  attribute.  Here,  they rather  give  alternate
variants of the date attribute.

=item A mandatory type code.

The allowed type codes are:

=defn %A

The full day of week name.

=defn %b

The abbreviated month name.

=defn %B

The full month name.

=defn %d

The day of the month as a decimal number (range 01 to 30).

=defn %Ed

The name of the day within the month, corresponding to method C<month-day-name>.

=defn %e

Like C<%d>, the  day of the month  as a decimal number,  but a leading
zero is replaced by a space.

=defn %f

The month as a decimal number (1  to 12). Unlike C<%m>, a leading zero
is  replaced  by a  space.  The  special  value  13 represents  the  5
additional days at the end of the year.

=defn %F

Equivalent to %Y-%m-%d (the ISO 8601 date format)

=defn %G

The "week year"  as a decimal number. Mostly similar  to C<%Y>, but it
may differ  on the very  first days  of the year  or on the  very last
days. Analogous to the year number  in the so-called "ISO date" format
for Gregorian dates.

=defn %j

The day of the year as a decimal number (range 001 to 385).

=defn %m

The month as a two-digit decimal  number (range 01 to 13), including a
leading  zero if  necessary. The  special  value 13  represents the  5
additional days at the end of the year.

=defn %n

A newline character.

=defn %Ep

Gives a 1-char string representing the day part:

=item C<☾> or C<U+263E> before sunrise,
=item C<☼> or C<U+263C> during daylight,
=item C<☽> or C<U+263D> after sunset.

Rationale: in  C or in  other programming languages,  when C<strftime>
deals with a date-time object, the day is split into two parts, before
noon and  after noon. The  C<%p> specifier  reflects this by  giving a
C<"AM"> or C<"PM"> string.

The  3-part   splitting  in   the  C<Date::Calendar::>R<xxx>   may  be
considered as  an alternate  splitting of  a day.  To reflect  this in
C<strftime>, we use an alternate version of C<%p>, therefore C<%Ep>.

=defn %t

A tab character.

=defn %u

The day of week as a 1..7 number.

=defn %V

The week  number as defined above,  similar to the week  number in the
so-called "ISO date" format for Gregorian dates.

=defn %Y

The year as a decimal number.

=defn %%

A literal `%' character.

=head1 PROBLEMS AND KNOWN ISSUES

=head2 Names

The  name for  sunday has  changed over  the times.  At first,  it was
I<miašabatʿi> and  it changed to  I<kiraki>. The class uses  the newer
name.

When cross-referencing  the names  given by a  webpage with  the names
given  by  another  webpage,  I   do  not  consider  that  changes  in
transcription are  significant. I  do not  mind reading  I<kiraki> and
I<aweleacʿ>  at one  place and  I<giragi> and  I<Aveliats> at  another
place.

=head2 Sarkawag Reform

The Armenian calendar had a reform proposed by Yovhannes Sarkawag in
1084, to add a leap day every 4 years. According to the C<convertdate>
Python library, this leap day is added after the 5 usual additional
days. According to the webpage
L<https://icalendrier.fr/calendriers-saga/calendriers/armenien>, the
leap day is added between months Mehekan and Areg (months 7 and 8).

This distribution does  not try to implement the  Sarkawag reform. One
reason  is that,  as stated  in  the previous  paragraph, the  sources
disagree about the  way this reform is implemented.  Another reason is
that if the "icalendrier.fr" webpage  is right, there is no convenient
way to represent  the leap days, belonging to a  "7.5"-th month with a
duration of a single day.

=head2 Beginning of the day

As stated above, according to
L<http://www.tacentral.com/astronomy.asp?story_no=3>, days begin at
sunrise. On the other hand, another webpage,
L<https://icalendrier.fr/calendriers-saga/calendriers/armenien> gives
an array starting at 18h, rolling over at 24h and stopping at 17h,
which suggests that days begin at sunset.

This class supposes that days begin at sunrise.

=head2 Definition of the week

No explicit definition of the week is given in the webpages I have
read. Yet, the webpage
L<https://icalendrier.fr/calendriers-saga/calendriers/armenien>  gives
an  array starting  at "dimanche"  (Sunday) and  stopping at  "samedi"
(Saturday), so I consider that a week spans from Sunday to Saturday.

=head2 Security issues

As explained in  the C<Date::Calendar::Strftime> documentation, please
ensure that format-string  passed to C<strftime> comes  from a trusted
source. Failing  that, the untrusted  source can include  a outrageous
length in  a C<strftime> specifier  and can  drain your PC's  RAM very
fast.

=head2 Relations with :ver<0.0.x> classes and with core class Date

Version 0.1.0 (and API 1) was  introduced to ease the conversions with
other calendars in  which the day is  defined as midnight-to-midnight.
If all C<Date::Calendar::>R<xxx> classes use  version 0.1.x and API 1,
the conversions will be correct. But if some C<Date::Calendar::>R<xxx>
classes use version 0.0.x and API 0, there might be problems.

A date from a 0.0.x class has no C<daypart> attribute. But when "seen"
from  a  0.1.x class,  the  0.0.x  date  seems  to have  a  C<daypart>
attribute equal to C<daylight>. When converted from a 0.1.x class to a
0.0.x  class,  the  date  may  just  shift  from  C<after-sunset>  (or
C<before-sunrise>) to C<daylight>, or it  may shift to the C<daylight>
part of  the prior (or  next) date. This  means that a  roundtrip with
cascade conversions  may give the  starting date,  or it may  give the
date prior or after the starting date.

If you install C<<Date::Calendar::Armenian:ver<0.1.0>>>, why would you
refrain from upgrading other C<Date::Calendar::>R<xxxx> classes? So
actually, this issue applies mainly to the core class C<Date>, because
you may prefer avoiding the installation of
C<Date::Calendar::Gregorian>.

=head2 Time

This module  and the C<Date::Calendar::>R<xxx> associated  modules are
still date  modules, they are not  date-time modules. The user  has to
give  the C<daypart>  attribute  as a  value among  C<before-sunrise>,
C<daylight> or C<after-sunset>. There is no provision to give a HHMMSS
time and convert it to a C<daypart> parameter.

=head1 SEE ALSO

=head2 Raku Software

L<Date::Calendar::Strftime|https://raku.land/zef:jforget/Date::Calendar::Strftime>
or L<https://github.com/jforget/raku-Date-Calendar-Strftime>

L<Date::Calendar::Gregorian|https://raku.land/zef:jforget/Date::Calendar::Gregorian>
or L<https://github.com/jforget/raku-Date-Calendar-Gregorian>

L<Date::Calendar::Julian|https://raku.land/zef:jforget/Date::Calendar::Julian>
or L<https://github.com/jforget/raku-Date-Calendar-Julian>

L<Date::Calendar::Hebrew|https://raku.land/zef:jforget/Date::Calendar::Hebrew>
or L<https://github.com/jforget/raku-Date-Calendar-Hebrew>

L<Date::Calendar::CopticEthiopic|https://raku.land/zef:jforget/Date::Calendar::CopticEthiopic>
or L<https://github.com/jforget/raku-Date-Calendar-CopticEthiopic>

L<Date::Calendar::MayaAztec|https://raku.land/zef:jforget/Date::Calendar::MayaAztec>
or L<https://github.com/jforget/raku-Date-Calendar-MayaAztec>

L<Date::Calendar::FrenchRevolutionary|https://raku.land/zef:jforget/Date::Calendar::FrenchRevolutionary>
or L<https://github.com/jforget/raku-Date-Calendar-FrenchRevolutionary>

L<Date::Calendar::Hijri|https://raku.land/zef:jforget/Date::Calendar::Hijri>
or L<https://github.com/jforget/raku-Date-Calendar-Hijri>

L<Date::Calendar::Persian|https://raku.land/zef:jforget/Date::Calendar::Persian>
or L<https://github.com/jforget/raku-Date-Calendar-Persian>

L<Date::Calendar::Bahai|https://raku.land/zef:jforget/Date::Calendar::Bahai>
or L<https://github.com/jforget/raku-Date-Calendar-Bahai>

=head2 Perl 5 Software

L<DateTime|https://metacpan.org/pod/DateTime>

L<Date::Converter|https://metacpan.org/pod/Date::Converter>

=head2 Other Software

date(1), strftime(3)

L<https://pypi.org/project/convertdate/>
or L<https://convertdate.readthedocs.io/en/latest/modules/armenian.html>

CALENDRICA 4.0 -- Common Lisp, which can be download in the "Resources" section of
L<https://www.cambridge.org/us/academic/subjects/computer-science/computing-general-interest/calendrical-calculations-ultimate-edition-4th-edition?format=PB&isbn=9781107683167>
(Actually, I have used the 3.0 version which is not longer available)

=head2 Books

Calendrical Calculations (Third or Fourth Edition) by Nachum Dershowitz and
Edward M. Reingold, Cambridge University Press, see
L<http://www.calendarists.com>
or L<https://www.cambridge.org/us/academic/subjects/computer-science/computing-general-interest/calendrical-calculations-ultimate-edition-4th-edition?format=PB&isbn=9781107683167>.

=head2 Internet

L<http://www.epistemeacademy.org/calendars/yearly_calendar.html?cyear=2020&vADBC=AD&CCode=Armenian&day=1>

L<https://en.wikipedia.org/wiki/Armenian_calendar>
or L<https://fr.wikipedia.org/wiki/Calendrier_arm%C3%A9nien> in French.

L<http://www.tacentral.com/astronomy.asp?story_no=3>

L<https://icalendrier.fr/calendriers-saga/calendriers/armenien> (in French).

L<https://www.ephemeride.com/calendrier/autrescalendriers/21/autres-types-de-calendriers.html>
(in French)

L<https://www.webcal.guru/fr-CD/aujourd%27hui> (in French).

=head1 AUTHOR

Jean Forget <J2N-FORGET at orange dot fr>

=head1 THANKS

Many thanks to  all those who were  involved in Perl 6  / Raku, Rakudo
and Rakudo-Star.

Many thanks  to Andrew,  Laurent and C<brian>  for writing  books that
helped me learn Perl 6 / Raku.

And some additional thanks to Andrew, for writing Perl module C<Date::Converter>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2025 Jean Forget, all rights reserved

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
