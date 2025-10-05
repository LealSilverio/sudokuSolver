# Overview

This project is a Sudoku board generator and solver written in Erlang through VSCode. This is a project where I can test and learn the basics of Erlang syntax and its features, such as functional programming, formatting, pattern matching, recursion, and guards. The program generates a random Sudoku board, checks if it's solvable, and solves them if possible using a recursive backtracking algorithm.

[Software Demo Video](http://youtube.link.goes.here)

# Development Environment

* VSCode
* Erlang 16.1
* Erlang extension for VSCode

# Useful Websites

* [Erlang Documentation](https://www.erlang.org/doc/readme.html)
* [Erlang Tutorial Playlist on Youtube](https://www.youtube.com/watch?v=HRrfc9CiR_s&list=PLdOYTlKwc71ljrfUqrKYoULxRjqI0p8it)

# Future Work

* Add a time buffer for user input before displaying "taking too long" message on terminal or removing message altogether
* Add retry limit to find a solvable board so there's no infinite loop when trying to find a solvable board
* Add a time limit for how long it takes to solve a board