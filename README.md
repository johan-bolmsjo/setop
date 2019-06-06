# setop

Command line tool to perform set operations on lines from text files.

## Usage

    usage: setop OPTIONS
    
    union files...     => Union of lines from all files
    inter file1 file2  => Intersection of lines from file1 and file2
    diff  file1 file2  => Difference of lines from file1 and file2

## Build

A working OCaml installation is required, see https://ocaml.org/.

Make sure the following packages are installed (using opam).

* dune

Execute the following commands to install `setop`:

    dune build && dune install --prefix ~/.local
