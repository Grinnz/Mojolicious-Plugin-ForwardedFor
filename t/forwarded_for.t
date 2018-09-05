use strict;
use warnings;
use Test::Mojo;
use Test::More;

use Mojolicious::Lite;

get '/' => sub {
  my $c = shift;
  $c->render(text => $c->forwarded_for);
};

my $t = Test::Mojo->new;

# default 1 level
plugin 'ForwardedFor';

$t->get_ok('/')->content_is($t->tx->local_address);
$t->get_ok('/', {'X-Forwarded-For' => '1.2.3.4'})->content_is('1.2.3.4');
$t->get_ok('/', {'X-Forwarded-For' => '4.3.2.1, 1.2.3.4'})->content_is('1.2.3.4');
$t->get_ok('/', {'X-Forwarded-For' => '8.8.8.8, 4.3.2.1, 1.2.3.4'})->content_is('1.2.3.4');

# no proxy handling
plugin ForwardedFor => {levels => 0};

$t->get_ok('/')->content_is($t->tx->local_address);
$t->get_ok('/', {'X-Forwarded-For' => '1.2.3.4'})->content_is($t->tx->local_address);
$t->get_ok('/', {'X-Forwarded-For' => '4.3.2.1, 1.2.3.4'})->content_is($t->tx->local_address);
$t->get_ok('/', {'X-Forwarded-For' => '8.8.8.8, 4.3.2.1, 1.2.3.4'})->content_is($t->tx->local_address);

# 2 levels
plugin ForwardedFor => {levels => 2};

$t->get_ok('/')->content_is($t->tx->local_address);
$t->get_ok('/', {'X-Forwarded-For' => '1.2.3.4'})->content_is('1.2.3.4');
$t->get_ok('/', {'X-Forwarded-For' => '4.3.2.1, 1.2.3.4'})->content_is('4.3.2.1');
$t->get_ok('/', {'X-Forwarded-For' => '8.8.8.8, 4.3.2.1, 1.2.3.4'})->content_is('4.3.2.1');

done_testing;
