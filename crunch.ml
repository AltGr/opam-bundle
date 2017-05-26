let add_file f =
  let basename = Filename.basename f in
  let name =
    String.map (function
        | 'a'..'z' | 'A'..'Z' | '0'..'9' | '_' as c -> c
        | _ -> '_')
      basename
  in
  let f = open_in f in
  let buf = Buffer.create 4096 in
  (try while true do Buffer.add_channel buf f 4096 done with End_of_file -> ());
  close_in f;
  Printf.printf "let %s =\n%S\n\n" name (Buffer.contents buf);
  basename, name

let () =
  let files = List.tl (Array.to_list Sys.argv) in
  let nf = List.map add_file files in
  Printf.printf "let all_scripts = [\n  %s\n]\n"
    (String.concat "\n  "
       (List.map (fun (f, name) -> Printf.sprintf "%S, %s;" f name) nf))
