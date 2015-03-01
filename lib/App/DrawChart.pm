package App::DrawChart;
use 5.008001;
use strict;
use warnings;
use App::DrawChart::Controller;
use Plack::Runner;
use Pod::Usage 'pod2usage';

our $VERSION = "0.01";

sub draw {
    my ($class, @argv) = @_;
    if (grep { /^(?:-h|--help)$/ } @argv) {
        pod2usage(0);
    }

    my $runner = Plack::Runner->new;
    $runner->parse_options("--port", 5555, @argv);
    my $csv = shift @{$runner->{argv}} # yes, evil
        or do { warn "Missing csv file.\n"; pod2usage(1) };

    my $app = App::DrawChart::Controller->init($csv)->to_app;
    $runner->run($app);
}

1;
__END__

=encoding utf-8

=head1 NAME

App::DrawChart - draw time-series chart for csv files

=head1 SYNOPSIS

    > head -n5 file.csv
    Date,foo,bar,baz
    2015-01-01,4.5,19.4,0.2
    2015-01-02,6.8,22.2,1.0
    2015-01-03,7.3,26.7,2.8
    2015-01-04,9.6,24.7,3.6

    > draw-chart file.csv
    # http server acceptiong connections at http://0.0.0.0:5555

=begin html

<p><img src="https://raw.githubusercontent.com/shoichikaji/App-DrawChart/master/eg/chart.png" /></p>

=end html

=head1 DESCRIPTION

App::DrawChart draws time-series chart for csv files,
which uses L<http://dygraphs.com|http://dygraphs.com>.

=head1 TIPS

=head2 how often git commit?

    > git log --format='%ad' --date=short | sort | uniq -c | perl -anle 'BEGIN { print "Date,commit" } print join ",", reverse @F' > commit.csv
    > draw-chart commit.csv

=head1 LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

=cut

