let rec img_to_str img width height =
  let rec aux acc w h =
    if w = 0 && h = height then acc
    else if w = width then aux (String.concat "" [acc; "\n"]) 0 (h+1)
    else aux (String.concat "" [acc; (Hashtbl.find img (w, h))]) (w+1) h
  in aux "" 0 0


let rec gcd a = function
  | 0 -> a
  | b -> gcd b (a mod b)

let is_visible_from m n w h map =
  if m = w && n = h || Hashtbl.find map (w, h) = "." then false
  else
    let dx = w - m in
    let dy = h - n in
    let cf = abs (gcd dx dy) in
    let dx' = dx / cf in
    let dy' = dy / cf in
    (* print_endline (string_of_int dx' ^ " " ^ string_of_int dy'); *)
    let rec aux k l =
      (* print_endline (string_of_int k ^ " " ^ string_of_int l); *)
      if k = w && l = h then true
      else if Hashtbl.find map (k, l) = "#" then false
      else aux (k+dx') (l+dy')
    in aux (m+dx') (n+dy')

let visible_from m n map width height =
  if Hashtbl.find map (m, n) = "." then 0
  else
    let rec aux acc w h =
      if w = 0 && h = height then acc
      else if w = width then aux acc 0 (h+1)
      else if Hashtbl.find map (w, h) = "." then aux (acc) (w+1) h
      else if is_visible_from m n w h map then aux (acc+1) (w+1) h
      else aux (acc) (w+1) h
    in 
    let v = aux 0 0 0 in
    (* print_endline (string_of_int m ^ " " ^ string_of_int n ^ " " ^ string_of_int v); *)
    v


let naloga1 map width height =
  let rec aux acc w h =
    if w = 0 && h = height then acc
    else if w = width then aux (acc) 0 (h+1)
    else aux (max acc (visible_from w h map width height)) (w+1) h
    (* else let v = visible_from w h map width height in 
       if acc < v then (print_endline (string_of_int w ^ " " ^ string_of_int h); aux (v) (w+1) h)
       else aux acc (w+1) h *)
  in aux 0 0 0

let cmp (m, n) (k, l) =
  (atan2 (float_of_int (-m)) (float_of_int (n))) <
  (atan2 (float_of_int (-k)) (float_of_int (l)))

let before m n k l map width height = 
  let rec aux acc w h =
    if w = 0 && h = height then acc
    else if w = width then aux (acc) 0 (h+1)
    else if cmp (k - m, l - n) (w - m, h - n) then aux acc (w+1) h
    else if is_visible_from m n w h map then aux (acc+1) (w+1) h
    else aux acc (w+1) h
  in aux 0 0 0

let naloga2 m n map width height =
  (* visible_from m n map width height *)
  (* before m n 19 19 map width height *)
  let rec aux acc w h =
    if w = 0 && h = height then acc
    else if w = width then aux (acc) 0 (h+1)
    else if Hashtbl.find map (w, h) = "." then aux (acc) (w+1) h
    else if before m n w h map width height = 199 (* off by 1 *) then 
      (print_endline (string_of_int w ^ " " ^ string_of_int h); aux (100*w + h) (w+1) h)
    else aux acc (w+1) h
  in aux 0 0 0

let _ =
  let preberi_datoteko ime_datoteke =
    let chan = open_in ime_datoteke in
    let vsebina = really_input_string chan (in_channel_length chan) in
    close_in chan;
    vsebina
  and izpisi_datoteko ime_datoteke vsebina =
    let chan = open_out ime_datoteke in
    output_string chan vsebina;
    close_out chan
  in
  let vsebina_datoteke = Hashtbl.create 1000 in
  List.iteri (fun n s -> List.iteri (fun m c -> Hashtbl.add vsebina_datoteke (m, n) (Char.escaped c)) (List.of_seq (String.to_seq s)))
    (String.split_on_char '\n' (preberi_datoteko "day_10.in"));
  let odgovor1 = naloga1 vsebina_datoteke 26 26
  and odgovor2 = naloga2 19 14 vsebina_datoteke 26 26
  in
  print_endline (Hashtbl.find vsebina_datoteke (3, 5));
  print_endline (string_of_int (before 19 14 3 5 vsebina_datoteke 26 26));
  izpisi_datoteko "day_10_1.out" (string_of_int odgovor1);
  izpisi_datoteko "day_10_2.out" (string_of_int odgovor2)
