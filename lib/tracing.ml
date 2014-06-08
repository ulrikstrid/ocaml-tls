
(* This is so not thread-safe it's not even funny. *)

let current = ref None

let the_function ~hook f =
  let prev = !current in
  current := Some hook ;
  try
    let res = f () in
    ( current := prev ; res )
  with exn -> ( current := prev ; raise exn )

let form_trace id sexp =
  let open Sexplib in
  Sexp.(List [ Atom id ; sexp ])

let sexp ~tag lz =
  match !current with
  | None      -> ()
  | Some hook -> hook @@ form_trace tag (Lazy.force lz)

let sexpf ~tag ~f x = sexp ~tag @@ lazy (f x)

let cs ~tag = sexpf ~tag ~f:Sexp_ext.Cstruct_s.sexp_of_t

