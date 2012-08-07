#!/usr/bin/env perl
use strict;
use warnings;

use AnyEvent;
use AnyMQ;
use Dancer;
use Data::Dump qw<dump>;
use Plack::Builder;

my $bus = AnyMQ->new;
my $topic = $bus->topic('rates');

our $w = AnyEvent->timer(after => 1, interval => 1, cb => sub {
    $topic->publish({ msg => time });
});

# Web::Hippie routes
get '/new_listener' => sub {
    request->env->{'hippie.listener'}->subscribe($topic);
};

get '/message' => sub {
    my $msg = request->env->{'hippie.message'};
    $topic->publish($msg);
};

builder {
    mount '/rates' => builder {
        enable '+Web::Hippie';
        enable '+Web::Hippie::Pipe', bus => $bus;
        dance;
    };
};
