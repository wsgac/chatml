let recv_int socket =
  let length = 1 in
  let buffer = String.create length in
  match Unix.recv socket buffer 0 length [] with
  | 1 ->
    Some (Char.code (String.get buffer 0))

  | _ ->
    None
    

let recv_string socket =
  match recv_int socket with
  | None -> None
  | Some length ->
    let buffer = String.create length in

    try
      match Unix.recv socket buffer 0 length [] with
      | 0 ->
        None

      | n ->
        Some (String.sub buffer 0 n)

    with _ ->
      None

let send_int socket length =
  let buffer = String.create 1 in
  String.set buffer 0 (Char.chr length);

  Unix.send socket buffer 0 1 []
  |> ignore

let send_string socket buffer =
  let length = String.length buffer in
  send_int socket length;

  Unix.send socket buffer 0 length []
  |> ignore

