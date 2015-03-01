# NAME

App::DrawChart - draw time-series chart for csv files

# SYNOPSIS

    > head -n5 file.csv
    Date,foo,bar,baz
    2015-01-01,4.5,19.4,0.2
    2015-01-02,6.8,22.2,1.0
    2015-01-03,7.3,26.7,2.8
    2015-01-04,9.6,24.7,3.6

    > draw-chart file.csv
    # http server acceptiong connections at http://0.0.0.0:5555

<div>
    <p><img src="https://raw.githubusercontent.com/shoichikaji/App-DrawChart/master/eg/chart.png" /></p>
</div>

# DESCRIPTION

App::DrawChart draws time-series chart for csv files,
which uses [http://dygraphs.com](http://dygraphs.com).

# TIPS

## how often git commit?

    > git log --format='%ad' --date=short | sort | uniq -c | perl -anle 'BEGIN { print "Date,commit" } print join ",", reverse @F' > commit.csv
    > draw-chart commit.csv

# LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Shoichi Kaji <skaji@cpan.org>
