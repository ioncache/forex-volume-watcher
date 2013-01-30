PERL_MAJOR=5.14

export PATH=/oanda/system/perls/$PERL_MAJOR/local/tools/bin:/oanda/system/perls/$PERL_MAJOR/bin:/oanda/system/bin:$PATH
export PERL5LIB=/oanda/system/perls/$PERL_MAJOR/local/tools/lib/perl5:/oanda/system/perls/$PERL_MAJOR/local/tools/lib/perl5/i86pc-solaris

perl$PERL_MAJOR app.psgi daemon --listen "http://*:5000"
