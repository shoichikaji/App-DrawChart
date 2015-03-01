package App::DrawChart::Controller;
use strict;
use warnings;

use Amon2::Lite;

sub _warn { warn "\e[31m@_\e[m\n" }

my $app = sub {
    my $csv = shift;

    get "/" => sub {
        my $c = shift;
        $c->render('index.tt', {
            csv_url => $csv =~ /^http/i ? $csv : "/data.csv",
            dygraphs_url => $ENV{PERL_DYGRAPHS_PATH}
                          ? "/dygraph-combined.js"
                          : "//cdnjs.cloudflare.com/ajax/libs/dygraph/1.1.0/dygraph-combined.js",

        });
    };

    if ($csv !~ /^http/i) {
        get "/data.csv" => sub {
            my $c = shift;
            my $fh;
            open $fh, "<", $csv
                or do { undef $fh; _warn "Cannot read $csv: $!" };

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
            open $fh, "<", "$path.map"; # don't check
            my $res = $c->create_response(200);
            $res->content_type("application/json");
            $res->content_length($fh ? -s $fh : 0);
            $res->body($fh || "");
            $res;
        };
    }
};

sub init {
    my ($class, $csv) = @_;
    $app->($csv);
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
    font-family: "Helvetica Neue", Helvetica, "Segoe UI", Arial, freesans, sans-serif;
  }
  h1 {
    margin: 0 auto;
    text-align: center;
    padding: 20px 0;
  }
  div#chart {
    margin: 0 auto;
  }
  </style>

</head>
<body>
<h1>chart</h1>

<div id="chart" style="width: 80%;">
</div>
<script>
(function () {
  var div = document.getElementById("chart");
  var graph = new Dygraph(div, "[% csv_url %]", {
    strokeWidth: 2
  });
} ());
</script>
</body>
