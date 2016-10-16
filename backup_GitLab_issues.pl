#!/usr/bin/perl

use v5.18;
use warnings;
use strict;

use Data::Dumper;
use GitLab::API::v3;
use POSIX qw(strftime);

my $v3_api_url = 'http://gitlab.com/api/v3';
my $token = ''; # Secret thing you create on your GitLab web console.

my $project_id_num = 0; # Find in your GitLab web console.
my $backup_root = '/path/to/your/backups/';
my $now_string = strftime("%Y-%m-%d_%H-%M-%S", localtime);
my $backup_dir = $backup_root . $now_string;

my $api = GitLab::API::v3->new(
url   => $v3_api_url,
token => $token,
);

say "Getting issues for project $project_id_num.";
my $all_issues = $api->paginator(
    'issues',
    $project_id_num,
)->all();

mkdir $backup_dir or die "Fail to mkdir $backup_dir";
my $issues_out = $backup_dir . '/issues.dump';

say "Logging issues.";
open (my $issues_fh, '>', $issues_out) or die "Cannot open $issues_out";
print $issues_fh Dumper($all_issues);
close $issues_fh;

say "Getting comments.";
for my $issue_ref (@$all_issues) {
    my $issue_id = $issue_ref->{'id'};
    my $iid = $issue_ref->{'iid'};
    my $comments = $api->issue_comments($project_id_num, $issue_id);
    
    next if scalar(@$comments) == 0;
    say "Logging comments for $iid.";
    
    my $comment_dir = $backup_dir . '/' . $iid;
    mkdir $comment_dir or die "Fail to mkdir $comment_dir";
    
    my $comment_out = $comment_dir . '/comments.dump';
    open my $comment_fh, '>', $comment_out or die "Cannot open $comment_out";
    print $comment_fh Dumper($comments);
    close $comment_fh;
}

say "Logging labels.";
my $labels = $api->labels($project_id_num);
my $labels_out = $backup_dir . '/labels.dump';
open my $labels_fh, '>', $labels_out or die "Cannot open $labels_out";
print $labels_fh Dumper($labels);
close $labels_fh;

exit 0;
