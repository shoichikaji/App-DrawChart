requires 'perl', '5.008001';
requires 'Amon2::Lite';
requires 'Plack::Runner';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

