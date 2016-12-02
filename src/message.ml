type textMessagePayload = { time: float; text: string }
type tripMessagePayload = { trip: float }


type message =
  | TextMessage of textMessagePayload
  | TripMessage of tripMessagePayload


let build_text_message text time = { text = text; time = time }


let parse_text_message text time =
  build_text_message text (float_of_string time)


let build_trip_message time = { trip = time }


let parse_trip_message time =
  build_trip_message (float_of_string time)

(* ------- *)
(* Sending *)
(* ------- *)

let send_text_message socket message =
  Socket.send_string socket "1";
  Socket.send_string socket message.text;
  Socket.send_string socket (string_of_float message.time)


let send_trip_message socket message =
  Socket.send_string socket "2";
  Socket.send_string socket (string_of_float message.trip)


let send socket message =
  match message with
  | TextMessage m -> send_text_message socket m
  | TripMessage m -> send_trip_message socket m

(* --------- *)
(* Receiving *)
(* --------- *)

let recv_text_message socket =
  match Socket.recv_string socket with
  | None -> None
  | Some text ->
    match Socket.recv_string socket with
    | None -> None
    | Some time ->
      Some (TextMessage (parse_text_message text time))


let recv_trip_message socket =
  match Socket.recv_string socket with
  | None -> None
  | Some time ->
    Some (TripMessage (parse_trip_message time))


let recv output socket =
  match Socket.recv_string socket with
  | None -> None
  | Some t ->
    match t with
    | "1" -> recv_text_message socket
    | "2" -> recv_trip_message socket
    |  _  -> None

(* ---------- *)
(* Processing *)
(* ---------- *)

let proc_text_message output (socket, message) =
  output (Printf.sprintf "> %s" message.text);
  
  let response = build_trip_message message.time in
  send socket (TripMessage response)


let proc_trip_message output (socket, message) =
  output (Printf.sprintf "] Round-trip: %.2f" (Unix.time () -. message.trip))


let proc output (socket, message) =
  match message with
  | TextMessage m -> proc_text_message output (socket, m)
  | TripMessage m -> proc_trip_message output (socket, m)

