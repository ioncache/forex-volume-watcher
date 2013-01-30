#!/usr/bin/perl

# CPAN Modules
use Crypt::GeneratePassword;
use Data::Dumper;
use JSON;
use Mojo::IOLoop;
use Mojolicious::Lite;
use Time::HiRes qw/usleep/;

# OANDA Modules
use OANDA::Rates;

my $clients = {};
my $loop    = Mojo::IOLoop->singleton;

get '/password' => sub {
    my $self = shift;
    my $word;
    do {
        $word = Crypt::GeneratePassword::word(8,8,,0,1,1);
    } while ($word =~ m/[\+~!@#$%^&*()=-_]/);
    $self->render_text( $word );
};

get '/hello' => { text => 'Hello World!' };

get '/time'     => 'clock';
get '/buz/:foo' => sub {
    my $self = shift;
    my $foo  = $self->param('foo');
    $self->render( text => "Hello from $foo." );
};

get '/list/:offset' => sub {
    my $self    = shift;
    my $numbers = [ 0 .. $self->param('offset') ];
    $self->respond_to(
        json => { json => $numbers },
        txt  => { text => join( ',', @$numbers ) }
    );

};

# Scrape information from remote sites
post '/title' => sub {
    my $self = shift;
    my $url = $self->param('url') || 'http://mojolicio.us';
    $self->render_text(
        $self->ua->get($url)->res->dom->html->head->title->text );
};

get '/' => 'echo';

# WebSocket echo service
websocket '/echo' => sub {
    my $self = shift;
    print "I am in websocket rates\n";

    # Client id
    my $cid = "$self";

    my @currencies = qw / EUR USD CAD JPY HKD CHF SGD /;
    my @pairs = qw < 
    AUD/CAD AUD/CHF AUD/HKD AUD/JPY AUD/NZD AUD/SGD AUD/USD CAD/CHF CAD/HKD
    CAD/JPY CAD/SGD CHF/HKD CHF/JPY CHF/ZAR EUR/AUD EUR/CAD EUR/CHF EUR/CZK
    EUR/DKK EUR/GBP EUR/HKD EUR/HUF EUR/JPY EUR/NOK EUR/NZD EUR/PLN EUR/SEK
    EUR/SGD EUR/TRY EUR/USD EUR/ZAR GBP/AUD GBP/CAD GBP/CHF GBP/HKD GBP/JPY
    GBP/NZD GBP/PLN GBP/SGD GBP/USD GBP/ZAR HKD/JPY NZD/CAD NZD/CHF NZD/HKD
    NZD/JPY NZD/SGD NZD/USD SGD/CHF SGD/HKD SGD/JPY TRY/JPY USD/CAD USD/CHF
    USD/CNY USD/CZK USD/DKK USD/HKD USD/HUF USD/INR USD/JPY USD/MXN USD/NOK
    USD/PLN USD/SAR USD/SEK USD/SGD USD/THB USD/TRY USD/TWD USD/ZAR ZAR/JPY
    >;

    my $j = JSON->new;
    $self->on(
        message => sub {
            my ( $self, $message ) = @_;
            print "websocket received a message $message\n";

            my $rates = OANDA::Rates->new( {host => 'house-rates.dev.oanda.com'} );
            my $prev  = $rates->current_rates;

            my $send_sub;
            $send_sub = sub {
                my $current = $rates->current_rates;

                my @keys = grep { my $k = $_; grep { $_ eq $k } @pairs } keys %$current;
                my @keys = grep { $current->{$_}{timestamp} > $prev->{$_}{timestamp} } @keys;
                if (@keys) {
                    $message = {
                        bullet => [
                            map { make_bullet($_, $prev->{$_}, $current->{$_}) } @keys
                        ],
                    };

                    $self->send($j->encode($message));
                    $prev = $current;
                }
                $loop->timer( 0.1, $send_sub );
            };
            $send_sub->();
        }
    );
};

sub make_bullet {
    my $cp   = shift;
    my $prev = shift;
    my $curr = shift;

    return unless $curr->{timestamp} > $prev->{timestamp};
    my ($q,$b) = split(qr{/}, $cp);
    my ($src, $dest,$diff);
    if ( $curr->{bid} > $prev->{bid} ) {
        $src = $b;
        $dest = $q;
        $diff = ($curr->{bid} - $prev->{bid})/$prev->{bid};
    } else {
        $src = $q;
        $dest = $b;
        $diff = ($prev->{bid} - $curr->{bid})/$prev->{bid};
    }

    return { src => $src, dest => $dest, delta => $diff };
}



app->start;
__DATA__

@@ clock.html.ep
% use Time::Piece;
% my $now = localtime;
The time is <%= $now->hms %>.

@@ echo_bak.html.ep
<!DOCTYPE HTML>
<html>
<head>
<script type="text/javascript">
function WebSocketTest()
{
  if ("WebSocket" in window)
  {
     alert("WebSocket is supported by your Browser!");
     // Let us open a web socket
     var ws = new WebSocket("ws://ii9-dev.dev.oanda.com:3000/echo");
     ws.onopen = function()
     {
        // Web Socket is connected, send data using send()
        ws.send("Message to send");
        alert("Message is sent...");
     };
     ws.onmessage = function (evt) 
     { 
        var received_msg = evt.data;
        // alert("Message is received..." + received_msg);
        document.write(received_msg + '<br/>');
     };
     ws.onclose = function()
     { 
        // websocket is closed.
        alert("Connection is closed..."); 
     };
  }
  else
  {
     // The browser doesn't support WebSocket
     alert("WebSocket NOT supported by your Browser!");
  }
}
</script>
</head>
<body >
<div id="sse">
   <a href="javascript:WebSocketTest()">Run WebSocket</a>
</div>
</body>
</html>

@@ echo.html.ep
<!DOCTYPE HTML>
<html>
  <head>
    <style>
      body {
        margin: 0px;
        padding: 0px;
        background: black;
      }
    </style>
    <script>
//.keys function
Object.prototype.keys = function ()
{
  var keys = [];
  for(var i in this) if (this.hasOwnProperty(i))
  {
    keys.push(i);
  }
  return keys;
}

//state object
function State() {
    var that = {};
//max and min radius coefficient (from 22px)
    var minradius = 0.73; //16
    var maxradius = 1.37; //30
    var decayrate = 2;
    that.currencies = {
            "TRY": { x: 500+250*Math.cos(Math.PI/7*1), y: 350+250*Math.sin(Math.PI/7*1), radius:1 },
            "ZAR": { x: 500+250*Math.cos(Math.PI/7*2), y: 350+250*Math.sin(Math.PI/7*2), radius:1 },
            "JPY": { x: 500+250*Math.cos(Math.PI/7*3), y: 350+250*Math.sin(Math.PI/7*3), radius:1 },
            "GBP": { x: 500+250*Math.cos(Math.PI/7*4), y: 350+250*Math.sin(Math.PI/7*4), radius:1 },
            "CHF": { x: 500+250*Math.cos(Math.PI/7*5), y: 350+250*Math.sin(Math.PI/7*5), radius:1 },
            "EUR": { x: 500+250*Math.cos(Math.PI/7*6), y: 350+250*Math.sin(Math.PI/7*6), radius:1 },
            "USD": { x: 500+250*Math.cos(Math.PI/7*8), y: 350+250*Math.sin(Math.PI/7*8), radius:1 },
            "NZD": { x: 500+250*Math.cos(Math.PI/7*9), y: 350+250*Math.sin(Math.PI/7*9), radius:1 },
            "CAD": { x: 500+250*Math.cos(Math.PI/7*10), y: 350+250*Math.sin(Math.PI/7*10), radius:1 },
            "SGD": { x: 500+250*Math.cos(Math.PI/7*11), y: 350+250*Math.sin(Math.PI/7*11), radius:1 },
            "HKD": { x: 500+250*Math.cos(Math.PI/7*12), y: 350+250*Math.sin(Math.PI/7*12), radius:1 },
            "PLN": { x: 500+250*Math.cos(Math.PI/7*13), y: 350+250*Math.sin(Math.PI/7*13), radius:1 },
            "AUD": { x: 500+250*Math.cos(Math.PI/7*14), y: 350+250*Math.sin(Math.PI/7*14), radius:1 },

            "MXN": { x: 300+250*Math.cos(Math.PI/2+Math.PI/14*12), y: 350+250*Math.sin(Math.PI/2+Math.PI/14*12), radius:1 },
            "INR": { x: 300+250*Math.cos(Math.PI/2+Math.PI/14*11), y: 350+250*Math.sin(Math.PI/2+Math.PI/14*11), radius:1 },
            "CNY": { x: 300+250*Math.cos(Math.PI/2+Math.PI/14*10), y: 350+250*Math.sin(Math.PI/2+Math.PI/14*10), radius:1 },
            "SAR": { x: 300+250*Math.cos(Math.PI/2+Math.PI/14*9), y: 350+250*Math.sin(Math.PI/2+Math.PI/14*9), radius:1 },
            "THB": { x: 300+250*Math.cos(Math.PI/2+Math.PI/14*8), y: 350+250*Math.sin(Math.PI/2+Math.PI/14*8), radius:1 },
            "TWD": { x: 300+250*Math.cos(Math.PI/2+Math.PI/14*7), y: 350+250*Math.sin(Math.PI/2+Math.PI/14*7), radius:1 },

            "SEK": { x: 300+250*Math.cos(Math.PI/2+Math.PI/14*6), y: 350+250*Math.sin(Math.PI/2+Math.PI/14*6), radius:1 },
            "NOK": { x: 300+250*Math.cos(Math.PI/2+Math.PI/14*5), y: 350+250*Math.sin(Math.PI/2+Math.PI/14*5), radius:1 },
            "CZK": { x: 300+250*Math.cos(Math.PI/2+Math.PI/14*4), y: 350+250*Math.sin(Math.PI/2+Math.PI/14*4), radius:1 },
            "DKK": { x: 300+250*Math.cos(Math.PI/2+Math.PI/14*3), y: 350+250*Math.sin(Math.PI/2+Math.PI/14*3), radius:1 },
            "HUF": { x: 300+250*Math.cos(Math.PI/2+Math.PI/14*2), y: 350+250*Math.sin(Math.PI/2+Math.PI/14*2), radius:1 },

          };
    that.bullets = [];

    function Bullet(src,dest,delta,timestamp) {
        var that = {};
        that.src = src;
        that.dest = dest;
        that.delta = delta;
        that.timestamp = timestamp; //milliseconds since epoch

        that.toString = function() {
            return (that.src + ":" + that.dest + ":" + that.delta + ":" + that.timestamp);
        }

        return that;
    }

    that.addBullet = function (src,dest,delta) {
        delta *= bullet_weight;
        timestamp = new Date().getTime();
        if (!state.currencies[src] || !state.currencies[dest]) {return;}
        newBullet = Bullet(src,dest,delta,timestamp);
        timestamp = 
        that.bullets.push(newBullet);
        that.updateRadius(src, -delta);
    }

    that.updateRadius = function (currency, delta) {
        that.currencies[currency]["radius"] += delta;
        if (that.currencies[currency]["radius"] < minradius) {
            that.currencies[currency]["radius"] = minradius;
        }
        if (that.currencies[currency]["radius"] > maxradius) {
            that.currencies[currency]["radius"] = maxradius;
        }
    }

//unused for now
    that.decayAllRadius = function () {
        for (var i=0; that.currencies.length; i++) {
            diff = that.currencies[i]["radius"] - defaultradius
            if (diff != 0) {
                that.currencies[i]["radius"] -= diff/decayrate;
            }
            if (that.currencies[i]["radius"] < minradius) {
                that.currencies[i]["radius"] = minradius;
            }
            if (that.currencies[i]["radius"] > maxradius) {
                that.currencies[i]["radius"] = maxradius;
            }
        }
    }

    return that;
}

//GLOBALS
      //for fps counter
      var fps = 0, now, lastUpdate = (new Date)*1 - 1;
      var fpsFilter = 50;
      //objects
      var canvas;
      var context;
      var state = State();
      //bullets travel time (in ms)
      var bullet_life = 2000;
      //coefficient for bullet size
      var bullet_size = 40;
      //coefficient to bullet weight
      var bullet_weight = 10;
      //how often currency bubbles decay
      var decay_period = 50;
      //how much currency bubbles decay
      var decay_magnitude = 0.001;

      //onLoad
      window.onload = function() {
        canvas = document.getElementById("myCanvas");
        context = canvas.getContext("2d");

        draw_frame();
        ConnectToBackend();
        currency_decay();
      };

      //draws a currency circle
      function draw_cur_circle(cur_name, coor_x, coor_y, size)
      {
        context.save();
        context.beginPath();
        context.fillStyle = "white";
        context.setTransform(size, 0, 0, size, coor_x, coor_y);
        context.arc(0, 0, 22, 0, 2 * Math.PI, false);
        context.fill();
        context.lineWidth = 1;
        context.strokeStyle = "black";
        context.stroke();
        context.font = "12pt Calibri";
        context.fillStyle = "blue";

        context.fillText(cur_name, -18, 5);
        context.restore();
      }

      //draws a bullet
      function draw_bullet(bullet)
      {
        var src = state.currencies[bullet.src];
        var dest = state.currencies[bullet.dest];

        var dt = bullet_life - lastUpdate + bullet.timestamp;
        if (dt <= 0) dt = 0;
        dt = dt/bullet_life;
        // dt = Math.sqrt(dt);
        var x = src["x"]*dt + dest["x"]*(1-dt);
        var y = src["y"]*dt + dest["y"]*(1-dt);

        context.save();
        context.beginPath();
        context.fillStyle = "red";
        context.arc(x, y, bullet.delta*bullet_size, 0, 2 * Math.PI, false);
        context.lineWidth = 1;
        context.strokeStyle = "red";
        context.stroke();
        context.fill();
      }

      //draws 1 frame and schedules the next one to be drawn
      function draw_frame()
      {
        var time_delta = (now=new Date) - lastUpdate;
        var thisFrameFPS = 1000 / (time_delta);
        fps += (thisFrameFPS - fps) / fpsFilter;
        lastUpdate = now;
        calculate_all(time_delta);
        draw_all();

        setTimeout( draw_frame, 1 );
      }

      //does all the math to change the scene
      function calculate_all(time_delta)
      {
        //var now = new Date().getTime();
        for (var bullet in state.bullets)
        {
          if (state.bullets[bullet].timestamp+bullet_life <= lastUpdate)
          {

            var bullet_removed = state.bullets[bullet];
            state.bullets.splice(bullet,1);
            state.updateRadius(bullet_removed.dest, bullet_removed.delta);
          }
        }
      }

      //draws the scene
      function draw_all()
      {
        //clear canvas
        canvas.width = canvas.width;
        context.fillStyle = "#000000";
        context.fillRect(0,0,1200, 800);

        //draw all bullets
        for (var i in state.bullets)
        {
          if (!state.bullets.hasOwnProperty(i)) continue;
          draw_bullet(state.bullets[i]);
        }

        //draw all currencies
        for (var i in state["currencies"])
        {
          if (!state["currencies"].hasOwnProperty(i)) continue;
          draw_cur_circle(i, state["currencies"][i]["x"], state["currencies"][i]["y"], state["currencies"][i]["radius"]);
        }

        //draw fps counter
        context.font = "20pt Calibri";
        context.fillStyle = "white";
        context.fillText("FPS:"+Math.floor(fps), 10, 780);
      }

function ConnectToBackend()
{
    if ("WebSocket" in window)
    {
        var ws = new WebSocket("ws://ii9-dev.dev.oanda.com:3000/echo");

        ws.onopen = function()
        {
            ws.send("send me some roffles");
        };

        ws.onmessage = function (evt) 
        { 
            var received_msg = evt.data;
            convertJSON(received_msg);
        };

        ws.onclose = function()
        { 
            alert("Connection closed. We are very sad."); 
        };
    }
    else
    {
        // The browser doesn't support WebSocket
        alert("WebSocket NOT supported by your Browser!");
        alert("Tell me, how are the 90's like?");
    }
}

function convertJSON(s) {
    var x = eval('('+s+')');
    var result = [];
    if (x.bullet.length > 0) {
        for (var i=0; i < x.bullet.length; i++) {
            state.addBullet( x.bullet[i].src, x.bullet[i].dest, Math.sqrt(x.bullet[i].delta) )
        }
    }
    return result
}

function currency_decay()
{
      for (var i in state["currencies"])
      {
          if (!state["currencies"].hasOwnProperty(i)) continue;
          if (state["currencies"][i]["radius"] > 1) {state["currencies"][i]["radius"] -= decay_magnitude;}
          if (state["currencies"][i]["radius"] < 1) {state["currencies"][i]["radius"] += decay_magnitude;}
      }

      setTimeout("currency_decay()", decay_period);
}

function change_params()
{
  bullet_life = parseInt(document.getElementById('bullet_life').value);
  bullet_size = parseInt(document.getElementById('bullet_size').value);
  bullet_weight = parseInt(document.getElementById('bullet_weight').value);
  decay_period = parseInt(document.getElementById('decay_period').value);
  decay_magnitude = parseFloat(document.getElementById('decay_magnitude').value);
}
    </script>
  </head>
  <body align="center" valign="middle">
    <canvas id="myCanvas" width="1200" height="800"></canvas><br/><br/>
<!--
      Tick travel time: <input type="text" id="bullet_life"  value=5000 />
      Tick size coef: <input type="text" id="bullet_size" value=400 />
      Tick weight coef: <input type="text" id="bullet_weight" value=100 />
      Currency decay interval: <input type="text" id="decay_period" value=50 />
      Currency decay magnitude: <input type="text" id="decay_magnitude" value="0.001" />
      <input type="button" value="Change" onClick="change_params();" />
-->
  </body>
</html>


