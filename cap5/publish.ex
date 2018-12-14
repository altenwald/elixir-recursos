defmodule Hooks do
  defmacro __using__(_data) do
    quote do
      Module.register_attribute __MODULE__, :publish,
                                accumulate: true,
                                persist: false
      @before_compile Hooks
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def published, do: @publish
    end
  end
end

defmodule Publish do
  use Hooks

  @publish :hello
  def hello, do: "hello world!"

  def hidden, do: "unpublished"

  @publish :bye
  def bye, do: "bye bye!"
end
