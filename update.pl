#! /usr/bin/perl
use strict;
use warnings;
use Email::Simple;
use Email::Sender::Simple qw(sendmail);
use Email::Simple::Creator;
use Email::MIME;
  
#Place to set the variablbles for the script
sub emailVars
{
        my $fromAddress = 'me@jordanmcgilvray.com';
        my $toAddress = 'jordanjm@gmail.com';
        my $hostName = getHostName();
        my $emailSubject = "Updates Available for $hostName.";
        my $numOfPackages = 0;
        my $updatesAvailable = "";
        my $emailMessage = "";
        my $numOfUpdates = getUpdateCount();
        if ($numOfUpdates > 0)
        {
                $updatesAvailable = getUpdatesList();
                $numOfPackages = numOfInstalledPackages();
                $emailMessage = "$numOfUpdates/$numOfPackages have updates available.\n\nPackages with updates:\n$updatesAvailable";
        }
        my @allVB = ($numOfUpdates,$fromAddress,$toAddress,$emailSubject,$emailMessage);
        return @allVB;
}

#Get the number of packages installed on the system
sub numOfInstalledPackages
{
        my $numOfPackages =`pacman -Q | wc -l`;
        chomp($numOfPackages);
        return $numOfPackages;
}

#Get the number of packages with updates
sub getUpdateCount
{
        my $countUpdates = `pacman -Qu | wc -l`;
        chomp($countUpdates);
        return $countUpdates;
}

#Get the hostname
sub getHostName
{
        chomp(my $hostName = `hostname -s` );
        return $hostName;
}

#Get the list of packages with updates.
sub getUpdatesList
{
        my @updates = `pacman -Qu`;
        my $updatesList = join("\n\t\t", @updates);
        $updatesList = "\t\t$updatesList";
        return $updatesList;
}

#Send the email
sub sendEmail
{
        my $toAddress = shift @_;
        my $fromAddress = shift @_;
        my $subjectLine = shift @_;
        my $message = shift @_;
        my $email = Email::Simple->create(
                header => [
                        From    => "$fromAddress",
                        To      => "$toAddress",
                        Subject => "$subjectLine",
                ],
                body    => "$message",
        );
        $email->header_set( 'X-Content-Container' => 'bottle/glass' );
        sendmail($email) or die "Could not send";
}

sub main
{
        #Set Values for the email
        my @emailInfo = emailVars();
        my $updatesAvailable = shift @emailInfo;
        my $fromAddress = shift @emailInfo;
        my $toAddress = shift @emailInfo;
        my $subjectLine = shift @emailInfo;
        my $emailBody = shift @emailInfo;
        #If there are updates send an email.
        if ($updatesAvailable >0)
        {
                sendEmail($toAddress,$fromAddress,$subjectLine,$emailBody);
        }
}

main();
