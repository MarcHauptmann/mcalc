package MCalc::Context;

use Moose::Role;

requires "getVariable";

requires "setVariable";

requires "variableIsDefined";

requires "getFunction";

requires "setFunction";

requires "functionIsDefined";

1;
