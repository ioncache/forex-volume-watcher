!/usr/bin/env perl

use strict;
use warnings;
use utf8;

#use Data::Dump qw<dump>;
use Data::Printer;

#use IO::Async::Loop;
#use JSON;
#use Net::Async::WebSocket::Client;
#
#my $j = JSON->new;
#
#my $client = Net::Async::WebSocket::Client->new(
#    on_frame => sub {
#        my ( $self, $frame ) = @_;
#        print $frame;
#    },
#);
#
#my $loop = IO::Async::Loop->new;
#$loop->add($client);
#
#$client->connect(
#    host    => "localhost",
#    service => 5000,
#    url     => "ws://localhost:5000/rates/ws",
#
#    on_connected => sub {
#        warn "connected";
#        #$client->send_frame("Hello world!");
#    },
#
#    on_connect_error => sub { die "Cannot connect - $_[-1]" },
#    on_resolve_error => sub { die "Cannot resolve - $_[-1]" },
#);
#
#$loop->loop_forever;

#use Protocol::WebSocket::Handshake::Client;
#
#my $h =
#  Protocol::WebSocket::Handshake::Client->new(url => 'ws://localhost:5000/rates/ws');
# 
## Create request
#$h->to_string;
# 
## Parse server response
#print $h->parse(<<"EOF");
#    WebSocket HTTP message
#EOF
# 
#print $h->error;   # Check if there were any errors
#
#p $h;
#print $h->is_done; # Returns 1

#use AnyEvent;
#use Protocol::WebSocket::Frame;
#use Protocol::WebSocket::Handshake::Client;
#use IO::Socket;
#use constant {READ => 0, WRITE => 1};
#
#$| = 1;
#
#run();
#
#sub run {
#  my $cv = AE::cv;
#  my $s = IO::Socket::INET->new(PeerAddr => '127.0.0.1', PeerPort => 5000, Proto => 'tcp', Blocking => 0);
#  if (not $s or not $s->connected) {
#    client_exit();
#  }
#
#  my $hc = Protocol::WebSocket::Handshake::Client->new(url => 'ws://127.0.0.1:5000/rates/ws');
#  # handshare request
#  $s->syswrite($hc->to_string);
#
#  my (@messages, $wsr, $wsw, $stdin);
#
#  my $finish = sub { undef $stdin; undef $wsr; undef $wsw; $cv->send; client_exit($s) };
#
#  local @SIG{qw/INT TERM ALRM/} = ($finish) x 3;
#
#  $stdin = AE::io *STDIN, READ, sub {
#    my $line = <STDIN>;
#    unless ($line) {
#      $finish->();
#    } else {
#      chomp $line;
#      push @messages, Encode::decode('utf8', $line)
#    }
#  };
#
#  $wsw = AE::io $s, WRITE, sub {
#    if ($s->connected) {
#      while (my $msg = shift @messages) {
#        $s->syswrite(Protocol::WebSocket::Frame->new($msg)->to_string);
#      }
#    } else {
#      $finish->();
#    }
#  };
#
#  # parse server response
#  my $frame_chunk = '';
#  until ($hc->is_done) {
#    $s->sysread(my $buf, 1024);
#    if ($buf) {
#      if ($buf =~ s{(\x00.+)$}{}) {
#        $frame_chunk = $1;
#      }
#      print $buf;
#      $hc->parse($buf);
#      if ($hc->error) {
#        warn $hc->error;
#        $finish->();
#      }
#    }
#  }
#
#  my $frame = Protocol::WebSocket::Frame->new();
#  $frame->append($frame_chunk) if $frame_chunk;
#  $wsr = AE::io $s, READ, sub {
#    $s->sysread(my $buf, 100);
#    $frame->append($buf);
#    while (my $msg = $frame->next) {
#      print Encode::encode('utf8', $msg), "\n";
#    }
#  };
#
#  $cv->recv;
#
#  client_exit($s);
#}
#
#sub client_exit {
#  my $s = shift;
#  close $s if $s;
#  exit;
#}