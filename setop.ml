exception Bad_arg of string

let usage =
  Bad_arg (Printf.sprintf
    "usage: %s OPTIONS\n\
     \n\
     union files...     => Union of lines from all files\n\
     inter file1 file2  => Intersection of lines from file1 and file2\n\
     diff  file1 file2  => Difference of lines from file1 and file2" Sys.argv.(0))

module StringSet = Set.Make(String)

type set_result = (StringSet.t, exn) result

let line_stream_of_channel chan =
  Stream.from (fun _ -> try Some (input_line chan) with End_of_file -> None)

let set_of_file name :set_result =
  try
    let ichan = open_in name in
    let set = ref StringSet.empty in
    try
      Stream.iter
          (fun line -> set := StringSet.add line !set)
          (line_stream_of_channel ichan);
      close_in ichan;
      Ok !set
    with e -> close_in ichan; Error e
  with e -> Error e

let (let*) x f = match x with Ok v -> f v | Error _ as e -> e

let union_cmd (args :string list) :set_result =
  let rec aux acc = function
    | x :: xs ->
      let* set = set_of_file x in
      aux (StringSet.union acc set) xs
    | [] -> Ok acc
  in
  aux StringSet.empty args 

let two_arg_cmd apply (args :string list) :set_result =
  match args with
  | x :: y :: [] ->
    let* set1 = set_of_file x in
    let* set2 = set_of_file y in
    Ok(apply set1 set2)
  | _ -> Error usage

let inter_cmd : string list -> set_result = two_arg_cmd StringSet.inter

let diff_cmd : string list -> set_result = two_arg_cmd StringSet.diff

let dispatch : string list -> set_result = function
  | x :: l ->
    begin
      match x with
      | "union" -> union_cmd l
      | "inter" -> inter_cmd l
      | "diff"  -> diff_cmd l
      | _ -> Error usage
    end
  | _ -> Error usage

let () =
  match (dispatch (List.tl (Array.to_list Sys.argv))) with
  | Ok set -> StringSet.iter (fun s -> print_endline s) set
  | Error(Bad_arg msg|Sys_error msg) -> print_endline msg; exit 1
  | Error(e) -> print_endline (Printexc.to_string e); exit 1
