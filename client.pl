#!/usr/bin/env perl

use strict;
use warnings;

use AnyEvent;
use Furl;
use utf8;

my $furl = Furl->new;

while(1) {
    $furl->post('http://localhost:5000/new_rates', [], { rates => time });
    sleep 1;
}
