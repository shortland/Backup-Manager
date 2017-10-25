#!/usr/bin/perl

package MessageRequest;

use v5.10;

use ApiKeys;

use JSON;
use Try::Tiny;
use Exporter;

our @ISA = qw(Exporter);

#can be
our @EXPORT_OK = qw(MakeDiscordGet MakeDiscordPostJson);
#default
our @EXPORT = qw(MakeDiscordGet MakeDiscordPostJson);

sub MakeDiscordGet {
	my @parms = @_;
	#parms[0] = endpoint /users/\@me
	#parms[1] = 
	#parms[2] = return decoded json, 0=no, 1=yes
	#parms[3] = sleep time, if !defined then default.2
	my $userAgent = "DiscordBot (http://ilankleiman.com, 4.0.0)";
	my $contentType = "Content-Type: application/x-www-form-urlencoded";
	my $authorizeCode = "Authorization: Bot $API_DISCORD";
	my $baseURL = "https://discordapp.com/api";
	my $response = `curl -s --max-time 5 -A "$userAgent" -H "$contentType" -H "$authorizeCode" "${baseURL}@{parms[0]}" -L`;
	#say $response;
	try {
		$response = decode_json($response) if (@parms[2] =~ /^1$/);
	}
	catch {
		$response = "";
	};
	if(!defined @parms[3] || @parms[3] eq "") {
		sleep(.2);
	}
	else {
		sleep(@parms[3]);
	}
	return $response;
}

sub MakeDiscordPostJson {
	my @parms = @_;
	#parms[0] = endpoint /users/\@me
	#parms[1] = json to post
	#parms[2] = return decoded json, 0=no, 1=yes
	#parms[3] = post type, -X POST/PUT/DELETE/etc...
	#parms[4] = sleep time, if !defined then default 1
	my $getType;
	if ( (@parms[3] =~ /^()$/) || (!defined(@parms[3])) ) {
		$getType = "POST";
	}
	else {
		$getType = @parms[3];
	}
	my $userAgent = "DiscordBot (http://ilankleiman.com, 4.0.0)";
	my $contentType = "Content-Type: application/json";
	my $authorizeCode = "Authorization: Bot $API_DISCORD";
	my $baseURL = "https://discordapp.com/api";
	my $response = `curl -s --max-time 5 -X $getType -d '@parms[1]' -A "$userAgent" -H "$contentType" -H "$authorizeCode" "${baseURL}@{parms[0]}" -L`;
	try {
		$response = decode_json($response) if (@parms[2] =~ /^(1)$/);
	}
	catch {
		$response = "";
	};
		
	# say "THIS IS WHAT IM SENDING: " . $parms[1];
	# use Data::Dumper;
	# say Dumper($response);

	if(!defined @parms[4] || @parms[4] eq "") {
		sleep(1);
	}
	else {
		sleep(@parms[4]);
	}

	return $response;
}

1;