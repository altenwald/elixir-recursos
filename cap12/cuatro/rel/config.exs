~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"PALCx)hn$ZB&1),$RY(usmSR8Tex.uaS>[Qia~r(>MP89EBYa[n`VKscGc!cY~Dj"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"{2EQ$SA5l,QCwF@YIx3W*5Wz@Tw,QHY%!8Q6M@4_;w5W[j1(kW:pp3s%ojquX]Bc"
end

release :cuatro do
  set version: current_version(:cuatro)
  set applications: [
    :runtime_tools
  ]
end
