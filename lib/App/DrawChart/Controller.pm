package App::DrawChart::Controller;
use strict;
use warnings;
use Digest::MD5 'md5_hex';
use Amon2::Lite;

sub _warn { warn "\e[31m@_\e[m\n" }

my $app = sub {
    my @csv = @_;
    @csv = map { [ $_, md5_hex($_) ] } @csv;

    get "/" => sub {
        my $c = shift;
        $c->render('index.tt', {
            csv => \@csv,
            dygraphs_url => $ENV{PERL_DYGRAPHS_PATH}
                          ? "/dygraph-combined.js"
                          : "//cdnjs.cloudflare.com/ajax/libs/dygraph/1.1.0/dygraph-combined.js",
        });
    };

    for my $csv (@csv) {
        get "/$csv->[1].csv" => sub {
            my $c = shift;
            my $fh;
            open $fh, "<", $csv->[0]
                or do { undef $fh; _warn "Cannot read $csv->[0]: $!" };

            my $res = $c->create_response(200);
            $res->content_type("text/csv");
            $res->content_length($fh ? -s($fh) : 0);
            $res->body($fh || "");
            $res;
        };
    }

    if (my $path = $ENV{PERL_DYGRAPHS_PATH}) {
        get "/dygraph-combined.js" => sub {
            my $c = shift;
            my $fh;
            open $fh, "<", $path
                or do { undef $fh; _warn "Cannot read $path: $!" };
            my $res = $c->create_response(200);
            $res->content_type("application/javascript");
            $res->content_length($fh ? -s $fh : 0);
            $res->body($fh || "");
            $res;
        };
        get "/dygraph-combined.js.map" => sub {
            my $c = shift;
            my $fh;
            open $fh, "<", "$path.map" or do { undef $fh }; # don't check
            my $res = $c->create_response(200);
            $res->content_type("application/json");
            $res->content_length($fh ? -s $fh : 0);
            $res->body($fh || "");
            $res;
        };
    }
};

sub init {
    my ($class, @csv) = @_;
    $app->(@csv);
    $class;
}

1;
__DATA__
@@ index.tt
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>chart</title>
  <script src="[% dygraphs_url %]"></script>
  <style>
  body {
    width: 100%;
    margin: 0 0;
    font-family: "Helvetica Neue", Helvetica, "Segoe UI", Arial, freesans, sans-serif;
  }
  div#wrapper {
    width: 90%;
    margin: 0 auto;
  }
  h2 {
    margin: 0 auto;
    padding: 20px 0;
  }
  div.chart {
    margin: 0 auto;
  }
  </style>
</head>
<body>
<div id="wrapper">
[% FOREACH c IN csv %]
    <h2>[% c.0 %]</h2>
    <div class="chart" id="[% c.1 %]" style="width: 100%;"></div>
[% END %]
</div>
<script>
(function () {
  var elems = document.getElementsByClassName("chart");
  var charts = [];
  for (var i = 0; i < elems.length; i++) {
    charts.push(new Dygraph(elems[i], "/" + elems[i].id + ".csv", {
      strokeWidth: 2
    }));
  }
} ());
</script>
</body>
