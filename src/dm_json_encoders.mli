open Json_encoding
open Fixtypes

module Uuidm : sig
  include module type of Uuidm
    with type t = Uuidm.t

  include Sexplib0.Sexpable.S with type t = Uuidm.t
  val encoding : t encoding
end

module Ptime : sig
  include module type of Ptime
    with type t = Ptime.t
     and type span = Ptime.span

  include Sexplib0.Sexpable.S with type t = Ptime.t
  val encoding : t encoding
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

val trade : trade encoding
