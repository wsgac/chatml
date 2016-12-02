open Printf

(* ------------------------------------- *)
(* Command line options (visible to all) *)
(* ------------------------------------- *)

let mode = ref "client"
let host = ref (Unix.gethostname ())
let port = ref 1111

(* ------ *)
(* Common *)
(* ------ *)

let get_host () =
  let record = Unix.gethostbyname !host in
  record.Unix.h_addr_list.(0)


let get_port () = !port


let get_end_point () =
  Unix.ADDR_INET (get_host (), get_port ())


let recv_loop (output, socket) =
  let rec loop () =
    match Message.recv output socket with
    | None -> ()
    | Some m ->
      Message.proc output (socket, m);
      loop ()
  in
    loop ()
    

let create_thread (output, socket) =
  Thread.create recv_loop (output, socket)


let create_socket () =
  Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0

(* ------ *)
(* Client *)
(* ------ *)

let create_client_socket output =
  let socket = create_socket () in

  try
    Unix.connect socket (get_end_point ());
    
    output "Connected to server.";

    Some socket
  with exn -> None


let run_as_client output =
  match create_client_socket output with
  | None -> None
  | Some socket ->
    Some (socket, create_thread (output, socket))

(* ------ *)
(* Server *)
(* ------ *)

let create_server_socket output =
  let socket = create_socket () in

  try
    Unix.bind socket (get_end_point ());
    Unix.listen socket 1;
    
    output "Listening for client connections..";

    Some socket
  with _ -> 
    output "Unable to create server.";

    None


let run_as_server output =
  match create_server_socket output with
  | None -> None
  | Some socket ->
    let (client, _) = Unix.accept socket in
    
    output "Client connected.";

    Some (client, create_thread (output, client))

(* ---- *)
(* Main *)
(* ---- *)

let set_mode s =
  mode := s


let usage = "Usage: chat [-host <host>] [-port <port>] [-mode <client|server>]"


let args = [
  ("-host", Arg.Set_string host, "The hostname to connect to/listen on: default localhost")
; ("-port", Arg.Set_int port, "The port to connect to/listen on: default 1111")  
; ("-mode", Arg.Symbol (["client"; "server"], set_mode), " default server")
]


let init output =
  match !mode with
  | "client" ->
    output "Running in client mode.";
    run_as_client output
    
  | "server" ->
    output "Running in server mode.";
    run_as_server output
    
  | _ -> None


let main () =
  match init print_endline with
  | None -> ()

  | Some (socket, thread) ->
    while true do
      let text = read_line () in
      let message = Message.build_text_message text (Unix.time ()) in

      Message.send socket (Message.TextMessage message)
    done


let _ =
  Arg.parse args (fun _ -> ()) usage;
  main ()

