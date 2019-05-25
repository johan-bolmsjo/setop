let usage =
  Printf.sprintf
    "usage: %s OPTIONS\n\
     \n\
     union files...     => Union of lines from all files\n\
     inter file1 file2  => Intersection of lines from file1 and file2\n\
     diff  file1 file2  => Difference of lines from file1 and file2" Sys.argv.(0)

module StringSet = Set.Make(String)

type set_result = (StringSet.t, string) result

let readline (ic :in_channel) : (string option, string) result =
  try
    let line = input_line ic in Ok(Some line)
  with
  | End_of_file -> Ok None

let set_of_file name :set_result =
  try
    let ic = open_in name in
    let rec slurp set =
      match (readline ic) with
      | Ok(Some line) -> slurp (StringSet.add line set)
      | Ok None -> Ok set
      | Error msg -> Error msg
    in
    let res = slurp StringSet.empty in
    close_in ic; res
  with Sys_error msg -> Error msg

let union_cmd (args :string list) :set_result =
  let rec aux acc = function
    | x :: l ->
      begin
        match set_of_file x with
        | Ok set -> aux (StringSet.union acc set) l
        | Error msg -> Error msg
      end
    | [] -> Ok acc
  in
  aux StringSet.empty args 

let two_arg_cmd apply (args :string list) :set_result =
  match args with
  | a :: b :: [] ->
    begin
      match set_of_file a with
      | Ok a ->
        begin
          match set_of_file b with
          | Ok b -> Ok(apply a b)
          | Error msg -> Error msg
        end
      | Error msg -> Error msg
    end
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
  | Error msg -> print_endline msg; exit 1
