#!/usr/bin/perl

package Command::Backup;

use v5.10;
use utf8;
use open ':std', ':encoding(UTF-8)';
binmode(FILE, ':utf8');
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(cmd_shrug);

use Mojo::Discord;
use Bot::Goose;
use Mojo::JSON qw(decode_json);
use Data::Dumper;
use File::Slurp;

###########################################################################################
# Command Info
my $command = "Backup";
my $access = 0; # For everyone
my $description = "List available commands";
my $pattern = '^(~backup)(\s)?$';
my $function = \&cmd_backup;
my $usage = <<EOF;
Usage: ~backup
EOF
###########################################################################################

sub new
{
    my ($class, %params) = @_;
    my $self = {};
    bless $self, $class;
     
    # Setting up this command module requires the Discord connection 
    $self->{'bot'} = $params{'bot'};
    $self->{'discord'} = $self->{'bot'}->discord;
    $self->{'pattern'} = $pattern;

    # Register our command with the bot
    $self->{'bot'}->add_command(
        'command'       => $command,
        'access'        => $access,
        'description'   => $description,
        'usage'         => $usage,
        'pattern'       => $pattern,
        'function'      => $function,
        'object'        => $self,
    );
    
    return $self;
}
my $main_channel = "";
sub cmd_backup
{
    my ($self, $channel, $author, $msg) = @_;

    my $args = "¯\\_(ツ)_/¯";
    my $pattern = $self->{'pattern'};

    my $discord = $self->{'discord'};
    my $replyto = '<@' . $author->{'id'} . '>';
    $main_channel = $channel;
    $args = GetLastMessage(MakeDiscordGet("/channels/$channel/messages", "", "1"));

    eval 
    { 
        my $json = decode_json($args);
        $discord->send_message($channel, $json);
    };
    if ($@)
    {
       $discord->send_message($channel, $args);
    }
}

use MessageRequest;
sub GetLastMessage {
    my ($arrayJsonData, $messageCalled, $fileName) = @_;
    my @chars = ("A".."Z", "a".."z", "0".."9");
    my $string = $fileName;
    if (!defined $messageCalled) {
        $string = "";
        $string .= $chars[rand @chars] for 1..16;

        write_file("static/${string}.log.txt", "Unix Backup Time: " . localtime(time) . "\nBackup of Channel ID: ");
    }
    if (!defined $arrayJsonData) {
        say "That call didn't have data... meaning there are no messages prior to that one.\n";
        exit;
    }
    my $lastMessage;
    foreach my $jsonMessage (@{$arrayJsonData}) {
        if (!defined $messageCalled) {
            $messageCalled = "not undef";
            append_file_utf8("static/${string}.log.txt", $jsonMessage->{channel_id} . "\n\n");
            say "Set Channel ID";
        }
        if (@{$arrayJsonData}[-1] == $jsonMessage) {
            $lastMessage = $jsonMessage->{id};
        }
        (my $context = $jsonMessage->{content}) =~ s/\n/\\n/g;;

        append_file_utf8("static/${string}.log.txt", $jsonMessage->{author}{username} . "#" . $jsonMessage->{author}{discriminator} . " : " . $context . "\n(".$jsonMessage->{author}{id}.") on " . $jsonMessage->{timestamp} . "\n\n");
    }
    if (!defined $lastMessage) {
        say "No more messages: " . $messageCalled;
        return "http://138.197.50.244/files/shortcut.pl?p=" . $string . ".log.txt";
    }
    else {
        say "Doing recusive ($lastMessage)";
        GetLastMessage(MakeDiscordGet("/channels/$main_channel/messages?before=$lastMessage", "", "1"), $lastMessage, $string);
    }
}

sub append_file_utf8 {
    my ($name, $data) = @_;
    open my $fh, '>>:encoding(UTF-8)', $name
        or die "Couldn't create '$name': $!";
    local $/;
    print $fh $data;
    close $fh;
};

1;
