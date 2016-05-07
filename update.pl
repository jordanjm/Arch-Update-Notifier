#! /usr/bin/perl
use strict;
use warnings;
use Email::Simple;
use Email::Sender::Simple qw(sendmail);
use Email::Simple::Creator;
use Email::MIME;
#use Email::Sender::Transport::SMTP::TLS;
sub numOfInstalledPackages
{
	my $numOfPackages =`pacman -Q | wc -l`;
	chomp($numOfPackages);
	return $numOfPackages; 
}

sub getUpdateCount
{
	my $countUpdates = `pacman -Qu | wc -l`;
	chomp($countUpdates);
	return $countUpdates;
}

sub getHostName
{
	chomp(my $hostName = `hostname -s` );
	return $hostName;
}

sub getUpdatesList
{
	my @updates = `pacman -Qu`;
	return @updates;
}

sub sendEmail
{
	my $toAddress = shift @_;
	my $hostName = shift @_;
	my $message = shift @_;
	my $subjectLine = "Updates Available for $hostName.";
	my $email = Email::Simple->create(
		header => [
			From	=> '"Jordan McGilvray" <root@localhost>',
			To	=> "$toAddress",
			Subject	=> "subjectLine",
		],
		body	=> "$message",
	);
	$email->header_set( 'X-Content-Container' => 'bottle/glass' );
	sendmail($email) or die "Could not send";
}

sub main
{
	#Set Values for the email
	my $emailAddressToSendTo = 'jordan@localhost';
	my $myHostName = getHostName();
	my $numOfUpdates = getUpdateCount();
	my $numOfPackages = numOfInstalledPackages();
	my $updates = join("\n\t\t", getUpdatesList());
	$updates = "\t\t$updates";
	my $myMessage = "$numOfUpdates/$numOfPackages have updates available.\n\nPackages with updates:\n$updates";
	sendEmail($emailAddressToSendTo,$myHostName,$myMessage);
}

main();
