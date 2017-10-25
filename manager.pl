#!/usr/bin/env perl

use v5.10;
use utf8;
use strict;
use warnings;

use File::Slurp;
use MessageRequest;

binmode STDOUT, ":utf8";

use Config::Tiny;
use Bot::Goose;

#MINE
use Command::Backup;

use Data::Dumper;

# Fallback to "config.ini" if the user does not pass in a config file.
my $config_file = $ARGV[0] // 'config.ini';
my $config = Config::Tiny->read($config_file, 'utf8');
say localtime(time) . " Loaded Config: $config_file";

my $self = {};  # For miscellaneous information about this bot such as discord id

# Initialize the bot
my $bot = Bot::Goose->new(%{$config});

# Register the commands
Command::Backup->new			('bot' => $bot);

GetAndMakeHooks(MyBotName(), MyServers());

sub MyBotName {
	return MakeDiscordGet('/users/@me', "", "1")->{'username'};
}

sub MyServers {
	return MakeDiscordGet('/users/@me/guilds', "", "1");
}

sub GetAndMakeHooks {
	my @parms = @_;
	# @parms[0] = bot name
	# @parms[1] = array of servers bot is in
	say "Loading webhooks...\n";
	write_file("buffers/channel_buffer.txt", ""); # holds list of channels
	write_file("buffers/webhook_buffer.txt", ""); # holds list of webhooks created
	for(my $i = 0; $i < scalar(@{$parms[1]}); $i++) {

		## delete any pre-existing david kim webhooks,... just cause easier/quicker than having to check if exists for x channel then remake
		my $webhookList = MakeDiscordGet("/guilds/$parms[1]->[$i]{'id'}/webhooks", "", "1");
		for(my $j = 0; $j < scalar(@{$webhookList}); $j++) {
			if($webhookList->[$j]{'name'} =~ /^($parms[0])$/) {
				MakeDiscordPostJson("/webhooks/".$webhookList->[$j]{'id'}, "", "1", "DELETE");
			}
		}
		# @webhooks contains channel ids of channels which have correct webhooks already
		my $channelList = MakeDiscordGet("/guilds/$parms[1]->[$i]{'id'}/channels", "", "1");
		my $picture = read_file("static/picture");
		for(my $j = 0; $j < scalar(@{$channelList}); $j++) {
			if(($channelList->[$j]{'type'} =~ /^text$/)) {
				append_file("buffers/channel_buffer.txt", $channelList->[$j]{'id'}."|");
				MakeDiscordPostJson("/channels/".$channelList->[$j]{'id'}."/webhooks", '{"name":"'.$parms[0].'", "avatar" : "'.$picture.'"}', "1");
			}
		}
		$webhookList = MakeDiscordGet("/guilds/$parms[1]->[$i]{'id'}/webhooks", "", "1");
		for(my $j = 0; $j < scalar(@{$webhookList}); $j++) {
			if($webhookList->[$j]{'name'} =~ /^($parms[0])$/) {
				append_file("buffers/webhook_buffer.txt", ($webhookList->[$j]{'channel_id'} . "|" . $webhookList->[$j]{'id'} . "|" . $webhookList->[$j]{'token'}."\n"));
			}
		}
	}
	say "done.\n";
}

my @WH_channels = split(m/\n/, read_file("buffers/webhook_buffer.txt"));
my @words = split(m/\|/, $WH_channels[6]);

#say MakeDiscordPostJson("/webhooks/$words[1]/$words[2]", '{"content" : "Online"}', "1", "");

# Start the bot
$bot->start();
