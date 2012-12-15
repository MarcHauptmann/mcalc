package MCalc::Context;

use Moose::Role;

=pod

=head1 Name

MCalc::Context

=head1 Description

A Context is a store for variables and functions.

=head1 Methods

=head2 getVariable

Returns the value of a variable

=cut
requires "getVariable";

=pod

=head2 setVariable

Sets the value of a variable

=cut
requires "setVariable";

=pod

=head2 vatiableIsDefined

Returns whether a variable is defined or not

=cut
requires "variableIsDefined";

=pod

=head2 getFunction

Returns the function with a given name

=cut
requires "getFunction";

=pod

=head2 setFunction

Sets the function for a given name

=cut
requires "setFunction";

=head2 functionIsDefined

Returns whether a function is defined or not

=cut
requires "functionIsDefined";

=pod

=head2 getCompletions

Returns a list of completions for a given input

=cut
requires "getCompletions";

1;
