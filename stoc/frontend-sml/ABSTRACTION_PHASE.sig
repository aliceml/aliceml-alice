signature ABSTRACTION_PHASE =
  sig
    structure C : CONTEXT          = BindEnv
    structure I : INPUT_GRAMMAR    = InputGrammar
    structure O : ABSTRACT_GRAMMAR = AbstractGrammar

    val translate : BindEnv.t -> I.Component -> O.comp
  end
