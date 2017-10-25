#!/usr/bin/perl -w

use strict;
use warnings;

use Mojolicious::Lite;
use Math::Round;

our $headers = qq{
<!DOCTYPE html>
<html>
	<head>
		<title>sc</title>
	</head>
	<body>
};

our $endheaders = qq{
	</body>
</html>
};


get '/' => sub {
    my $self = shift;

    my $file = $self->param('p');
    my $fileGotData;
    if ($file =~ /^(| |\.\.|\/|\.|\.\.\/|\.\.\/\.\.\/|\.\.\/\.\.\/\.\.\/|\.\.\/\.\.\/\.\.\/\.\.\/)$/) {
        $fileGotData = "err";
    }
    else {
        my $temp_path = "http://138.197.50.244/DISCORD_BOTS/Manager/static/" . $file;
        $fileGotData = `curl -s "$temp_path"`;
    }

    $fileGotData =~ s/\n/<br>\n/g;
	$self->render( text => qq{$fileGotData});
};
 
app->secrets(['password']);
app->start;

__DATA__
@@ not_found.html.ep
<!DOCTYPE html>
<html>
  <head><title>Page not found</title></head>
  <body>Page not found <%= $status %></body>
</html>