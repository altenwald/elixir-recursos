defmodule Hooks do
  defmacro __using__(_data) do
    quote do
      Module.register_attribute __MODULE__, :published,
                                accumulate: true,
                                persist: false
      @before_compile Hooks
      @on_definition {Hooks, :on_def}
    end
  end

  def on_def(env, :def, name, _args, _guards, _body) do
    if Module.get_attribute(env.module, :publish) do
      Module.delete_attribute(env.module, :publish)
      Module.put_attribute(env.module, :published, name)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def published, do: @published
    end
  end
end

defmodule Publish do
  use Hooks

  @publish true
  def hello, do: "hello world!"

  def hidden, do: "unpublished"

  @publish true
  def bye, do: "bye bye!"
end
