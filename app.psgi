# app.psgi
use strict;
use warnings;

use AnyEvent::Handle;
use AnyEvent;
use Plack::Builder;
use Plack::Request;

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $res = $req->new_response(200);

    if (my $fh = $env->{'websocket.impl'}->handshake) {
        return start_ws_echo($fh);
    }
    $res->code($env->{'websocket.impl'}->error_code);

    return $res->finalize;
};

sub start_ws_echo {
    my ($fh) = @_;

    my $handle = AnyEvent::Handle->new(fh => $fh);
    return sub {
        my $respond = shift;

        on_read $handle sub {
            shift->push_read(
                'AnyEvent::Handle::Message::WebSocket',
                sub {
                    my $msg = $_[1];
                    my $w;
                    $w = AE::timer 1, 0, sub {
                        $handle->push_write(
                            'AnyEvent::Handle::Message::WebSocket', $msg);
                        undef $w;
                    };
                },
            );
        };
    };
}

builder {
    enable 'WebSocket';
    $app;
};

