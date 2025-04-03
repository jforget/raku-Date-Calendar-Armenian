NAME
====

Date::Calendar::Armenian - Conversions from / to the Armenian calendar

SYNOPSIS
========

Converting a Gregorian date (e.g. 13th November 2024) into Armenian

```
use Date::Calendar::Armenian;
my  Date                     $d-grg
my  Date::Calendar::Armenian $d-arm;

$d-grg .= new(2024, 11, 13);
$d-arm .= new-from-date($d-grg);

say $d-arm;
# --> 1474-04-26
say "{.day-name} {.day} {.month-name} {.year}" with $d-arm;
# --> čʿorekʿšabatʿi 26 trē 1474

```

Converting a Armenian date (e.g. 16 ahekan 1474) into Gregorian

```
use Date::Calendar::Armenian;
my  Date::Calendar::Armenian $d-arm;
my  Date                     $d-grg;

$d-arm .= new(year  => 1474
            , month =>    9
            , day   =>   16);
$d-grg = $d-arm.to-date;

say $d-grg;
# ---> 2025-04-02
```

Converting a Armenian date to Gregorian, while paying attention to sunset.

```
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
```

INSTALLATION
============

```shell
zef install Date::Calendar::Armenian
```

or

```shell
git clone https://github.com/jforget/raku-Date-Calendar-Armenian.git
cd raku-Date-Calendar-Armenian
zef install .
```

DESCRIPTION
===========

Date::Calendar::Armenian is a class representing dates in the Armenian
calendar. It allows you to convert an Armenian date into Gregorian (or
possibly other) calendar and the other way.

when creating  the `Date::Calendar::xxxx` instance, you  may include a
`daypart` parameter, so the conversion will give the proper result for
dates after sunset.

AUTHOR
======

Jean Forget <J2N-FORGET at orange dot fr>

COPYRIGHT AND LICENSE
=====================

Copyright (c) 2025 Jean Forget, all rights reserved

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

