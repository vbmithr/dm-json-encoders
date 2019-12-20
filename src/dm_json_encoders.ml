open Json_encoding
open Fixtypes
open Sexplib.Std

module Uuidm = struct
  include Uuidm

  let t_of_sexp sexp =
    let sexp_str = string_of_sexp sexp in
    match of_string sexp_str with
    | None -> invalid_arg "Uuidm.t_of_sexp"
    | Some u -> u

  let sexp_of_t t =
    sexp_of_string (to_string t)

  let encoding =
    let open Json_encoding in
    conv
      (fun u -> to_string u)
      (fun s -> match of_string s with
         | None -> invalid_arg "Uuidm.encoding"
         | Some u -> u)
      string
end

module Ptime = struct
  include Ptime

  let t_of_sexp sexp =
    let sexp_str = string_of_sexp sexp in
    match of_rfc3339 sexp_str with
    | Ok (t, _, _) -> t
    | _ -> invalid_arg "Ptime.t_of_sexp"

  let sexp_of_t t =
    sexp_of_string (to_rfc3339 t)

  let encoding =
    let open Json_encoding in
    conv
      (fun t -> Ptime.to_rfc3339 t)
      (fun ts -> match Ptime.of_rfc3339 ts with
         | Error _ -> invalid_arg "Ptime.encoding"
         | Ok (t, _, _) -> t)
      string
end

type trade = {
  id: Uuidm.t ;
  filledQty: float ;
  price: float ;
  ts: Ptime.t ;
  side: Side.t ;
  exchange: string ;
  instrument: string ;
  baseCurrency: string option ;
  quoteCurrency: string option ;
  fees: float ;
  feesCurrency: string ;
}

let trade =
  conv
    (fun { id; filledQty; price; ts; side; exchange; instrument; baseCurrency; quoteCurrency; fees; feesCurrency } ->
       ((id, filledQty, price, ts, side, exchange, instrument, baseCurrency, quoteCurrency, fees), feesCurrency))
    (fun ((id, filledQty, price, ts, side, exchange, instrument, baseCurrency, quoteCurrency, fees), feesCurrency) ->
       { id; filledQty; price; ts; side; exchange; instrument; baseCurrency; quoteCurrency; fees; feesCurrency })
    (merge_objs
       (obj10
          (req "tradeID" Uuidm.encoding)
          (req "filledQty" float)
          (req "price" float)
          (req "ts" Ptime.encoding)
          (req "side" Side.encoding)
          (req "exchange" string)
          (req "instrument" string)
          (opt "baseCurrency" string)
          (opt "quoteCurrency" string)
          (req "fees" float))
       (obj1 (req "feesCurrency" string)))
