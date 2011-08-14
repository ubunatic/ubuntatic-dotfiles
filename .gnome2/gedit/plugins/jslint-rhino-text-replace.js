//
// Copyright (C) 2011 by Uwe Jugel, uwe.jugel@gmail.com
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.  
//
// Info:
// gedit support referencing and navigating from shell output lines to source 
// code lines if the output follows the "filename:linenumber:message" pattern
// This script removes some verbosity from the JSLint error messages and
// reformats them to support this pattern.
//
// Use this script after calling JSLint from gedit External Tools.
//
// Usage:
// js <PATH_TO>jslint-rhino-text-replace.js FILENAME JSLINTOUTPUT...
//

var newArgs = [], errorPrefix, i = 1, lastErrorIndex = -1, fileName = "";
var len = arguments.length, fileName = arguments[0];

while (i < len) {
	if (arguments[i] === "Lint" && arguments[i+1] === "at"){ //new Lint starting	
		errorPrefix = fileName + ":" + (arguments[i+3]-1) + ":";
		newArgs.push(errorPrefix);
		lastErrorIndex = newArgs.length-1;
		i += 6;
	}
	newArgs[lastErrorIndex] += " " + arguments[i];
	i += 1;
}

for(i = 0; i < newArgs.length; i += 1) {
	print(newArgs[i]);
}

if(newArgs.length === 0) {
	print(fileName + ": Excellent! Your JS code is clean and shiny.");
}

