#!/usr/bin/perl

use strict;
use warnings;
use Time::Piece;

my $today = localtime;

printf("       %4d/ %2d\n", $today->year, $today->mon);
printf(" 日 月 火 水 木 金 土\n");

my $sdy = 1;
my $edy = $today->month_last_day;

my @l;
my $str='';

for (my $i = $sdy; $i < $edy + 1; $i++) {
    my $k = Time::Piece->strptime($today->year . '-' . $today->mon . '-' . $i, "%Y-%m-%d");

    if ($k->wday != 1 && $i == 1) { # 月初日で日曜日以外
        for (my $j = 1; $j < $k->wday; $j++) {
            $str .= '   ';
        }
    }

    if ($k->wday == 1 && $i != 1) { # 月初日以外で日曜日
        push(@l, $str);
        $str = '';
    }

    $str .= sprintf('%3d', $i);
}

if ( length($str) !=0 ) {
    push(@l, $str);
}

foreach my $item ( @l ) {
    print $item . "\n";
}
